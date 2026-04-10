import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ItemImage extends StatelessWidget {
  final String? imageUrl;
  final double width;
  final double height;
  final BoxFit fit;
  final BorderRadius borderRadius;
  final Color? placeholderColor;
  final IconData placeholderIcon;
  final double iconSize;

  const ItemImage({
    super.key,
    required this.imageUrl,
    this.width = double.infinity,
    required this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = BorderRadius.zero,
    this.placeholderColor,
    this.placeholderIcon = Icons.image,
    this.iconSize = 32,
  });

  @override
  Widget build(BuildContext context) {
    final trimmed = imageUrl?.trim();
    final fallback = Container(
      color: placeholderColor ?? Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
      alignment: Alignment.center,
      child: Icon(placeholderIcon, size: iconSize, color: Colors.white70),
    );

    Widget child;
    if (trimmed == null || trimmed.isEmpty) {
      child = fallback;
    } else if (trimmed.startsWith('data:image/')) {
      final commaIndex = trimmed.indexOf(',');
      if (commaIndex > 0) {
        try {
          final bytes = base64Decode(trimmed.substring(commaIndex + 1));
          child = Image.memory(bytes, fit: fit, width: width, height: height);
        } catch (_) {
          child = fallback;
        }
      } else {
        child = fallback;
      }
    } else if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      child = Image.network(
        trimmed,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (_, __, ___) => fallback,
      );
    } else if (trimmed.startsWith('gs://')) {
      child = FutureBuilder<String>(
        future: FirebaseStorage.instance.refFromURL(trimmed).getDownloadURL(),
        builder: (context, snapshot) {
          final resolvedUrl = snapshot.data;
          if (!snapshot.hasData || resolvedUrl == null || resolvedUrl.isEmpty) {
            return fallback;
          }
          return Image.network(
            resolvedUrl,
            fit: fit,
            width: width,
            height: height,
            errorBuilder: (_, __, ___) => fallback,
          );
        },
      );
    } else {
      child = FutureBuilder<String>(
        future: FirebaseStorage.instance.ref(trimmed).getDownloadURL(),
        builder: (context, snapshot) {
          final resolvedUrl = snapshot.data;
          if (!snapshot.hasData || resolvedUrl == null || resolvedUrl.isEmpty) {
            return fallback;
          }
          return Image.network(
            resolvedUrl,
            fit: fit,
            width: width,
            height: height,
            errorBuilder: (_, __, ___) => fallback,
          );
        },
      );
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(width: width, height: height, child: child),
    );
  }
}