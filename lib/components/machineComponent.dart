import 'package:html_character_entities/html_character_entities.dart';

abstract class MachineComponent {
  /// Generate a json representing the current configuration of the machine component
  Map<String, dynamic> generateConfig();
}

class BasicEnigmaCharacterSet {
  // static List<String> characters = generateCharacterList();
  List<String> generateCharacterList() {
    Set<String> charSet = HtmlCharacterEntities.characters.values.toSet();
    charSet.addAll("۞\n".split(""));
    return charSet.toList();
  }
}
