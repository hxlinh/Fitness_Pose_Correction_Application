# Fitness Pose Correction Application
## Overview
![Giao diện ứng dụng](https://github.com/user-attachments/assets/75260afa-b453-4039-84a4-810e9292be60)

The Fitness Pose Correction Application is an academic project developed to help users improve their exercise posture through instant feedback. The system utilizes Artificial Intelligence (AI) to analyze user movements and postures from video, then provides corrective suggestions to ensure proper technique, minimize injury risk, and optimize workout effectiveness.

The project consists of three main components: a powerful AI model (LSTM with Attention) on a Python (Flask) backend, a user-friendly Flutter mobile application, and Firebase for data management and feedback delivery.

## Features

- **Real-time Pose Analysis**: The system is capable of detecting and analyzing keypoints on the human body to assess exercise posture.
- **Instant Corrective Feedback**: Provides specific feedback on posture errors, allowing users to make immediate adjustments.
- **Support for Various Exercises**: (If applicable, you can add specific exercises the model supports, e.g., plank, squat, push-up).
- **User-Friendly Mobile Interface**: The Flutter application enables users to easily interact and receive feedback.

## Demo
Check out the video demonstration of the app here: [Video demo](https://drive.google.com/drive/folders/1bUFHgGhRlI2OzPpl7ntK551H8ReKADiE?usp=sharing)

## How it works

The system operates according to the following process:
1. **Data Collection and Preprocessing:**
- The mobile application (Flutter) records user exercise videos/images and sends them to the backend.
- The backend uses the Mediapipe and OpenCV libraries to detect human body keypoints in each frame.
- Keypoint data (x, y, z coordinates and visibility) is extracted and normalized, then organized into sequences for AI model input. This process includes cropping frames based on the body's bounding box and normalizing coordinates to ensure consistency.
2. **AI Model (LSTM with Attention):**
- The preprocessed keypoint data is fed into the LSTM with Attention model (built using TensorFlow and Keras).
- This model is trained on a large dataset of correct and incorrect postures to learn how to classify and evaluate posture quality.
- The Attention layer helps the model focus on the most critical parts of the movement sequence to make more accurate predictions.
3. **Feedback and Communication:**
- After the AI model processes the data, the prediction results (e.g., posture error codes) are sent back to the backend (Flask).
- The backend then relays this feedback to the mobile application via Firebase, allowing the app to display instant corrective suggestions to the user.
4. **Model Training and Optimization:**
- The AI model is trained with optimization techniques such as EarlyStopping to prevent overfitting and ReduceLROnPlateau to adjust the learning rate, ensuring optimal performance.
- Training data includes carefully labeled keypoint sequences, helping the model learn the differences between correct and incorrect postures.
