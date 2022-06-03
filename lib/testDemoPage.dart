import 'package:enigma_flutter/components/plugboard.dart';
import 'package:enigma_flutter/components/reflector.dart';
import 'package:enigma_flutter/components/rotor.dart';
import 'package:enigma_flutter/helpers/mutation_detection.dart';
import 'package:enigma_flutter/machine.dart';
import 'package:flutter/material.dart';

class TestDemoPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TestDemoPageState();
}

class _TestDemoPageState extends State<TestDemoPage> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  final EnigmaMachine _encryptionMachine = BasicEnigmaMachine(
      plugboard: BasicPlugboard(),
      reflector: BasicAlphaNumericReflector(),
      rotorSet: BasicRotorSet([]));

  late final EnigmaMachine _decryptionMachine;
  String message = "";
  String encryptedMessage = "";
  String decryptedMessage = "";
  late Map<String, dynamic> _lastEncryptionConfig;
  final TextMutationClassifier _textMutationClassifier =
      SimpleEnigmaTextMutationClassifier();

  @override
  void initState() {
    // Setup encryption machine
    _encryptionMachine.plugboard.set("K", "M");
    _encryptionMachine.plugboard.set("d", "p");
    _encryptionMachine.plugboard.set("q", "x");

    // Set rotors
    List<Rotor> rotors = [];
    rotors.add(BasicAlphaNumericRotor());
    rotors.add(BasicAlphaNumericRotor());
    rotors.add(BasicAlphaNumericRotor());
    _encryptionMachine.rotorSet = BasicRotorSet(rotors);

    _lastEncryptionConfig = _encryptionMachine.generateConfig();

    // Copy encryption config to decryption machine
    _decryptionMachine = EnigmaMachine.config(_lastEncryptionConfig);

    _configureTextMutationClassifier();
    super.initState();
  }

  void _configureTextMutationClassifier() {
    _textMutationClassifier.onAppend = _appendText;
    _textMutationClassifier.onTruncationAtEnd = _truncateTextAtEnd;
    _textMutationClassifier.onReplaced = _replaceText;
  }

  /// Handle appendage to input text
  void _appendText(Appendage appendage) async {
    if (appendage.previousText != message) return;
    SimpleAppendage simpleAppendage = appendage as SimpleAppendage;

    // Add new characters to encrypted message
    String encryptedAppendage =
        await _encryptionMachine.transform(simpleAppendage.charactersAppended);

    encryptedMessage += encryptedAppendage;

    // Decrypt new encrypted message
    decryptedMessage += await _decryptionMachine.transform(encryptedAppendage);

    setState(() {
      message = appendage.newText;
    });
  }

  /// Handle truncation from end of input text
  void _truncateTextAtEnd(TruncationAtEnd truncationAtEnd) {
    if (truncationAtEnd.previousText != message) return;
    SimpleTruncationAtEnd simpleTruncationAtEnd =
        truncationAtEnd as SimpleTruncationAtEnd;

    //message = message.substring(0, simpleTruncationAtEnd.truncationStart);
    encryptedMessage =
        encryptedMessage.substring(0, simpleTruncationAtEnd.truncationStart);
    decryptedMessage =
        decryptedMessage.substring(0, simpleTruncationAtEnd.truncationStart);

    // Revert the rotors of both machines to just before the truncated text was added
    _encryptionMachine.rotorSet.step(
        backwards: true, nSteps: simpleTruncationAtEnd.truncatedText.length);
    _decryptionMachine.rotorSet.step(
        backwards: true, nSteps: simpleTruncationAtEnd.truncatedText.length);

    setState(() {
      message = truncationAtEnd.newText;
    });
  }

  /// Handle complete replacement of input text
  void _replaceText(String previousText, String newText) async {
    if (previousText != message) return;
    // Revert the rotors to their initial state
    _encryptionMachine.rotorSet
        .step(backwards: true, nSteps: previousText.length);
    _decryptionMachine.rotorSet
        .step(backwards: true, nSteps: previousText.length);

    encryptedMessage = await _encryptionMachine.transform(newText);
    decryptedMessage = await _decryptionMachine.transform(encryptedMessage);

    setState(() {
      message = newText;
    });
  }

  void _addEncryptedCharacterToMessage(String message) async {
    // Classify mutation performed on input text
    _textMutationClassifier.classifyMutation(this.message, message);
  }

  Widget get _rawTextBox {
    return TextFormField(
      onChanged: _addEncryptedCharacterToMessage,
      decoration: const InputDecoration(labelText: "Message"),
    );
  }

  Widget get _encryptedResultWidget {
    return Text(encryptedMessage);
  }

  Widget get _decryptedResultWidget {
    return Text(decryptedMessage);
  }

  Widget get _form {
    return Form(
        key: _formKey,
        child: Column(
          children: [
            Flexible(
                fit: FlexFit.loose,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: _rawTextBox,
                )),
            Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: _encryptedResultWidget,
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: _decryptedResultWidget,
            )
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(
      child: SingleChildScrollView(child: LayoutBuilder(
        builder: ((context, constraints) {
          return ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child:
                    Column(mainAxisSize: MainAxisSize.max, children: [_form]),
              ));
        }),
      )),
    ));
  }
}
