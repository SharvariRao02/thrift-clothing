import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CheckoutPage extends StatelessWidget {
  final Map<String, int> cart;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();

  CheckoutPage({required this.cart});

  void _confirmOrder(BuildContext context) {
    String name = _nameController.text;
    String age = _ageController.text;
    String address = _addressController.text;
    String pincode = _pincodeController.text;
    String state = _stateController.text;

    cart.forEach((productId, quantity) async {
      await FirebaseFirestore.instance
          .collection('clothes')
          .doc(productId)
          .update({
        'sold': true,
        'buyerDetails': {
          'name': name,
          'age': age,
          'address': address,
          'pincode': pincode,
          'state': state,
        }
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Your order will reach within 7 working days.')),
    );

    Navigator.popUntil(context, ModalRoute.withName('/'));
  }

  double _calculateTotalAmount() {
    double totalAmount = 0.0;
    cart.forEach((productId, quantity) async {
      DocumentSnapshot product = await FirebaseFirestore.instance
          .collection('clothes')
          .doc(productId)
          .get();
      double price = double.tryParse(product['price'].toString()) ?? 0.0;
      totalAmount += price * quantity;
    });
    return totalAmount;
  }

  @override
  Widget build(BuildContext context) {
    double totalAmount = _calculateTotalAmount();
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _ageController,
              decoration: InputDecoration(labelText: 'Age'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(labelText: 'Address'),
            ),
            TextField(
              controller: _pincodeController,
              decoration: InputDecoration(labelText: 'Pin Code'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _stateController,
              decoration: InputDecoration(labelText: 'State'),
            ),
            SizedBox(height: 16.0),
            Text('Total Amount: \$${totalAmount.toStringAsFixed(2)}'),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
              onPressed: () {
                _confirmOrder(context);
              },
              child: Text('Confirm Order'),
            ),
          ],
        ),
      ),
    );
  }
}
