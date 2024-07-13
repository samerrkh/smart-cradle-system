import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';
import 'monitoring_options_screen.dart';
import 'settings_screen.dart';
import 'notifications_screen.dart';
import 'package:badges/badges.dart' as badges;
import 'gas_sensor_provider.dart';

class MainScreen extends StatefulWidget {
  final int notificationCount;

  const MainScreen({Key? key, required this.notificationCount}) : super(key: key);

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(initialNotificationCount: widget.notificationCount),
      const MonitoringOptionsScreen(),
      const SettingsScreen(),
      const NotificationsScreen(),
    ];
    _pageController.addListener(() {
      if (_pageController.page?.round() != _currentIndex) {
        setState(() {
          _currentIndex = _pageController.page!.round();
        });
      }
    });
  }

  void _onItemTapped(int index) {
    _pageController.jumpToPage(index); // Use jumpToPage for instant changes
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gasSensorProvider = Provider.of<GasSensorProvider>(context);
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Icon(Icons.home, size: 30),
            ),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Icon(Icons.monitor, size: 30),
            ),
            label: 'Monitoring',
          ),
          const BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Icon(Icons.settings, size: 30),
            ),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: badges.Badge(
              badgeContent: gasSensorProvider.notificationCount > 0
                  ? Text('${gasSensorProvider.notificationCount}', style: const TextStyle(color: Colors.white))
                  : null,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Icon(Icons.notifications, size: 30),
              ),
            ),
            label: 'Notifications',
          ),
        ],
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        fixedColor: Color.alphaBlend(const Color.fromARGB(221, 8, 0, 119), const Color.fromARGB(8, 10, 3, 189)),
      ),
    );
  }
}
