import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FacebookAuth _facebookAuth = FacebookAuth.instance;

  // 1. Lấy user hiện tại
  User? get currentUser => _auth.currentUser;

  // 2. Đăng ký tài khoản
  Future<UserCredential> signUp(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // 4. Gửi lại Email xác thực
  Future<void> sendVerificationEmail() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  // 6. Kiểm tra trạng thái đã xác thực email chưa
  bool isEmailVerified() {
    return _auth.currentUser?.emailVerified ?? false;
  }

  // 7. Reload để lấy thông tin mới nhất từ Firebase (cần thiết cho email verification)
  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }
  // Hàm Đăng nhập

  Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Đăng nhập bằng Google
  Future<UserCredential> signInWithGoogle() async {
    // 1. Kích hoạt luồng đăng nhập Google
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;

    // 2. Tạo credential cho Firebase
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // 3. Đăng nhập vào Firebase
    return await _auth.signInWithCredential(credential);
  }

  // Đăng nhập bằng Facebook
  Future<UserCredential> signInWithFacebook() async {
    // 1. Kích hoạt luồng đăng nhập Facebook
    final LoginResult loginResult = await _facebookAuth.login();

    if (loginResult.status == LoginStatus.success) {
      final AccessToken accessToken = loginResult.accessToken!;

      // 2. Tạo credential cho Firebase
      final OAuthCredential credential = FacebookAuthProvider.credential(
        accessToken.token,
      );

      // 3. Đăng nhập vào Firebase
      return await _auth.signInWithCredential(credential);
    } else {
      throw Exception('Đăng nhập Facebook thất bại: ${loginResult.message}');
    }
  }

  // Hàm Đăng xuất tất cả (Firebase + Google + Facebook)
  Future<void> signOutAll() async {
    // 1. Thoát Firebase
    await _auth.signOut();

    // 2. Thoát Google
    await _googleSignIn.signOut();

    // 3. Thoát Facebook
    await _facebookAuth.logOut();
  }

  Future<void> signOut() async {
    await signOutAll();
  }
}
