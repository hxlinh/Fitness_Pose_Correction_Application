import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutterproject/app.dart';
import 'package:flutterproject/firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  

  // Khởi tạo Firebase
  if(kIsWeb) {
    await Firebase.initializeApp(options: const FirebaseOptions(
    apiKey: "AIzaSyBuOkFWW-Lh4_baQwx9-bk4lJ1ube93ehc",
    appId: "1:874531864475:ios:1a2574c055894af92f2b3e", 
    messagingSenderId: "874531864475", 
    projectId: "flutterproject-9fa77",
    authDomain: "flutterproject-9fa77.firebaseapp.com",
    storageBucket: "flutterproject-9fa77.appspot.com",
  ));
  }else{
    await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  }
  
  runApp( const App());
}