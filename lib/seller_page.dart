import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'view_products_page.dart'; // Import the ViewProductsPage

class SellerPage extends StatefulWidget {
  @override
  _SellerPageState createState() => _SellerPageState();
}

class _SellerPageState extends State<SellerPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  File? _image;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadClothes() async {
    if (_image != null &&
        nameController.text.isNotEmpty &&
        descriptionController.text.isNotEmpty &&
        priceController.text.isNotEmpty) {
      try {
        // Upload image to Firebase Storage
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference firebaseStorageRef =
            FirebaseStorage.instance.ref().child('clothes_images/$fileName');
        UploadTask uploadTask = firebaseStorageRef.putFile(_image!);

        // Monitor the upload task
        TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});

        if (taskSnapshot.state == TaskState.error) {
          throw Exception('Upload failed: ${taskSnapshot.state}');
        }

        // Get the download URL
        String imageUrl = await taskSnapshot.ref.getDownloadURL();

        // Add clothes details to Firestore
        await _firestore.collection('clothes').add({
          'name': nameController.text,
          'description': descriptionController.text,
          'price': priceController.text,
          'imageUrl': imageUrl,
          'sellerEmail':
              FirebaseAuth.instance.currentUser!.email, // Add seller's email
          'createdAt': Timestamp.now(), // Add createdAt field
        });

        _showDialog('Success', 'Clothes uploaded successfully!');

        // Navigate to ViewProductsPage
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ViewProductsPage(
                  email: FirebaseAuth.instance.currentUser!.email!)),
        );
      } catch (e) {
        _showDialog('Error', 'Upload failed: $e');
        print('Error: $e');
      }
    } else {
      _showDialog('Error', 'Please fill all fields and select an image.');
    }
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Clothes'),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: Icon(Icons.view_list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ViewProductsPage(
                        email: FirebaseAuth.instance.currentUser!.email!)),
              );
            },
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlue[50]!, Colors.blue[100]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.purple, width: 2.0),
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.white,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Clothes Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: priceController,
                        decoration: InputDecoration(
                          labelText: 'Price',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 10),
                      _image == null
                          ? TextButton(
                              onPressed: _pickImage,
                              child: Text('Select Image'),
                            )
                          : Image.file(_image!),
                      SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          textStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        onPressed: _uploadClothes,
                        child: Text('Upload Clothes'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
