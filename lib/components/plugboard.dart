import 'package:enigma_flutter/components/machineComponent.dart';

/// Represents the enigma plugboard
/// It's a static mapping from one character to another
abstract class Plugboard extends MachineComponent {
  String transform(String character);

  /// Set the mapping from a character to another
  void set(String from, String to);

  /// Remove the mapping from the character
  void remove(String from);

  /// Configure a plugboard with json config information
  factory Plugboard.config(Map<String, dynamic> json) {
    return BasicPlugboard.config(json["config"]);
  }
}

class BasicPlugboard implements Plugboard {
  final Map<String, String> setting = {};
  BasicPlugboard({Map<String, String>? setting}) {
    this.setting.addAll(setting ?? {});
  }
  @override
  String transform(String character) {
    bool isCharacterUpperCase = character.toUpperCase() == character;

    String? tranformedCharacter = setting[character.toLowerCase()];
    tranformedCharacter = tranformedCharacter ?? character;

    if (isCharacterUpperCase) return tranformedCharacter.toUpperCase();

    return tranformedCharacter;
  }

  @override
  void set(String from, String to) {
    setting[from.toLowerCase()] = to.toLowerCase();
  }

  @override
  void remove(String from) {
    setting.remove(from.toLowerCase());
  }

  factory BasicPlugboard.config(Map<String, dynamic> json) {
    return BasicPlugboard(setting: json["setting"]);
  }

  @override
  Map<String, dynamic> generateConfig() {
    return {
      "type": "${this.runtimeType}",
      "config": {"setting": setting}
    };
  }
}
