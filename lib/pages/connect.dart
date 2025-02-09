// page for telling you to connect to the bluetooth device

import "package:flutter/material.dart";

class ConnectPage extends StatelessWidget {
  const ConnectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Connect"),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // loading spinner
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text("Connect to the bluetooth device", style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}