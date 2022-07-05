import 'package:flutter/material.dart';
import 'package:iot_app/main.dart';


class ForgotPasswordResetScreen extends StatefulWidget {
  final String email;
  const ForgotPasswordResetScreen(this.email, {Key? key}): super(key: key);

  @override
  _ForgotPasswordResetScreenState createState() => _ForgotPasswordResetScreenState();
}

class _ForgotPasswordResetScreenState extends State<ForgotPasswordResetScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String resetCode = '';
  String newPassword = '';
  bool passwordConfirmed = false;

  void submit(BuildContext context) async {
    _formKey.currentState?.save();

    List forgotPassword = await cloud.forgotPasswordSetNew(widget.email, resetCode, newPassword);
    // parse 2 variables from response
    bool success = forgotPassword[0];
    String message = forgotPassword[1];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: const Text("Password"),
          content: Text(message),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            TextButton(
              child: const Text("Ok"),
              onPressed: () async {
                Navigator.pop(context);
                if (success) {
                  // clear the reset code between attempts
                  resetCode = '';
                  Navigator.popUntil(context, (route) => route.isFirst);
                }
              }
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set New Password'),
        automaticallyImplyLeading: true,
        //`true` if you want Flutter to automatically add Back Button when needed,
        //or `false` if you want to force your own back button every where
        leading: IconButton(icon: const Icon(Icons.arrow_back),
          onPressed:() => Navigator.pop(context, ''),
        )
      ),
      body: Builder(
        builder: (BuildContext context) {
          return Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.email),
                  title: TextFormField(
                    decoration: const InputDecoration(
                        hintText: '', labelText: 'reset password code'),
                    keyboardType: TextInputType.number,
                    onSaved: (String? code) {
                      resetCode = code!;
                    },
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.lock),
                  title: TextFormField(
                    decoration: const InputDecoration(labelText: 'New Password'),
                    obscureText: true,
                    onSaved: (String? password) {
                      newPassword = password!;
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20.0),
                  width: screenSize.width,
                  margin: const EdgeInsets.only(top: 10.0),
                  child: ElevatedButton(
                    onPressed: () {
                      submit(context);
                    },
                    style: ElevatedButton.styleFrom(
                        primary: Colors.blue
                    ),
                    child: const Text(
                      'Submit',
                      style: TextStyle(color: Colors.white),
                    )
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20.0),
                  width: screenSize.width,
                  margin: const EdgeInsets.only(top: 10.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                        primary: Colors.blue
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white),
                    )
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}