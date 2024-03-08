// import 'package:flutter/material.dart';

class RegistrationFailure {
  final String message;

  const RegistrationFailure([this.message = "Registration Failed"]);

  factory RegistrationFailure.code(String code) {
    switch (code) {
      case 'invalid-email':
        return const RegistrationFailure("Please enter valid email");
      case 'email-already-used':
        return const RegistrationFailure("Email is already used");
     
      default:
        return const RegistrationFailure();
    }
  }
}
