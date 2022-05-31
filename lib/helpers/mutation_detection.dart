abstract class Mutation {
  String previousText;
  String newText;

  Mutation({required this.previousText, required this.newText});
}

class Insertion extends Mutation {
  Insertion({required String previousText, required String newText})
      : super(previousText: previousText, newText: newText);
}

class SimpleInsertion extends Insertion {
  String insertedText;
  int index;

  SimpleInsertion(
      {required previousText,
      required newText,
      required this.insertedText,
      required this.index})
      : super(previousText: previousText, newText: newText);
}

class Appendage extends Mutation {
  Appendage({required String previousText, required String newText})
      : super(previousText: previousText, newText: newText);
}

class SimpleAppendage extends Appendage {
  String charactersAppended;

  SimpleAppendage(
      {required String previousText,
      required String newText,
      required this.charactersAppended})
      : super(previousText: previousText, newText: newText);
}

class Prependage extends Mutation {
  Prependage({required String previousText, required String newText})
      : super(previousText: previousText, newText: newText);
}

class SimplePrependage extends Prependage {
  String textPrepended;
  SimplePrependage(
      {required String previousText,
      required String newText,
      required this.textPrepended})
      : super(previousText: previousText, newText: newText);
}

class TruncationAtEnd extends Mutation {
  TruncationAtEnd({required String previousText, required String newText})
      : super(previousText: previousText, newText: newText);
}

class SimpleTruncationAtEnd extends TruncationAtEnd {
  String truncatedText;
  int truncationStart;

  SimpleTruncationAtEnd(
      {required String previousText,
      required String newText,
      required this.truncatedText,
      required this.truncationStart})
      : super(previousText: previousText, newText: newText);
}

/// A utility class meant to classify mutations performed on a text
abstract class TextMutationClassifier {
  void Function(TruncationAtEnd truncationAtEnd)? onTruncationAtEnd;

  void Function(Appendage appendage)? onAppend;

  void Function(Insertion insertion)? onInsert;

  void Function(String previousText, String newText)? onReplaced;

  void Function(Prependage prependage)? onPrepend;

  void classifyMutation(String previousText, String newText);
}

class SimpleEnigmaTextMutationClassifier implements TextMutationClassifier {
  /// Called on appendage detected. If it is not set, appendage detection will
  /// not be performed
  @override
  void Function(Appendage appendage)? onAppend;

  /// Called on insertion detected. If it is not set, insertion detection will
  /// not be performed
  @override
  void Function(Insertion insertion)? onInsert;

  /// Called on truncation detected. If it is not set, truncation detection will
  /// not be performed
  @override
  void Function(TruncationAtEnd truncationAtEnd)? onTruncationAtEnd;

  /// Called on complete text replacement detected. If it is not set, complete
  /// text replacement detection will not be performed
  @override
  void Function(String previousText, String newText)? onReplaced;

  /// Called on prependage detected. If it is not set, prependage detection will
  /// not be performed
  @override
  void Function(Prependage prependage)? onPrepend;

  /// Detects if the previousText was appended to
  Appendage? isAppended(String previousText, String newText) {
    if (newText.startsWith(previousText)) {
      return SimpleAppendage(
          previousText: previousText,
          newText: newText,
          charactersAppended: newText.replaceFirst(previousText, ""));
    }
    return null;
  }

  /// Detects if text was inserted into the previousText
  Insertion? isInserted(String previousText, String newText) {
    if (previousText.length >= newText.length) return null;
    String startingString =
        ""; // Substring of the previous Text that starts the new Text
    int startingPosition = 0; // Starting position of the inserted string

    // Find substring of previous Text that previous Text and new Text both start with
    for (int i = 0; i < previousText.length; i++) {
      String subString = startingString + previousText[i];
      if (!newText.startsWith(subString)) {
        break;
      }
      startingString = subString;
      startingPosition = i + 1;
    }

    if (startingString.isEmpty) return null;
    String remainingPreviousSubString =
        previousText.substring(startingPosition);

    int endPosition = newText.lastIndexOf(remainingPreviousSubString);

    /// It is not an insertion if the insertion could not be found or if the
    /// newText does not end with the remainingPreviousSubString
    if (endPosition == -1 ||
        (endPosition + remainingPreviousSubString.length) != newText.length) {
      return null;
    }
    String insertedCharacters =
        newText.substring(startingPosition, endPosition);

    return SimpleInsertion(
        previousText: previousText,
        newText: newText,
        insertedText: insertedCharacters,
        index: startingPosition);
  }

  /// Detects if previous text was prepended to
  Prependage? isPrepended(String previousText, String newText) {
    if (!newText.endsWith(previousText)) return null;
    return SimplePrependage(
        previousText: previousText,
        newText: newText,
        textPrepended:
            newText.substring(0, newText.length - previousText.length));
  }

  /// Detects if previous text was truncated at end
  TruncationAtEnd? isTruncatedAtEnd(String previousText, String newText) {
    if (previousText.length <= newText.length) return null;
    int numberOfTruncatedCharacters = previousText.length - newText.length;
    if (previousText.substring(0, newText.length) != newText) return null;

    return SimpleTruncationAtEnd(
        previousText: previousText,
        newText: newText,
        truncatedText: previousText.replaceFirst(newText, ""),
        truncationStart: previousText.length - numberOfTruncatedCharacters);
  }

  /// Detect the kind of mutation performed on a previousText based on a new
  /// text. Calls the function associated with the type of mutation detected
  @override
  void classifyMutation(String previousText, String newText) {
    if (onAppend != null) {
      Appendage? appendage = isAppended(previousText, newText);
      if (appendage != null) {
        onAppend!.call(appendage);
        return;
      }
    }

    if (onTruncationAtEnd != null) {
      TruncationAtEnd? truncationAtEnd =
          isTruncatedAtEnd(previousText, newText);
      if (truncationAtEnd != null) {
        onTruncationAtEnd!.call(truncationAtEnd);
        return;
      }
    }

    if (onPrepend != null) {
      Prependage? prependage = isPrepended(previousText, newText);
      if (prependage != null) {
        onPrepend!.call(prependage);
        return;
      }
    }

    if (onInsert != null) {
      Insertion? insertion = isInserted(previousText, newText);
      if (insertion != null) {
        onInsert!.call(insertion);
        return;
      }
    }

    // If none of the defined mutations is detected, we decide that the previous
    // text was just replaced
    if (onReplaced != null) {
      onReplaced!.call(previousText, newText);
    }
  }
}
