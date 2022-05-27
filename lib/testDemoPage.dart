import 'package:enigma_flutter/components/plugboard.dart';
import 'package:enigma_flutter/components/reflector.dart';
import 'package:enigma_flutter/components/rotor.dart';
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
    _encryptionMachine.onCompleted = _onEncryptionCompleted;
    _decryptionMachine.onCompleted = _onDeryptionCompleted;
    super.initState();
  }

  void _onEncryptionCompleted(
      String originalMessage, String transformedMessage) {
    if (originalMessage == message) {}
  }

  void _onDeryptionCompleted(
      String originalMessage, String transformedMessage) {}

  void _setMessage(String message) async {
    String encryptedMessage = "";
    String decryptedMessage = "";
    if (this.message.isNotEmpty &&
        this.message.substring(0, this.message.length - 1) == message) {
      encryptedMessage =
          this.encryptedMessage.substring(0, this.encryptedMessage.length - 1);
      decryptedMessage =
          this.decryptedMessage.substring(0, this.decryptedMessage.length - 1);
    } else {
      encryptedMessage = await _encryptionMachine.transform(message);
      decryptedMessage = await _decryptionMachine.transform(encryptedMessage);
    }
    setState(() {
      this.message = message;
      this.encryptedMessage = encryptedMessage;
      this.decryptedMessage = decryptedMessage;
    });
  }

  String _getAppendedCharacters(String oldMessage, String newMessage) {
    return newMessage.replaceFirst(oldMessage, "");
  }

  /// Append Encrypted characters to existing encrypted messages
  void _appendEncryptedCharacters(String oldMessage, String newMessage) async {
    // Add encrypted character
    String appendedEncCharacters = await _encryptionMachine
        .transform(_getAppendedCharacters(oldMessage, newMessage));
    encryptedMessage += appendedEncCharacters;
    decryptedMessage +=
        await _decryptionMachine.transform(appendedEncCharacters);
  }

  void _addEncryptedCharacterToMessage(String message) async {
    if (message.startsWith(this.message) &&
        message.length > this.message.length) {
      _appendEncryptedCharacters(this.message, message);
    } else {}

    setState(() {
      this.message = message;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: _rawTextBox,
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: _encryptedResultWidget,
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: _decryptedResultWidget,
              )
            ],
          )),
    ));
  }
}
