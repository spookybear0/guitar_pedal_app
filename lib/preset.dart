import "effect.dart";
import "package:flutter/foundation.dart";

class Preset {
  int id;
  String name;
  List<Effect> effects;

  Preset({
    required this.id,
    required this.name,
    required this.effects,
  });

  factory Preset.fromJson(Map<String, dynamic> json) {
    debugPrint("Preset.fromJson: $json");
    debugPrint("Name: ${json["name"]}");
    debugPrint("Effects: ${json["effects"]}");
    return Preset(
      name: json["name"] as String,
      id: json["id"] as int,
      effects: (json["effects"] as List)
          .map((e) => Effect.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "effects": effects.map((e) => e.toJson()).toList(),
    };
  }
}