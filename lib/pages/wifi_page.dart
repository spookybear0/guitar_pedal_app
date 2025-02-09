import "package:flutter/material.dart";
import "../client.dart";
import "dart:async";

class WifiPage extends StatefulWidget {
  @override
  _WifiPageState createState() => _WifiPageState();
}

class _WifiPageState extends State<WifiPage> {
  String? connectedDevice;

  @override
  void initState() {
    super.initState();
    Client.connectToWiFi();
  }

  void disconnectDevice() {
    
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Bluetooth Connection"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              connectedDevice != null
                  ? Column(
                      children: [
                        const SizedBox(height: 16),
                        Text("Connected to: $connectedDevice",
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: disconnectDevice,
                          child: const Text("Disconnect"),
                        ),
                      ],
                    )
                  : const Column(
                      children: [
                        SizedBox(height: 16),
                        Text("Scanning for Vortex Pedal...",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 16),
                        CircularProgressIndicator(),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}