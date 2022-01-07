import 'package:animely/core/models/network_return_result.dart';
import 'package:animely/core/widgets/loading_screen.dart';
import 'package:flutter/material.dart';

Future<NetworkResult> loading(
    BuildContext context, Future<NetworkResult> f) async {
  return await Navigator.of(context).push(PageRouteBuilder(
    opaque: false,
    pageBuilder: (context, animation, secondaryAnimation) {
      return LoadingScreen(f: f);
    },
  ));
}
// dynamic loading(BuildContext context, Future f) async {
//   return await Navigator.of(context).push(PageRouteBuilder(
//     opaque: false,
//     pageBuilder: (context, animation, secondaryAnimation) {
//       return LoadingScreen(f: f);
//     },
//   ));
// }
