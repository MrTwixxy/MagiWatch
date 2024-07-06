import 'dart:convert';

extension StringExtension on String {
  String capitalize() {
    return length > 0 ? "${this[0].toUpperCase()}${substring(1)}" : "";
  }
}

extension IsSomething on String {
  bool get isBase64 {
    try {
      base64.decode(this);
      return true;
    } catch (e) {
      return false;
    }
  }
}
