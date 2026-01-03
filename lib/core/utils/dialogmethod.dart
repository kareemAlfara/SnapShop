
import 'package:flutter/material.dart';

class dialogmethod {
  static Future<void> Showdialogfunction(context,
      {required String subtilte,
      bool iserror = false,
      required Function fct}) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              "Users assets/assets/images/warning.png",
              width: 60,
              height: 60,
            ),
            const SizedBox(
              height: 12,
            ),
            Text(subtilte),
            const SizedBox(
              height: 12,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Visibility(
                  visible: iserror,
                  child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Cancel",
                        style: TextStyle(fontSize: 18),
                      )),
                ),
                TextButton(
                    onPressed: () {
                      fct();
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "ok",
                      style: TextStyle(fontSize: 22, color: Colors.red),
                    )),
              ],
            )
          ],
        ),
      ),
    );
  }

  static Future<void> imagePickerDialog(
    context, {
    required Function galleryFun,
    required Function cameraFun,
    required Function RemoveFun,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
          title: const Center(
            child: Text("Choose option"),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                TextButton.icon(
                    onPressed: () {
                      cameraFun();
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                    icon: const Icon(Icons.camera),
                    label: const Text("camera")),
                TextButton.icon(
                    onPressed: () {
                      galleryFun();
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                    icon: const Icon(Icons.image),
                    label: const Text("Gallery")),
                TextButton.icon(
                    onPressed: () {
                      RemoveFun();
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                    icon: const Icon(Icons.remove),
                    label: const Text("remove")),
              ],
            ),
          )),
    );
  }
}
