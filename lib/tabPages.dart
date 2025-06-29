import 'package:untitled/CartPage.dart';
import 'package:untitled/homepage.dart';
import 'package:untitled/profilePage.dart';
import 'package:flutter/material.dart';
import 'package:liquid_swipe/liquid_swipe.dart';
import 'package:untitled/settingpage.dart';

import 'Register/checkoutpage.dart';


class Mainpage extends StatefulWidget {
  const Mainpage({super.key});

  @override
  State<Mainpage> createState() => _MainpageState();
}

class _MainpageState extends State<Mainpage> {
  int _currentIndex = 0;
  late LiquidController _liquidController;

  @override
  void initState() {

    _liquidController = LiquidController();
    super.initState();
  }

  final List<Widget> pages = [

    Homepage(),
    CheckoutPage(),
    Settingpage(),
    Profilepage(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _liquidController.animateToPage(page: index, duration: 700);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: LiquidSwipe(
          pages: pages,
          enableLoop: false,
          positionSlideIcon:0.5 ,
          waveType: WaveType.liquidReveal,
          slideIconWidget:  Icon(Icons.back_hand),
          liquidController: _liquidController,
          onPageChangeCallback: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          selectedItemColor: Colors.red,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: "Cart"),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), label: "Profile"),
          ],
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }

  @override
  void dispose() {
    // _liquidController.dispose();
    super.dispose();
  }
}