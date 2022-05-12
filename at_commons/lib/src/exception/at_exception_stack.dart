import 'dart:collection';

import 'package:at_commons/src/exception/at_exceptions.dart';

/// Class to maintain stack of exceptions to form a chained exception.
class AtExceptionStack implements Comparable<AtChainedException> {
  final _exceptionList = Queue<AtChainedException>();

  void add(AtChainedException atChainedException) {
    if (compareTo(atChainedException) == 0) {
      return;
    }
    _exceptionList.addFirst(atChainedException);
  }

  /// Concatenate the error messages in the exceptionList and returns a trace message
  String getTraceMessage() {
    var size = _exceptionList.length;
    String fullMessage = '';
    fullMessage =
        '${getIntentMessage(_exceptionList.first.intent)} caused by\n';
    for (AtChainedException element in _exceptionList) {
      size--;
      fullMessage += '${element.atException.message}';
      if (size != 0) {
        fullMessage += ' caused by\n';
      }
    }
    return fullMessage;
  }

  /// Accepts the Intent and returns a message
  String getIntentMessage(Intent intent) {
    if (intent == Intent.fetchData) {
      return 'Failed to fetch data';
    }
    if (intent == Intent.shareData) {
      return 'Failed to share data';
    }
    return 'Failed to notify data';
  }

  @override
  int compareTo(AtChainedException atChainedException) {
    for (var element in _exceptionList) {
      if (element.atException == atChainedException.atException) {
        return 0;
      }
    }
    return 1;
  }
}

class AtChainedException {
  late Intent intent;
  late ExceptionScenario exceptionScenario;
  late AtException atException;

  AtChainedException(this.intent, this.exceptionScenario, this.atException);
}
