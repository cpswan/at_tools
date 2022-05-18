import 'package:at_commons/src/verb/verb_builder.dart';

class SetVerbBuilder implements VerbBuilder {
  //name of the configuration that is to be modified
  String? configName;

  //value to which above mentioned configuration is changed
  String? configValue;

  @override
  String buildCommand() {
    return 'set:' + configName! + ':' + configValue! + '\n';
  }

  @override
  bool checkParams() {
    return configName != null && configValue != null;
  }
}
