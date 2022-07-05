import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';


const String userManualURL = 'https://your_domain.com/support';

class AboutPage extends StatefulWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String _version = '';

  _AboutPageState() {
    getAppVersionNumber().then((val) => setState(() {
      _version = val;
    }));
  }

  Future<String> getAppVersionNumber() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String versionName = packageInfo.version;
    return versionName;
  }

  Future<void> _launchInBrowser(String url) async {
    if (!await launch(
      url,
      forceSafariVC: false,
      forceWebView: false,
      headers: <String, String>{'my_header_key': 'my_header_value'},
    )) {
      throw 'Could not launch $url';
    }
  }

  void showLicensePage({
    required BuildContext context,
    required String applicationName,
    required String applicationVersion,
    Widget? applicationIcon,
    String? applicationLegalese,
    bool useRootNavigator = false,
  }) {
    Navigator.push(context,
        MaterialPageRoute<void>(
            builder: (
                BuildContext context
                ) => LicensePage(
                       applicationName: applicationName,
                       applicationVersion: applicationVersion,
                       applicationIcon: applicationIcon,
                       applicationLegalese: applicationLegalese,
                     ),
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Align(
            alignment: Alignment.topCenter,
            child: Card(
              child: Column(
                children: [
                  ListTile(
                    title: const Text('App Version:',
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    subtitle: Text(_version),
                    leading: Icon(
                      Icons.assignment,
                      color: Colors.blue[500],
                    ),
                  ),
                  ListTile(
                    title: Text('View Licenses', style: TextStyle(color: Colors.amber.shade500)),
                    leading: Icon(
                      Icons.assignment,
                      color: Colors.blue[500],
                    ),
                    onTap: () async {
                      String version = await getAppVersionNumber();
                      showLicensePage(context: context, applicationName: "IoT app", applicationVersion: version);
                    },
                  ),
                ]
              ),
            ),
          ),
        )
      ),
    );
  }
}