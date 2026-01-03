// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:shop_app/feature/auth/presentation/cubit/signup_cubit/signup_cubit.dart';


// class registerImage extends StatelessWidget {
//   const registerImage({
//     super.key,
//     required this.cubit,
//   });

//   final SignupCubit cubit;

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Center(
//         child: Stack(
//           alignment: Alignment.topRight,
//           children: [
//             CircleAvatar(
//               radius: 80,
//               backgroundImage: NetworkImage( 
//                 cubit.imageUrl ??
//                     "https://i.pinimg.com/736x/c0/74/9b/c0749b7cc401421662ae901ec8f9f660.jpg",
//               ),
//             ),
//       Positioned(
//       right: 11,
//       top: 11,
//         child:   IconButton(
//               onPressed: () async {
//                 await cubit.pickAndSendImage(
//                   source: ImageSource.gallery,
//                 );
//               },
//               icon: Icon(
//                 Icons.photo_camera,
//                 color: Colors.blueAccent,
//                 size: 33,
//               ),
//             ),)
          
//           ],
//         ),
//       ),
//     );
//   }
// }
