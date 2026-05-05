import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_timetable_managment/core/binding/binding.dart';
import 'package:smart_timetable_managment/core/constants/app_colors.dart';
import 'package:smart_timetable_managment/core/routes/routes.dart';
import 'package:smart_timetable_managment/core/routes/routes_name.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/services.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
statusBarColor: Colors.transparent,           // Transparent status bar
      statusBarIconBrightness: Brightness.dark,     // ← Ye important hai (black icons)
      statusBarBrightness: Brightness.light,        // iOS ke liye
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    )
  );
  // // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);

  runApp(SmartTimeTable());
}

class SmartTimeTable extends StatelessWidget {
  const SmartTimeTable({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      child: GetMaterialApp(
        initialBinding: InitialBinding(),
        debugShowCheckedModeBanner: false,
        initialRoute: RoutesName.splashScreen,
        getPages: AppRoutes.appRoutes(),
        theme: ThemeData(
          scaffoldBackgroundColor: AppColors.white,
          primaryColor: AppColors.primary,
          colorScheme: ColorScheme.light(
            primary: AppColors.primary,
          ),

          appBarTheme: AppBarThemeData(
            backgroundColor: AppColors.white,
            surfaceTintColor: AppColors.white
          ),
          
        ),
        
       
      ),
    );
  }
}
