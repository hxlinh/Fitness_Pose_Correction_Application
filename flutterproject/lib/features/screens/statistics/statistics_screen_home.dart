import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutterproject/common/styles/widgets/appbar/appbar.dart';
import 'package:flutterproject/features/screens/home/home.dart';
import 'package:flutterproject/features/screens/statistics/default_statistics.dart';
import 'package:flutterproject/features/screens/statistics/plank_statistics.dart';
import 'package:flutterproject/features/screens/statistics/test.dart';
import 'package:flutterproject/utils/constants/colors.dart';
import 'package:flutterproject/utils/constants/text_strings.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class StatisticsHomeScreen extends StatefulWidget {
  const StatisticsHomeScreen({Key? key}) : super(key: key);

  @override
  State<StatisticsHomeScreen> createState() => _StatisticsHomeScreenState();
}

class _StatisticsHomeScreenState extends State<StatisticsHomeScreen> {
  int _selectedIndex = 0;
  int? selectedEntry;

  final List<Map<String, dynamic>> _exerciseTabs = [
    {'icon': Icons.fitness_center, 'label': 'Push Up', 'totalCount': 0},
    {'icon': Icons.arrow_downward, 'label': 'Squat', 'totalCount': 0},
    {'icon': Icons.timer, 'label': 'Plank', 'totalCount': 0},
  ];

  final List<Map<String, dynamic>> _exerciseTab = [
    {'icon': Icons.fitness_center, 'label': 'pushup', 'totalCount': 0},
    {'icon': Icons.arrow_downward, 'label': 'squat', 'totalCount': 0},
    {'icon': Icons.timer, 'label': 'plank', 'totalCount': 0},
  ];

  final List<Map<String, dynamic>> _exerciseTabss = [
    {'icon': Icons.fitness_center, 'label': 'PushUp', 'totalCount': 0},
    {'icon': Icons.arrow_downward, 'label': 'Squat', 'totalCount': 0},
    {'icon': Icons.timer, 'label': 'Plank', 'totalCount': 0},
  ];

  final FirebaseDatabase database = FirebaseDatabase.instance;

  

  @override
  void initState() {
    super.initState();
    _fetchExerciseData();
  }

  Future<void> _fetchExerciseData() async {
    final Trace trace = FirebasePerformance.instance.newTrace('statistics_home');
    trace.start();
    for (var i = 0; i < _exerciseTabs.length; i++) {
      final label = _exerciseTab[i]['label'];
      final labels = _exerciseTabss[i]['label'];
      final path = 'history_$label/entryCount$labels';
      final snapshot = await database.ref(path).get();

      if (snapshot.exists) {
        setState(() {
          _exerciseTabs[i]['totalCount'] = snapshot.value ?? 0;
        });
      }
    }
    trace.stop();
  }
  

  Widget _buildExerciseContent(int index) {
  final exerciseData = _exerciseTabs[index];
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${exerciseData['label']} Statistics',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tổng số lần tập:',
                  style: Theme.of(context).textTheme.titleMedium),
              Text('${exerciseData['totalCount']}',
                  style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Nhập lần tập',
                    hintText: 'Nhập lần tập bạn muốn xem',
                    hintStyle: const TextStyle(
                      color: AppColors.grey,
                    ),
                    prefixIcon: const Icon(Iconsax.setting,
                        color: AppColors.primary),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      selectedEntry = int.tryParse(value);
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF98FF98),
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.white, width: 0),
                ),
                onPressed: () {
                  FirebaseDatabase.instance.ref().child('exercise').set(exerciseData['label']);
                  FirebaseDatabase.instance.ref().child('entry').set(selectedEntry);
                  switch (exerciseData['label']) {
                    case 'Plank':
                      Get.to(() => const PlankStatisticsScreen());
                      break;
                    default:
                      Get.to(() => const StatisticsScreen());
                  }
                },
                child: const Text('Xem'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Biểu đồ tùy thuộc loại bài tập
          ErrorStatisticsPieChart(
            exerciseType: 'statistics_${exerciseData['label']}',
          ),
        ],
      ),
    ),
  );
}


  Widget _buildTabItem(int index) {
    final bool isSelected = _selectedIndex == index;
    final tab = _exerciseTabs[index];

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isSelected
              ? AppColors.primary
              : Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              tab['icon'],
              color: isSelected ? Colors.orange : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              tab['label'],
              style: TextStyle(
                color: isSelected ? Colors.orange : Colors.grey,
                fontSize: 14,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            AppPrimaryHeaderContainer(
              height: 150,
              child: Column(
                children: [
                  AppAppBar(
                    showBackArrow: true,
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          AppTexts.homeAppbarTitle,
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium!
                              .apply(color: AppColors.darkerGrey),
                        ),
                        Text(
                          AppTexts.homeAppbarSubTitle,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .apply(color: const Color(0xFF5D4037)),
                        ),
                      ],
                    ),
                    actions: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.person),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(
                    _exerciseTabs.length,
                    (index) => _buildTabItem(index),
                  ),
                ),
              ),
            ),
            _buildExerciseContent(_selectedIndex),
          ],
        ),
      ),
    );
  }
}