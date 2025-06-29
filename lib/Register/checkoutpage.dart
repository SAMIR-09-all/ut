import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

enum PaymentMethod {  COD, khalti}


class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String currentAddress = '';
  double latitude = 0.0;
  double longitude = 0.0;

  Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    latitude = position.latitude;
    longitude = position.longitude;

    List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
    Placemark place = placemarks[0];
    setState(() {
      currentAddress = '${place.subLocality}, ${place.locality}, ${place.country}';
    });
  }

  PaymentMethod? selectedPaymentMethod;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  TextEditingController PhoneController = TextEditingController();
  TextEditingController AddressController= TextEditingController();
  TextEditingController EmailController= TextEditingController();

  onclickValidation() {
    if (PhoneController.text.isEmpty || AddressController.text.isEmpty ||
        EmailController.text.isEmpty)
    {
      Fluttertoast.showToast(msg: "Please Fill out all the Fields");
    }
    else  {
      Fluttertoast.showToast(msg: "Order placed");
    }

  }

  Future<void> placeOrder(Map<String, dynamic> product) async {
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to add to cart')),
      );
      return;
    }

    final orderRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .doc(product['name']);

    final existing = await orderRef.get();

    if (existing.exists) {

      final currentQty = existing.data()?['qty'] ?? 1;
      await orderRef.update({'qty': currentQty + 1});
    } else {

      await orderRef.set({
        'name': product['name'],
        'price': product['price'],
        'image': product['image'],
        'qty': 1,
        'isCheckout':true,
        'isDelivered':false,
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order Placed')),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown,
        title: Text("CheckOut", style: TextStyle(
          color: Colors.white,
        ),),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [

            SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.all(10),
              child: TextFormField(
                controller: PhoneController,
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.phone),
                  hintText: 'Phone number',

                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                ), ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextFormField(
                controller: AddressController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.location_on),
                  hintText: currentAddress,

                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                ),

              ),
            ),
            SizedBox(height: 20,),
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextFormField(
                controller: EmailController,
                maxLines: 1,
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.mail),
                  hintText: 'Email',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                ), ),
            ),
            SizedBox(height: 30),

            GestureDetector(
              onTap: () {
                    getCurrentLocation();
              },
              child: Text("Get current location"),
            ),
            SizedBox(height: 30),

            Container(
              height: 50,
              width: double.infinity,
              decoration: BoxDecoration(

                color: Colors.grey,
              ),
              child: Center(
                child: Text("Total Price: ",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),),
              ),
            ),
            SizedBox(height: 30),

            Text("Payment Methods: ",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),),
            SizedBox(height: 30),

            DropdownButtonFormField<PaymentMethod>(
              value: selectedPaymentMethod,
              items: PaymentMethod.values.map((method) {
                return DropdownMenuItem(
                  value: method,
                  child: Text(method.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (method) {

                setState(() {
                  selectedPaymentMethod = method;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Select Payment Method',
                border: OutlineInputBorder(),
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(

                      onPressed: ()
                      {

                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text("cancel", style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),),
                    ),
                  ),

                  SizedBox(width: 30,),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: ()
                      {

                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.brown,
                      ),


                      child: Text("Place Order",style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),),
                    ),
                  ),
                ],
              ),
            ),


          ],
        ),
      ),
    );
  }
}