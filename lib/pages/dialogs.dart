import 'dart:async';
import 'package:flutter/material.dart';


void showNotification(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(message)
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Ok'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

Timer? _timer;

// Dialog with message, no buttons for user to press
// this will close after 2 seconds
//  or when the program pops the context
void showNotificationAndClose(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      _timer = Timer(const Duration(seconds: 2), () {
        Navigator.of(context).pop();
      });

      return AlertDialog(
        backgroundColor: Colors.white,
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(message)
            ],
          ),
        ),
      );
    }
  ).then((val){
    if (_timer!.isActive) {
      _timer?.cancel();
    }
  });
}