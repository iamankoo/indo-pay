import "dart:io";

import "package:flutter/material.dart";

import "../indo_pay_colors.dart";
import "../indo_pay_tokens.dart";

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.displayName,
    this.profilePhotoPath,
    this.size = 54,
  });

  final String displayName;
  final String? profilePhotoPath;
  final double size;

  @override
  Widget build(BuildContext context) {
    final imagePath = profilePhotoPath;
    if (imagePath != null && imagePath.isNotEmpty && File(imagePath).existsSync()) {
      return ClipOval(
        child: SizedBox.square(
          dimension: size,
          child: Image.file(
            File(imagePath),
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
            errorBuilder: (context, error, stackTrace) {
              return _AvatarPlaceholder(
                displayName: displayName,
                size: size,
              );
            },
          ),
        ),
      );
    }

    return _AvatarPlaceholder(
      displayName: displayName,
      size: size,
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder({
    required this.displayName,
    required this.size,
  });

  final String displayName;
  final double size;

  @override
  Widget build(BuildContext context) {
    final initials = _initialsFor(displayName);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: size,
      width: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: isDark
              ? const [
                  Color(0xFF1F2A52),
                  Color(0xFF273B84),
                ]
              : const [
                  Color(0xFFE8EEFF),
                  Color(0xFFD6E3FF),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : IndoPayColors.shellBorder.withValues(alpha: 0.72),
        ),
        boxShadow: IndoPayShadows.surface(isDark),
      ),
      child: Text(
        initials,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : IndoPayColors.textPrimary,
            ),
      ),
    );
  }

  String _initialsFor(String value) {
    final parts = value
        .trim()
        .split(RegExp(r"\s+"))
        .where((part) => part.isNotEmpty)
        .toList(growable: false);

    if (parts.isEmpty) {
      return "IP";
    }

    final leading = parts.first.substring(0, 1);
    final trailing = parts.length > 1 ? parts.last.substring(0, 1) : "";
    return "$leading$trailing".toUpperCase();
  }
}
