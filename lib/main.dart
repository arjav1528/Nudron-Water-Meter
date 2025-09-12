import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:water_metering/utils/excel_helpers.dart';
import '../theme/theme2.dart';
import '../views/pages/DashboardPage2.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'config.dart';
import 'view_model/loginPostRequests.dart';
import 'views/pages/LoginPage2.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:water_metering/bloc/dashboardBloc/dashboardBloc.dart';

final mainNavigatorKey = GlobalKey<NavigatorState>();
final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await ExcelHelper.deleteOldExportFiles();
  final themeProvider = ThemeNotifier();
  await themeProvider.readThemeMode();
  runApp(
    BlocProvider<DashboardBloc>(
      create: (context) => DashboardBloc(),
      child: ChangeNotifierProvider(
        create: (_) => themeProvider,
        child: const MyApp(),
        // child: DevicePreview(
        //   enabled: !kReleaseMode,
        //   builder: (context) => const MyApp(), // Wrap your app
        // ),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  checkLogin() async {
    await LoginPostRequests.checkLogin();
    setState(() {});
  }

  // vibrateeverytwoseconds() {
  //   MiscellaneousFunctions.vibratePhone();
  //   Future.delayed(Duration(seconds: 2), () {
  //     vibrateeverytwoseconds();
  //   });
  // }

  @override
  initState() {
    // vibrateeverytwoseconds();
    // print(NFCFunctions().remove9000FromEnd("2102178411B20111223344556677889900AABBCCDDEEFF584D00004201000000000000000000000000000000000000000000000000000000000000000000000A00000102029F1C412C08230200100E00000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF4999C81A060AD111291A955C3458109000F1A2DCD42AA0F7FEE2FAE3F81C002E50A55F364E8CE50A62F3D1BE62E392472AF5EDF45A7303FD73105AF5880BC3A3573CA2A015CC2BADD762E695EE39BE14E5C87AF5905D72816498731991B9B553613CC7B2BF8A2D821203A9D9DDCCB73A072A5AC761A44D9EBED8ABA936C298FCF0EA5638BF2CE79DC435997D96E3B6D7E77C7CB37D03834B41B5B394370841F0C7DA01B419B4400A4DB2501B647E53616C2ED57B080E0D60B7FC84C741C5D565B348F0D80C175C608A525055CA4089F145593198F26A99F918997920079B0892AA06F4C9F56C7542C09E47BCA4D4B249439000"));
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
    // SystemChrome.setPreferredOrientations(
    //     [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    super.initState();
    checkLogin();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(430, 881.55),
        minTextAdapt: true,
        splitScreenMode: true,
        // Use builder only if you need to use library outside ScreenUtilInit context
        builder: (_, child) {
          // print("Splash color: ");
          // print(Theme.of(context).splashColor);
          return MaterialApp(
            // showPerformanceOverlay: true,
            home: child,
          );
        },
        child: MaterialApp(
          title: 'Meter Config',
          debugShowCheckedModeBanner: false,
          // useInheritedMediaQuery: true,
          // locale: DevicePreview.locale(context), // Ensures correct locale
          // builder: DevicePreview.appBuilder, // Important to wrap the whole app
          builder: (context, child) {
            return MediaQuery(
              child: child!,
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(1.0)),
            );
          },
          navigatorKey: mainNavigatorKey,
          scaffoldMessengerKey: scaffoldMessengerKey,
          routes: {
            '/': (context) {
              if (ConfigurationCustom.isTest) {
                return ConfigurationCustom.testScreen;
              }
              // print("Is logged in: ${LoginPostRequests.isLoggedIn}");
              if (LoginPostRequests.isLoggedIn) {
                return const DashboardPage();
              } else {
                return const LoginPage();
              }
            },
            '/login': (context) => const LoginPage(),
            '/homePage': (context) => const DashboardPage(),
          },
          initialRoute: "/",
          // onGenerateRoute: (settings) {
          //   if (settings.name == "/dashboard") {
          //     print("Going to dashboard page>??");
          //     return MaterialPageRoute(
          //       builder: (context) {
          //         return BlocProvider<DashboardBloc>(
          //             create: (context) => DashboardBloc(),
          //             child: const DashboardPage()
          //         );
          //       },
          //     );
          //   }
          //   return null;
          // }
        ));
  }
}