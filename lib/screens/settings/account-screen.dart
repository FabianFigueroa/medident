// account-screen.dart - Account screen (responsive wrapper)
import 'package:flutter/material.dart';
import 'package:medident/screens/settings/account-mobile.dart';

class AccountScreen extends StatelessWidget {
  final String uid;

  const AccountScreen({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return AccountScreenMobile(uid: uid);
  }
}
