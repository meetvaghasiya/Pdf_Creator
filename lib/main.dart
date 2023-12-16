import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pdf_creator/Screens/DashBoard%20Screen/dashboard.dart';
import 'package:pdf_creator/Screens/onboardingscreen/onboardingscreen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:crop_image/crop_image.dart';

Future<void> main() async {
  await GetStorage.init();
  WidgetsFlutterBinding.ensureInitialized();
  const FlutterSecureStorage secureStorage = FlutterSecureStorage();
  String? onboardingStatus = await secureStorage.read(key: 'onboarding_status');

  runApp(MyApp(
    showOnboarding: onboardingStatus != 'finished',
  ));
}

class MyApp extends StatelessWidget {
  final bool showOnboarding;
  const MyApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: AnimatedSplashScreen.withScreenFunction(
        centered: true,
        splash: 'assets/images/splashlogo.png',
        splashIconSize: 400,
        splashTransition: SplashTransition.scaleTransition,
        curve: Curves.easeInOutCubic,
        pageTransitionType: PageTransitionType.rightToLeft,
        duration: 1000,
        screenFunction: () async {
          return showOnboarding ? OnboardingScreen() : DashBoard();
        },
      ),
    );
  }
}




class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final controller = CropController(
    aspectRatio: 1,
    defaultCrop: const Rect.fromLTRB(0.1, 0.1, 0.9, 0.9),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.title),
    ),
    body: Center(
      child: CropImage(
        controller: controller,
        image: Image.asset(''),
        paddingSize: 25.0,
        alwaysMove: true,
      ),
    ),
    bottomNavigationBar: _buildButtons(),
  );

  Widget _buildButtons() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      IconButton(
        icon: const Icon(Icons.close),
        onPressed: () {
          controller.rotation = CropRotation.up;
          controller.crop = const Rect.fromLTRB(0.1, 0.1, 0.9, 0.9);
          controller.aspectRatio = 1.0;
        },
      ),
      IconButton(
        icon: const Icon(Icons.aspect_ratio),
        onPressed: _aspectRatios,
      ),
      IconButton(
        icon: const Icon(Icons.rotate_90_degrees_ccw_outlined),
        onPressed: _rotateLeft,
      ),
      IconButton(
        icon: const Icon(Icons.rotate_90_degrees_cw_outlined),
        onPressed: _rotateRight,
      ),
      TextButton(
        onPressed: _finished,
        child: const Text('Done'),
      ),
    ],
  );

  Future<void> _aspectRatios() async {
    final value = await showDialog<double>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Select aspect ratio'),
          children: [
            // special case: no aspect ratio
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, -1.0),
              child: const Text('free'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 1.0),
              child: const Text('square'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 2.0),
              child: const Text('2:1'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 1 / 2),
              child: const Text('1:2'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 4.0 / 3.0),
              child: const Text('4:3'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 16.0 / 9.0),
              child: const Text('16:9'),
            ),
          ],
        );
      },
    );
    if (value != null) {
      controller.aspectRatio = value == -1 ? null : value;
      controller.crop = const Rect.fromLTRB(0.1, 0.1, 0.9, 0.9);
    }
  }

  Future<void> _rotateLeft() async => controller.rotateLeft();

  Future<void> _rotateRight() async => controller.rotateRight();

  Future<void> _finished() async {
    final image = await controller.croppedImage();
    // ignore: use_build_context_synchronously
    await showDialog<bool>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          contentPadding: const EdgeInsets.all(6.0),
          titlePadding: const EdgeInsets.all(8.0),
          title: const Text('Cropped image'),
          children: [
            Text('relative: ${controller.crop}'),
            Text('pixels: ${controller.cropSize}'),
            const SizedBox(height: 5),
            image,
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}