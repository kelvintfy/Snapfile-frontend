/*
 * Alex Yip 2021-04-07.
 * utils.dart last modified 2021-04-07.
 */

import 'package:firebase_auth/firebase_auth.dart';

onGoogleSubmit() async {
  GoogleAuthProvider googleProvider = GoogleAuthProvider();
  await FirebaseAuth.instance.signInWithRedirect(googleProvider);
}
