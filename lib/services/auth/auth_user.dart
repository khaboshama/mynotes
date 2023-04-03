
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

@immutable
class AuthUser {
 final bool emailVerified;

 const AuthUser(this.emailVerified);

 factory AuthUser.fromFirebase(User user) => AuthUser(user.emailVerified);
}