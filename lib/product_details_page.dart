import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductDetailsPage extends StatelessWidget {
  final String productId;

  ProductDetailsPage({required this.productId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Details'),
        backgroundColor: Colors.purple,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('clothes').doc(productId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Product not found.'));
          }

          var data = snapshot.data!.data() as Map<String, dynamic>;
          var buyerDetails = data['buyerDetails'] ?? {};

          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['name'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.purple,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Description: ${data['description']}',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                SizedBox(height: 8),
                Text(
                  'Price: ₹${data['price']}',
                  style: TextStyle(fontSize: 16, color: Colors.green),
                ),
                SizedBox(height: 8),
                Text(
                  'Image:',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                SizedBox(height: 8),
                Image.network(data['imageUrl'], height: 200),
                if (buyerDetails.isNotEmpty) ...[
                  SizedBox(height: 16),
                  Text(
                    'Buyer Details:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.purple,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Name: ${buyerDetails['name']}',
                    style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                  ),
                  Text(
                    'Address: ${buyerDetails['address']}',
                    style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                  ),
                  Text(
                    'Pin Code: ${buyerDetails['pincode']}',
                    style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                  ),
                  Text(
                    'State: ${buyerDetails['state']}',
                    style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
