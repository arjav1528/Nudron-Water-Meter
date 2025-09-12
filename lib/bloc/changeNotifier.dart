import 'package:flutter/cupertino.dart';
import 'package:water_metering/api/auth.dart';


class NudronRandomStuff {
  static ValueNotifier<bool> isAuthEnabled = ValueNotifier<bool>(false);
  static ValueNotifier<bool> isBiometricEnabled = ValueNotifier<bool>(false);
  static ValueNotifier<String> dropDownValueForSortBy = ValueNotifier("Dues");
  static ValueNotifier<bool> isSignIn = ValueNotifier(true);

  static Future<void> logout() async {
    // try {
      await LoginPostRequests.logout();
    // } catch (e) {
    //   print(e);
    // }
  }
}
