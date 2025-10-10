import 'package:flutter/widgets.dart';
import 'dart:ui';

/// Lightweight defensive background image loader.
/// Uses `Image.asset` with an `errorBuilder` so Flutter handles
/// asynchronous decoding and errors. This avoids pre-loading bytes
/// via `rootBundle.load` which can block the UI during navigation.
class BackgroundImage extends StatelessWidget {
  final double opacity;
  final String assetPath;
  final double blurSigma;
  const BackgroundImage({
    super.key,
    this.opacity = 0.05,
    required this.assetPath,
    this.blurSigma = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget = Image.asset(
      assetPath,
      fit: BoxFit.cover,
      // If the asset is missing or fails to decode, render nothing.
      errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
    );

    // Apply blur if specified
    if (blurSigma > 0.0) {
      imageWidget = ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: imageWidget,
      );
    }

    return Opacity(
      opacity: opacity,
      child: imageWidget,
    );
  }
}
