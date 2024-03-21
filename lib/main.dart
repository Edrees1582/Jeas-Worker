import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:jeas_worker/models/custom_user.dart';
import 'package:jeas_worker/resources/auth_methods.dart';
import 'package:jeas_worker/widgets/wrapper.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyBufAw_TgOPQ89P2YMKttwGt3FvL4zo0Eg',
      appId: '1:989353194267:android:970ec4fb60b25f1769d9be',
      messagingSenderId: '989353194267',
      projectId: 'instagram-clone-7d399',
      storageBucket: 'instagram-clone-7d399.appspot.com',
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamProvider<CustomUser?>.value(
      catchError: (context, error) => null,
      value: AuthMethods().user,
      initialData: null,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Jeas Worker',
        theme: ThemeData.light(),
        home: const Wrapper(),
      ),
    );
  }
}
