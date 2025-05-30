import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';

class PlankStatisticsScreen extends StatefulWidget {

  const PlankStatisticsScreen({super.key,});

  @override
  // ignore: library_private_types_in_public_api
  _PlankStatisticsScreenState createState() => _PlankStatisticsScreenState();
}

class _PlankStatisticsScreenState extends State<PlankStatisticsScreen> {
  String currentExercise = "";
  Map<String, dynamic> errorDescriptions = {};
  Map<String, int> errorCount = {};
  int totalTimes = 0;
  String exerciseDate = "";
  int entry= 0;

  @override
  void initState() {
    super.initState();

    // Retrieve data from Firebase Realtime Database
    DatabaseReference database = FirebaseDatabase.instance.ref();
    

    // Lấy bài tập hiện tại
    database.child('exercise').onValue.listen((event) {
      setState(() {
        currentExercise = event.snapshot.value as String? ?? "";
      });
    });
    database.child('entry').onValue.listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
        entry = event.snapshot.value as int? ?? 0;
        fetchExerciseData();
        });
      }
    });
  }


  void fetchExerciseData() {
  final Trace trace = FirebasePerformance.instance.newTrace('statistics_plank');
  trace.start();
  if (currentExercise.isEmpty ) return;

  final DatabaseReference historyRef = getHistoryRef();

  // Lấy thông tin của bài tập
  historyRef.onValue.listen((event) {
    if (event.snapshot.value != null) {
      setState(() {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        exerciseDate = data['date'] ?? ""; // Lấy ngày
        totalTimes = data['times'] ?? 0; // Lấy tổng số lần thực hiện
      });
    }
  });

  // Lấy thông tin lỗi từ history_error, bao gồm mã lỗi 'c'
  final List<String> errorCodes = ['1', '2', '3', '4', '5', '6', '7', 'c'];

  for (String errorCode in errorCodes) {
    DatabaseReference specificErrorRef = getErrorRefForSpecificCode(errorCode);

    specificErrorRef.onValue.listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          // Lấy giá trị frequency nếu có
          final errorData = Map<String, dynamic>.from(event.snapshot.value as Map);
          int frequency = errorData['frequency'] as int? ?? 0;
          errorCount[errorCode] = frequency; // Lưu trữ số lần xuất hiện của lỗi
        });
      }
    });
  }
  trace.stop();
}



  DatabaseReference getHistoryRef() {
    final databaseRef = FirebaseDatabase.instance.ref();
    String historyPath = '';

    switch (currentExercise) {
      case "Push Up":
        historyPath = 'history_pushup/$entry';
        break;
      case "Plank":
        historyPath = 'history_plank/$entry';
        break;
      case "Squat":
        historyPath = 'history_squat/$entry';
        break;
      default:
        return databaseRef;
    }

    return databaseRef.child(historyPath);
  }

  DatabaseReference getErrorRefForSpecificCode(String errorCode) {
  final databaseRef = FirebaseDatabase.instance.ref();
  String errorPath = '';

  switch (currentExercise) {
    case "Push Up":
      errorPath = 'history_pushup/$entry/history_error/$errorCode';
      break;
    case "Plank":
      errorPath = 'history_plank/$entry/history_error/$errorCode';
      break;
    case "Squat":
      errorPath = 'history_squat/$entry/history_error/$errorCode';
      break;
    default:
      return databaseRef;
  }

  return databaseRef.child(errorPath);
}


  DatabaseReference getHistoryErrorRef() {
    final databaseRef = FirebaseDatabase.instance.ref();
    String historyPathError = '';

    switch (currentExercise) {
      case "Push Up":
        historyPathError = 'history_pushup/$entry/history_error';
        break;
      case "Plank":
        historyPathError = 'history_plank/$entry/history_error';
        break;
      case "Squat":
        historyPathError = 'history_squat/$entry/history_error';
        break;
      default:
        return databaseRef;
    }

    return databaseRef.child(historyPathError);
  }

  String getErrorDescription(String maloi) {
    if (maloi == 'c') {
      return 'Correct';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise Stats'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Exercise: $currentExercise"),
            Text("Date: $exerciseDate"),
            Text("Total Times: $totalTimes"),
            Text("Lần tập thứ: $entry"),
            const SizedBox(height: 20),
            Expanded(
              child: DataTable(
                columns: const [
                  DataColumn(label: Text("Error")),
                  DataColumn(label: Text("Time")),
                  DataColumn(label: Text("% of Times")),
                ],
                rows: errorCount.entries.map((entry) {
                  final errorDescription = getErrorDescription(entry.key);
                  final count = entry.value;
                  final percentage = totalTimes > 0 ? (count / totalTimes * 100).toStringAsFixed(2) : "0";
                  return DataRow(cells: [
                    DataCell(Text(errorDescription)),
                    DataCell(Text(count.toString())),
                    DataCell(Text("$percentage%")),
                  ]);
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: PieChart(
                PieChartData(
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 2,
                  centerSpaceRadius: 50,
                  sections: errorCount.entries.map((entry) {
                    final percentage = totalTimes > 0 ? (entry.value / totalTimes * 100) : 0;
                    return PieChartSectionData(
                      value: percentage.toDouble(),
                      title: "${percentage.toStringAsFixed(1)}%",
                      color: Colors.primaries[entry.key.hashCode % Colors.primaries.length],
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      radius: 100,
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}