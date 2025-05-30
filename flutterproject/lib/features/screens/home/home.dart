import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutterproject/common/styles/widgets/appbar/appbar.dart';
import 'package:flutterproject/common/styles/widgets/custom_shapes/curved_edges/curved_edges.dart';
import 'package:flutterproject/features/screens/controllers/home_controller.dart';
import 'package:flutterproject/features/screens/setup/setup_plank_screen.dart';
import 'package:flutterproject/features/screens/setup/setup_pushup_screen.dart';
import 'package:flutterproject/features/screens/setup/setup_squat_screen.dart';
import 'package:flutterproject/features/screens/videosupport/video_support.dart';
import 'package:flutterproject/utils/constants/colors.dart';
import 'package:flutterproject/utils/constants/image_strings.dart';
import 'package:flutterproject/utils/constants/sizes.dart';
import 'package:flutterproject/utils/constants/text_strings.dart';
import 'package:flutterproject/utils/device/device_utility.dart';
import 'package:flutterproject/utils/helpers/helper_functions.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = AppHelperFunctions.isDarkMode(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            AppPrimaryHeaderContainer(
              height: 250,
              child: Column(
                children: [
                  AppAppBar(title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppTexts.homeAppbarTitle, style: Theme.of(context).textTheme.labelMedium!.apply(color: AppColors.darkerGrey)),
                      Text(AppTexts.homeAppbarSubTitle, style: Theme.of(context).textTheme.headlineSmall!.apply(color: Color(0xFF5D4037))),
                      ],
                    ),
                    actions: [
                      IconButton( onPressed: (){}, icon: const Image( width: AppSizes.iconMd, height: AppSizes.iconMd, image: AssetImage(AppImages.hello))),
                    ],
                  ),
                  const SizedBox(height: AppSizes.spaceBtwSections),


                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.defaultSpace),
                    child: Container(
                      width: AppDeviceUtils.getScreenWidth(context),
                      padding: const EdgeInsets.all(AppSizes.md),
                      decoration: BoxDecoration(
                        color: dark ? AppColors.dark : AppColors.light,
                        borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
                        border: Border.all(color: AppColors.grey),
                      ),
                      child: Row(
                        children: [
                          const Icon(Iconsax.search_normal,color: AppColors.darkerGrey),
                          const SizedBox(width: AppSizes.spaceBtwItems),
                          Text('Search', style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              child: Container(
                width: AppDeviceUtils.getScreenWidth(context),
                padding: const EdgeInsets.all(AppSizes.md),
                child: Text(
                  AppTexts.videosupport,
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.left, // Căn trái cho văn bản
                ),
              ),
            ),
            
            Padding(
              padding: EdgeInsets.all(AppSizes.defaultSpace),
              child: AppPromoSlider( ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              child: Container(
                width: AppDeviceUtils.getScreenWidth(context),
                padding: const EdgeInsets.all(AppSizes.md),
                child: Text(
                  AppTexts.choose,
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.left, // Căn trái cho văn bản
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.defaultSpace),
              child: Container(
                height: 100,
                width: AppDeviceUtils.getScreenWidth(context),
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: dark ? AppColors.dark : AppColors.light,
                  borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
                  border: Border.all(color: AppColors.grey),
                ),
                child: GestureDetector(
                  onTap: () {
                    Get.to(() => const SetupScreenPushUp());
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(AppImages.pushup,height: 80,width: 80, fit: BoxFit.cover),
                      ),
                      
                      const SizedBox(width: AppSizes.spaceBtwItems),
                      
                      Expanded(
                        child: Text('Push Up', style: Theme.of(context).textTheme.headlineSmall),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: AppSizes.spaceBtwItems),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.defaultSpace),
              child: Container(
                height: 100,
                width: AppDeviceUtils.getScreenWidth(context),
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: dark ? AppColors.dark : AppColors.light,
                  borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
                  border: Border.all(color: AppColors.grey),
                ),
                child: GestureDetector(
                  onTap: () {
                    Get.to(() => const SetupScreenSquat());
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(AppImages.squat,height: 80,width: 80, fit: BoxFit.cover),
                      ),
                      
                      const SizedBox(width: AppSizes.spaceBtwItems),
                      
                      Expanded(
                        child: Text('Squat', style: Theme.of(context).textTheme.headlineSmall),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSizes.spaceBtwItems),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.defaultSpace),
              child: Container(
                height: 100,
                width: AppDeviceUtils.getScreenWidth(context),
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: dark ? AppColors.dark : AppColors.light,
                  borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
                  border: Border.all(color: AppColors.grey),
                ),
                child: GestureDetector(
                  onTap: () {
                    Get.to(() => const SetupScreenPlank());
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(AppImages.plank,height: 80,width: 80, fit: BoxFit.cover),
                      ),
                      
                      const SizedBox(width: AppSizes.spaceBtwItems),
                      
                      Expanded(
                        child: Text('Plank', style: Theme.of(context).textTheme.headlineSmall),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BannerItem {
  final String imageUrl;
  final String title;
  final String calories;
  final String duration;
  final String videoUrl;

  BannerItem({
    required this.imageUrl,
    required this.title,
    required this.calories,
    required this.duration,
    required this.videoUrl,
  });
}


class AppPromoSlider extends StatelessWidget {
  AppPromoSlider({
    super.key,
  });
  final List<BannerItem> banners = [
    BannerItem(
      imageUrl: AppImages.pushup,
      title: 'Push Up',
      calories: '500 Kcal',
      duration: '50 Min',
      videoUrl: 'assets/video_support/push-up_1.mp4',
    ),
    BannerItem(
      imageUrl: AppImages.squat,
      title: 'Squat',
      calories: '400 Kcal',
      duration: '40 Min',
      videoUrl: 'assets/video_support/squat.mp4',
    ),
    BannerItem(
      imageUrl: AppImages.plank,
      title: 'Plank',
      calories: '400 Kcal',
      duration: '40 Min',
      videoUrl: 'assets/video_support/plank_3.mp4',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            viewportFraction: 1,
            onPageChanged: (index, _) => controller.updatePageIndicator(index)
          ),
          items: banners.map((BannerItem) {
            return AppRoundedImage(
              imageUrl: BannerItem.imageUrl,
              title: BannerItem.title,
              calories: BannerItem.calories,
              duration: BannerItem.duration,
              videoUrl: BannerItem.videoUrl,
            ); 
          }).toList(),
        ),
    
        const SizedBox(height: AppSizes.spaceBtwItems),
    
        Center(
          child: Obx(
            () =>  Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for(int i=0; i< banners.length; i++) 
                  AppCircularContainer(
                    width: 20,
                    height: 4, 
                    margin: const EdgeInsets.only(right: 10),
                    backgroundColor: controller.carousalCurrentIndex.value == i ? AppColors.primary : AppColors.grey
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class AppRoundedImage extends StatelessWidget {
  const AppRoundedImage({
    super.key,
    this.border,
    this.padding,
    this.onPressed,
    this.width,
    this.height,
    this.applyImageRadius = true,
    required this.imageUrl,
    this.fit = BoxFit.contain,
    this.backgroundColor = AppColors.light,
    this.isNetworkImage = false,
    this.borderRadius= AppSizes.md,
    required this.title,
    required this.calories,
    required this.duration,
    required this.videoUrl,
  });

  final double? width, height;
  final String imageUrl;
  final bool applyImageRadius;
  final BoxBorder? border;
  final Color backgroundColor;
  final BoxFit? fit;
  final EdgeInsetsGeometry? padding;
  final bool isNetworkImage;
  final VoidCallback? onPressed;
  final double borderRadius;
  final String title;
  final String calories;
  final String duration;
  final String videoUrl;


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width,
        height: height,
        padding: padding,
        decoration: BoxDecoration( borderRadius: BorderRadius.circular(AppSizes.md)),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: applyImageRadius ? BorderRadius.circular(AppSizes.md) : BorderRadius.zero,
              child: Image(
                fit: fit,
                image: isNetworkImage ? NetworkImage(imageUrl) : AssetImage(imageUrl) as ImageProvider,
              ),
            ),
            // Icon play
            Positioned(
              right: 20, // Khoảng cách từ bên phải
              top: 0,
              bottom: 0, // Đặt để căn giữa theo chiều dọc
              child: GestureDetector(
                onTap: () {
                  Get.to(() =>  VideoSupportScreen(videoUrl: videoUrl,));
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary, // Màu nền cho icon (xanh lá cây)
                  ),
                  child: const Icon(
                    Iconsax.play,
                    color: Colors.white,
                    size: 30, // Kích thước icon
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tiêu đề bài tập
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Lượng calo và thời gian
                  Row(
                    children: [
                      const Icon(Icons.local_fire_department, color: Colors.white),
                      const SizedBox(width: 5),
                      Text(
                        calories, // Lượng calo tiêu thụ
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(width: 20),
                      const Icon(Icons.timer, color: Colors.white),
                      const SizedBox(width: 5),
                      Text(
                        duration, // Thời gian tập luyện
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppPrimaryHeaderContainer extends StatelessWidget {
  const AppPrimaryHeaderContainer({
    super.key, 
    required this.child,
    required this.height,
  });

  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AppCurvedEdgeWidget(
      child: Container(
        color: AppColors.primary,
        padding: const EdgeInsets.all(0),
        child: SizedBox(
          height: height, // doi o day
          child: Stack(
            children: [
              Positioned(top: -150, right: -250,child:  AppCircularContainer(backgroundColor: AppColors.textWhite.withOpacity(0.2))),
              Positioned(top: 100, right: -300,child:  AppCircularContainer(backgroundColor: AppColors.textWhite.withOpacity(0.2))),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class AppCurvedEdgeWidget extends StatelessWidget {
  const AppCurvedEdgeWidget({
    super.key, this.child,
  });

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: AppCustomCurvedEdges(),
      child: child,
    );
  }
}

class AppCircularContainer extends StatelessWidget {
  const AppCircularContainer({
    super.key,
    this.child,
    this.width = 400,
    this.height = 400,
    this.radius = 400,
    this.margin,
    this.padding = 0,
    this.backgroundColor = AppColors.white,
  });

  final double? width;
  final double? height;
  final double radius;
  final EdgeInsets? margin;
  final double padding;
  final Widget? child;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: backgroundColor,
      ),
      child: child,
    );
  }
}