/// Represents the enigma plugboard
/// It's a static mapping from one character to another
abstract class Plugboard {
  String transform(String character);

  /// Set the mapping from a character to another
  void set(String from, String to);

  /// Remove the mapping from the character
  void remove(String from);
}

class BasicPlugboard implements Plugboard {
  final Map<String, String> _setting = {};
  @override
  String transform(String character) {
    String? tranformedCharacter = _setting[character];
    return tranformedCharacter ?? character;
  }

  @override
  void set(String from, String to) {
    _setting[from] = to;
  }

  @override
  void remove(String from) {
    _setting.remove(from);
  }
}
