import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/material.dart';
import 'package:flutterproject/common/styles/widgets/appbar/appbar.dart';
import 'package:flutterproject/features/screens/statistics/statistics_screen.dart';
import 'package:flutterproject/utils/constants/colors.dart';
import 'package:flutterproject/utils/constants/sizes.dart';
import 'package:flutterproject/utils/helpers/helper_functions.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:audioplayers/audioplayers.dart'; // Import audio package

class RecognizeScreen extends StatefulWidget {
  const RecognizeScreen({super.key});

  @override
  _RecognizeState createState() => _RecognizeState();
}

class _RecognizeState extends State<RecognizeScreen> {
  late final WebViewController _controller;
  late final Trace trace; // Khai báo Trace để đo độ trễ
  String currentExercise = "";
  String maloi = "";
  DateTime? lastErrorTime;
  final AudioPlayer _audioPlayer = AudioPlayer(); // Initialize audio player
  int? currentEntryCount;
  


  @override
  void initState() {
    super.initState();

    trace = FirebasePerformance.instance.newTrace('webview_load_time');

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('http://127.0.0.1:8000/video_feed'));
    
    // Retrieve data from Firebase Realtime Database
    DatabaseReference databaseRef = FirebaseDatabase.instance.ref();

    // Cập nhật số lần entry count dựa trên bài tập hiện tại
    updateEntryCount(databaseRef);

    // Lắng nghe thay đổi của bài tập hiện tại
    databaseRef.child('current_exercise').onValue.listen((event) {
      setState(() {
        currentExercise = event.snapshot.value as String? ?? "";
        updateEntryCount(databaseRef); // Cập nhật entry count khi bài tập thay đổi
      });
    });

    databaseRef.child('maloi').onValue.listen((event) {
      final newMaloi = event.snapshot.value as String? ?? "";
      if (newMaloi != maloi) {
        setState(() {
          maloi = newMaloi;
          saveErrorHistory(currentExercise, maloi);
          playErrorSound(currentExercise, maloi);
        });
      }
    });
  }

  // Phương thức để cập nhật entry count dựa trên bài tập hiện tại
  void updateEntryCount(DatabaseReference databaseRef) {
    if (currentExercise.isEmpty) return;

    String entryCountPath = '';
    switch (currentExercise) {
      case "Push Up":
        entryCountPath = 'history_pushup/entryCountPushUp';
        break;
      case "Squat":
        entryCountPath = 'history_squat/entryCountSquat';
        break;
      case "Plank":
        entryCountPath = 'history_plank/entryCountPlank';
        break;
      default:
        return;
    }

    databaseRef.child(entryCountPath).onValue.listen((event) {
      setState(() {
        currentEntryCount = event.snapshot.value as int? ?? 1;
      });
    });
  }

  // Hàm để lấy reference đến node history_error tương ứng
  DatabaseReference getHistoryErrorRef() {
    final databaseRef = FirebaseDatabase.instance.ref();
    String historyPath = '';
    
    switch (currentExercise) {
      case "Push Up":
        historyPath = 'history_pushup/$currentEntryCount/history_error';
        break;
      case "Plank":
        historyPath = 'history_plank/$currentEntryCount/history_error';
        break;
      case "Squat":
        historyPath = 'history_squat/$currentEntryCount/history_error';
        break;
      default:
        return databaseRef;
    }
    
    return databaseRef.child(historyPath);
  }

  // Save error history for each exercise
void saveErrorHistory(String exercise, String error) async {
  final Trace saveErrorTrace = FirebasePerformance.instance.newTrace('save_error_history');
  saveErrorTrace.start(); // Bắt đầu đo trace
  // Skip if there's no exercise or error or if the error is "c" (correct)
  if (exercise.isEmpty || error.isEmpty ) return;

  final now = DateTime.now();
  if (lastErrorTime == null || now.difference(lastErrorTime!).inSeconds >= 2) {
    lastErrorTime = now;

    final historyErrorRef = getHistoryErrorRef();

    try {
      // Define the possible errors for each exercise
      Map<String, List<String>> possibleErrors = {
        "Plank": ["c","1", "3", "4", "5", "7"],
        "Push Up": ["c","1", "3", "5", "7"],
        "Squat": ["c","1", "2", "3", "4", "5"],
      };

      List<String> errors = possibleErrors[exercise] ?? [];

      // For each possible error, update or set frequency to 0 if not encountered
      for (String err in errors) {
        final errorRef = historyErrorRef.child(err);
        final snapshot = await errorRef.child('frequency').get();
        int currentFrequency = snapshot.value as int? ?? 0;

        if (err == error) {
          // If this is the current error, increment its frequency
          currentFrequency++;
        }

        // Update the frequency for each error
        await errorRef.child('frequency').set(currentFrequency);
      }

      print('Updated frequencies for errors in "$exercise"');

      // Update the 'rep' count and check if all reps are completed
      final repSnapshot = await historyErrorRef.parent!.child('rep').get();
      final currentRep = repSnapshot.value as int? ?? 0;
      await historyErrorRef.parent!.child('rep').set(currentRep + 1);

      // Get total reps count and navigate if complete
      final repsSnapshot = await historyErrorRef.parent!.child('reps').get();
      final totalReps = repsSnapshot.value as int? ?? 0;
      if (currentRep + 1 >= totalReps) {
        await updateStatistics(exercise, totalReps, historyErrorRef);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ExerciseStatsScreen(currentExercise: exercise)),
        );
      }
    } catch (e) {
      print('Error saving error history: $e');
    }
  }
  saveErrorTrace.stop(); // Dừng đo trace sau khi xử lý xong
}

  Future<void> updateStatistics(String exercise, int reps, DatabaseReference historyErrorRef) async {
  final databaseRef = FirebaseDatabase.instance.ref();
  final statisticsRepRef = databaseRef.child('statistics_$exercise/statisticstimes');
  final statisticsErrorRef = databaseRef.child('statistics_$exercise/statisticserror');

  // Update `statisticsrep`
  final repSnapshot = await statisticsRepRef.get();
  int totalReps = repSnapshot.value as int? ?? 0;
  totalReps += reps;
  await statisticsRepRef.set(totalReps);

  // Define the possible errors for each exercise
  Map<String, List<String>> possibleErrors = {
    "Plank": [ "c","1", "3", "4", "5", "7"],
    "Push Up": [ "c","1", "3", "5", "7"],
    "Squat": [ "c","1", "2", "3", "4", "5"],
  };

  List<String> errors1 = possibleErrors[exercise] ?? [];

  // Update `statisticserror`
  for (String err in errors1) { // Adjust errors based on exercise
    final errorHistoryRef = historyErrorRef.child(err);
    final errorFrequencySnapshot = await errorHistoryRef.child('frequency').get();
    int sessionFrequency = errorFrequencySnapshot.value as int? ?? 0;

    final statisticErrorRef = statisticsErrorRef.child(err);
    final statisticErrorSnapshot = await statisticErrorRef.child('frequency').get();
    int totalFrequency = statisticErrorSnapshot.value as int? ?? 0;
    totalFrequency += sessionFrequency;
    await statisticErrorRef.child('frequency').set(totalFrequency);
  }
}




  String getErrorMessage(String currentExercise, String maloi) {
  if (maloi == "c") {
    return "Correct";
  }

  switch (currentExercise) {
    case "Plank":
      switch (maloi) {
        case "1":
          return "Tay cao hơn ngực";
        case "3":
          return "Mông cao";
        case "4":
          return "Mông thấp";
        case "5":
          return "Lưng gù";
        case "7":
          return "Chân không thẳng";
        default:
          return "";
      }

    case "Push Up":
      switch (maloi) {
        case "1":
          return "Tay cao hơn ngực";
        case "3":
          return "Mông cao";

        case "5":
          return "Mông thấp";
        case "7":
          return "Chân không thẳng";
        default:
          return "";
      }

    case "Squat":
      switch (maloi) {
        case "1":
          return "Hạ quá thấp";
        case "2":
          return "Hạ nông quá";
        case "3":
          return "Lưng không thẳng";
        case "4":
          return "Nâng mông trước nâng người sau";
        case "5":
          return "Chường người về phía trước";
        default:
          return "";
      }

    default:
      return "";
    }
  }


  void playErrorSound(String currentExercise, String maloi) async {
    final Trace playSoundTrace = FirebasePerformance.instance.newTrace('play_error_sound');
  playSoundTrace.start(); // Bắt đầu đo trace
  String soundPath;

  if (maloi == "c") {
    soundPath = 'sound/success.mp3'; // Path to sound for "Correct" feedback
  } else {
    switch (currentExercise) {
      case "Plank":
        switch (maloi) {
          case "1":
            soundPath = 'sound/11.mp3';
            break;
          case "3":
            soundPath = 'sound/13.mp3';
            break;
          case "4":
            soundPath = 'sound/14.mp3';
            break;
          case "5":
            soundPath = 'sound/15.mp3';
            break;
          case "7":
            soundPath = 'sound/17.mp3';
            break;
          default:
            soundPath = '';
        }
        break;

      case "Push Up":
        switch (maloi) {
          case "1":
            soundPath = 'sound/21.mp3';
            break;
          case "3":
            soundPath = 'sound/23.mp3';
            break;
          case "5":
            soundPath = 'sound/25.mp3';
            break;
          case "7":
            soundPath = 'sound/27.mp3';
            break;
          default:
            soundPath = '';
        }
        break;

      case "Squat":
        switch (maloi) {
          case "1":
            soundPath = 'sound/31.mp3';
            break;
          case "2":
            soundPath = 'sound/32.mp3';
            break;
          case "3":
            soundPath = 'sound/33.mp3';
            break;
          case "4":
            soundPath = 'sound/34.mp3';
            break;
          case "5":
            soundPath = 'sound/35.mp3';
            break;
          default:
            soundPath = '';
        }
        break;

      default:
        soundPath = '';
    }
  }

  if (soundPath.isNotEmpty) {
    await _audioPlayer.play(AssetSource(soundPath));
  }
  playSoundTrace.stop(); // Dừng đo trace sau khi âm thanh được phát
}


  @override
  void dispose() {
    _audioPlayer.dispose(); // Dispose the audio player when not needed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = AppHelperFunctions.isDarkMode(context);
    String displayText = getErrorMessage(currentExercise,maloi);

    return Scaffold(
      appBar: const AppAppBar(showBackArrow: true),
      body: Stack(
        children: [
          Positioned.fill(
            child: WebViewWidget(controller: _controller),
          ),
          
          Positioned(
            bottom: AppSizes.spaceBtwSections,
            left: AppSizes.defaultSpace,
            right: AppSizes.defaultSpace,
            child: Container(
              height: 100,
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: dark ? AppColors.dark : AppColors.light,
                borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
                border: Border.all(color: AppColors.grey),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: AppSizes.spaceBtwItems),
                  Expanded(
                    child: Text(
                      displayText,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
