import 'dart:async';
import 'package:flutter/material.dart';
import 'wifi_page.dart';
import '../client.dart';
import '../effect.dart';
import 'edit_preset.dart';
import '../preset.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Effect> effects = [];
  List<Preset> presets = [];
  String? _selectedEffect;
  Effect selectedEffect = Effect(id: -1, name: "None"); // default selected effect
  Timer? _connectionTimer; // timer for periodically checking connection
  Timer? _fetchDataTimer; // timer for periodically fetching data

  double param1 = 0;
  double param2 = 0;
  double param3 = 0;

  bool parametersChanged = false;

  @override
  void initState() {
    super.initState();
    _startConnectionCheckTimer();
    _startEffectUpdateTimer();
  }

  // start a timer to check the connection status periodically
  void _startConnectionCheckTimer() {
    if (_connectionTimer != null && _connectionTimer!.isActive) {
      return;
    }

    _connectionTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (Client.isConnected) {
        _connectionTimer?.cancel(); // Stop the timer once connected
        debugPrint("Connected to Vortex Pedal!!!");
        _fetchData(); // Fetch effects if connected
        _startFetchDataTimer();
      }
    });
  }

  // start a timer to update the effect parameters periodically
  void _startEffectUpdateTimer() {
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (parametersChanged) {
        debugPrint("Updating effect parameters...");
        Client.setEffect(selectedEffect);
        parametersChanged = false;
      }
    });
  }

  void _startFetchDataTimer() {
    if (_fetchDataTimer != null && _fetchDataTimer!.isActive) {
      return;
    }
    Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchData();

      // update selected effect
      if (selectedEffect.id != -1) {
        selectedEffect = effects.firstWhere((e) => e.id == selectedEffect.id);
        param1 = selectedEffect.param1.toDouble();
        param2 = selectedEffect.param2.toDouble();
        param3 = selectedEffect.param3.toDouble();
      }
    });
  }

  void _fetchData() {
    Client.getEffects().then((effectList) {
      if (mounted) {
        setState(() {
          effects = effectList;
        });
      }
    }).catchError((e) {
      debugPrint("Failed to fetch effects: $e");
    });

    Client.getPresets().then((presetList) {
      if (mounted) {
        setState(() {
          presets = presetList;
        });
      }
    }).catchError((e) {
      debugPrint("Failed to fetch presets: $e");
    });
  }

  // handle effect selection
  void onEffectSelect(String? effect) {
    if (effect != null) {
      setState(() {
        _selectedEffect = effect;
        // update the parameters based on the selected effect
        selectedEffect = effects.firstWhere((e) => e.id.toString() == effect);
        param1 = selectedEffect.param1.toDouble();
        param2 = selectedEffect.param2.toDouble();
        param3 = selectedEffect.param3.toDouble();

        parametersChanged = true;
      });
      Client.singleEffectSet(int.parse(effect)); // update current effect
    }
  }

  @override
  void dispose() {
    _connectionTimer?.cancel(); // cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Home"),
        actions: [
          IconButton(
            icon: Icon(Client.isConnected ? Icons.wifi : Icons.wifi_off),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WifiPage())
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            DropdownButton<String>(
              value: _selectedEffect,
              hint: const Text("Select Effect"),
              items: effects.map((effect) {
                return DropdownMenuItem<String>(
                  value: effect.id.toString(),
                  child: Text(effect.name),
                );
              }).toList(),
              onChanged: onEffectSelect,
            ),
            // 3 sliders for the 3 parameters
            Text(
              selectedEffect.param1Name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Slider(
              value: param1,
              min: 0,
              max: 255,
              onChanged: selectedEffect.id != -1 ? (value) {
                setState(() {
                  param1 = value;
                  selectedEffect.param1 = value.toInt();
                  parametersChanged = true;
                });
              } : null
            ),
            Text(
              selectedEffect.param2Name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Slider(
              value: param2,
              min: 0,
              max: 255,
              onChanged: selectedEffect.id != -1 ? (value) {
                setState(() {
                  param2 = value;
                  selectedEffect.param2 = value.toInt();
                  parametersChanged = true;
                });
              } : null
            ),
            Text(
              selectedEffect.param3Name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Slider(
              value: param3,
              min: 0,
              max: 255,
              onChanged: selectedEffect.id != -1 ? (value) {
                setState(() {
                  param3 = value;
                  selectedEffect.param3 = value.toInt();
                  parametersChanged = true;
                });
              } : null
            ),
            const SizedBox(height: 16),
            const Text("Presets:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            // List of presets that go to the edit preset screen (on hold ask about deleting)
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: presets.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(presets[index].name, style: const TextStyle(color: Colors.white, fontSize: 18)),
                    // grayish color
                    tileColor: Theme.of(context).colorScheme.onSurface,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditPresetPage(preset: presets[index]),
                        ),
                      );
                    },
                    onLongPress: () async {
                      bool? confirm = await showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Delete Preset"),
                            content: const Text("Are you sure you want to delete this preset?"),
                            backgroundColor: Theme.of(context).colorScheme.inverseSurface,
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text("Delete", style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirm == true) {
                        Client.removePreset(presets[index].id);
                        setState(() {
                          presets.removeAt(index);
                        });
                      }
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: Client.isConnected
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditPresetPage(preset: Preset(id: -1, name: "New Preset", effects: []), isNew: true),
                        ),
                      );
                    }
                  : null,
              child: const Text("Add New Preset"),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}