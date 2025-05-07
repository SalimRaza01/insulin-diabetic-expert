

import 'package:INSUL/presentation/screens/otp_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'core/services/bluetooth_service_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/sharedpref_utils.dart';
import 'core/services/flutter_background_service.dart';
import 'data/providers/basal_delivery_provider.dart';
import 'data/providers/bolus_delivery_provider.dart';
import 'data/providers/glucose_provider.dart';
import 'data/providers/nutrition_provider.dart';
import 'data/providers/smart_bolus_delivery_provider.dart';
import 'data/providers/theme_provider.dart';
import 'data/providers/profile_updated_provider.dart';
import 'data/providers/auth_provider.dart';
import 'data/providers/weight_provider.dart';
import 'presentation/screens/basal_screen.dart';
import 'presentation/screens/bolus_screen.dart';
import 'presentation/screens/device_setup_screen.dart';
import 'presentation/screens/devices_screen.dart';
import 'presentation/screens/glucose_screen.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/insulin_screen.dart';
import 'presentation/screens/nutrition_screen.dart';
import 'presentation/screens/profile_screen.dart';
import 'presentation/screens/settings_screen.dart';
import 'presentation/screens/setup_profile_screen.dart';
import 'presentation/screens/smartbolus_screen.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/weight_screen.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPrefsHelper().init();
  FlutterBluePlus.setLogLevel(LogLevel.verbose, color: true);
  await initializeService();
  runApp(
    MultiProvider(
      providers: [

        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => OtpProvider()),
        ChangeNotifierProvider(create: (_) => ResendOtp()),
        ChangeNotifierProvider(create: (_) => Bolusdelivery()),
        ChangeNotifierProvider(create: (_) => BasalDelivery()),
        ChangeNotifierProvider(create: (_) => WeightSetup()),
        ChangeNotifierProvider(create: (_) => GlucoseDelivery()),
        ChangeNotifierProvider(create: (_) => NutritionChartNotifier()),
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(create: (_) => ProfileUpdateNotifier()),
        ChangeNotifierProvider(create: (_) => SmartBolusDelivery()),
        ChangeNotifierProvider(create: (_) => BleManager()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final _sharedPref = SharedPrefsHelper();
  @override
  Widget build(
    BuildContext context,
  ) {
    return Consumer<ThemeNotifier>(
      builder: (context, value, child) {
        print('this value ${value.isDarkMode}');
        if (_sharedPref.getBool('darkMode') == true) {
          Provider.of<ThemeNotifier>(context, listen: false)
              .themeMode(_sharedPref.getBool('darkMode')!);
        }

        return MaterialApp(
          theme: lightMode,
          darkTheme: darkMode,
          themeMode: value.isDarkMode && _sharedPref.getBool('darkMode') == true
              ? ThemeMode.dark
              : ThemeMode.light,
          debugShowCheckedModeBanner: false,
          initialRoute: "/HomeScreen",
          routes: {
            "/SplashScreen": (context) => Splashscreen(),
            "/HomeScreen": (context) => HomeScreen(),
            "/DeviceSetupScreen": (context) => DeviceSetupScreen(),
            "/WeightScreen": (context) => WeightScreen(),
            "/InsulinScreen": (context) => InsulinScreen(),
            "/NutritionScreen": (context) => NutritionScreen(),
            "/ProfileScreen": (context) => ProfileScreen(),
            "/SetupProfile": (context) => SetupProfile(),
            "/GlucoseScreen": (context) => GlucoseScreen(),
            "/SettingScreen": (context) => SettingsScreen(),
            "/BolusWizard": (context) => BolusWizard(),
            "/BasalWizard": (context) => BasalWizard(),
            "/SmartBolusScreen": (context) => SmartBolusScreen(),
            "/DevicesScreen": (context) => DevicesScreen(),
          },
        );
      },
    );
  }
}
