import "package:flutter/material.dart";
import "pages/home.dart";
import "pages/connect.dart";
import "client.dart";

void main() {
  runApp(const GuitarPedal());
}

class GuitarPedal extends StatelessWidget {
  const GuitarPedal({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "GuitarPedal",
      theme: ThemeData.light().copyWith(
        colorScheme: ColorScheme.fromSeed(
                seedColor: const Color.fromRGBO(120, 169, 253, 1))
            .copyWith(
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(
                seedColor: const Color.fromRGBO(120, 169, 253, 1))
            .copyWith(
          brightness: Brightness.dark,
        ),
      ),
      //home: const HomePage(title: "GuitarPedal Home Page"),

      home: FutureBuilder<bool>(
        future: _checkConnectionStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // show connect page while waiting for connection
            return const ConnectPage();
          } else {
            final bool isConnected = snapshot.data ?? false;
            Widget home;
            if (isConnected) {
              home = HomePage();//title: "GuitarPedal Home Page");
            }
            else {
              home = const ConnectPage();
            }
            return home;
          }
        },
      )
    );
  }

  Future<bool> _checkConnectionStatus() async {
    debugPrint("Checking connection status...");

    Client.connectToWiFi();

    return true;
  }
}