



import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:water_metering/api/auth.dart';
import 'package:water_metering/bloc/dashboardBloc/dashboardBloc.dart';
import 'package:water_metering/config.dart';
import 'package:water_metering/main.dart';
import 'package:water_metering/theme/size_extension.dart';
import 'package:water_metering/theme/theme.dart';
import 'package:water_metering/utils/biometric.dart';
import 'package:water_metering/utils/functions.dart';
import 'package:water_metering/widgets/alerts/alert.dart';
import 'package:water_metering/widgets/appbar/appbar.dart';
import 'package:water_metering/widgets/buttons/custom_button.dart';
import 'package:water_metering/widgets/loader/loader.dart';
import 'package:water_metering/widgets/text/chamfered_textwidget.dart';
import 'package:water_metering/widgets/textfield/custom_textfield.dart';
import 'package:water_metering/widgets/textfield/password_textfield.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  void _showEmailConfirmationDialog(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      // Prevents the dialog from being dismissed by tapping outside
      builder: (BuildContext dialogContext) {
        return AutoLogin(email: emailBiometricSaved!);
      },
    );
  }

  bool isLargerTextField = ConfigurationCustom.isLargerTextField;

  TextEditingController emailController = TextEditingController();

  var passwordControllerObscure = ObscuringTextEditingController();

  bool openForgotPasswordButtons = false;
  double scale = 1.2;

  String getPassword() {
    return passwordControllerObscure.getText();
  }

  @override
  void initState() {
    super.initState();
  }

  String? emailBiometricSaved;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Padding(
              padding: EdgeInsets.only(left: 35.w, right: 35.w),
              child: CustomTextField(
                key: UniqueKey(),
                controller: emailController,
                iconPath: 'assets/icons/mail.svg',
                hintText: 'Enter Email',
                keyboardType: TextInputType.emailAddress,
              )),
          Visibility(
            visible: openForgotPasswordButtons,
            child: Padding(
              padding: EdgeInsets.only(left: 35.w, right: 35.w),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Forgot Password?",
                          style: GoogleFonts.roboto(
                              fontSize: ThemeNotifier.medium.minSp,
                              fontWeight: FontWeight.w500,
                              color: CommonColors.red),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomButton(
                        width: 130.w,
                        text: "CANCEL",
                        isRed: true,
                        onPressed: () {
                          setState(() {
                            openForgotPasswordButtons = false;
                          });
                        },
                      ),
                      CustomButton(
                        width: 130.w,
                        text: "SEND EMAIL",
                        onPressed: () async {
                          LoaderUtility.showLoader(
                                  context,
                                  LoginPostRequests.forgotPassword(
                                      emailController.text))
                              .then((s) {
                            CustomAlert.showCustomScaffoldMessenger(
                                context,
                                "Temporary password sent to your email",
                                AlertType.info);

                            setState(() {
                              openForgotPasswordButtons = false;
                            });
                          }).catchError((e) {
                            CustomAlert.showCustomScaffoldMessenger(
                                context, e.toString(), AlertType.error);
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          LayoutBuilder(builder: (context, constraints) {
            return Visibility(
              visible: !openForgotPasswordButtons,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Padding(
                          padding: EdgeInsets.only(
                              left: 35.w, right: 35.w, top: 22.h),
                          child: PasswordTextField(
                            controller: passwordControllerObscure,
                          )),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          // color: Colors.green,
                          child: Padding(
                            padding: EdgeInsets.only(right: 35.w, top: 25.h),
                            child: GestureDetector(
                              onTap: () async {
                                if (emailController.text.isNotEmpty) {
                                  final bool emailValid =
                                      MiscellaneousFunctions.isEmailValid(
                                          emailController.text);
                                  if (emailValid == false) {
                                    CustomAlert.showCustomScaffoldMessenger(
                                        context,
                                        "Please enter a valid email",
                                        AlertType.warning);
                                    return;
                                  } else {
                                    setState(() {
                                      openForgotPasswordButtons = true;
                                    });
                                  }
                                } else {
                                  CustomAlert.showCustomScaffoldMessenger(
                                      context,
                                      "Please enter an email",
                                      AlertType.warning);
                                }
                              },
                              child: Text(
                                "Forgot Password?",
                                style: GoogleFonts.roboto(
                                    fontSize: ThemeNotifier.medium.minSp,
                                    decoration: TextDecoration.underline,
                                    decorationColor: CommonColors.red,
                                    fontWeight: FontWeight.w500,
                                    color: CommonColors.red),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(height: 40.h),
                      Center(
                        child: CustomButton(
                          text: "SIGN IN",
                          // fontSize: 16,
                          // width: 147.64.w,
                          // height: 58.h,
                          onPressed: () async {
                            FocusScope.of(context).unfocus();
                            if (ConfigurationCustom.skipAnyAuths == false) {
                              if (emailController.text.isEmpty ||
                                  getPassword().isEmpty) {
                                CustomAlert.showCustomScaffoldMessenger(
                                    context,
                                    "Please Enter Email and Password",
                                    AlertType.warning);
                                return;
                              }
                              final bool emailValid =
                                  MiscellaneousFunctions.isEmailValid(
                                      emailController.text);
                              if (emailValid == false) {
                                CustomAlert.showCustomScaffoldMessenger(
                                    context,
                                    "Please enter a valid email",
                                    AlertType.warning);
                                return;
                              }
                            }
                            LoaderUtility.showLoader(
                              context,
                              LoginPostRequests.login(
                                emailController.text,
                                getPassword(),
                              ),
                            ).then((twoFacRefCode) async {
                              // The loader has been dismissed at this point
                              // Handle the login result here
                              if (twoFacRefCode != null) {
                                CustomAlert.showCustomScaffoldMessenger(
                                    context,
                                    "Please enter the code sent to your authenticator app/sms",
                                    AlertType.info);

                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => EnterTwoFacCode(
                                          referenceCode: twoFacRefCode!,
                                        )));
                                // Login successful, proceed further
                              } else {
                                CustomAlert.showCustomScaffoldMessenger(
                                    context,
                                    "Successfully logged in!",
                                    AlertType.success);

                                LoginPostRequests.isLoggedIn = true;

                                // Preload user info before navigating to dashboard
                                final dashboardBloc = BlocProvider.of<DashboardBloc>(context, listen: false);
                                await dashboardBloc.initUserInfo();

                                Navigator.of(context).pushNamedAndRemoveUntil(
                                    "/", (route) => false);
                              }
                            }).catchError((error) {
                              CustomAlert.showCustomScaffoldMessenger(
                                  context, error.toString(), AlertType.error);
                            });
                          },
                        ),
                      ),
                      Container(height: 40.h),
                    ],
                  ),
                  // Container(height: 70.h),
                  // ((emailBiometricSaved == null) ||
                  //         (emailBiometricSaved!.isEmpty))
                  //     ? Container()
                  Column(
                    children: [
                      Material(
                        //make the splash blue color
                        color: Colors.transparent,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.transparent),
                            shadowColor:
                                MaterialStateProperty.all(Colors.transparent),
                            elevation: MaterialStateProperty.all(0),
                            overlayColor:
                                MaterialStateProperty.resolveWith<Color?>(
                              (Set<MaterialState> states) {
                                if (states.contains(MaterialState.pressed)) {
                                  return CommonColors.blue
                                      .withOpacity(0.25); // Custom splash color
                                }
                                return null; // Default splash color
                              },
                            ),
                          ),
                          onPressed: () async {
                            emailBiometricSaved =
                                await BiometricHelper.isBiometricEnabled();
                            if (emailBiometricSaved == null ||
                                emailBiometricSaved!.isEmpty) {
                              CustomAlert.showCustomScaffoldMessenger(
                                  context,
                                  "No biometric data saved. Please enable in the profile section on login",
                                  AlertType.warning);
                              return;
                            }
                            _showEmailConfirmationDialog(context);
                          },
                          child: Column(
                            children: [
                              Icon(
                                Icons.fingerprint,
                                size: 70.minSp,
                                color: Provider.of<ThemeNotifier>(context)
                                    .currentTheme
                                    .basicAdvanceTextColor,
                              ),
                              Text(
                                "LOGIN WITH BIOMETRICS",
                                style: GoogleFonts.robotoMono(
                                  decoration: TextDecoration.underline,
                                  decorationColor:
                                      Provider.of<ThemeNotifier>(context)
                                          .currentTheme
                                          .basicAdvanceTextColor,
                                  fontSize: ThemeNotifier.small.minSp,
                                  color: Provider.of<ThemeNotifier>(context)
                                      .currentTheme
                                      .basicAdvanceTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                    ],
                  )
                ],
              ),
            );
          }),
          // SizedBox(height: 38.h),
        ],
      ),
    );
  }
}



class AutoLogin extends StatefulWidget {
  final String email;

  const AutoLogin({super.key, required this.email});

  @override
  State<AutoLogin> createState() => _AutoLoginState();
}

class _AutoLoginState extends State<AutoLogin> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0.0),
      ),
      backgroundColor:
          Provider.of<ThemeNotifier>(context).currentTheme.dialogBG,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color:
                Provider.of<ThemeNotifier>(context).currentTheme.gridLineColor,
            width: 3.minSp,
          ),
        ),
        width: 350.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ChamferedTextWidget2(
                  text: "  AUTO LOGIN  ",
                  borderColor: Provider.of<ThemeNotifier>(context)
                      .currentTheme
                      .gridLineColor,
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Provider.of<ThemeNotifier>(context)
                        .currentTheme
                        .gridLineColor,
                  ),
                  onPressed: () {
                    if (mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 20.h),
            Center(
              child: Text(
                "WELCOME BACK! \nLOGIN AS ${widget.email}?",
                textAlign: TextAlign.center,
                style: GoogleFonts.robotoMono(
                  color: Provider.of<ThemeNotifier>(context)
                      .currentTheme
                      .basicAdvanceTextColor,
                  fontSize: ThemeNotifier.small.minSp,
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomButton(
                  text: "NO",
                  isRed: true,
                  onPressed: () {
                    if (mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
                CustomButton(
                  text: "YES",
                  onPressed: () async {
                    // Initiating biometric authentication
                    BiometricHelper biometricHelper = BiometricHelper();

                    if (!await biometricHelper.isBiometricSetup()) {
                      CustomAlert.showCustomScaffoldMessenger(
                        context,
                        "Biometric authentication not available. Please enable biometrics on your device first.",
                        AlertType.error,
                      );
                      Navigator.of(context).pop();
                      return;
                    }

                    bool isCorrectBiometric =
                        await biometricHelper.isCorrectBiometric();

                    if (!isCorrectBiometric) {
                      CustomAlert.showCustomScaffoldMessenger(
                        context,
                        "Biometric authentication failed",
                        AlertType.error,
                      );
                      Navigator.of(context).pop();
                      return;
                    }

                    // Assuming successful biometric authentication
                    String password = await biometricHelper.getPassword();
                    LoaderUtility.showLoader(
                      context,
                      LoginPostRequests.login(widget.email, password),
                    ).then((twoFacRefCode) async {
                      print("Hey");
                      print(twoFacRefCode);
                      if (twoFacRefCode != null) {
                        // CustomAlert.showCustomScaffoldMessenger(
                        //   context,
                        //   "Please enter the code sent to your authenticator app/sms",
                        //   AlertType.info,
                        // );//TODO: Show Alert after page rendering with context (Throws error )
                        Navigator.of(mainNavigatorKey.currentContext!).push(
                          MaterialPageRoute(
                            builder: (context) => EnterTwoFacCode(
                              referenceCode: twoFacRefCode!,
                            ),
                          ),
                        );
                        Navigator.of(context).pop();
                      } else {
                        LoginPostRequests.isLoggedIn = true;

                        // Preload user info before navigating to dashboard
                        final dashboardBloc = BlocProvider.of<DashboardBloc>(context, listen: false);
                        await dashboardBloc.initUserInfo();

                        Navigator.of(mainNavigatorKey.currentContext!)
                            .pushNamedAndRemoveUntil("/", (route) => false);
                        Navigator.of(context).pop();
                      }
                    }).catchError((error) {
                      print(error);
                      CustomAlert.showCustomScaffoldMessenger(
                          mainNavigatorKey.currentContext!,
                          error.toString(),
                          AlertType.error);
                      Navigator.of(context).pop();
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}







class EnterTwoFacCode extends StatefulWidget {
  EnterTwoFacCode({super.key, required this.referenceCode});

  String referenceCode;

  @override
  State<EnterTwoFacCode> createState() => _EnterTwoFacCodeState();
}

class _EnterTwoFacCodeState extends State<EnterTwoFacCode> with CodeAutoFill {
  TextEditingController otpFieldController = TextEditingController();

  printdevicehash() async {
    String a = await SmsAutoFill().getAppSignature;
    print("Getting my device code: $a. ");
  }

  @override
  void initState() {
    printdevicehash();
    listenForCode();

    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
    // SystemChrome.setPreferredOrientations(
    //     [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor:
              Provider.of<ThemeNotifier>(context).currentTheme.bgColor,
          appBar: CustomAppBar(choiceAction: null),
          body: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  Container(
                    height: 3.h,
                    color: CommonColors.blue,
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back,
                                color: Provider.of<ThemeNotifier>(context)
                                    .currentTheme
                                    .basicAdvanceTextColor),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            "TWO-FACTOR AUTHENTICATION",
                            style: GoogleFonts.robotoMono(
                              color: Provider.of<ThemeNotifier>(context)
                                  .currentTheme
                                  .basicAdvanceTextColor,
                              fontSize: ThemeNotifier.large.minSp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(height: 40.h),
                        SvgPicture.asset(
                          'assets/images/2falogo.svg',
                          width: min(width / 2.5, height / 2.5),
                          color: CommonColors.blue,
                        ),
                        SizedBox(height: 40.h),
                        Text(
                          "PLEASE ENTER THE CODE SENT TO YOUR\nAUTHENTICATOR APP/SMS",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.robotoMono(
                            color: Provider.of<ThemeNotifier>(context)
                                .currentTheme
                                .basicAdvanceTextColor,
                            fontSize: ThemeNotifier.small.minSp,
                          ),
                        ),
                        SizedBox(height: 25.h),
                        PinCodeTextField(
                          // key: UniqueKey(),
                          length: 6,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                          ],
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          cursorColor: Provider.of<ThemeNotifier>(context)
                              .currentTheme
                              .basicAdvanceTextColor,
                          obscureText: false,
                          animationType: AnimationType.fade,
                          textStyle: GoogleFonts.roboto(
                            color: Provider.of<ThemeNotifier>(context)
                                .currentTheme
                                .basicAdvanceTextColor,
                            fontSize: ThemeNotifier.medium.minSp,
                            fontWeight: FontWeight.w400,
                          ),
                          pinTheme: PinTheme(
                            shape: PinCodeFieldShape.underline,
                            borderRadius: BorderRadius.circular(5),
                            fieldHeight: 50.h,
                            fieldWidth: 40.w,

                            activeFillColor: Provider.of<ThemeNotifier>(context)
                                .currentTheme
                                .basicAdvanceTextColor,
                            activeColor: CommonColors.blue,
                            selectedColor: CommonColors.blue,
                            inactiveColor: Provider.of<ThemeNotifier>(context)
                                .currentTheme
                                .basicAdvanceTextColor,
                            // inactiveColor: Theme.of(context).drawerTheme.backgroundColor,
                            selectedFillColor:
                                Provider.of<ThemeNotifier>(context)
                                    .currentTheme
                                    .bgColor,
                          ),
                          animationDuration: const Duration(milliseconds: 300),
                          backgroundColor: Provider.of<ThemeNotifier>(context)
                              .currentTheme
                              .bgColor,
                          controller: otpFieldController,
                          enablePinAutofill: true,
                          onCompleted: (v) {
                            if (kDebugMode) {
                              print("Completed");
                            }
                          },
                          beforeTextPaste: (text) {
                            //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                            //but you can show anything you want here, like your pop up saying wrong paste format or etc
                            return true;
                          },
                          appContext: context,
                          onChanged: (String value) {},
                        ),
                        SizedBox(height: 40.h),
                        SizedBox(
                          // width: double.infinity,
                          child: CustomButton(
                            text: "VERIFY",
                            onPressed: () async {
                              if (otpFieldController.text.length == 6) {
                                LoaderUtility.showLoader(
                                        context,
                                        LoginPostRequests.sendTwoFactorCode(
                                            widget.referenceCode,
                                            otpFieldController.text))
                                    .then((a) {
                                  CustomAlert.showCustomScaffoldMessenger(
                                      context,
                                      "Successfully logged in! Redirecting to home page...",
                                      AlertType.success);
                                  LoginPostRequests.isLoggedIn = true;
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                      "/", (route) => false);
                                }).catchError((e) {
                                  CustomAlert.showCustomScaffoldMessenger(
                                      context, e.toString(), AlertType.error);
                                });
                              } else {
                                CustomAlert.showCustomScaffoldMessenger(
                                    context,
                                    "Please enter a valid code",
                                    AlertType.error);
                              }
                            },
                          ),
                        ),
                        SizedBox(height: 100.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void codeUpdated() {
    print("Code updated: $code");
    setState(() {
      if (code != null) {
        otpFieldController.text = code!;
      }
    });
  }

  @override
  void dispose() {
    cancel(); // Dispose the listener
    super.dispose();
  }
}