import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. Lấy user hiện tại
  User? get currentUser => _auth.currentUser;

  // 2. Đăng ký tài khoản
  Future<UserCredential> signUp(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // 3. Đăng nhập
  Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // 4. Gửi lại Email xác thực
  Future<void> sendVerificationEmail() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  // 5. Đăng xuất
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // 6. Kiểm tra trạng thái đã xác thực email chưa
  bool isEmailVerified() {
    return _auth.currentUser?.emailVerified ?? false;
  }

  // 7. Reload để lấy thông tin mới nhất từ Firebase (cần thiết cho email verification)
  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }
}
