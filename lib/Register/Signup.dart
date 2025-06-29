import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TextEditingController FullNameController =TextEditingController();
  TextEditingController EmailController=TextEditingController();
  TextEditingController PasswordController=TextEditingController();
  TextEditingController ConfirmPasswordController=TextEditingController();
  bool _obsecure =true;

  void _validation(){
    if(FullNameController.text.isEmpty){
      Fluttertoast.showToast(msg: "Fill the Name");
    }
    else if(EmailController.text.isEmpty){
      Fluttertoast.showToast(msg: "Fill the Email");
      }
    else if(PasswordController.text.isEmpty){
      Fluttertoast.showToast(msg: "Fill the Password");
      }
    else if(ConfirmPasswordController.text.isEmpty){
      Fluttertoast.showToast(msg: "ConfromPassword");
    }
    else
      {

        registerUser(EmailController.text,PasswordController.text,FullNameController.text);
        Fluttertoast.showToast(msg: "EmailController.text");
      }
  }
  Future<void> registerUser(String email, String password,String name) async {
    try {

      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = userCredential.user;

      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set(
            {
              'uid': user.uid,
              'email': user.email,
              'name': name,


            });

        print("User registered and added to Firestore");
      }
    } catch (e, stacktrace) {
      print("Registration Error: $e");
      print("StackTrace: $stacktrace");
    }
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.red,
          ),

          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [


                SizedBox(height: 10,),

                Center(
                  child: Text("Sign Up",
                  style:
                    TextStyle(
                      fontSize: 30,
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),),
                ),

                Padding(
                  padding: const EdgeInsets.all(5),
                  child: TextFormField(
                    controller: FullNameController,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: Icon(Icons.abc),
                      labelText: 'Full Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ) ,

                Padding(
                  padding: const EdgeInsets.all(5),
                  child: TextFormField(
                    controller: EmailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon:GestureDetector(

                        onTap: (){
                          if (_obsecure==true){
                            setState(() {
                              _obsecure=false;

                            });
                          }
                          else if(_obsecure==false){
                            setState(() {
                              _obsecure=true;
                            });
                          }else {
                            setState(() {
                              _obsecure = true;
                            });
                          }
                          log(_obsecure.toString());
                        },
                          child: Icon(Icons.email)),
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(5),
                  child: TextFormField(
                    obscureText: _obsecure,
                    controller: PasswordController,
                    keyboardType: TextInputType.visiblePassword,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      suffixIcon: GestureDetector
                        (
                        onTap: (){
                          if (_obsecure==true){
                            setState(() {
                              _obsecure=false;

                            });
                          }
                          else if(_obsecure==false){
                            setState(() {
                              _obsecure=true;
                            });
                          }else {
                            setState(() {
                              _obsecure = true;
                            });
                          }
                          log(_obsecure.toString());
                        },
                          child: Icon(_obsecure==true?Icons.remove_red_eye:Icons.remove_red_eye_outlined)),
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(5),
                  child: TextFormField(
                    obscureText: _obsecure,
                    controller: ConfirmPasswordController,
                    keyboardType: TextInputType.visiblePassword,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      suffixIcon: Icon(Icons.remove_red_eye),
                      labelText: 'Confirm Password',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),



                SizedBox(height: 20,),
                
                ElevatedButton(onPressed: (){
                  Navigator.pop(context);
                  _validation();
                },
                    child: Text("Register",style: TextStyle(
                      fontSize: 20,
                      color: Colors.redAccent,

                    ),),
                ),
                SizedBox(height: 20,),

                GestureDetector(
                  onTap: (){

                    // Navigator.pop(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => Signup()),
                    //
                    // );

                  },
                  child: Center(
                    child: Text("Already have a Account?Signin"),
                  ),
                ),

                
              ],


            ),
          ),
        )
    );
  }
}

