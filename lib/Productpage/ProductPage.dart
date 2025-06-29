import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Productpage extends StatefulWidget {
  const Productpage({super.key});

  @override
  State<Productpage> createState() => _ProductpageState();
}

class _ProductpageState extends State<Productpage> {
  TextEditingController ProductNameController = TextEditingController();
  TextEditingController ProductPriceController = TextEditingController();
  TextEditingController ProductDescriptionController = TextEditingController();

  onclickValidation() {
    if (ProductNameController.text.isEmpty || ProductDescriptionController.text.isEmpty ||
        ProductPriceController.text.isEmpty)
   {
     Fluttertoast.showToast(msg: 'please fill the product');
   }
    CreateProduct();
    Fluttertoast.showToast(msg: 'Product add');
  }
  Future<void>CreateProduct() async{
    try{
      await FirebaseFirestore.instance.collection('products').add({
        'name': ProductNameController.text,
        'price' : ProductPriceController.text,
        'description' : ProductDescriptionController.text

      });
    }catch(e){

    }
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueAccent,
          title: Text("Add Product", style: TextStyle(
            color: Colors.black,
          ),),
          iconTheme: IconThemeData(color: Colors.grey),
          centerTitle: true,
        ),
        body: Column(
          children: [

            SizedBox(height: 30,),

            Padding(
              padding: const EdgeInsets.all(10),
              child: TextFormField(
                controller: ProductNameController,
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.add_box_sharp),
                  hintText: 'Product Name',

                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                ), ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextFormField(
                 controller: ProductPriceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.monetization_on_sharp),
                  hintText: 'Product Price',

                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                ), ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextFormField(
                controller: ProductDescriptionController,
                maxLines: 5,
                keyboardType: TextInputType.name,
                decoration: InputDecoration(

                  hintText: 'Product Description',

                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ), ),
            ),
            SizedBox(height: 30),

            ElevatedButton(onPressed: ()
            {

              onclickValidation();
            },
              child: Text("Save Product"),
            ),

          ],
        ),
      ),
    );
  }
}

