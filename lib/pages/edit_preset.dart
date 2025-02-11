import "package:flutter/material.dart";
import "dart:async";
import "../preset.dart";
import "../effect.dart";
import "../client.dart";

class EditPresetPage extends StatefulWidget {
  final Preset preset;
  final bool isNew;
  const EditPresetPage({super.key, required this.preset, this.isNew = false});

  @override
  _EditPresetPageState createState() => _EditPresetPageState();
}

class _EditPresetPageState extends State<EditPresetPage> {
  final TextEditingController _nameTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameTextController.text = widget.preset.name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Edit Preset"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // name of effect
            const SizedBox(height: 16),
            Center(
              child: SizedBox(
                width: 300,
                child: TextField(
                  controller: _nameTextController,
                  onChanged: (value) {
                    setState(() {
                      widget.preset.name = value;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: "Preset Name",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // draggable list of effects that can dropdown to change 3 parameters, volume and mix
            Expanded(
              child: ReorderableListView(
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) newIndex--; // Adjust index due to removal
                    final effect = widget.preset.effects.removeAt(oldIndex);
                    widget.preset.effects.insert(newIndex, effect);
                  });
                },
                children: widget.preset.effects.asMap().entries.map((entry) {
                  int index = entry.key;
                  Effect effect = entry.value;

                  return Card(
                    key: ValueKey(effect),
                    color: Theme.of(context).colorScheme.inverseSurface,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ExpansionTile(
                      title: Text(effect.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
                      children: [
                        Text(
                          effect.param1Name,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Slider(
                          value: effect.param1.toDouble(),
                          min: 0,
                          max: 255,
                          onChanged: (value) {
                            setState(() {
                              effect.param1 = value.toInt();
                            });
                          }
                        ),
                        Text(
                          effect.param2Name,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Slider(
                          value: effect.param2.toDouble(),
                          min: 0,
                          max: 255,
                          onChanged: (value) {
                            setState(() {
                              effect.param2 = value.toInt();
                            });
                          }
                        ),
                        Text(
                          effect.param3Name,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Slider(
                          value: effect.param3.toDouble(),
                          min: 0,
                          max: 255,
                          onChanged: (value) {
                            setState(() {
                              effect.param3 = value.toInt();
                            });
                          }
                        ),
                        const Text(
                          "Volume",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Slider(
                          value: effect.volume.toDouble(),
                          min: 0,
                          max: 255,
                          onChanged: (value) {
                            setState(() {
                              effect.volume = value.toInt();
                            });
                          }
                        ),
                        const Text(
                          "Mix",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Slider(
                          value: effect.mix.toDouble(),
                          min: 0,
                          max: 255,
                          onChanged: (value) {
                            setState(() {
                              effect.mix = value.toInt();
                            });
                          }
                        ),
                        // Delete effect button
                        TextButton(
                          onPressed: () {
                            setState(() {
                              widget.preset.effects.removeAt(index);
                            });
                          },
                          child: const Text("Remove Effect", style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),
            // add effect button
            ElevatedButton(
              onPressed: () {
                // add effect
                setState(() {
                  // create popup to select effect (1-8)

                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Select Effect"),
                        backgroundColor: Theme.of(context).colorScheme.inverseSurface,
                        content: SingleChildScrollView(
                          child: ListBody(
                            children: Client.effects.map((effect) {
                              return ListTile(
                                title: Text(effect.name, style: const TextStyle(color: Colors.white)),
                                onTap: () {
                                  setState(() {
                                    Effect copy = effect.copy();
                                    copy.param1 = 0;
                                    copy.param2 = 0;
                                    copy.param3 = 0;
                                    copy.volume = 255;
                                    copy.mix = 255;
                                    widget.preset.effects.add(copy);
                                    Navigator.pop(context);
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    },
                  );
                });
              },
              child: const Text("Add Effect"),
            ),

            // save button
            ElevatedButton(
              onPressed: () {
                // save preset

                // get the list values of the effects
                List<Map<String, dynamic>> effects = widget.preset.effects.map((effect) => effect.toJson()).toList();
                // save effects to preset object
                widget.preset.effects = effects.map((effect) => Effect.fromJson(effect)).toList();
                widget.preset.name = _nameTextController.text;

                // send preset to server

                if (widget.isNew) {
                  Client.addPreset(widget.preset);
                } else {
                  Client.editPreset(widget.preset);
                }

                Navigator.pop(context, widget.preset);
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}