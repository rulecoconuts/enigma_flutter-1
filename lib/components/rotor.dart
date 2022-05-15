abstract class RotorSet {
  void step();
  String transform(String character, {bool backwards = false});
}

abstract class Rotor {
  set onFullRotation(Function()? onFullRotation);
  Function()? get onFullRotation;
  void step();
  String transform(String character, {bool backwards = false});
}

class BasicAlphaNumericRotor implements Rotor {
  static const String alphaNumerics =
      "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

  // Analogous to the mapping from one alphabet to another
  late List<int> wheel;

  // Analogous to the wiring
  //late List<String> settings;

  int offsetFromInitialWheelPosition = 0;

  BasicAlphaNumericRotor({List<int>? wheel, List<String>? settings}) {
    this.wheel = wheel ?? _generateWheel();
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
  Function()? onFullRotation;

  /// Get the index of the alphabet
  int _getAlphabetIndex(String character) {
    return alphaNumerics.indexOf(character);
  }

  /// Rotate the wheel one step
  @override
  void step() {
    wheel.insert(wheel.length - 1, wheel.removeAt(0));
    offsetFromInitialWheelPosition =
        (offsetFromInitialWheelPosition + 1) % alphaNumerics.length;
    if (offsetFromInitialWheelPosition == 0) onFullRotation?.call();
  }

  // Inverse of the transform operation
  String _backwardsTransform(String character) {
    return alphaNumerics[wheel.indexOf(_getAlphabetIndex(character))];
  }

  /// Transform a character according to the rotor mapping
  @override
  String transform(String character, {bool backwards = false}) {
    return backwards
        ? _backwardsTransform(character)
        : alphaNumerics[wheel[_getAlphabetIndex(character)]];
  }
}

/// Basic alphabet rotor set for holding a standard set of basic alphabetic rotors
class BasicAlphaNumericRotorSet implements RotorSet {
  List<BasicAlphaNumericRotor> _rotors;

  BasicAlphaNumericRotorSet(this._rotors) {
    _setupRotorSetMechanics();
  }

  /// Setup the mechanics by which _rotors affect other _rotors
  void _setupRotorSetMechanics() {
    for (int i = 0; i < _rotors.length; i++) {
      if (i != _rotors.length - 1) {
        // When this rotor completes a full rotation rotate the next rotor one step
        _rotors[i].onFullRotation = () => _rotors[i + 1].step();
      }
    }
  }

  @override
  void step() {
    _rotors.first.step();
  }

  /// Transform a character through the rotors in the rotor set
  @override
  String transform(String character, {bool backwards = false}) {
    return _rotors.fold<String>(
        character,
        (previousValue, element) =>
            element.transform(previousValue, backwards: backwards));
  }
}
