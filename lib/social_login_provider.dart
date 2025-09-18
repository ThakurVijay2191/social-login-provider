import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';

/// A unified social login provider supporting Google, Apple, and Facebook.
///
/// Example usage:
/// ```dart
/// final loginProvider = SocialLoginProvider(appleGroupId: 'com.example.app');
/// final user = await loginProvider.signInWithGoogle();
/// ```
class SocialLoginProvider {
  /// The optional Apple group ID for iOS secure storage.
  ///
  /// If provided, Apple credentials will be stored in the specified
  /// App Group. If null, defaults to standard secure storage.
  final String? appleGroupId;

  /// Creates a new instance of [SocialLoginProvider].
  ///
  /// [appleGroupId] is only needed if you are using Apple Sign In
  /// with App Group storage on iOS.
  SocialLoginProvider({this.appleGroupId});

  /// Signs in the user using Google.
  ///
  /// Returns a [SocialUser] with the user's ID, email, display name, and photo URL.
  /// If the user cancels the sign-in, returns null.
  Future<SocialUser?> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

    // Ensure no previous sign-in session exists
    if (await googleSignIn.isSignedIn()) {
      await googleSignIn.signOut();
    }

    final user = await googleSignIn.signIn();

    if (user == null) return null;

    return SocialUser(
      userId: user.id,
      email: user.email,
      fullName: user.displayName,
      image: user.photoUrl,
    );
  }

  /// Signs in the user using Apple Sign-In.
  ///
  /// Uses [FlutterSecureStorage] to store email and full name securely.
  /// Returns a [SocialUser] with the user's Apple ID, stored email, and name.
  /// If Apple credentials are partially missing, stored values are used.
  Future<SocialUser?> signInWithApple() async {
    final rawNonce = generateNonce();

    final secureStorage = FlutterSecureStorage(
      iOptions: IOSOptions(groupId: appleGroupId),
    );

    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: rawNonce,
      state: generateNonce(),
    );

    // If Apple provides new email or name, overwrite stored values
    if (appleCredential.email != null && appleCredential.givenName != null) {
      await secureStorage.write(
        key: "apple_email",
        value: appleCredential.email,
      );
      await secureStorage.write(
        key: "apple_full_name",
        value:
            "${appleCredential.givenName ?? ""} ${appleCredential.familyName ?? ""}",
      );
    }

    // Read stored values (new or old)
    final storedEmail = await secureStorage.read(key: "apple_email");
    final storedFullName = await secureStorage.read(key: "apple_full_name");

    return SocialUser(
      userId: appleCredential.userIdentifier,
      email: storedEmail,
      fullName: storedFullName,
      image: null,
    );
  }

  /// Generates a cryptographically secure random nonce.
  ///
  /// [length] defines the number of random bytes (default 32).
  /// Returns a hexadecimal string representing the nonce.
  String generateNonce([int length = 32]) {
    final random = Random.secure();
    final values = List<int>.generate(length, (_) => random.nextInt(256));
    return values.map((e) => e.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Signs in the user using Facebook.
  ///
  /// Requests [publicProfile] and [email] permissions.
  /// Returns a [SocialUser] with the user's Facebook ID, name, email, and profile image.
  /// Returns null if the user cancels login or if an error occurs.
  Future<SocialUser?> signInWithFacebook() async {
    final fb = FacebookLogin();

    final res = await fb.logIn(
      permissions: [FacebookPermission.publicProfile, FacebookPermission.email],
    );

    switch (res.status) {
      case FacebookLoginStatus.success:
        final profile = await fb.getUserProfile();
        final imageUrl = await fb.getProfileImageUrl(width: 100);
        final email = await fb.getUserEmail();

        return SocialUser(
          userId: profile?.userId,
          email: email,
          fullName: profile?.name,
          image: imageUrl,
        );

      case FacebookLoginStatus.cancel:
        return null;

      case FacebookLoginStatus.error:
        print('Error while logging in with Facebook: ${res.error}');
        return null;
    }
  }
}

/// Represents a social user returned from Google, Apple, or Facebook login.
class SocialUser {
  /// The unique user identifier from the social provider.
  final String? userId;

  /// The user's email address, if available.
  final String? email;

  /// The user's full name, if available.
  final String? fullName;

  /// The user's profile image URL, if available.
  final String? image;

  /// Creates a new instance of [SocialUser].
  ///
  /// All fields are optional, as some social logins may not provide them.
  SocialUser({
    required this.userId,
    required this.email,
    required this.fullName,
    required this.image,
  });
}
