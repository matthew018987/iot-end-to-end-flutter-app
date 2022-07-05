import 'package:flutter/material.dart';
import 'package:iot_app/main.dart';
import 'package:iot_app/pages/home_page.dart';
import 'package:iot_app/pages/forgot_password_page.dart';
import 'package:iot_app/pages/signup_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? username;
  String? password;
  bool autologin = false;
  bool authenticated = false;
  bool initComplete = false;
  bool firstRefreshComplete = false;

  submit(BuildContext context) async {
    autologin = true;
    _formKey.currentState?.save();

    // do sign in process
    await cloud.signIn(username!, password!);
    if (cloud.checkAuthenticatedSync()) {
      // get all the latest data from the cloud, if there is any
      await device.init(cloud);
    }

    if (!cloud.checkAuthenticatedSync()) {
      authenticated = false;
      final snackBar = SnackBar(
        content: const Text('Invalid user name or password'),
        action: SnackBarAction(
          label: 'Check username & password',
          onPressed: () {},
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      authenticated = true;
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute<void>(builder: (BuildContext context) => const HomePage()), (Route<dynamic> route) => false);
    }
  }

  Future<void> initData(BuildContext context) async {
    if (!initComplete) {
      await Future.wait(
        [
          cloud.init(),
          device.init(cloud)
        ]
      );
    }
    initComplete = true;
    authenticated = cloud.checkAuthenticatedSync();
    autologin = true;
    return;
  }

  Widget homeWidget() {
    return FutureBuilder(
      future: initData(context),
      builder: (context, AsyncSnapshot snapshot) {
        if (autologin) {
          if (authenticated) {
            device.init(cloud);
            return HomePage();
          } else {
            final Size screenSize = MediaQuery
                .of(context)
                .size;
            return Scaffold(
              body: Builder(
                builder: (BuildContext context) {
                  return Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        ListTile(
                          leading: const Icon(Icons.email),
                          title: TextFormField(
                            initialValue: username, //widget.email,
                            decoration: const InputDecoration(
                                hintText: 'example@gmail.com',
                                labelText: 'Email'),
                            keyboardType: TextInputType.emailAddress,
                            onSaved: (String? email) {
                              setState(() {
                                username = email;
                              });
                            },
                          ),
                        ),
                        ListTile(
                          leading: const Icon(Icons.lock),
                          title: TextFormField(
                            decoration:
                            const InputDecoration(labelText: 'Password'),
                            obscureText: true,
                            onSaved: (String? pword) {
                              setState(() {
                                password = pword;
                              });
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
                                'Login',
                                style: TextStyle(color: Colors.white),
                              )
                          ),
                        ),
                        Center(
                          heightFactor: 3,
                          child: InkWell(
                            child: const Text(
                              'Sign up',
                              style: TextStyle(color: Colors.blueAccent),
                            ),
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute<void>(
                                      builder: (
                                          BuildContext context
                                          ) => const SignUpScreen()
                                  )
                              );
                            },
                          ),
                        ),
                        Center(
                          heightFactor: 3,
                          child: InkWell(
                            child: const Text(
                              'Forgot password',
                              style: TextStyle(color: Colors.blueAccent),
                            ),
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute<void>(
                                      builder: (
                                          BuildContext context
                                          ) => const ForgotPasswordScreen()
                                  )
                              );
                            },
                          ),
                        )
                      ]
                    ),
                  );
                },
              ),
            );
          }
        }
        return Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const <Widget>[
                SizedBox(
                  height: 150,
                  width: 350,
                  //padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: Text('Loading...', style: TextStyle(fontSize: 18))
                ),
              ]
            )
          )
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: homeWidget(),
    );
  }
}