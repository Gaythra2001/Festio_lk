// Firebase initialization - only used when useFirebase is true
// This file is kept separate to avoid compilation errors in demo mode

import 'package:firebase_core/firebase_core.dart';
import '../../firebase_options.dart';

Future<void> initializeFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

