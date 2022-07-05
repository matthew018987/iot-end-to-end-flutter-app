import 'package:flutter/material.dart';
import 'package:iot_app/main.dart';
import 'package:iot_app/pages/login_page.dart';
import 'package:iot_app/pages/dialogs.dart';


class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}): super(key: key);

  @override
  SettingsPageClass createState() => SettingsPageClass();
}

enum ConfirmAction { cancel, accept }

class SettingsPageClass extends State<SettingsPage>
{

  //****************************************************************************
  //
  //  Function & Widget for managing change password functions
  //
  //****************************************************************************

  final oldPassword = TextEditingController();
  final newPassword = TextEditingController();

  _changePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: SizedBox(
            height: 250,
            width: 300,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ListTile(
                    leading: Icon(
                      Icons.lock_outline,
                      color: Colors.blue[500],
                    ),
                    title: TextFormField(
                      decoration: const InputDecoration(labelText: 'current password'),
                      obscureText: true,
                      controller: oldPassword,
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.lock),
                    title: TextFormField(
                      decoration: const InputDecoration(labelText: 'new password'),
                      obscureText: true,
                      controller: newPassword,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      TextButton(
                        child: const Text('CANCEL'),
                        onPressed: () {
                          oldPassword.text = "";
                          newPassword.text = "";
                          Navigator.pop(context);
                        }),
                      TextButton(
                        child: const Text('OK'),
                        onPressed: () async {
                          List result = await cloud.changePassword(
                              oldPassword.text, newPassword.text);
                          oldPassword.text = "";
                          newPassword.text = "";
                          Navigator.pop(context);

                          bool success = result[0];
                          String message = result[1];
                          if (success) {
                            showNotificationAndClose(context, 'Change password successful');
                          } else {
                            showNotification(context, message);
                          }
                        }
                      )
                    ]
                  )
                ],
              ),
            ),
          ),
        );
      }
    );
  }

  Widget changePasswordLogoutWidget() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: ButtonBar(
            alignment: MainAxisAlignment.center,
            children: <Widget>[
              TextButton(
                child: Text('Change Password', semanticsLabel: 'Remove', style: TextStyle(color: Colors.amber.shade500)),
                onPressed: () {
                  _changePasswordDialog(context);
                },
              ),
            ],
          )
        ),
        Expanded(
          child: ButtonBar(
            alignment: MainAxisAlignment.center,
            children: <Widget>[
              TextButton(
                child: Text('Logout', semanticsLabel: 'Remove', style: TextStyle(color: Colors.amber.shade500)),
                //textColor: Colors.amber.shade500,
                onPressed: () {
                  cloud.signOut();
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute<void>(builder: (BuildContext context) => const LoginScreen()), (Route<dynamic> route) => false);
                },
              ),
            ],
          ),
        )
      ]
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        child: Column(children: <Widget>[
          const ListTile(
            title: Text('IoT device settings page',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Feature not yet implemented',
              textAlign: TextAlign.center,
            ),
          ),
          const Divider(),
          Container(
            child: Column(
              children: <Widget> [
                changePasswordLogoutWidget()
              ]
            )
          )
        ])
      )
    );
  }
}
