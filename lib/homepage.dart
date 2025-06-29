import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled/Productpage/ProductPage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Homepage extends StatefulWidget {
  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<String> images = [
    'https://www.w3schools.com/css/img_5terre.jpg',
    'https://www.w3schools.com/css/img_forest.jpg',
    'https://www.w3schools.com/css/img_lights.jpg',
  ];

  String name = "";

  void getData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      name = preferences.getString("username") ?? "Guest";
    });
  }

  Future<void> addToCart(Map<String, dynamic> product) async {
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to add to cart')),
      );
      return;
    }

    final cartRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .doc(product['name']);

    final existing = await cartRef.get();

    if (existing.exists) {
      final currentQty = existing.data()?['qty'] ?? 1;
      await cartRef.update({'qty': currentQty + 1});
    } else {
      await cartRef.set({
        'name': product['name'],
        'price': product['price'],
        'image': product['image'],
        'qty': 1,
        'isCheckout': false,
        'isDelivered': false,
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Added to cart!')),
    );
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(name),
        ),
        drawer: Drawer(
          backgroundColor: Colors.white,
          child: Column(
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(color: Colors.indigo),
                child: Center(
                  child: Stack(
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundImage:
                        AssetImage('assets/C-ic.jpg'),
                      ),
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Icon(Icons.camera_alt_outlined),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    ListTile(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      leading: Icon(Icons.home_rounded),
                      title: Text('Home'),
                    ),
                    ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  Productpage()),
                        );
                      },
                      leading: Icon(Icons.add_shopping_cart),
                      title: Text('Add product'),
                    ),
                    ListTile(
                      onTap: () {

                      },
                      leading: Icon(Icons.shopping_cart),
                      title: Text('My Cart'),
                    ),
                  ],
                ),
              ),
              const Divider(),
              ListTile(
                onTap: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                leading: Icon(Icons.logout),
                title: Text('Log Out'),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            CarouselSlider(
              options: CarouselOptions(
                height: 150,
                enlargeCenterPage: true,
                autoPlay: true,
                aspectRatio: 16 / 9,
                viewportFraction: 0.7,
              ),
              items: images.map((e) {
                return Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(image: NetworkImage(e), fit: BoxFit.cover),
                  ),
                );
              }).toList(),
            ),
            Expanded(
              child: SizedBox(
                width: 400,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('products').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(child: Text('Something went wrong'));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final docs = snapshot.data!.docs;

                    return GridView.builder(
                      padding: const EdgeInsets.all(10),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Productpage()));
                          },
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: data['image'] != null && data['image'] != ""
                                      ? Image.memory(
                                    base64Decode(data['image']),
                                    fit: BoxFit.cover,
                                  )
                                      : const Icon(Icons.image, size: 80),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(data['name'] ?? "No Name",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      Text("Price: Rs .${data['price'] ?? 'N/A'}"),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                  child: ElevatedButton(
                                    onPressed: () => addToCart(data),
                                    child: const Text('Add to Cart'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}