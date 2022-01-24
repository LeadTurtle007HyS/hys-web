import 'package:HyS/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_core/firebase_core.dart';

FirebaseApp app = Firebase.app();
auth.FirebaseAuth _auth = auth.FirebaseAuth.instanceFor(app: app);

class AuthService {
  // CrudMethods crudobj = CrudMethods();

  /// Changed to idTokenChanges as it updates depending on more cases.
  // Stream<User> get authStateChanges =>
  //     _auth.idTokenChanges().map(_userFromFirebaseUser);

  // User? _userFromFirebaseUser(auth.User user) {
  //   return user != null ? User(user.uid) : null;
  // }

  /// This won't pop routes so you could do something like
  /// Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
  /// after you called this method if you want to pop all routes.
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (error) {
      print(error.toString());
      return null;
    }
  }

  /// There are a lot of different ways on how you can do exception handling.
  /// This is to make it as easy as possible but a better way would be to
  /// use your own custom class that would take the exception and return better
  /// error messages. That way you can throw, return or whatever you prefer with that instead.
  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      return "Signed in";
    } on auth.FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  /// There are a lot of different ways on how you can do exception handling.
  /// This is to make it as easy as possible but a better way would be to
  /// use your own custom class tha
  /// t would take the exception and return better
  /// error messages. That way you can throw, return or whatever you prefer with that instead.
  Future<String?> signUp(String email, String password, String datetime) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      // crudobj.addUserCallingProfileData("", "", "", email);
      // crudobj.addUserData(
      //     "", "", "", email, "", "", "", "", "", "", "", "", datetime);
      // crudobj.addUserSchoolData("", "", "", "", "", "", "", "", datetime);
      // crudobj.addUserRegistrationProcessStatusData("0", "0", "0", "0");

      return "Signed up";
    } on auth.FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future resetPasswordEmail(String email) async {
    try {
      return await _auth.sendPasswordResetEmail(email: email);
    } catch (error) {
      print(error.toString());
      return 1;
    }
  }
}
