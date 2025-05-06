import 'package:firebase_auth/firebase_auth.dart';

class SignUpController {
  String? email;
  String? password;

  void setEmail(String email) {
    this.email = email;
  }

  void setPassword(String password) {
    this.password = password;
  }

  Future<void> completeSignUp(String email, String password) async {
    this.email = email;
    this.password = password;
    await createNewFireBaseUser();
    print("Sign up comlpeted successfully");
  }

  Future<void> createNewFireBaseUser() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email!, password: password!);
      User? user = userCredential.user;
      print("User created with ID: $user?.uid and email: $user?.email");
    } on FirebaseAuthException catch (e) {
      print("Error saving user data $e");
    }
  }
}
