import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jeas_worker/models/custom_user.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CustomUser _userFromFirebaseUser(User? user) {
    return CustomUser(uid: user!.uid);
  }

  Stream<CustomUser> get user {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }

  Future<String> signUpWorker({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
  }) async {
    String res = "Some error occurred";

    try {
      if (email.isNotEmpty ||
          password.isNotEmpty ||
          name.isNotEmpty ||
          phoneNumber.isNotEmpty) {
        UserCredential userCredential = await _auth
            .createUserWithEmailAndPassword(email: email, password: password);

        await _firestore
            .collection('workers')
            .doc(userCredential.user!.uid)
            .set({
          'uid': userCredential.user!.uid,
          'name': name,
          'email': email,
          'phoneNumber': phoneNumber,
          'requests': [],
          'messages': []
        });

        res = "success";
      }
    } catch (err) {
      res = err.toString();
    }

    return res;
  }

  Future<String> login({
    required String email,
    required String password,
  }) async {
    String res = "Some error occurred";

    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);

        res = "success";
      }
    } catch (err) {
      res = err.toString();
    }

    return res;
  }

  Future<String> logout() async {
    String res = "Some error occurred";

    try {
      await _auth.signOut();

      res = "success";
    } catch (err) {
      res = err.toString();
    }

    return res;
  }
}
