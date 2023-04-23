import 'package:enigma_flutter/helpers/mutation_detection.dart';
import 'package:enigma_flutter/machine.dart';

/// Context of an enigma machine.
/// It keeps track of the various mutations performed on a text
class EnigmaMutationContext {
  String _text = "";
  String _transformedText = "";
  final EnigmaMachine machine;
  TextMutationClassifier textMutationClassifier =
      SimpleEnigmaTextMutationClassifier();

  Function(String text, String transformedText) onTextTransformed;

  EnigmaMutationContext(
      {required this.machine, required this.onTextTransformed}) {
    _configureTextMutationClassifier();
  }

  String get transformedText => _transformedText;

  set text(String newText) {
    textMutationClassifier.classifyMutation(_text, newText);
  }

  void _configureTextMutationClassifier() {
    textMutationClassifier.onAppend = _appendText;
    textMutationClassifier.onTruncationAtEnd = _truncateTextAtEnd;
    textMutationClassifier.onReplaced = _replaceText;
  }

  /// Handle appendage to input text
  void _appendText(Appendage appendage) async {
    if (appendage.previousText != _text) return;
    SimpleAppendage simpleAppendage = appendage as SimpleAppendage;

    // Add new characters to encrypted _text
    String encryptedAppendage =
        await machine.transform(simpleAppendage.charactersAppended);

    _transformedText += encryptedAppendage;
    _text = appendage.newText;
    onTextTransformed(_text, _transformedText);
  }

  /// Handle truncation from end of input text
  void _truncateTextAtEnd(TruncationAtEnd truncationAtEnd) {
    if (truncationAtEnd.previousText != _text) return;
    SimpleTruncationAtEnd simpleTruncationAtEnd =
        truncationAtEnd as SimpleTruncationAtEnd;

    //_text = _text.substring(0, simpleTruncationAtEnd.truncationStart);
    _transformedText =
        _transformedText.substring(0, simpleTruncationAtEnd.truncationStart);

    // Revert the rotors of both machines to just before the truncated text was added
    machine.rotorSet.step(
        backwards: true, nSteps: simpleTruncationAtEnd.truncatedText.length);
    _text = truncationAtEnd.newText;
    onTextTransformed(_text, _transformedText);
  }

  /// Handle complete replacement of input text
  void _replaceText(String previousText, String newText) async {
    if (previousText != _text) return;
    // Revert the rotors to their initial state
    machine.rotorSet.step(backwards: true, nSteps: previousText.length);

    _transformedText = await machine.transform(newText);
    _text = newText;
    onTextTransformed(_text, _transformedText);
  }
}
