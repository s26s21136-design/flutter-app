import 'package:flutter/material.dart';
import '../screens/guide_screen.dart';
import '../screens/map_screen.dart';
import '../screens/news_screen.dart';
//import '../screens/profile_screen.dart';
import '../screens/rewards_screen.dart';
//import '../screens/login_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int currentIndex = 0;

  final List<Widget> pages = const [
    //LoginScreen(),
    //ProfileScreen(),
    MapScreen(),
    NewsScreen(),
    RewardsScreen(),
    GuideScreen(),
    
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.map),
            label: 'Bins',
          ),
          NavigationDestination(
            icon: Icon(Icons.newspaper),
            label: 'News',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events),
            label: 'Rewards',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book),
            label: 'Guide',
          ),
         /*  NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Profile',
          ), */
        ],
      ),
    );
  }
}