import numpy as np
import cv2
import mediapipe as mp
import tensorflow as tf
from mediapipe.framework.formats import landmark_pb2 
import copy
import time
import firebase_admin
from firebase_admin import credentials, db

class PlankDetector:
    def __init__(self):
        self.model = tf.keras.models.load_model('plank.h5')
        self.fixed_bbox = None
        self.mp_drawing = mp.solutions.drawing_utils
        self.mp_pose = mp.solutions.pose
        self.pose = self.mp_pose.Pose(min_detection_confidence=0.5, min_tracking_confidence=0.5)

        self.actions = ['c', '1', '3', '4', '5', '7']
        self.sequence_length = 10
        self.sequence = []
        self.current_action = ''

        self.required_landmarks = [12, 14, 16, 24, 26, 28]
        self.initialization_complete = False
        self.countdown_started = False
        self.countdown_start_time = None
        self.frame_cropped = False

        # Define custom connections for each action
        self.ACTION_CONNECTIONS = {
            '1': [
                ([self.mp_pose.PoseLandmark.RIGHT_SHOULDER.value,
                  self.mp_pose.PoseLandmark.RIGHT_ELBOW.value,
                  self.mp_pose.PoseLandmark.RIGHT_WRIST.value],
                 [self.mp_pose.PoseLandmark.LEFT_SHOULDER.value,
                  self.mp_pose.PoseLandmark.LEFT_ELBOW.value,
                  self.mp_pose.PoseLandmark.LEFT_WRIST.value])
            ],
            '3': [
                ([self.mp_pose.PoseLandmark.RIGHT_SHOULDER.value,
                  self.mp_pose.PoseLandmark.RIGHT_HIP.value,
                  self.mp_pose.PoseLandmark.RIGHT_KNEE.value],
                 [self.mp_pose.PoseLandmark.LEFT_SHOULDER.value,
                  self.mp_pose.PoseLandmark.LEFT_HIP.value,
                  self.mp_pose.PoseLandmark.LEFT_KNEE.value],
                 [self.mp_pose.PoseLandmark.LEFT_HIP.value,
                  self.mp_pose.PoseLandmark.RIGHT_HIP.value])
            ],
            '4': [
                ([self.mp_pose.PoseLandmark.RIGHT_SHOULDER.value,
                  self.mp_pose.PoseLandmark.RIGHT_HIP.value,
                  self.mp_pose.PoseLandmark.RIGHT_KNEE.value],
                 [self.mp_pose.PoseLandmark.LEFT_SHOULDER.value,
                  self.mp_pose.PoseLandmark.LEFT_HIP.value,
                  self.mp_pose.PoseLandmark.LEFT_KNEE.value],
                 [self.mp_pose.PoseLandmark.LEFT_HIP.value,
                  self.mp_pose.PoseLandmark.RIGHT_HIP.value])
            ],
            '5': [
                ([self.mp_pose.PoseLandmark.RIGHT_SHOULDER.value,
                  self.mp_pose.PoseLandmark.RIGHT_HIP.value],
                 [self.mp_pose.PoseLandmark.LEFT_SHOULDER.value,
                  self.mp_pose.PoseLandmark.LEFT_HIP.value],
                 [self.mp_pose.PoseLandmark.LEFT_SHOULDER.value,
                  self.mp_pose.PoseLandmark.RIGHT_SHOULDER.value],
                 [self.mp_pose.PoseLandmark.LEFT_HIP.value,
                  self.mp_pose.PoseLandmark.RIGHT_HIP.value])
            ],
            '7': [
                ([self.mp_pose.PoseLandmark.RIGHT_HIP.value,
                  self.mp_pose.PoseLandmark.RIGHT_KNEE.value,
                  self.mp_pose.PoseLandmark.RIGHT_ANKLE.value],
                [ self.mp_pose.PoseLandmark.LEFT_HIP.value,
                  self.mp_pose.PoseLandmark.LEFT_KNEE.value,
                  self.mp_pose.PoseLandmark.LEFT_ANKLE.value])
            ]
        }

    def check_required_landmarks(self, results):
        if not results.pose_landmarks:
            return False
        
        landmarks = results.pose_landmarks.landmark
        for idx in self.required_landmarks:
            if not (0 <= landmarks[idx].x <= 1 and 
                   0 <= landmarks[idx].y <= 1 and 
                   landmarks[idx].visibility > 0.5):
                return False
        return True

    def get_bounding_box(self, results, margin=10):
        if not results.pose_landmarks:
            return None

        landmarks = results.pose_landmarks.landmark
        x_coords = [landmark.x for landmark in landmarks]
        y_coords = [landmark.y for landmark in landmarks]

        x_min = max(min(x_coords) - margin / 100, 0)
        x_max = min(max(x_coords) + margin / 100, 1)
        y_min = max(min(y_coords) - margin / 100, 0)
        y_max = min(max(y_coords) + margin / 100, 1)

        return x_min, x_max, y_min, y_max

    def mediapipe_detection(self, image):
        image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
        image.flags.writeable = False
        results = self.pose.process(image)
        image.flags.writeable = True
        image = cv2.cvtColor(image, cv2.COLOR_RGB2BGR)
        
        if self.initialization_complete and not self.frame_cropped:
            bbox = self.get_bounding_box(results)
            if bbox:
                h, w, _ = image.shape
                x_min, x_max, y_min, y_max = bbox
                self.fixed_bbox = (int(x_min * w), int(x_max * w), int(y_min * h), int(y_max * h))
                self.frame_cropped = True
        
        if self.fixed_bbox:
            x_min, x_max, y_min, y_max = self.fixed_bbox
            cropped_image = image[y_min:y_max, x_min:x_max]

            if results.pose_landmarks:
                h, w, _ = image.shape
                new_pose_landmarks = landmark_pb2.NormalizedLandmarkList()
                
                for landmark in results.pose_landmarks.landmark:
                    new_x = (landmark.x * w - x_min) / (x_max - x_min)
                    new_y = (landmark.y * h - y_min) / (y_max - y_min)
                    new_x = max(0.0, min(1.0, new_x))
                    new_y = max(0.0, min(1.0, new_y))
                    
                    new_landmark = landmark_pb2.NormalizedLandmark(
                        x=new_x,
                        y=new_y,
                        z=landmark.z,
                        visibility=landmark.visibility
                    )
                    new_pose_landmarks.landmark.append(new_landmark)
                
                new_results = copy.deepcopy(results)
                new_results.pose_landmarks = new_pose_landmarks
                return cropped_image, new_results
                
            return cropped_image, results
        return image, results

    def extract_keypoints(self, results):
        selected_landmarks = [11, 12, 13, 14, 15, 16, 23, 24, 25, 26, 27, 28]
        pose = np.array([[res.x, res.y, res.z, res.visibility] for idx, res in enumerate(results.pose_landmarks.landmark) if idx in selected_landmarks]).flatten() if results.pose_landmarks else np.zeros(len(selected_landmarks) * 4)
        return pose

    def draw_custom_landmarks(self, image, results):
        default_drawing_spec = self.mp_drawing.DrawingSpec(color=(245,117,66), thickness=2, circle_radius=2)
        default_connection_spec = self.mp_drawing.DrawingSpec(color=(245,66,230), thickness=2, circle_radius=2)
        
        if not results.pose_landmarks:
            return
            
        if self.current_action == 'c':
            self.mp_drawing.draw_landmarks(
                image, 
                results.pose_landmarks, 
                self.mp_pose.POSE_CONNECTIONS,
                default_drawing_spec,
                default_connection_spec
            )
        else:
            self.mp_drawing.draw_landmarks(
                image, 
                results.pose_landmarks, 
                self.mp_pose.POSE_CONNECTIONS,
                default_drawing_spec,
                default_connection_spec
            )
            
            if self.current_action in self.ACTION_CONNECTIONS:
                landmarks = results.pose_landmarks.landmark
                red_color = (0, 0, 255)
                
                for connection_group in self.ACTION_CONNECTIONS[self.current_action]:
                    for part in connection_group:
                        for i in range(len(part) - 1):
                            start_idx = part[i]
                            end_idx = part[i + 1]
                            
                            start_point = (
                                int(landmarks[start_idx].x * image.shape[1]),
                                int(landmarks[start_idx].y * image.shape[0])
                            )
                            end_point = (
                                int(landmarks[end_idx].x * image.shape[1]),
                                int(landmarks[end_idx].y * image.shape[0])
                            )
                            
                            cv2.line(image, start_point, end_point, red_color, 3)
                            cv2.circle(image, start_point, 4, red_color, -1)
                            cv2.circle(image, end_point, 4, red_color, -1)
                            
    def process_frame(self, frame):
        image, results = self.mediapipe_detection(frame)
        
        # Check initialization phase
        if not self.initialization_complete:
            if self.check_required_landmarks(results):
                if not self.countdown_started:
                    self.countdown_started = True
                    self.countdown_start_time = time.time()
                    
                elapsed_time = time.time() - self.countdown_start_time
                remaining_time = max(3 - int(elapsed_time), 0)
                
                # Draw countdown
                cv2.putText(image, f"Starting in: {remaining_time}", 
                           (10, 60), cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 255, 0), 2)
                
                if elapsed_time >= 3:
                    self.initialization_complete = True
            else:
                cv2.putText(image, "Please stand in position", 
                           (10, 60), cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 0, 255), 2)
                self.countdown_started = False
            
            return image
        
        if self.check_required_landmarks(results):
            # Normal processing after initialization
            self.draw_custom_landmarks(image, results)
            keypoints = self.extract_keypoints(results)        
            self.sequence.append(keypoints)      
            self.sequence = self.sequence[-self.sequence_length:]

            if len(self.sequence) == self.sequence_length:
                res = self.model.predict(np.expand_dims(self.sequence, axis=0), verbose=0)[0]
                if np.max(res) >= 0.5:
                    self.current_action = self.actions[np.argmax(res)]
                    check = db.reference('check')
                    check1= check.get()
                    if check1 !=1:
                        db.reference('maloi').set(self.current_action)
                    else:
                        db.reference('maloi').delete()
            return image
        else:
            self.initialization_complete = False
            self.countdown_started = False
            self.countdown_start_time = None
            self.frame_cropped = False
            self.fixed_bbox = None
            return image
        
# def main():
#     detector = PlankDetector()
#     cap = cv2.VideoCapture(0)

#     while cap.isOpened():
#         ret, frame = cap.read()
#         if not ret:
#             break
        
#         image = detector.process_frame(frame)
#         cv2.imshow('Plank Detection', image)

#         if cv2.waitKey(10) & 0xFF == ord('q'):
#             break

#     cap.release()
#     cv2.destroyAllWindows()

# if __name__ == "__main__":
#     main()