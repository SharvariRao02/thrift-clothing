import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerPage extends StatefulWidget {
  @override
  _CustomerPageState createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  final TextEditingController _searchController = TextEditingController();
  List<DocumentSnapshot> _products = [];
  Map<String, int> _cart = {};

  void _searchProducts(String query) async {
    final result = await FirebaseFirestore.instance
        .collection('clothes')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: query + '\uf8ff')
        .get();

    setState(() {
      _products = result.docs;
    });
  }

  void _addToCart(String productId) {
    setState(() {
      if (_cart.containsKey(productId)) {
        _cart[productId] = _cart[productId]! + 1;
      } else {
        _cart[productId] = 1;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Product added to cart'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
      ),
    );
  }

  void _viewCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartPage(cart: _cart),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customer Page'),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: _viewCart,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Products',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    _searchProducts(_searchController.text);
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _products.length,
              itemBuilder: (context, index) {
                var product = _products[index];
                double priceInRupees =
                    double.tryParse(product['price'].toString()) ?? 0.0;
                return Card(
                  margin: EdgeInsets.all(8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 5.0,
                  child: ListTile(
                    contentPadding: EdgeInsets.all(8.0),
                    leading: Image.network(
                      product['imageUrl'],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(
                      product['name'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Description: ${product['description']}',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        Text(
                          'Price: ₹${priceInRupees.toStringAsFixed(2)}',
                          style: TextStyle(color: Colors.green),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.add_shopping_cart, color: Colors.purple),
                      onPressed: () {
                        _addToCart(product.id);
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailPage(
                            product: product,
                            addToCart: _addToCart,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ProductDetailPage extends StatelessWidget {
  final DocumentSnapshot product;
  final Function(String) addToCart;

  ProductDetailPage({required this.product, required this.addToCart});

  @override
  Widget build(BuildContext context) {
    double priceInRupees = double.tryParse(product['price'].toString()) ?? 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(product['name']),
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(product['imageUrl']),
            SizedBox(height: 16.0),
            Text(
              product['name'],
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              'Description: ${product['description']}',
              style: TextStyle(color: Colors.grey[700]),
            ),
            SizedBox(height: 8.0),
            Text(
              'Price: ₹${priceInRupees.toStringAsFixed(2)}',
              style: TextStyle(color: Colors.green),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                addToCart(product.id);
                Navigator.pop(context);
              },
              child: Text('Add to Cart'),
            ),
          ],
        ),
      ),
    );
  }
}

class CartPage extends StatelessWidget {
  final Map<String, int> cart;

  CartPage({required this.cart});

  @override
  Widget build(BuildContext context) {
    double totalAmount = 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
        backgroundColor: Colors.purple,
      ),
      body: ListView(
        children: cart.keys.map((productId) {
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('clothes')
                .doc(productId)
                .get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return CircularProgressIndicator();
              var product = snapshot.data!;
              double priceInRupees =
                  double.tryParse(product['price'].toString()) ?? 0.0;
              int quantity = cart[productId]!;
              totalAmount += priceInRupees * quantity;
              return Card(
                margin: EdgeInsets.all(8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 5.0,
                child: ListTile(
                  contentPadding: EdgeInsets.all(8.0),
                  leading: Image.network(
                    product['imageUrl'],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(
                    product['name'],
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Quantity: $quantity'),
                  trailing: Text(
                    'Total: ₹${(priceInRupees * quantity).toStringAsFixed(2)}',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            minimumSize: Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            _checkout(context, totalAmount);
          },
          child: Text('Checkout'),
        ),
      ),
    );
  }

  void _checkout(BuildContext context, double totalAmount) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController nameController = TextEditingController();
        final TextEditingController localityController =
            TextEditingController();
        final TextEditingController addressController = TextEditingController();
        final TextEditingController pinController = TextEditingController();
        final TextEditingController stateController = TextEditingController();

        return AlertDialog(
          title: Text('Enter your details'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: localityController,
                  decoration: InputDecoration(labelText: 'Locality'),
                ),
                TextField(
                  controller: addressController,
                  decoration: InputDecoration(labelText: 'Address'),
                ),
                TextField(
                  controller: pinController,
                  decoration: InputDecoration(labelText: 'Pin Code'),
                ),
                TextField(
                  controller: stateController,
                  decoration: InputDecoration(labelText: 'State'),
                ),
                SizedBox(height: 16.0),
                Text('Total Amount: ₹${totalAmount.toStringAsFixed(2)}'),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
              ),
              onPressed: () async {
                String name = nameController.text;
                String locality = localityController.text;
                String address = addressController.text;
                String pinCode = pinController.text;
                String state = stateController.text;

                await _placeOrder(
                  name,
                  locality,
                  address,
                  pinCode,
                  state,
                  totalAmount,
                  context,
                );

                Navigator.pop(context);
              },
              child: Text('Order'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _placeOrder(
    String name,
    String locality,
    String address,
    String pinCode,
    String state,
    double totalAmount,
    BuildContext context,
  ) async {
    var batch = FirebaseFirestore.instance.batch();

    for (String productId in cart.keys) {
      DocumentReference productRef =
          FirebaseFirestore.instance.collection('clothes').doc(productId);
      DocumentSnapshot productSnapshot = await productRef.get();
      var productData = productSnapshot.data() as Map<String, dynamic>;
      double priceInRupees =
          double.tryParse(productData['price'].toString()) ?? 0.0;

      // Creating an order entry
      DocumentReference orderRef =
          FirebaseFirestore.instance.collection('orders').doc();
      batch.set(orderRef, {
        'productId': productId,
        'productName': productData['name'],
        'quantity': cart[productId],
        'totalPrice': priceInRupees * cart[productId]!,
        'customerName': name,
        'locality': locality,
        'address': address,
        'pinCode': pinCode,
        'state': state,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    // Commit the batch
    await batch.commit();

    // Clear the cart after placing the order
    cart.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Order placed successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    // Navigate back to the customer page
    Navigator.pop(context);
  }
}
