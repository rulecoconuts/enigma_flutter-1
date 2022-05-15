import 'dart:collection';

import 'package:enigma_flutter/components/rotor.dart';

/// Reflects characters in pairs
abstract class Reflector {
  String transform(String character);
}

class BasicAlphaNumericReflector extends Reflector {
  final Map<String, String> mapping = {};

  BasicAlphaNumericReflector({Map<String, String>? mapping}) {
    this.mapping.addAll(mapping ?? _generateMapping());
  }

  /// Randomly generate a mapping
  Map<String, String> _generateMapping() {
    List<String> alphabetList = List.generate(
        BasicAlphaNumericRotor.alphaNumerics.length,
        (index) => BasicAlphaNumericRotor.alphaNumerics[index]);

    alphabetList.shuffle();
    Map<String, String> mapping = {};
    while (alphabetList.isNotEmpty) {
      // Select a random pair of alphabets
      String firstChoice = alphabetList.removeAt(0);
      String secondChoice = alphabetList.removeAt(0);
      mapping[firstChoice] = secondChoice;
      mapping[secondChoice] = firstChoice;
    }
    return mapping;
  }

  @override
  String transform(String character) {
    return mapping[character]!;
  }
}
