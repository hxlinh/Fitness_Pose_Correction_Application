import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class RestTimeClock extends StatefulWidget {
  final String currentExercisePath; // Đường dẫn cơ sở của current_exercise

  const RestTimeClock({Key? key, required this.currentExercisePath}) : super(key: key);

  @override
  State<RestTimeClock> createState() => _RestTimeClockState();
}

class _RestTimeClockState extends State<RestTimeClock> {
  int _remainingSeconds = 0;
  Timer? _timer;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    _fetchRestTime();
  }

  // Hàm để chuyển đổi current_exercise thành đường dẫn Firebase tương ứng
  String _getHistoryPath(String exerciseName) {
    return 'history_${exerciseName.toLowerCase().replaceAll(' ', '')}';
  }

  void _fetchRestTime() async {
    // Lấy giá trị của current_exercise
    final DataSnapshot currentExerciseSnapshot = await _dbRef.child(widget.currentExercisePath).get();
    if (currentExerciseSnapshot.exists) {
      final String exerciseName = currentExerciseSnapshot.value.toString();

      // Xác định đường dẫn history và số lượng entryCount
      final String historyPath = _getHistoryPath(exerciseName);
      final DataSnapshot entryCountSnapshot = await _dbRef.child('$historyPath/entryCount${exerciseName.replaceAll(' ', '')}').get();

      if (entryCountSnapshot.exists) {
        final int entryCount = int.parse(entryCountSnapshot.value.toString());

        // Lấy thời gian nghỉ từ Firebase
        final DataSnapshot restTimeSnapshot = await _dbRef.child('$historyPath/$entryCount/restTime').get();
        if (restTimeSnapshot.exists) {
          setState(() {
            _remainingSeconds = int.parse(restTimeSnapshot.value.toString()) * 60; // Chuyển đổi phút thành giây
          });
          _startCountdown();
        }
      }
    }
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Color(0xFF3DC5A0).withOpacity(0.3), width: 2),
      ),
      child: Center(
        child: Text(
          _formatTime(_remainingSeconds),
          style: TextStyle(
            fontSize: 48,
            color: Color(0xFF3DC5A0),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
