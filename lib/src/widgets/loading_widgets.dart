import 'package:flutter/material.dart';
import '../theme_colors.dart';
import '../theme_provider.dart';
import 'package:provider/provider.dart';

/// Reusable loading widgets and state management patterns for async operations
class LoadingWidgets {
  LoadingWidgets._();
  
  /// Standard loading indicator with optional message
  static Widget loadingIndicator({String? message, double size = 48}) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppLoadingIcon(size: size),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
          ],
        ],
      ),
    );
  }
  
  /// Inline loading indicator (for buttons, smaller spaces)
  static Widget inlineLoading({double size = 16, Color? color}) {
    return SizedBox(
      width: size,
      height: size,
      child: AppLoadingIcon(size: size),
    );
  }
  
  /// Loading scaffold (full screen loading)
  static Widget loadingScaffold({
    String? message,
    PreferredSizeWidget? appBar,
  }) {
    return Scaffold(
      appBar: appBar,
      body: loadingIndicator(message: message),
    );
  }
  
  /// Error widget with retry button
  static Widget errorWidget(
    BuildContext context, {
    required String message,
    VoidCallback? onRetry,
    String retryText = 'Retry',
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline, 
              size: 48, 
              color: AppThemeColors.text(context).withOpacity(0.5)
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                child: Text(retryText),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  /// Empty state widget
  static Widget emptyState(
    BuildContext context, {
    required String message,
    IconData icon = Icons.inbox,
    VoidCallback? onAction,
    String? actionText,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon, 
              size: 64, 
              color: AppThemeColors.text(context).withOpacity(0.5)
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            if (onAction != null && actionText != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionText),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Generic async state management
enum AsyncState { idle, loading, success, error }

/// Mixin for handling common async operations in widgets
mixin AsyncOperationsMixin<T extends StatefulWidget> on State<T> {
  AsyncState _asyncState = AsyncState.idle;
  String? _errorMessage;
  
  AsyncState get asyncState => _asyncState;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _asyncState == AsyncState.loading;
  bool get hasError => _asyncState == AsyncState.error;
  
  /// Execute an async operation with automatic state management
  Future<R?> executeAsync<R>(
    Future<R> Function() operation, {
    void Function(R result)? onSuccess,
    void Function(String error)? onError,
    bool showLoadingState = true,
  }) async {
    if (showLoadingState) {
      setState(() {
        _asyncState = AsyncState.loading;
        _errorMessage = null;
      });
    }
    
    try {
      final result = await operation();
      
      if (mounted) {
        setState(() {
          _asyncState = AsyncState.success;
          _errorMessage = null;
        });
        
        onSuccess?.call(result);
      }
      
      return result;
    } catch (e) {
      final error = e.toString();
      
      if (mounted) {
        setState(() {
          _asyncState = AsyncState.error;
          _errorMessage = error;
        });
        
        onError?.call(error);
      }
      
      return null;
    }
  }
  
  /// Reset async state
  void resetAsyncState() {
    setState(() {
      _asyncState = AsyncState.idle;
      _errorMessage = null;
    });
  }
  
  /// Show loading indicator if loading, otherwise show content
  Widget buildWithAsyncState({
    required Widget Function() builder,
    String? loadingMessage,
    Widget Function(String error)? errorBuilder,
  }) {
    switch (_asyncState) {
      case AsyncState.loading:
        return LoadingWidgets.loadingIndicator(message: loadingMessage);
      case AsyncState.error:
        final error = _errorMessage ?? 'An error occurred';
        return errorBuilder?.call(error) ?? 
               LoadingWidgets.errorWidget(context, message: error);
      default:
        return builder();
    }
  }
}

/// StreamBuilder wrapper with consistent loading/error states
class StreamBuilderWrapper<T> extends StatelessWidget {
  final Stream<T> stream;
  final Widget Function(BuildContext context, T data) builder;
  final Widget Function(BuildContext context, Object error)? errorBuilder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final T? initialData;
  
  const StreamBuilderWrapper({
    super.key,
    required this.stream,
    required this.builder,
    this.errorBuilder,
    this.loadingBuilder,
    this.initialData,
  });
  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
      stream: stream,
      initialData: initialData,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return errorBuilder?.call(context, snapshot.error!) ??
                 LoadingWidgets.errorWidget(
                   context,
                   message: 'Error: ${snapshot.error}',
                 );
        }
        
        if (!snapshot.hasData) {
          return loadingBuilder?.call(context) ??
                 LoadingWidgets.loadingIndicator();
        }
        
        final data = snapshot.data;
        if (data == null) {
          return LoadingWidgets.errorWidget(context, message: 'Data is null');
        }
        
        return builder(context, data);
      },
    );
  }
}

/// FutureBuilder wrapper with consistent loading/error states
class FutureBuilderWrapper<T> extends StatelessWidget {
  final Future<T> future;
  final Widget Function(BuildContext context, T data) builder;
  final Widget Function(BuildContext context, Object error)? errorBuilder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final T? initialData;
  
  const FutureBuilderWrapper({
    super.key,
    required this.future,
    required this.builder,
    this.errorBuilder,
    this.loadingBuilder,
    this.initialData,
  });
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      initialData: initialData,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return errorBuilder?.call(context, snapshot.error!) ??
                 LoadingWidgets.errorWidget(
                   context,
                   message: 'Error: ${snapshot.error}',
                 );
        }
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingBuilder?.call(context) ??
                 LoadingWidgets.loadingIndicator();
        }
        
        if (!snapshot.hasData) {
          return LoadingWidgets.emptyState(
            context,
            message: 'No data available',
          );
        }
        
        final data = snapshot.data;
        if (data == null) {
          return LoadingWidgets.errorWidget(context, message: 'Data is null');
        }
        
        return builder(context, data);
      },
    );
  }
}

/// Small rotating app icon used as a loading indicator.
class AppLoadingIcon extends StatefulWidget {
  final double size;
  final Duration duration;

  const AppLoadingIcon({super.key, this.size = 48, this.duration = const Duration(milliseconds: 1200)});

  @override
  State<AppLoadingIcon> createState() => _AppLoadingIconState();
}

class _AppLoadingIconState extends State<AppLoadingIcon> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: Image.asset(
        'assets/float_it_no_text.png',
        width: widget.size,
        height: widget.size,
        fit: BoxFit.contain,
      ),
    );
  }
}

/// Theme-aware app icon that shows different icons for light and dark mode
class ThemeAwareAppIcon extends StatelessWidget {
  final double width;
  final double height;
  final BoxFit fit;

  const ThemeAwareAppIcon({
    super.key,
    this.width = 28,
    this.height = 28,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDark;
        final iconPath = isDark ? 'assets/float_it_dark_mode.png' : 'assets/float_it.png';

        return Image.asset(
          iconPath,
          width: width,
          height: height,
          fit: fit,
        );
      },
    );
  }
}