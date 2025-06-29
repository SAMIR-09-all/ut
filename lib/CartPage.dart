import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled/Productpage/ProductPage.dart';
import 'cart_page.dart';
import 'dart:convert';
import 'package:khalti_flutter/khalti_flutter.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown,
        title: Text('My Cart',style: TextStyle(
            color: Colors.white60
        ),),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 500,
              width: 400,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('users').doc(_auth.currentUser!.uid).collection('cart').snapshots(),
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
                        onTap: (){
                          // Navigator.push(context, MaterialPageRoute(builder: (context)=>ProductDetailPage(product: data,)));
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
                                    Text('Quantity: ${data['qty']}'),
                                  ],
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
        
            SizedBox(height: 100),
        
            ElevatedButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => Productpage()));
            },
                child: Text("Check Out")),
        
            SizedBox(height: 10,),
        
            ElevatedButton(onPressed: (){
              KhaltiScope.of(context).pay(
                config: PaymentConfig(
                    amount: (100).toInt(),
                    productIdentity: 'shopping-items-',
                    productName: 'Shopping Items'
                ),
                preferences: [
                  PaymentPreference.khalti,
                  PaymentPreference.connectIPS,
                  PaymentPreference.eBanking,
                  PaymentPreference.mobileBanking,
                ],
                onSuccess: (success) async {
                  print("Payment Success: $success");
        
                  try {
                    // await sendOrderEmail(widget.selectedItems);
                    // await saveOrderToFirestore();
        
                    // await generateAndDownloadPDF();
        
                    if (mounted) {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Payment Successful'),
                            content: const Text('Your order has been placed successfully!'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
        
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  } catch (e) {
                    print("Error processing successful payment: $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Error processing your order. Please contact support.')),
                    );
                  } finally {
                    setState(() {
                    });
                  }
                },
                onFailure: (failure) {
                  print("Payment Failed: $failure");
                  setState(() {
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Payment failed. Please try again.')),
                  );
                },
              );
            },
                child: Text("Khalti")),
          ],
        ),
      ),
    );
  }
}