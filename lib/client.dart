import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wifi_iot/wifi_iot.dart';
import 'package:flutter/material.dart';
import "effect.dart";
import "preset.dart";

class Client {
  static const String ssid = "Vortex Pedal";
  static const String? password = null;
  static const String serverIP = "192.168.1.1";
  static const int port = 80;

  static bool isConnected = false;

  // cache
  static List<Effect> effects = [];
  static List<Preset> presets = [];

  /// Connects to the ESP32's Wi-Fi Access Point
  static Future<bool> connectToWiFi() async {
    // check if already connected
    if (await WiFiForIoTPlugin.isConnected() && await WiFiForIoTPlugin.getSSID() == ssid) {
      debugPrint("Already connected to Wi-Fi: $ssid");
      isConnected = true;
      return true;
    }
    
    bool success = await WiFiForIoTPlugin.connect(
      ssid,
      password: password,
      security: NetworkSecurity.NONE,
      joinOnce: true,
      withInternet: false,
    );
    
    if (success) {
      WiFiForIoTPlugin.forceWifiUsage(true);

      debugPrint("Connected to Wi-Fi: $ssid");
      isConnected = true;
      return true;
    } else {
      debugPrint("Failed to connect to Wi-Fi.");
      return false;
    }
  }

  static void disconnect() async {
    await WiFiForIoTPlugin.disconnect();
    isConnected = false;
  }

  // send get request to ESP32
  static Future<Map<String, dynamic>?> getRequest(String path) async {
    try {
      final response = await http.get(Uri.parse("http://$serverIP:$port$path"));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        debugPrint("GET Request Failed: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("GET Request Error: $e");
    }
    return null;
  }

  /// send post request to ESP32
  static Future<Map<String, dynamic>?> postRequest(String path, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse("http://$serverIP:$port$path"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        debugPrint("POST Request Failed: ${response.statusCode}");
      }
    }
    catch (e) {
      if (e is http.ClientException && e.message.contains("Connection failed")) {
        debugPrint("POST Request Error: Connection refused. Is the ESP32 running?");
        Client.isConnected = false;
      }
      
      else {
        debugPrint("POST Request Error: $e");
      }
    }
    return null;
  }

  // ping
  static Future<bool> ping() async {
    // send post to /ping
    final response = await postRequest("/ping", {});
    return response != null;
  }

  static Future<List<Effect>> getEffects() async {
    final response = await postRequest("/effects/get", {});
    if (response != null) {
      List<Effect> data = (response["data"]["effects"] as List)
          .map((e) => Effect.fromJson(e))
          .toList();
      effects = data;
      return data;
    }

    return [];
  }

  static Future<bool> setEffect(Effect effect) async {
    Map<String, dynamic> data = {"draw": true}; // draw is true to update the effect on the ESP32

    // serialize effect

    data["effect"] = effect.toJson();

    final response = await postRequest("/effects/set", data);
    return response != null;
  }

  static Future<bool> singleEffectSet(int id) async {
    final response = await postRequest("/single_effect/set", {"effect_id": id});
    return response != null;
  }

  static Future<bool> addPreset(Preset preset) async {
    final response = await postRequest("/presets/add", preset.toJson());

    if (response != null && response["status"] == "success") {
      return true;
    }
    return false;
  }

  static Future<List<Preset>> getPresets() async {
    final response = await postRequest("/presets/get", {});
    if (response != null) {
      List<Preset> data = (response["data"]["presets"] as List)
          .map((e) => Preset.fromJson(e))
          .toList();
      presets = data;
      return data;
    }

    return [];
  }

  static Future<Preset?> getPreset(String name) async {
    final response = await postRequest("/presets/get", {"name": name});
    if (response != null) {
      return Preset.fromJson(response["data"]["preset"]);
    }

    return null;
  }

  static Future<bool> editPreset(Preset preset) async {
    final response = await postRequest("/presets/edit", preset.toJson());

    if (response != null && response["status"] == "success") {
      return true;
    }
    return false;
  }

  static Future<bool> removePreset(int id) async {
    final response = await postRequest("/presets/remove", {"id": id});
    if (response != null && response["status"] == "success") {
      return true;
    }
    return false;
  }
}