import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterproject/common/styles/widgets/appbar/appbar.dart';
import 'package:flutterproject/features/screens/home/home.dart';
import 'package:flutterproject/features/screens/recognize_screen/recognize_screen.dart';
import 'package:flutterproject/utils/constants/colors.dart';
import 'package:flutterproject/utils/constants/image_strings.dart';
import 'package:flutterproject/utils/constants/sizes.dart';
import 'package:flutterproject/utils/constants/text_strings.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:firebase_database/firebase_database.dart'; // Ensure Firebase is added to your project

class SetupScreenPushUp extends StatefulWidget {
  const SetupScreenPushUp({super.key});

  @override
  _SetupScreenPushUpState createState() => _SetupScreenPushUpState();
}

class _SetupScreenPushUpState extends State<SetupScreenPushUp> {
  String Exercise = 'Push Up'; // Fixed exercise
  int? selectedReps; // Variable to store the number of reps selected
  List<String> exerciseList = []; // List of added exercises

  // Function to send data to Firebase
  void sendDataToFirebase() async {
    final trace = FirebasePerformance.instance.newTrace('setting_pushup');
    await trace.start(); // Bắt đầu theo dõi
    final databaseRef = FirebaseDatabase.instance.ref('history_pushup');

    // Get the current entry count
    final entryCountPushUpSnapshot = await databaseRef.child('entryCountPushUp').get();
    int entryCountPushUp = entryCountPushUpSnapshot.exists ? entryCountPushUpSnapshot.value as int : 0;

    // Increment the entry count
    entryCountPushUp++;

    // Get the current date
    final currentDate = DateTime.now();
    final formattedDate = '${currentDate.day}/${currentDate.month}/${currentDate.year}';

    // Add new exercise to Firebase
    await databaseRef.child(entryCountPushUp.toString()).set({
      'exerciseName': Exercise,
      'reps': selectedReps,
      'date': formattedDate, // Add the current date
    });

    // Update the entry count in Firebase
    await databaseRef.child('entryCountPushUp').set(entryCountPushUp);

    // Log the current exercise
    final currentExerciseRef = FirebaseDatabase.instance.ref('current_exercise');
    currentExerciseRef.set(Exercise);
    await trace.stop(); // Kết thúc theo dõi
  }

  // Function to add an exercise
  void addExercise() {
    if (selectedReps != null) {
      setState(() {
        exerciseList.add(
          'Bài tập: $Exercise, Reps: $selectedReps',
        );
      });

      // Send new data to Firebase
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
            // Exercise selection
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
                    color: AppColors.primary, // Border color
                    width: 2, // Border width
                  ),
                ),
                child: const Text(
                  'Push Up',
                  style: TextStyle(
                    color: AppColors.dark,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16), // Space between items

            // Reps input field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              child: TextField(
                decoration: InputDecoration(
                  border: const OutlineInputBorder(), // Input field border
                  labelText: 'Nhập số rep', // Label
                  hintText: 'Nhập số rep bạn muốn thực hiện', // Hint text
                  hintStyle: const TextStyle(
                    color: AppColors.grey, // Hint text color
                  ),
                  prefixIcon: const Icon(Iconsax.setting,color: AppColors.primary),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.primary, width: 2), // Border color when not selected
                    borderRadius: BorderRadius.circular(8), // Rounded corners
                  ),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    selectedReps = int.tryParse(value); // Update selected reps
                  });
                },
              ),
            ),
            const SizedBox(height: 16), // Space between items

            // Confirm button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF98FF98),
                foregroundColor: Colors.black,
                side: const BorderSide(color: Colors.white, width: 0),
              ),
              onPressed: addExercise,
              child: const Text('Xác nhận'),
            ),
            const SizedBox(height: AppSizes.spaceBtwItems), // Space between items

            // Display the list of added exercises
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              child: ListView.builder(
                shrinkWrap: true, // Prevent scroll expansion
                physics: const NeverScrollableScrollPhysics(), // Disable scrolling
                itemCount: exerciseList.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8.0), // Space between items
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primary, width: 1.5), // Border for each item
                      borderRadius: BorderRadius.circular(8), // Rounded corners for each item
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        exerciseList[index],
                        style: const TextStyle(fontSize: 16), // Text style
                      ),
                    ),
                  );
                },
              ),
            ),
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
                onPressed: () => Get.to(() => const RecognizeScreen()),
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
