// guitar effect that includes a name, 3 paramaters (and their names), mix, and volume

class Effect {
  int id;
  String name;
  
  int param1;
  int param2;
  int param3;
  String param1Name;
  String param2Name;
  String param3Name;

  int mix;
  int volume;

  Effect({
    required this.id,
    required this.name,
    this.param1 = 0,
    this.param2 = 0,
    this.param3 = 0,
    this.param1Name = "Param 1",
    this.param2Name = "Param 2",
    this.param3Name = "Param 3",
    this.mix = 255,
    this.volume = 255,
  });

  Effect.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        name = json["name"],
        param1 = json["params"][0],
        param2 = json["params"][1],
        param3 = json["params"][2],
        param1Name = json["paramNames"][0],
        param2Name = json["paramNames"][1],
        param3Name = json["paramNames"][2],
        mix = json["mix"],
        volume = json["volume"];

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "params": [param1, param2, param3],
      "paramNames": [param1Name, param2Name, param3Name],
      "mix": mix,
      "volume": volume
    };
  }

  @override
  String toString() {
    return "Effect(id: $id, name: $name, param1: $param1, param2: $param2, param3: $param3, param1Name: $param1Name, param2Name: $param2Name, param3Name: $param3Name, mix: $mix, volume: $volume)";
  }

  Effect copy() {
    return Effect(
      id: id,
      name: name,
      param1: param1,
      param2: param2,
      param3: param3,
      param1Name: param1Name,
      param2Name: param2Name,
      param3Name: param3Name,
      mix: mix,
      volume: volume,
    );
  }
}