// import 'package:INSUL/presentation/screens/auth/setup_profile_screen.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';

// class CompleteProfileCard extends StatelessWidget {
//   const CompleteProfileCard({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.only(top: 12),
//       padding: const EdgeInsets.all(10),
//       decoration: BoxDecoration(
//         color: const Color.fromARGB(255, 237, 179, 7),
//         borderRadius: BorderRadius.circular(5),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 4,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           // Text Section
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: const [
//                 Text(
//                   'Complete your profile',
//                   style: TextStyle(
//                     color: Color.fromARGB(255, 26, 26, 26),
//                     fontSize: 15,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 SizedBox(height: 4),
//                 Text(
//                   'Complete your profile to unlock full features.',
//                   style: TextStyle(
//                     color: Color.fromARGB(255, 42, 42, 42),
//                     fontSize: 12,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Upgrade Button
//           InkWell(
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => SetupProfile()),
//               );
//             },
//             child: Icon(
//               CupertinoIcons.chevron_forward,
//               color: const Color.fromARGB(255, 38, 38, 38),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileCompleteCard extends StatelessWidget {

  const ProfileCompleteCard({Key? key,})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:  const Color.fromARGB(255, 83, 154, 254),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 82, 163, 255).withOpacity(0.3),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(CupertinoIcons.person_crop_circle_badge_exclam, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Complete your profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Complete your profile to unclock all app features',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.blueAccent,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
              textStyle:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            onPressed: () => context.go('/setupProfile'),
            child: const Text("Go"),
          ),
        ],
      ),
    );
  }
}
