import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCsasRpgdcsqdnM5PjnwBIyUaUBq79OK0M',
    appId: '1:184301190803:android:cefc9453f29401a5201766',
    messagingSenderId: '184301190803',
    projectId: 'karakol-tinder',
    storageBucket: 'karakol-tinder.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDGdKY6TFlO5Z0C9HxP975FNj7HfrbbF2o',
    appId: '1:184301190803:ios:3ba68f997408e714201766',
    messagingSenderId: '184301190803',
    projectId: 'karakol-tinder',
    storageBucket: 'karakol-tinder.appspot.com',
    androidClientId:
        '184301190803-o9r96h042t9lrssj9glnssk0r2sh20md.apps.googleusercontent.com',
    iosClientId:
        '184301190803-06tfc0g84e2u17291vp1i8air4hhlrn9.apps.googleusercontent.com',
    iosBundleId: 'com.lancelotcomsanyn.lancelot',
  );
}
