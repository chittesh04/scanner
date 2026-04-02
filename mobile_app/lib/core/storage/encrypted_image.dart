import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartscan/core/di/service_locator.dart';
import 'package:shimmer/shimmer.dart';

/// A simple LRU cache for decrypted image bytes, shared across all
/// [EncryptedImage] instances. Avoids re-spawning an isolate + AES-GCM
/// decrypt on every widget rebuild / scroll.
class _ImageCache {
  static const _maxEntries = 24;

  final _cache = <String, Uint8List>{};

  Uint8List? get(String key) {
    final value = _cache.remove(key);
    if (value != null) {
      // Move to end (most recently used).
      _cache[key] = value;
    }
    return value;
  }

  void put(String key, Uint8List value) {
    _cache.remove(key);
    _cache[key] = value;
    while (_cache.length > _maxEntries) {
      _cache.remove(_cache.keys.first);
    }
  }
}

final _sharedCache = _ImageCache();

/// Decrypts an AES-GCM encrypted image file and displays it.
///
/// Uses an in-memory LRU cache so that scrolling through a document list
/// does not re-decrypt the same files on every rebuild.
class EncryptedImage extends ConsumerStatefulWidget {
  const EncryptedImage({
    super.key,
    required this.imagePath,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  final String imagePath;
  final BoxFit fit;
  final double? width;
  final double? height;

  @override
  ConsumerState<EncryptedImage> createState() => _EncryptedImageState();
}

class _EncryptedImageState extends ConsumerState<EncryptedImage> {
  Uint8List? _bytes;
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(EncryptedImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imagePath != widget.imagePath) {
      _load();
    }
  }

  Future<void> _load() async {
    // Check LRU cache first.
    final cached = _sharedCache.get(widget.imagePath);
    if (cached != null) {
      if (mounted) {
        setState(() {
          _bytes = cached;
          _loading = false;
          _error = false;
        });
      }
      return;
    }

    setState(() {
      _loading = true;
      _error = false;
    });

    try {
      final storage = ref.read(fileStorageProvider);
      final bytes = await storage.readEncrypted(File(widget.imagePath));
      _sharedCache.put(widget.imagePath, bytes);
      if (mounted) {
        setState(() {
          _bytes = bytes;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Shimmer.fromColors(
        baseColor: Colors.black12,
        highlightColor: Colors.white54,
        child: Container(
          width: widget.width,
          height: widget.height,
          color: Colors.white,
        ),
      );
    }

    if (_error || _bytes == null) {
      return const Center(child: Icon(Icons.broken_image, size: 48));
    }

    return Image.memory(
      _bytes!,
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
      gaplessPlayback: true, // Prevent flicker during hero transitions.
    );
  }
}
