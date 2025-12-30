// import 'package:flutter/material.dart';
// import 'package:shop_app/core/utils/components.dart';
// import 'package:shop_app/core/utils/custom_button.dart';
// import 'package:shop_app/feature/auth/data/auth_remote_data_source.dart';

// class NotificationView extends StatefulWidget {
//   const NotificationView({super.key});

//   @override
//   State<NotificationView> createState() => _NotificationViewState();
// }

// class _NotificationViewState extends State<NotificationView> {
//   final TextEditingController notificationTitleController =
//       TextEditingController();
//   final TextEditingController notificationBodyController =
//       TextEditingController();
//   final TextEditingController userIdController = TextEditingController();

//   bool isPrivate = false;

//   @override
//   void dispose() {
//     notificationTitleController.dispose();
//     notificationBodyController.dispose();
//     userIdController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Notifications"),
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 Switch(
//                     value: isPrivate,
//                     onChanged: (val) {
//                       setState(() {
//                         isPrivate = val;
//                       });
//                     }),
//                 const Text("Send private notification"),
//               ],
//             ),
//             if (isPrivate)
//               TextField(
//                 controller: userIdController,
//                 decoration: const InputDecoration(
//                   labelText: "User ID",
//                 ),
//               ),
//             TextField(
//               controller: notificationTitleController,
//               decoration: const InputDecoration(
//                 labelText: "Notification Title",
//               ),
//             ),
//             TextField(
//               controller: notificationBodyController,
//               decoration: const InputDecoration(
//                 labelText: "Notification Body",
//               ),
//             ),
//             const SizedBox(height: 20),
//             CustomButton(
//               text: isPrivate ? "Send Private" : "Send Global",
//               onPressed: () async {
//                 final title = notificationTitleController.text.trim();
//                 final body = notificationBodyController.text.trim();
//                 final receiverId =
//                     isPrivate ? userIdController.text.trim() : null;

//                 if (title.isEmpty || body.isEmpty) return;

//                 await AuthRemoteDataSource().sendOneSignalNotification(
//                   title: title,
//                   body: body,
//                   receiverId: receiverId,
//                 );

//                 notificationTitleController.clear();
//                 notificationBodyController.clear();
//                 userIdController.clear();
//               },
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shop_app/core/utils/components.dart';
import 'package:shop_app/core/utils/custom_button.dart';
import 'package:shop_app/feature/auth/data/auth_remote_data_source.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({super.key});

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  var notificationTitleController = TextEditingController();
  var notificationBodyController = TextEditingController();
  var userIdcontroller = TextEditingController();
  final List<List<Color>> bgColors = [
    [Colors.pink.shade500, Colors.orange.shade300],
  ];
  bool isUserNOTIFICATION = false;
  @override
  void initState() {
    super.initState();
  }

  void dispose() {
    notificationTitleController.dispose();
    notificationBodyController.dispose();
    userIdcontroller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        backgroundColor: Colors.pink.shade500,
        title: Text("Notifications", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: bgColors[0],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Switch(
                        value: isUserNOTIFICATION,
                        onChanged: (value) {
                          setState(() {
                            isUserNOTIFICATION = !isUserNOTIFICATION;
                          });
                          // cubit.changesaveAddress(value);
                        },
                      ),
                      SizedBox(width: 11),
                      defulttext(
                        context: context,
                        data: " Send private Notification",
                        // color: Colors.grey,
                        fSize: 18,
                        fw: FontWeight.w600,
                      ),
                    ],
                  ),
                ),
            
                SizedBox(height: 28),
                Visibility(
                  visible: isUserNOTIFICATION,
                  child: defulitTextFormField(
                    context: context,
                    controller: userIdcontroller,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "please inter the user id";
                      }
                      return null;
                    },
                    title: " user id",
                    textInputAction: TextInputAction.next,
                  ),
                ),
                SizedBox(height: 28),
                defulitTextFormField(
                  context: context,
                  controller: notificationTitleController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "please inter the notification Title";
                    }
                    return null;
                  },
                  title: " Notification Title",
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: 28),
                defulitTextFormField(
                  context: context,
                  controller: notificationBodyController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "please inter the notification body";
                    }
                    return null;
                  },
                  title: " notification body",
                  textInputAction: TextInputAction.next,
                ),
                 Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.notifications_active, size: 100, color: Colors.blue),
                const SizedBox(height: 20),
                const Text(
                  "OneSignal Test App",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
              onPressed: () async {
               await AuthRemoteDataSource().notifyUser(
                  userIdcontroller.text,
                  notificationTitleController.text,
                  notificationBodyController.text,
                );
                
              },
              child: Text("Send Private"),
            ),
            ElevatedButton(
              onPressed: () async {
                AuthRemoteDataSource().notifyAllUsers(
              notificationTitleController.text,
              notificationBodyController.text,
            );
            
                
              },
              child: Text("Send Global"),
            ),
                ElevatedButton(
                  onPressed: () async {
                    // Print current subscription info
                    final subId = OneSignal.User.pushSubscription.id;
                    final token = OneSignal.User.pushSubscription.token;
                    print("Current Subscription ID: $subId");
                    print("Current Token: $token");
                  },
                  child: const Text("Check Subscription"),
                ),
              ],
            ),
                    ),
                Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: CustomButton(
                    onPressed: () async {
                      // final receiverId =
                      //     "296f410b-c14c-44ba-b3c5-292c86d6ead0"; // 👈 not the current user
                      // isUserNOTIFICATION?
                      await AuthRemoteDataSource().notifyUser(
                        userIdcontroller.text,
                        notificationTitleController.text,
                        notificationBodyController.text,
                      );
                      // :
                      // await AuthRemoteDataSource().notifyAllUsers(
                      //   notificationTitleController.text,
                      //   notificationBodyController.text,
                      // );
                      notificationTitleController.clear();
                      notificationBodyController.clear();
                      userIdcontroller.clear();
                    },
                    text: isUserNOTIFICATION
                        ? " Send private Notification"
                        : "send  notification",
                    fSize: 18,
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