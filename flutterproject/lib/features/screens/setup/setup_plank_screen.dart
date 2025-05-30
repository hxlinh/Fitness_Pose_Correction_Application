import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterproject/common/styles/widgets/appbar/appbar.dart';
import 'package:flutterproject/features/screens/home/home.dart';
import 'package:flutterproject/features/screens/recognize_screen/recognize_screen_plank.dart';
import 'package:flutterproject/utils/constants/colors.dart';
import 'package:flutterproject/utils/constants/image_strings.dart';
import 'package:flutterproject/utils/constants/sizes.dart';
import 'package:flutterproject/utils/constants/text_strings.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:firebase_database/firebase_database.dart'; // Đảm bảo bạn đã thêm Firebase vào dự án

class SetupScreenPlank extends StatefulWidget {
  const SetupScreenPlank({super.key});

  @override
  _SetupScreenPlankState createState() => _SetupScreenPlankState();
}

class _SetupScreenPlankState extends State<SetupScreenPlank> {
  String Exercise = 'Plank'; // Động tác cố định
  int? selectedTimes; // Biến lưu số time đã chọn
  List<String> exerciseList = []; // Danh sách bài tập đã thêm

  // Hàm gửi dữ liệu lên Firebase
  void sendDataToFirebase() async {
    final trace = FirebasePerformance.instance.newTrace('setting_plank');
    await trace.start(); // Bắt đầu theo dõi
    final databaseRef = FirebaseDatabase.instance.ref('history_plank');

    // Đọc số thứ tự hiện tại
    final entryCountPlankSnapshot = await databaseRef.child('entryCountPlank').get();
    int entryCountPlank = entryCountPlankSnapshot.exists ? entryCountPlankSnapshot.value as int : 0;

    // Tăng số thứ tự
    entryCountPlank++;

    // Lấy ngày tháng năm hiện tại
    final currentDate = DateTime.now();
    final formattedDate = '${currentDate.day}/${currentDate.month}/${currentDate.year}';

    // Thêm bài tập mới vào Firebase
    await databaseRef.child(entryCountPlank.toString()).set({
      'exerciseName': Exercise,
      'times': selectedTimes,
      'date': formattedDate, // Thêm ngày tháng năm
    });

    // Cập nhật số thứ tự vào Firebase
    await databaseRef.child('entryCountPlank').set(entryCountPlank);

    // Ghi lại bài tập hiện tại
    final currentExerciseRef = FirebaseDatabase.instance.ref('current_exercise');
    currentExerciseRef.set(Exercise);
    await trace.stop(); // Kết thúc theo dõi
}



  void addExercise() {
  if (selectedTimes != null) {
    setState(() {
      exerciseList.add(
        'Bài tập: $Exercise, Times: $selectedTimes'
      );
    });

    // Gửi dữ liệu mới lên Firebase
    sendDataToFirebase();
    }
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
                        Text(AppTexts.settitle, style: Theme.of(context).textTheme.labelMedium!.apply(color: AppColors.darkerGrey)),
                        Text(AppTexts.homeAppbarSubTitle, style: Theme.of(context).textTheme.headlineSmall!.apply(color: Color(0xFF5D4037))),
                      ],
                    ),
                    actions: [
                      IconButton(onPressed: () {},icon: const Image( width: AppSizes.iconMd, height: AppSizes.iconMd, image: AssetImage(AppImages.fire)))
                    ],
                  )
                ],
              )
            ),
            // Chọn bài tập
            Text('Bài tập:',style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: AppSizes.spaceBtwItems),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              child: Container(
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: AppColors.primary, // Màu của khung
                    width: 2, // Độ dày của khung
                  ),
                ),
                child: const Text(
                  'Plank',
                  style: TextStyle(
                    color: AppColors.dark,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16), // Khoảng cách giữa các phần

            // Chọn số rep
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              child: TextField(
                decoration: InputDecoration(
                  border: const OutlineInputBorder(), // Viền ô nhập liệu
                  labelText: 'Nhập số time', // Nhãn cho ô nhập liệu
                  hintText: 'Nhập số time bạn muốn thực hiện', // Hướng dẫn cho người dùng
                  hintStyle: const TextStyle(
                    color: AppColors.grey, // Thay đổi màu của hint text
                  ),
                  prefixIcon: const Icon(Iconsax.setting,color: AppColors.primary),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.primary, width: 2), // Màu và độ dày khi không được chọn
                    borderRadius: BorderRadius.circular(8), // Đường viền bo góc
                  ),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    selectedTimes = int.tryParse(value); // Cập nhật số set đã chọn
                  });
                },
              ),
            ),
            const SizedBox(height: 16), // Khoảng cách giữa các phần

            // Nút thêm
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF98FF98),
                foregroundColor: Colors.black,
                side: const BorderSide(color: Colors.white, width: 0, ),
              ),
              onPressed: addExercise,
              child: const Text('Xác nhận'),
            ),
            const SizedBox(height: AppSizes.spaceBtwItems), // Khoảng cách giữa các phần

            // Hiển thị danh sách bài tập đã thêm
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              child: ListView.builder(
                shrinkWrap: true, // Để không làm kéo dài chiều cao
                physics: const NeverScrollableScrollPhysics(), // Tắt cuộn
                itemCount: exerciseList.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8.0), // Khoảng cách giữa các ô
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primary, width: 1.5), // Khung viền cho từng ô
                      borderRadius: BorderRadius.circular(8), // Bo góc từng ô
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        exerciseList[index],
                        style: const TextStyle(fontSize: 16), // Kích thước chữ
                      ),
                    ),
                  );
                },
              ),
            ), // Khoảng cách giữa các phần
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF98FF98),
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.white, width: 0),
                ),
                onPressed: () => Get.to(() =>  const RecognizePlankScreen()),
                child: const Text(AppTexts.start),
              ),
            ),
            const SizedBox(height: AppSizes.spaceBtwSections),
          ],
        ),
      ),
    );
  }
}
