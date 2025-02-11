import "package:flutter/material.dart";
import "../client.dart";
import "dart:async";

class WifiPage extends StatefulWidget {
  @override
  _WifiPageState createState() => _WifiPageState();
}

class _WifiPageState extends State<WifiPage> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      if (Client.isConnected) {
        setState(() {});
      }
    });

    connectDevice();
  }

  void connectDevice() async {
    bool connected = await Client.connectToWiFi();
    if (connected) {
      setState(() {});
    }
  }

  void disconnectDevice() {
    Client.disconnect();
    Navigator.pop(context);
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
        title: const Text("WiFi Connection"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              Client.isConnected
                  ? Column(
                      children: [
                        const SizedBox(height: 16),
                        const Text("Connected", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                        Text("Connecting...", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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