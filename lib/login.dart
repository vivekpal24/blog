import 'package:flutter/material.dart';
import 'package:blog/signup.dart';
class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                decoration: InputDecoration(
                  labelText: 'Email',
                ),
              ),
              SizedBox(height: 20.0),
              TextField(
                obscureText: true, // To hide the password
                decoration: InputDecoration(
                  labelText: 'Password',
                ),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  // Add login functionality here
                },
                child: Text('Login'),
              ),
        SizedBox(height: 10.0),
        TextButton(
          onPressed: () {
            // Navigate to the Sign Up screen
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SignUpScreen()),
            );
          },
          child: Text('Not registered? Sign Up'),

          ),
        ],
        ),
      ),
      ),
    );
  }
}