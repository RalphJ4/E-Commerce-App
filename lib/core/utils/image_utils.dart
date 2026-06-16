import 'dart:convert';
import 'package:flutter/material.dart';

ImageProvider? avatarImageProvider(String? avatarUrl) {
  if (avatarUrl == null || avatarUrl.isEmpty) return null;
  if (avatarUrl.startsWith('data:')) {
    final parts = avatarUrl.split(',');
    if (parts.length == 2) {
      final bytes = base64Decode(parts[1]);
      return MemoryImage(bytes);
    }
  }
  return NetworkImage(avatarUrl);
}
