import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:water_metering/api/auth.dart';
import 'package:water_metering/bloc/changeNotifier.dart';
import 'package:water_metering/bloc/dashboardBloc/dashboardBloc.dart';
import 'package:water_metering/pages/auth/Register.dart';
import 'package:water_metering/pages/auth/SignIn.dart';
import 'package:water_metering/theme/size_extension.dart';
import 'package:water_metering/theme/theme.dart';
import 'package:water_metering/utils/biometric.dart';
import 'package:water_metering/utils/functions.dart';
import 'package:water_metering/widgets/alerts/alert.dart';
import 'package:water_metering/widgets/appbar/appbar.dart';
import 'package:water_metering/widgets/buttons/custom_button.dart';
import 'package:water_metering/widgets/buttons/custom_toggle_button.dart';
import 'package:water_metering/widgets/loader/loader.dart';
import 'package:water_metering/widgets/text/chamfered_textwidget.dart';
import 'package:water_metering/widgets/textfield/custom_textfield.dart';
import 'package:water_metering/widgets/textfield/password_textfield.dart';
import '../../config.dart';
import '../../main.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
    // SystemChrome.setPreferredOrientations(
    //     [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    NudronRandomStuff.isSignIn.addListener(() {
      setState(() {});
    });
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _showEmailConfirmationDialog(context);
    // });
    super.initState();
  }

  List<Widget> pages = [
    const SigninPage(),
    const RegisterPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SafeArea(
        child: Scaffold(
          appBar: CustomAppBar(
            choiceAction: null,
          ),
          backgroundColor: Provider.of<ThemeNotifier>(context).currentTheme.bgColor,
          resizeToAvoidBottomInset: false,
          // Prevents resize when the keyboard appears
          body: SizedBox(
            // color:Colors.green,
            height: 1.sh - 51.h,
            width: 1.sw,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.bottomCenter,
                  // Keeps the icon at the bottom center
                  child: Transform.rotate(
                    angle: 0,
                    child: SvgPicture.asset(
                      'assets/icons/nfcicon.svg',
                      fit: BoxFit.cover,
                      clipBehavior: Clip.hardEdge,
                      color: CommonColors.blue.withOpacity(0.25),
                      width: 450.minSp,
                    ),
                  ),
                ),
                Scaffold(
                  backgroundColor: Colors.transparent,
                  resizeToAvoidBottomInset: true,
                  body: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 3.h,
                          color: CommonColors.blue,
                        ),
                        SizedBox(height: 20.h),
                        Center(
                          child: Text(
                            'Nudron IoT Solutions',
                            style: GoogleFonts.roboto(
                                fontSize: 37.minSp,
                                fontWeight: FontWeight.bold,
                                color: Provider.of<ThemeNotifier>(context)
                                    .currentTheme
                                    .loginTitleColor),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Center(
                            child: Container(
                              child: Text(
                                  "Welcome to Nudron's Water Metering Dashboard",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.roboto(
                                      fontSize: ThemeNotifier.medium.minSp,
                                      color: Provider.of<ThemeNotifier>(context)
                                          .currentTheme
                                          .basicAdvanceTextColor)),
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Center(
                          child: ToggleButtonCustom(
                            key: UniqueKey(),
                            tabs: const ["SIGN IN", "REGISTER"],
                            backgroundColor: null,
                            selectedTextColor: Colors.white,
                            unselectedTextColor:
                                Provider.of<ThemeNotifier>(context)
                                    .currentTheme
                                    .basicAdvanceTextColor,
                            index: NudronRandomStuff.isSignIn.value ? 0 : 1,
                            onTap: (index) {
                              setState(() {
                                NudronRandomStuff.isSignIn.value = index == 0;
                              });
                            },
                          ),
                        ),
                        SizedBox(height: 40.h),
                        IndexedStack(
                          index: NudronRandomStuff.isSignIn.value ? 0 : 1,
                          children: pages,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

