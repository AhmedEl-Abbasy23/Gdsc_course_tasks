import 'package:flutter/material.dart';

loadingDialog(BuildContext context, String status) {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(status),
          content: Container(
              height: 50, child: Center(child: CircularProgressIndicator())),
        );
      });
}