import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _showAlertDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
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
      body: Container(
        color: Colors.lightBlue[50],
        child: Center(
          child: Container(
            padding: EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.purple, width: 2.0),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    textStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () async {
                    try {
                      UserCredential userCredential =
                          await _auth.signInWithEmailAndPassword(
                        email: emailController.text,
                        password: passwordController.text,
                      );
                      if (userCredential.user != null) {
                        _showAlertDialog(
                            context, 'Success', 'Login successful!');
                        Navigator.pushNamed(context, '/role');
                      }
                    } on FirebaseAuthException catch (e) {
                      String errorMessage;
                      switch (e.code) {
                        case 'user-not-found':
                          errorMessage = 'No user found for that email.';
                          break;
                        case 'wrong-password':
                          errorMessage = 'Wrong password provided.';
                          break;
                        default:
                          errorMessage = 'Login failed: ${e.message}';
                          break;
                      }
                      _showAlertDialog(context, 'Error', errorMessage);
                    } catch (e) {
                      _showAlertDialog(
                          context, 'Error', 'An unknown error occurred.');
                    }
                  },
                  child: Text('Login', style: TextStyle(color: Colors.white)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/forgot-password');
                  },
                  child: Text('Forgot Password?'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: Text('Register'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/admin-login');
                  },
                  child: Text('Admin Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
