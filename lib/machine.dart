import 'dart:async';

import 'package:enigma_flutter/components/plugboard.dart';
import 'package:enigma_flutter/components/reflector.dart';
import 'package:enigma_flutter/components/rotor.dart';

abstract class EnigmaMachine {
  set rotorSet(RotorSet rotorSet);
  RotorSet get rotorSet;

  set plugboard(Plugboard plugboard);
  Plugboard get plugboard;

  set reflector(Reflector reflector);
  Reflector get reflector;

  Function(String originalCharacter, String character,
      String transformedCharacter, bool backwards)? onRotorTransformed;
  Function(String originalCharacter, String character,
      String transformedCharacter, bool backwards)? onPlugboardTransformed;
  Function(String originalCharacter, String character,
      String transformedCharacter)? onReflectorTransformed;

  Function(String originalMessage, String transformedMessage)? onCompleted;

  /// Transform a message by passing it through the machine
  FutureOr<String> transform(String message);

  /// Get the current machine configuration.
  /// The config is returned as a map that can be converted to a json string
  Map<String, dynamic> getConfig();

  /// Randomly configure the machine and its components
  void randomConfig();

  /// Factory constructor for creating config
  factory EnigmaMachine.config(Map<String, dynamic> json) {
    return BasicEnigmaMachine(
        plugboard: Plugboard.config(json["plugboard"]),
        reflector: Reflector.config(json["reflector"]),
        rotorSet: RotorSet.config(json["rotorSet"]));
  }

  factory EnigmaMachine.basicRandomConfig() {
    var machine = BasicEnigmaMachine(
        plugboard: BasicPlugboard(),
        reflector: BasicAlphaNumericReflector(),
        rotorSet: BasicRotorSet([]));
    machine.randomConfig();

    return machine;
  }
}

class BasicEnigmaMachine implements EnigmaMachine {
  @override
  Plugboard plugboard;

  @override
  Reflector reflector;

  @override
  RotorSet rotorSet;

  @override
  Function(String originalCharacter, String character,
      String transformedCharacter, bool first)? onRotorTransformed;

  @override
  Function(String originalCharacter, String character,
      String transformedCharacter, bool first)? onPlugboardTransformed;

  @override
  Function(String originalCharacter, String character,
      String transformedCharacter)? onReflectorTransformed;

  @override
  Function(String originalMessage, String transformedMessage)? onCompleted;

  BasicEnigmaMachine(
      {required this.plugboard,
      required this.reflector,
      required this.rotorSet});

  String _plugboardTransform(
      String original, String character, bool backwards) {
    String plugboardTransChar = plugboard.transform(character);
    onPlugboardTransformed?.call(
        original, character, plugboardTransChar, backwards);
    return plugboardTransChar;
  }

  String _reflectorTransform(String originalCharacter, String character) {
    String reflectorTransChar = reflector.transform(character);
    onReflectorTransformed?.call(
        originalCharacter, character, reflectorTransChar);
    return reflectorTransChar;
  }

  String _rotorTransform(
      String originalCharacter, String character, bool backwards) {
    String rotorTransChar = rotorSet.transform(character, backwards: backwards);
    if (backwards) rotorSet.step();
    onRotorTransformed?.call(
        originalCharacter, character, rotorTransChar, backwards);
    return rotorTransChar;
  }

  @override
  FutureOr<String> transform(String message) {
    String transformed = "";

    for (String character in message.split("")) {
      String plugboardFirst = _plugboardTransform(character, character, false);
      String rotorFirst = _rotorTransform(character, plugboardFirst, false);
      String reflectorCharacter = _reflectorTransform(character, rotorFirst);
      String rotorLast = _rotorTransform(character, reflectorCharacter, true);
      String plugboardLast = _plugboardTransform(character, rotorLast, true);
      transformed += plugboardLast;
    }

    onCompleted?.call(message, transformed);
    return transformed;
  }

  @override
  Map<String, dynamic> getConfig() {
    return {
      "type": "${this.runtimeType}",
      "plugboard": plugboard.generateConfig(),
      "reflector": reflector.generateConfig(),
      "rotorSet": rotorSet.generateConfig()
    };
  }

  @override
  void randomConfig() {
    // Configure plugboard
    plugboard.randomConfig();
    // Set rotors
    List<Rotor> rotors = [];
    rotors.add(BasicAlphaNumericRotor());
    rotors.add(BasicAlphaNumericRotor());
    rotors.add(BasicAlphaNumericRotor());
    rotorSet = BasicRotorSet(rotors);
  }
}
