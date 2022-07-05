import 'package:flutter/material.dart';
import 'package:iot_app/main.dart';
import 'package:iot_app/pages/forgot_password_reset_page.dart';


class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}): super(key: key);

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late  String email;

  void submit(BuildContext context) async {
    _formKey.currentState?.save();

    String message = await cloud.forgotPassword(email);

    if (message.isNotEmpty) {
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
                  // clear the message dialog
                  Navigator.pop(context);
                  // load the next page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ForgotPasswordResetScreen(email)
                    )
                  );
                }
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // ListView(
                //   children: <Widget>[
                    ListTile(
                      leading: const Icon(Icons.email),
                      title: TextFormField(
                        decoration: const InputDecoration(
                            hintText: 'example@gmail.com', labelText: 'Email'),
                        keyboardType: TextInputType.emailAddress,
                        onSaved: (String? email) {
                          this.email = email!;
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
                        child: const Text('Submit', style: TextStyle(color: Colors.white))
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