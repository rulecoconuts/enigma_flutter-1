import 'package:enigma_flutter/components/plugboard.dart';
import 'package:enigma_flutter/components/reflector.dart';
import 'package:enigma_flutter/components/rotor.dart';
import 'package:enigma_flutter/machine.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TestDemoPage extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey();

  final EnigmaMachine _encryptionMachine = BasicEnigmaMachine(
      plugboard: BasicPlugboard(),
      reflector: BasicAlphaNumericReflector(),
      rotorSet: BasicRotorSet([]));

  late final EnigmaMachine _decryptionMachine;

  TestDemoPage() {
    // Setup encryption machine
    _encryptionMachine.plugboard.set("K", "M");
    _encryptionMachine.plugboard.set("d", "p");
    List<Rotor> rotors = [];
    rotors.add(BasicAlphaNumericRotor());
    rotors.add(BasicAlphaNumericRotor());
    rotors.add(BasicAlphaNumericRotor());
    _encryptionMachine.rotorSet = BasicRotorSet(rotors);
    _decryptionMachine =
        EnigmaMachine.config(_encryptionMachine.generateConfig());
  }

  void _onEncryptionCompleted() {}

  Widget get _rawTextBox {
    return TextFormField(
      decoration: InputDecoration(labelText: "Message"),
    );
  }

  Widget get _encryptedResult {
    return Text("");
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: _rawTextBox,
              )
            ],
          )),
    );
  }
}
