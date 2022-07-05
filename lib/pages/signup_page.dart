import 'package:flutter/material.dart';
import 'package:iot_app/main.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}): super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? email;
  String? firstname;
  String? lastname;
  String? password;

  void showMessageToUser(String message, bool signUpSuccess) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sign Up'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text("Ok"),
              onPressed: () {
                if (signUpSuccess) {
                  Navigator.popUntil(context, (route) => route.isFirst);
                }
              },
            ),
          ],
        );
      },
    );
  }

  void submit(BuildContext context) async {
    _formKey.currentState?.save();

    final List signup = await cloud.signUp(email!, password!, firstname!, lastname!);
    // parse 2 variables from response
    bool signUpSuccess = signup[0];
    String message = signup[1];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Sign Up"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
                child: const Text("Ok"),
                onPressed: () async {
                  Navigator.pop(context);
                  if (signUpSuccess) {
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
        title: const Text('Sign Up'),
      ),
      body: Builder(
        builder: (BuildContext context) {
          return Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                ListTile(
                  title: TextFormField(
                    decoration: const InputDecoration(
                        hintText: 'example@gmail.com', labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    onSaved: (String? email) {
                      this.email = email;
                    },
                  ),
                ),
                ListTile(
                  title: TextFormField(
                    decoration: const InputDecoration(
                      hintText: '', labelText: 'Password',
                    ),
                    obscureText: true,
                    onSaved: (String? password) {
                      this.password = password;
                    },
                  ),
                ),
                ListTile(
                  title: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'First Name',
                    ),
                    onSaved: (String? name) {
                      firstname = name;
                    },
                  ),
                ),
                ListTile(
                  title: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Last Name',
                    ),
                    onSaved: (String? name) {
                      lastname = name;
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
                      'Sign Up',
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