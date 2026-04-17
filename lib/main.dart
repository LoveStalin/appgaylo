import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Truyện Huyền Thoại",
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
        title: const Text("Truyện Huyền Thoại"),
        centerTitle: true,
        backgroundColor: Colors.pink[100], // hồng pastel
      ),

      body: pages[currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,

        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },

        backgroundColor: Colors.pink[100], // hồng pastel

        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.grey,

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Trang chủ"),

          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Thư viện"),

          BottomNavigationBarItem(
            icon: Icon(Icons.create),
            label: "Viết truyện",
          ),

          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Tài khoản"),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // thanh tìm kiếm
        TextField(
          decoration: InputDecoration(
            hintText: "Tìm truyện...",
            prefixIcon: Icon(Icons.search),
            filled: true,
            fillColor: Colors.pink[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
          ),
        ),

        const SizedBox(height: 20),

        const Text(
          "🔥 Truyện nổi bật",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 10),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [StoryCard(), StoryCard(), StoryCard()],
        ),

        const SizedBox(height: 20),

        const Text(
          "📚 Truyện mới",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 10),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [StoryCard(), StoryCard(), StoryCard()],
        ),
      ],
    );
  }
}

class StoryCard extends StatelessWidget {
  const StoryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 140,
          decoration: BoxDecoration(
            color: Colors.pink[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.book, size: 40),
        ),

        const SizedBox(height: 5),

        const Text("Tên truyện", overflow: TextOverflow.ellipsis),
      ],
    );
  }
}

//Account Screen
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          SizedBox(height: 40),

          Text(
            "Đăng nhập Truyện Huyền Thoại",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          SizedBox(height: 40),

          ElevatedButton(onPressed: () {}, child: Text("Đăng nhập với Google")),

          ElevatedButton(
            onPressed: () {},
            child: Text("Đăng nhập với Facebook"),
          ),

          ElevatedButton(onPressed: () {}, child: Text("Đăng nhập với Apple")),

          SizedBox(height: 20),

          TextButton(
            onPressed: () {},
            child: Text("Đăng ký tài khoản Huyền Thoại"),
          ),
        ],
      ),
    );
  }
}
