import 'package:colours/colours.dart';
import 'package:enigma_flutter/components/plugboard.dart';
import 'package:enigma_flutter/components/reflector.dart';
import 'package:enigma_flutter/components/rotor.dart';
import 'package:enigma_flutter/helpers/enigma_mutation_context.dart';
import 'package:enigma_flutter/helpers/mutation_detection.dart';
import 'package:enigma_flutter/machine.dart';
import 'package:enigma_flutter/screw.dart';
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

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

  Widget get _topBar {
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(padding: EdgeInsets.only(left: 10)),
          Expanded(flex: 1, child: ScrewWidget(color: Colours.silver)),
          Expanded(flex: 12, child: Container()),
          Expanded(flex: 1, child: ScrewWidget(color: Colours.silver)),
          Padding(padding: EdgeInsets.only(left: 10)),
        ],
      ),
    );
  }

  Widget get _bottomBar {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(padding: EdgeInsets.only(left: 10)),
          Expanded(flex: 1, child: ScrewWidget(color: Colours.silver)),
          Expanded(flex: 12, child: Container()),
          Expanded(flex: 1, child: ScrewWidget(color: Colours.silver)),
          Padding(padding: EdgeInsets.only(left: 10)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Color(0xFFDEB887),
        child: Column(children: [
          Expanded(
              flex: 38,
              child: Material(
                child: _form,
                color: Colors.transparent,
              )),
          Expanded(
              flex: 2,
              child: Shimmer(
                child: _bottomBar,
                interval: Duration(seconds: 3),
              ))
        ]));
  }
}
