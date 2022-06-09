import 'package:enigma_flutter/components/machineComponent.dart';
import 'package:html_character_entities/html_character_entities.dart';

abstract class RotorSet extends MachineComponent {
  void step({bool backwards = false, int nSteps = 1});
  String transform(String character, {bool backwards = false});
  factory RotorSet.config(Map<String, dynamic> json) {
    return BasicRotorSet.config(json["config"]);
  }
}

abstract class Rotor extends MachineComponent {
  set onFullRotation(Function({bool backwards, int nSteps})? onFullRotation);
  Function({bool backwards, int nSteps})? get onFullRotation;
  void step({bool backwards = false, int nSteps = 1});
  String transform(String character, {bool backwards = false});

  /// Generate a rotor from a json configuration
  factory Rotor.config(Map<String, dynamic> json) {
    return BasicAlphaNumericRotor.config(json["config"]);
  }
}

class BasicAlphaNumericRotor implements Rotor {
  static String alphaNumerics = "";

  // Analogous to the mapping from one alphabet to another
  final List<int> wheel = [];

  // Analogous to the wiring
  //late List<String> settings;

  int offsetFromInitialWheelPosition = 0;
  late final bool clockWiseRotate;

  BasicAlphaNumericRotor(
      {List<int>? wheel,
      List<String>? settings,
      this.clockWiseRotate = false}) {
    this.wheel.addAll(wheel ?? _generateWheel());
    //this.settings = settings ?? _generateSettings();
  }

  List<int> _generateWheel() {
    List<int> wheel = List.generate(alphaNumerics.length, (index) => index);
    wheel.shuffle();
    return wheel;
  }

  List<String> _generateSettings() {
    List<String> settings =
        List.generate(alphaNumerics.length, (index) => alphaNumerics[index]);
    settings.shuffle();
    return settings;
  }

  @override
  Function({bool backwards, int nSteps})? onFullRotation;

  /// Get the index of the alphabet
  int _getAlphabetIndex(String character) {
    return alphaNumerics.indexOf(character);
  }

  /// Rotate the wheel a certain number of steps.
  /// The steps are in the direction of this.clockWiseRotate if backwards is false,
  /// and in the opposite direction if backwards is true
  @override
  void step({bool backwards = false, int nSteps = 1}) {
    assert(nSteps >= 1);

    // Select rotation direction
    bool clockWiseRotate =
        backwards ? !this.clockWiseRotate : this.clockWiseRotate;

    int direction = backwards ? -1 : 1;

    // Rotate rotor the number of steps
    for (int i = 0; i < nSteps; i++) {
      if (clockWiseRotate) {
        wheel.insert(0, wheel.removeAt(wheel.length - 1));
      } else {
        wheel.insert(wheel.length - 1, wheel.removeAt(0));
      }

      // Update offset from initial wheel position

      offsetFromInitialWheelPosition =
          (offsetFromInitialWheelPosition + direction) % alphaNumerics.length;

      bool passingFullRotationBackwards = backwards &&
          offsetFromInitialWheelPosition == alphaNumerics.length - 1;
      bool passingFullRotationForward =
          (!backwards) && offsetFromInitialWheelPosition == 0;
      if (passingFullRotationForward || passingFullRotationBackwards) {
        onFullRotation?.call(backwards: backwards, nSteps: nSteps);
      }
    }
  }

  // Inverse of the transform operation
  String _backwardsTransform(String character) {
    return alphaNumerics[wheel.indexOf(_getAlphabetIndex(character))];
  }

  /// Transform a character according to the rotor mapping
  @override
  String transform(String character, {bool backwards = false}) {
    String transformedCharacter = "";
    transformedCharacter = backwards
        ? _backwardsTransform(character)
        : alphaNumerics[wheel[_getAlphabetIndex(character)]];

    return transformedCharacter;
  }

  /// Generate a BasicAlphaNumericRotor from a json configuration
  factory BasicAlphaNumericRotor.config(Map<String, dynamic> json) {
    return BasicAlphaNumericRotor(wheel: json["wheel"]);
  }

  @override
  Map<String, dynamic> generateConfig() {
    return {
      "type": "${this.runtimeType}",
      "config": {"wheel": wheel}
    };
  }
}

/// Basic alphabet rotor set for holding a standard set of basic alphabetic rotors
class BasicRotorSet implements RotorSet {
  List<Rotor> _rotors;

  BasicRotorSet(this._rotors) {
    _setupRotorSetMechanics();
  }

  /// Setup the mechanics by which _rotors affect other _rotors
  void _setupRotorSetMechanics() {
    for (int i = 0; i < _rotors.length; i++) {
      if (i != _rotors.length - 1) {
        // When this rotor completes a full rotation rotate the next rotor one step
        _rotors[i].onFullRotation = (
                {bool backwards = false, int nSteps = 1}) =>
            _rotors[i + 1].step(backwards: backwards, nSteps: nSteps);
      }
    }
  }

  @override
  void step({bool backwards = false, int nSteps = 1}) {
    _rotors.first.step(backwards: backwards, nSteps: nSteps);
  }

  /// Transform a character through the rotors in the rotor set
  @override
  String transform(String character, {bool backwards = false}) {
    String transformedCharacter = character;
    // (backwards ? _rotors.reversed : _rotors)
    //     .fold<String>(
    //         character,
    //         (previousValue, element) =>
    //             element.transform(previousValue, backwards: backwards));

    if (backwards) {
      for (int i = _rotors.length - 1; i >= 0; i--) {
        transformedCharacter =
            _rotors[i].transform(transformedCharacter, backwards: true);
      }
    } else {
      for (int i = 0; i < _rotors.length; i++) {
        transformedCharacter = _rotors[i].transform(transformedCharacter);
      }
    }

    return transformedCharacter;
  }

  /// Generate a BasicRotorSet from a json configuration
  factory BasicRotorSet.config(Map<String, dynamic> json) {
    List<Rotor> rotors = (json["rotors"] as List<Map<String, dynamic>>)
        .map((rotorJson) => Rotor.config(rotorJson))
        .toList();
    return BasicRotorSet(rotors);
  }

  @override
  Map<String, dynamic> generateConfig() {
    return {
      "type": "${this.runtimeType}",
      "config": {
        "rotors": _rotors.map((rotor) => rotor.generateConfig()).toList()
      }
    };
  }
}
