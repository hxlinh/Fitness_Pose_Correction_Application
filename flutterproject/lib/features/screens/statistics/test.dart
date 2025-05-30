import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_database/firebase_database.dart';

class ErrorStatisticsPieChart extends StatelessWidget {
  final String exerciseType; // Nhập động tác cần hiển thị, ví dụ: "statistics_Push Up"

  const ErrorStatisticsPieChart({Key? key, required this.exerciseType})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ref = FirebaseDatabase.instance.ref(exerciseType);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Biểu đồ lỗi',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            StreamBuilder<DatabaseEvent>(
              stream: ref.onValue,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (snapshot.hasError) {
                  return Text('Lỗi: ${snapshot.error}');
                }

                if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
                  return const Text('Không có dữ liệu');
                }

                final data = snapshot.data!.snapshot.value as Map?;
                final statisticsError = data?['statisticserror'] as Map?;
                final total = data?['statisticstimes'] ?? 0;

                if (statisticsError == null) {
                  return const Text('Dữ liệu không hợp lệ');
                }

                Map<String, dynamic> errorFrequencies = statisticsError.map((key, value) {
                  return MapEntry(key, value['frequency'] ?? 0);
                });

                List<PieChartSectionData> sections = errorFrequencies.entries.map((entry) {
                  final errorCode = entry.key;
                  final frequency = entry.value;
                  final percentage = (frequency / total) * 100;

                  return PieChartSectionData(
                    color: _getRandomColor(errorCode),
                    value: frequency.toDouble(),
                    title: '${percentage.toStringAsFixed(1)}%',
                    radius: 50,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList();

                return Column(
                  children: [
                    SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sections: sections,
                          centerSpaceRadius: 40,
                          sectionsSpace: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tổng: $total',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    // Thêm phần hiển thị mã lỗi và màu sắc
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: errorFrequencies.keys.map((errorCode) {
                        return Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              color: _getRandomColor(errorCode),
                            ),
                            const SizedBox(width: 8),
                            Text(' ${_getErrorMessage(exerciseType, errorCode)}'),
                          ],
                        );
                      }).toList(),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getRandomColor(String key) {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.cyan,
    ];
    return colors[int.parse(key, radix: 16) % colors.length];
  }

  String _getErrorMessage(String exerciseType, String maloi) {
  print('Exercise Type: $exerciseType, Error Code: $maloi'); // Debug line
  switch (exerciseType) {
    case "statistics_Plank":
      switch (maloi) {
        case "c":
          return "Correct";
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
    case "statistics_Push Up":
      switch (maloi) {
        case "c":
          return "Correct";
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
    case "statistics_Squat":
      switch (maloi) {
        case "c":
          return "Correct";
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
      return "Không có thông tin lỗi";
  }
}
}
