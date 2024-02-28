# enigma_flutter

# A digital implementation of the German Enigma machine
This project is a highly customizable flutter digital implementation of the German enigma machine's cryptographic scheme, and its parts.

## Goal
This project was created out of curiosity. I wondered how the machine worked, learned how it worked, and decided to solidify my knowledge by creating an implementation of it
in flutter.

## Parts
The main parts are:

<ul>
  <li>Rotorset</li>
  <li>Rotor</li>
  <li>Plugboard</li>
  <li>Reflector</li>
  <li>Enigma Mutation Context</li>
</ul>

### Rotor
The rotor contains 1:1 mappings among the elements of a set of inputs. The basic implementation generates the mappings randomly upon construction.
The rotor's mappings can be changed with a step operation, similar to its mechanical counterpart

### Rotorset
A rotorset holds and synchronizes a set of rotors. When any rotor completes a full rotation, the rotor after it performs a single step.

### Plugboard
An arbitrary mapping of a set of inputs. The plugboard configuration scrambles up the message even further

### Reflector
A reflector is yet another mapping that receives an input from the motorset, maps it to some other value and sends that value through the rotorset in reverse.

### Enigma Mutation Context
The enigma mutation context makes it possible for this implementation of the enigma to perform edit operations (backspace/delete) unlike its mechanical counterpart. It simply keeps track of the various mutations performed on a piece of text and can rewind the machine's configuration back to any moment.


## Serialization
The machine, and all its parts have corresponding factory and serialization methods that make it easy to transfer them to some other user, allowing encrypted communication.

## How to use
The easiest way to use the machine is to wrap it in a Mutation Context which can then be used to monitor text changes;

```dart
// Setup encryption and decryption contexts
EnigmaMutationContext _encryptionContext = EnigmaMutationContext(
                                              machine: EnigmaMachine.basicRandomConfig(),
                                              onTextTransformed: _textEncrypted);

EnigmaMutationContext _decryptionContext = EnigmaMutationContext(
                                              machine: EnigmaMachine.config(_encryptionContext.machine.getConfig()),
                                              onTextTransformed: _textDecrypted);

.
.
.
void _textEncrypted(String text, String encryptedText) {
    setState(() {
      _decryptionContext.text = encryptedText;
    });
}

void _textDecrypted(String encryptedText, String decryptedText) {
    setState(() {});
}
```

Now to encrypt your text:
```dart
_encryptionContext.text = message;
```

To build this example project, run the following commands:
```bash
dart pub get
flutter run
```

## What is next for this project?
Currently, the machine runs on a simple UI.
The next step is to create an aesthetically pleasing UI that matches the look and feel of the original enigma machine.
I am leaning towards a 3D simulator.
