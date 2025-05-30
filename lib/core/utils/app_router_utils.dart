import 'package:INSUL/presentation/animations/tutorial_screen.dart';
import 'package:INSUL/presentation/screens/payment_screen.dart';
import 'package:INSUL/presentation/screens/report_screen.dart';
import 'package:INSUL/presentation/screens/tablet_screen.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/screens/auth/splash_screen.dart';
import '../../presentation/screens/home_screen.dart';
import '../../presentation/device_setup/device_setup_screen.dart';
import '../../presentation/device_setup/devices_screen.dart';
import '../../presentation/screens/weight_screen.dart';
import '../../presentation/screens/insulin_screen.dart';
import '../../presentation/screens/nutrition_screen.dart';
import '../../presentation/screens/profile_screen.dart';
import '../../presentation/screens/auth/setup_profile_screen.dart';
import '../../presentation/screens/glucose_screen.dart';
import '../../presentation/screens/settings_screen.dart';
import '../../presentation/screens/bolus_screen.dart';
import '../../presentation/screens/basal_screen.dart';
import '../../presentation/screens/smartbolus_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/HomeScreen',
  routes: [
    GoRoute(path: '/SplashScreen', builder: (context, state) => Splashscreen()),
    GoRoute(path: '/ReportScreen', builder: (context, state) => ReportScreen()),
    GoRoute(
        path: '/DevicesScreen', builder: (context, state) => DevicesScreen()),
    GoRoute(path: '/HomeScreen', builder: (context, state) => HomeScreenTablet()),
        GoRoute(path: '/tutorial', builder: (context, state) => TutorialScreen()),
              GoRoute(path: '/setupProfile', builder: (context, state) => SetupProfile()),
    GoRoute(
        path: '/DeviceSetupScreen',
        builder: (context, state) => DeviceSetupScreen()),
    GoRoute(path: '/WeightScreen', builder: (context, state) => WeightScreen()),
    GoRoute(
        path: '/InsulinScreen', builder: (context, state) => InsulinScreen()),
    GoRoute(
        path: '/NutritionScreen',
        builder: (context, state) => NutritionScreen()),
    GoRoute(
        path: '/ProfileScreen', builder: (context, state) => ProfileScreen()),
    GoRoute(path: '/SetupProfile', builder: (context, state) => SetupProfile()),
    GoRoute(
        path: '/GlucoseScreen', builder: (context, state) => GlucoseScreen()),
    GoRoute(
        path: '/SettingScreen', builder: (context, state) => SettingsScreen()),
    GoRoute(path: '/BolusWizard', builder: (context, state) => BolusWizard()),
    GoRoute(path: '/BasalWizard', builder: (context, state) => BasalWizard()),
    GoRoute(
        path: '/SmartBolusScreen',
        builder: (context, state) => SmartBolusScreen()),
    GoRoute(
        path: '/DevicesScreen', builder: (context, state) => DevicesScreen()),
    GoRoute(
        path: '/PaymentScreen', builder: (context, state) => BuySubscription()),
  ],
);
