import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Getter to expose the current user
  User? get currentUser => _auth.currentUser;

  Future<void> logout() async {
    try {
      await _auth.signOut();
      Fluttertoast.showToast(msg: "Logged out successfully!");
    } catch (e) {
      Fluttertoast.showToast(msg: "Logout failed: ${e.toString()}");
      throw e;
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      Fluttertoast.showToast(msg: "All fields are required");
      throw Exception("All fields are required");
    }

    if (newPassword != confirmPassword) {
      Fluttertoast.showToast(msg: "New passwords do not match");
      throw Exception("New passwords do not match");
    }

    if (newPassword.length < 6) {
      Fluttertoast.showToast(msg: "Password must be at least 6 characters");
      throw Exception("Password must be at least 6 characters");
    }

    final user = _auth.currentUser;
    if (user == null) {
      Fluttertoast.showToast(msg: "No user signed in");
      throw Exception("No user signed in");
    }

    try {
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
      Fluttertoast.showToast(msg: "Password updated successfully!");
    } catch (e) {
      String errorMessage = "Failed to update password";
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'wrong-password':
            errorMessage = "Current password is incorrect";
            break;
          case 'weak-password':
            errorMessage = "New password is too weak";
            break;
          default:
            errorMessage = "Error: ${e.message}";
        }
      }
      Fluttertoast.showToast(msg: errorMessage);
      throw e;
    }
  }

  Future<void> deleteAccount({required String password}) async {
    if (password.isEmpty) {
      Fluttertoast.showToast(msg: "Password is required");
      throw Exception("Password is required");
    }

    final user = _auth.currentUser;
    if (user == null) {
      Fluttertoast.showToast(msg: "No user signed in");
      throw Exception("No user signed in");
    }

    try {
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
      await _firestore.collection('users').doc(user.uid).delete();
      QuerySnapshot messages = await _firestore
          .collection('chat_messages')
          .where('userId', isEqualTo: user.uid)
          .get();
      for (var doc in messages.docs) {
        await doc.reference.delete();
      }
      await user.delete();
      Fluttertoast.showToast(msg: "Account deleted successfully!");
    } catch (e) {
      String errorMessage = "Failed to delete account";
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'wrong-password':
            errorMessage = "Password is incorrect";
            break;
          default:
            errorMessage = "Error: ${e.message}";
        }
      }
      Fluttertoast.showToast(msg: errorMessage);
      throw e;
    }
  }

  Future<void> updateProfile({required String name}) async {
    if (name.isEmpty) {
      Fluttertoast.showToast(msg: "Name cannot be empty");
      throw Exception("Name cannot be empty");
    }

    final user = _auth.currentUser;
    if (user == null) {
      Fluttertoast.showToast(msg: "No user signed in");
      throw Exception("No user signed in");
    }

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set({'name': name, 'email': user.email}, SetOptions(merge: true));
      Fluttertoast.showToast(msg: "Profile updated successfully!");
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to update profile: $e");
      throw e;
    }
  }

  Future<String?> getUserName() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      return doc.exists ? doc['name'] as String? : null;
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to load profile: $e");
      throw e;
    }
  }
}