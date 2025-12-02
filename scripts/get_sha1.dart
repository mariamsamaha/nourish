import 'dart:io';

void main() async {
  final userProfile = Platform.environment['USERPROFILE'];
  final keystorePath = '$userProfile\\.android\\debug.keystore';
  
  print('Checking keystore at: $keystorePath');
  
  final result = await Process.run(
    'keytool',
    [
      '-list',
      '-v',
      '-keystore',
      keystorePath,
      '-alias',
      'androiddebugkey',
      '-storepass',
      'android',
      '-keypass',
      'android',
    ],
    runInShell: true,
  );

  if (result.exitCode != 0) {
    print('Error running keytool:');
    print(result.stderr);
    return;
  }

  final output = result.stdout as String;
  final sha1Line = output.split('\n').firstWhere(
    (line) => line.trim().startsWith('SHA1:'),
    orElse: () => 'SHA1 not found',
  );

  print('\nFOUND FINGERPRINT:');
  print(sha1Line.trim());
}
