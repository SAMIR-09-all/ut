
import 'dart:convert';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart'as http;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled/Register/Signup.dart';
import 'package:untitled/homepage.dart';
import 'package:untitled/tabPages.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth =FirebaseAuth.instance;

  TextEditingController Emailcontroller=TextEditingController();
  TextEditingController Passwordcontroller=TextEditingController();
  bool _obsecure =true;

  Future postLogin() async {

    final response = await http.post(
        Uri.parse('https://api-barrel.sooritechnology.com.np/api/v1/user-app/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(
            {
              "userName": Emailcontroller.text,
              "password": Passwordcontroller.text,
            }
        ));

    if(response.statusCode==200){
      SharedPreferences prefs =await SharedPreferences.getInstance();

      log(jsonDecode(response.body)['userName']);
      prefs.setString("username",jsonDecode(response.body)['userName']);
      prefs.setInt("id",jsonDecode(response.body)['id']);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Mainpage()));
    }else{
      Fluttertoast.showToast(msg: "Invalid");
    }





    return response;
  }


  void _validation(){
    if(Emailcontroller.text.isEmpty){
      Fluttertoast.showToast(msg: "Please enter the email");
    }
    else if(Passwordcontroller.text.isEmpty){
      Fluttertoast.showToast(msg: "Please enter the password");
    }
    else
      {
        Fluttertoast.showToast(msg: Emailcontroller.text);
      }
  }
  Future<User?>LoginUser()async{
try{
  final UserCredential userCredential = await _auth.signInWithEmailAndPassword
    (
    email: Emailcontroller.text,
    password: Passwordcontroller.text,
  );
  final User? user = userCredential.user;

  if (user != null){
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Mainpage()));
  }

}catch(e){
  }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 50,
              ),
              Center(
                child: Text(
                  textAlign: TextAlign.center,
                  "Welcome to Login Page",
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold
                  ),),
              ),
              Center(
                child: Text(" Nama",style: TextStyle(
                  fontSize: 14,
                  color: Colors.blueAccent,

                ),),
              ),
              SizedBox(height: 70,),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: Emailcontroller,
                  decoration: InputDecoration(
                      fillColor: Colors.white,
                      prefixIcon: Icon(Icons.email_outlined),
                      hintText: 'Enter the email',
                      border: OutlineInputBorder()
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  obscureText: _obsecure,
                  controller: Passwordcontroller,
                  decoration: InputDecoration(
                   filled: true,
                      fillColor: Colors.white,
                      prefixIcon: Icon(Icons.password),
                      suffixIcon: GestureDetector

                        (
                          onTap: (){
                            if (_obsecure == true){
                              setState(() {
                                _obsecure=false;
                              });
                            }
                            else if (_obsecure == false){
                              setState(() {
                                _obsecure=true;
                              });
                            }else {
                              setState(() {
                                _obsecure=true;
                              });
                            }
                          log(_obsecure.toString());
                          },
                          child: Icon(_obsecure==true?Icons.remove_red_eye:Icons.remove_red_eye_outlined)),
                      hintText: 'Enter the password',
                      border: OutlineInputBorder()
                  ),
                ),
              ),
              SizedBox(height: 50,),
              Center(
                child: ElevatedButton(
                    onPressed: ()async{
                      LoginUser();
                //Navigator.push(context, MaterialPageRoute(builder: (context) => Homepage("")));
                //  postLogin();
                },
                    child: Text("Login")),

              ),
              SizedBox(height: 10,),

              GestureDetector(
                onTap: (){
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Signup()),

                  );
                  
                },
                child: Center(
                  child: Text("New user?Signup"),
                ),
              ),



            ],
          ),
        ),
      ),
    );
  }
}
