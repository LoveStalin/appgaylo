import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/account_screen.dart';
import '../l10n/localization.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int currentIndex = 0;

  final List<Widget> pages = const [
    HomeScreen(),
    Center(child: Text("Thư viện")),
    Center(child: Text("Viết truyện")),
    AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(L(context, 'app_title')),
        centerTitle: true,
        backgroundColor: Colors.pink[100],
      ),
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        backgroundColor: Colors.pink[100],
        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: L(context, 'home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.book),
            label: L(context, 'library'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.create),
            label: L(context, 'write'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: L(context, 'profile'),
          ),
        ],
      ),
    );
  }
}
