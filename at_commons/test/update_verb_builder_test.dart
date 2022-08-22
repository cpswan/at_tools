import 'package:at_commons/at_builders.dart';
import 'package:at_commons/at_commons.dart';
import 'package:test/test.dart';

import 'syntax_test.dart';

void main() {
  group('A group of update verb builder tests to check update command', () {
    test('verify public at key command', () {
      var updateBuilder = UpdateVerbBuilder()
        ..value = 'alice@gmail.com'
        ..isPublic = true
        ..atKey = 'email'
        ..sharedBy = 'alice';
      expect(updateBuilder.buildCommand(),
          'update:public:email@alice alice@gmail.com\n');
    });

    test('verify private at key command', () {
      var updateBuilder = UpdateVerbBuilder()
        ..value = 'alice@atsign.com'
        ..atKey = 'email'
        ..sharedBy = 'alice';
      expect(updateBuilder.buildCommand(),
          'update:email@alice alice@atsign.com\n');
    });

    test('verify shared key command', () {
      var updateBuilder = UpdateVerbBuilder()
        ..value = 'alice@atsign.com'
        ..atKey = 'email'
        ..sharedBy = 'alice'
        ..sharedWith = 'bob'
        ..pubKeyChecksum = '123'
        ..sharedKeyEncrypted = 'abc';
      expect(updateBuilder.buildCommand(),
          'update:sharedKeyEnc:abc:pubKeyCS:123:@bob:email@alice alice@atsign.com\n');
    });
  });

  group('A group of update verb builder tests to check update metadata command',
      () {
    test('verify isBinary metadata', () {
      var updateBuilder = UpdateVerbBuilder()
        ..isBinary = true
        ..atKey = 'phone'
        ..sharedBy = 'alice';
      expect(updateBuilder.buildCommandForMeta(),
          'update:meta:phone@alice:isBinary:true\n');
    });

    test('verify ttl metadata', () {
      var updateBuilder = UpdateVerbBuilder()
        ..ttl = 60000
        ..atKey = 'phone'
        ..sharedBy = 'alice';
      expect(updateBuilder.buildCommandForMeta(),
          'update:meta:phone@alice:ttl:60000\n');
    });

    test('verify ttr metadata', () {
      var updateBuilder = UpdateVerbBuilder()
        ..ttr = 50000
        ..atKey = 'phone'
        ..sharedBy = 'alice';
      expect(updateBuilder.buildCommandForMeta(),
          'update:meta:phone@alice:ttr:50000\n');
    });

    test('verify ttb metadata', () {
      var updateBuilder = UpdateVerbBuilder()
        ..ttb = 80000
        ..atKey = 'phone'
        ..sharedBy = 'alice';
      expect(updateBuilder.buildCommandForMeta(),
          'update:meta:phone@alice:ttb:80000\n');
    });

    test('verify isEncrypted and sharedkey metadata', () {
      var updateBuilder = UpdateVerbBuilder()
        ..isEncrypted = true
        ..atKey = 'phone'
        ..sharedBy = 'alice'
        ..sharedWith = 'bob'
        ..pubKeyChecksum = '123'
        ..sharedKeyEncrypted = 'abc';
      expect(updateBuilder.buildCommandForMeta(),
          'update:meta:@bob:phone@alice:isEncrypted:true:sharedKeyEnc:abc:pubKeyCS:123\n');
    });
  });

  group('A group of positive tests to validate the update regex', () {
    test('validate update regex', () {
      var inputToExpectedOutput = {
        'update:ttl:10000:ttb:10000:ttr:10000:ccd:true:dataSignature:123456:encoding:base64:public:phone@bob 12345':
            {
          'ttl': '10000',
          'ttb': '10000',
          'ttr': '10000',
          'ccd': 'true',
          'dataSignature': '123456',
          'encoding': 'base64',
          'forAtSign': null,
          'atKey': 'phone',
          'atSign': 'bob',
          'value': '12345'
        }
      };
      inputToExpectedOutput.forEach((command, expectedVerbParams) {
        test('validating regex for $command', () {
          var actualVerbParams = getVerbParams(VerbSyntax.update, command);
          for (var key in expectedVerbParams.keys) {
            expect(actualVerbParams[key], expectedVerbParams[key]);
          }
        });
      });
    });
    test('validate update command with negative ttl and ttr', () {
      final updateCommand =
          'update:ttl:-1:ttr:-1:dataSignature:abc:isBinary:false:isEncrypted:false:public:kryz.kryz_9850@kryz_9850 {"stationName":"KRYZ","frequency":"98.5 Mhz"}';
      var actualVerbParams = getVerbParams(VerbSyntax.update, updateCommand);
      expect(actualVerbParams[AT_TTL], '-1');
      expect(actualVerbParams[AT_TTR], '-1');
      expect(actualVerbParams[AT_KEY], 'kryz.kryz_9850');
      expect(actualVerbParams[AT_SIGN], 'kryz_9850');
    });
    test('validate update command with negative ttl and ttb', () {
      final updateCommand =
          'update:ttl:-1:ttb:-1:dataSignature:abc:isBinary:false:isEncrypted:false:public:kryz.kryz_9850@kryz_9850 {"stationName":"KRYZ","frequency":"98.5 Mhz"}';
      var actualVerbParams = getVerbParams(VerbSyntax.update, updateCommand);
      expect(actualVerbParams[AT_TTL], '-1');
      expect(actualVerbParams[AT_TTB], '-1');
      expect(actualVerbParams[AT_KEY], 'kryz.kryz_9850');
      expect(actualVerbParams[AT_SIGN], 'kryz_9850');
    });
    test('validate update meta command with negative ttl and ttr', () {
      final updateCommand =
          'update:meta:public:kryz.kryz_9850@kryz_9850:ttl:-1:ttr:-1';
      var actualVerbParams =
          getVerbParams(VerbSyntax.update_meta, updateCommand);
      expect(actualVerbParams[AT_TTL], '-1');
      expect(actualVerbParams[AT_TTR], '-1');
      expect(actualVerbParams[AT_KEY], 'kryz.kryz_9850');
      expect(actualVerbParams[AT_SIGN], 'kryz_9850');
    });
    test('validate update meta command with negative ttl and ttr', () {
      final updateCommand =
          'update:meta:public:kryz.kryz_9850@kryz_9850:ttl:-1:ttb:-1';
      var actualVerbParams =
          getVerbParams(VerbSyntax.update_meta, updateCommand);
      expect(actualVerbParams[AT_TTL], '-1');
      expect(actualVerbParams[AT_TTB], '-1');
      expect(actualVerbParams[AT_KEY], 'kryz.kryz_9850');
      expect(actualVerbParams[AT_SIGN], 'kryz_9850');
    });
  });

  group('A group of negative test on update verb regex', () {
    test('update verb with encoding value not specified', () {
      var command = 'update:encoding:@alice:phone@bob 123';
      var actualVerbParams = getVerbParams(VerbSyntax.update, command);
      expect(actualVerbParams.length, 0);
    });
  });
}
