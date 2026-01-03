import 'package:flutter/material.dart';
import 'package:shop_app/core/utils/components.dart';
import 'package:shop_app/feature/auth/presentation/widgets/signUpBody.dart';
class Signupview extends StatelessWidget {
  const Signupview({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: defaultAppBar(
        context: context,
        title: "Sign Up",
        isShowActions: false,
      ),
      body: SignUpPage(),
    );
  }
}
