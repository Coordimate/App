import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInApi {
 static final GoogleSignIn _googleSignIn = GoogleSignIn();

  static Future<GoogleSignInAccount?> login() async {
    try {
      return await _googleSignIn.signIn();
    } catch (error) {
      print(error);
      return null;
    }
  }

  static Future<void> logout() async {
    await _googleSignIn.disconnect();
  }
}