import 'package:flutter/material.dart';
import 'package:shop_app/core/utils/components.dart';
import 'package:shop_app/feature/auth/presentation/widgets/SigninBody.dart';


class SigninView extends StatelessWidget {
  const SigninView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: defaultAppBar(
        context: context,
        title: "Sign In",

        isShowActions: false,
        automaticallyImplyLeading: false,
      ),
      body: SigninBodyWidget(),
    );
  }
}
