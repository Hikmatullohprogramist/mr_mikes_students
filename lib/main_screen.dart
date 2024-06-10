import 'package:flutter/material.dart';
import 'package:mr_mikes_students/screens/home_page.dart';
import 'package:mr_mikes_students/screens/store_screen/store_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentSelected = 0;
  List<Widget> pages = [
    const HomeScreen(),
    const StorePage(),
  ];

  onTap(int index) {
    currentSelected = index;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentSelected,
          onTap: onTap,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.line_axis),
              label: "Rating",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag),
              label: "Market",
            )
          ]),
      body: pages[currentSelected],
    );
  }
}
