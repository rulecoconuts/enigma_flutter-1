import 'package:enigma_flutter/components/plugboard.dart';
import 'package:enigma_flutter/components/reflector.dart';
import 'package:enigma_flutter/components/rotor.dart';
import 'package:enigma_flutter/helpers/enigma_mutation_context.dart';
import 'package:enigma_flutter/helpers/mutation_detection.dart';
import 'package:enigma_flutter/machine.dart';
import 'package:flutter/material.dart';

class TestDemoPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TestDemoPageState();
}

class _TestDemoPageState extends State<TestDemoPage> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  late final EnigmaMutationContext _encryptionContext;
  late final EnigmaMutationContext _decryptionContext;

  @override
  void initState() {
    // Setup encryption and decryption contexts
    _encryptionContext = EnigmaMutationContext(
        machine: EnigmaMachine.basicRandomConfig(),
        onTextTransformed: _textEncrypted);

    _decryptionContext = EnigmaMutationContext(
        machine: EnigmaMachine.config(_encryptionContext.machine.getConfig()),
        onTextTransformed: _textDecrypted);

    super.initState();
  }

  void _textEncrypted(String text, String encryptedText) {
    setState(() {
      _decryptionContext.text = encryptedText;
    });
  }

  void _textDecrypted(String encryptedText, String decryptedText) {
    setState(() {});
  }

  void _addEncryptedCharacterToMessage(String message) async {
    // update text to be encrypted
    _encryptionContext.text = message;
  }

  Widget get _rawTextBox {
    return TextFormField(
      minLines: 1,
      maxLines: 99,
      onChanged: _addEncryptedCharacterToMessage,
      decoration: const InputDecoration(labelText: "Message"),
    );
  }

  Widget get _encryptedResultWidget {
    return Text(_encryptionContext.transformedText);
  }

  Widget get _decryptedResultWidget {
    return Text(_decryptionContext.transformedText);
  }

  Widget get _form {
    return Form(
        key: _formKey,
        child: ListView(
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
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Material(child: _form);
  }
}
