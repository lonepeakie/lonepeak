import 'package:firebase_auth/firebase_auth.dart' show User;

class AppUser {
  final String displayName;
  final String email;
  final String? phoneNumber;
  final String? profilePictureUrl;

  AppUser({
    required this.displayName,
    required this.email,
    this.phoneNumber,
    this.profilePictureUrl,
  });

  factory AppUser.fromUser(User user) {
    return AppUser(
      displayName: user.displayName ?? '',
      email: user.email ?? '',
      phoneNumber: user.phoneNumber,
      profilePictureUrl: user.photoURL,
    );
  }
}
