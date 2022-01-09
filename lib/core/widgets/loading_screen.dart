import 'package:animely/core/models/network_return_result.dart';
import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  final Future<NetworkResult> f;
  const LoadingScreen({Key? key, required this.f}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.4),
      body: FutureBuilder<NetworkResult>(
        future: f,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            Future.delayed(Duration.zero)
                .then((value) => Navigator.of(context).pop(snapshot.data!));
            return const SizedBox();
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

// class LoadingScreen extends StatelessWidget {
//   final Future f;
//   const LoadingScreen({Key? key, required this.f}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black.withOpacity(0.4),
//       body: FutureBuilder(
//         future: f,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.done) {
//             Navigator.of(context).pop(snapshot.data);
//             return const SizedBox();
//           } else {
//             return const Center(
//               child: CircularProgressIndicator(),
//             );
//           }
//         },
//       ),
//     );
//   }
// }
