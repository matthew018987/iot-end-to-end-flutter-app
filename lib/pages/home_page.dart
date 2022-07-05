import 'package:flutter/material.dart';

import 'package:iot_app/pages/about_page.dart';
import 'package:iot_app/pages/settings_page.dart';

class DecoratedTabBar extends StatelessWidget implements PreferredSizeWidget {
  const DecoratedTabBar({required this.tabBar, required this.decoration, Key? key}): super(key: key);

  final TabBar tabBar;
  final BoxDecoration decoration;

  @override
  Size get preferredSize => tabBar.preferredSize;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: Container(decoration: decoration)),
        tabBar,
      ],
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}): super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver{


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        //print("app in resumed");
        break;
      case AppLifecycleState.inactive:
        //print("app in inactive");
        break;
      case AppLifecycleState.paused:
        //print("app in paused");
        break;
      case AppLifecycleState.detached:
        //print("app in detached");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {

    final dataPage = Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Data Page'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // TODO
        ]
      )
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: DefaultTabController(
        length: 3,
        child: Scaffold(
          bottomNavigationBar: const PreferredSize(
            preferredSize:  Size(200.0, 200.0),
            child: SizedBox(
              width: 200.0,
              child: TabBar(
                // move indicator to the top of the tab buttons
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(color: Colors.blue, width: 8.0),
                  insets: EdgeInsets.fromLTRB(70.0, 0.0, 70.0, 54.0),
                ),
                unselectedLabelColor: Color(0xFFc9c9c9),
                tabs: [
                  SizedBox(
                    height: 60.0,
                    child: Tab(icon: Icon(Icons.show_chart, color: Colors.black54),),
                  ),
                  SizedBox(
                    height: 60.0,
                    child: Tab(icon: Icon(Icons.settings, color: Colors.black54),),
                  ),
                  SizedBox(
                    height: 60.0,
                    child: Tab(icon: Icon(Icons.perm_device_information, color: Colors.black54),),
                  ),
                ],
              ),
            ),
          ),
          body: TabBarView(
            children: [
              dataPage,
              SettingsPage(),
              const AboutPage()
            ]
          )
        )
      )
    );
  }
}