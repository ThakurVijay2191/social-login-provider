# social_login_provider

A unified Flutter social login provider for **Google**, **Apple**, and **Facebook**.  
Handles authentication and returns user information in a single `SocialUser` object.

[![pub package](https://img.shields.io/pub/v/social_login_provider.svg)](https://pub.dev/packages/social_login_provider)

---

## Features

- Sign in with **Google**, **Apple**, or **Facebook**
- Returns user ID, email, full name, and profile image
- Supports **Apple secure storage** with App Groups
- Fully documented and easy to integrate

---

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  social_login_provider: ^0.0.1
```

## Usage

1. Import the package:

```dart
import 'package:social_login_provider/social_login_provider.dart';

final loginProvider = SocialLoginProvider(
  appleGroupId: 'com.example.app', // optional for Apple Sign In
);

// Google login
final googleUser = await loginProvider.signInWithGoogle();
print('Google user: ${googleUser?.fullName}');

// Apple login
final appleUser = await loginProvider.signInWithApple();
print('Apple user: ${appleUser?.fullName}');

// Facebook login
final facebookUser = await loginProvider.signInWithFacebook();
print('Facebook user: ${facebookUser?.fullName}');
```

---

## **2️⃣ Optional: Full Flutter example snippet**

````markdown
```dart
import 'package:flutter/material.dart';
import 'package:social_login_provider/social_login_provider.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final loginProvider = SocialLoginProvider();

    return Scaffold(
      appBar: AppBar(title: const Text('Social Login Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                final user = await loginProvider.signInWithGoogle();
                print('Google user: ${user?.fullName}');
              },
              child: const Text('Sign in with Google'),
            ),
            ElevatedButton(
              onPressed: () async {
                final user = await loginProvider.signInWithApple();
                print('Apple user: ${user?.fullName}');
              },
              child: const Text('Sign in with Apple'),
            ),
            ElevatedButton(
              onPressed: () async {
                final user = await loginProvider.signInWithFacebook();
                print('Facebook user: ${user?.fullName}');
              },
              child: const Text('Sign in with Facebook'),
            ),
          ],
        ),
      ),
    );
  }
}
```
````
