import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'monitoring_options_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _screens = [
    const HomeScreen(),
    const MonitoringOptionsScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Ensuring the PageController is listening for page changes
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
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Icon(Icons.home, size: 40),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Icon(Icons.monitor, size: 40),
            ),
            label: 'Monitoring',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Icon(Icons.settings, size: 40),
            ),
            label: 'Settings',
          ),
        ],
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        fixedColor: Color.alphaBlend(const Color.fromARGB(221, 8, 0, 119), const Color.fromARGB(8, 10, 3, 189)),
      ),
    );
  }
}
