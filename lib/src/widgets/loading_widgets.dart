import 'package:flutter/material.dart';

/// Reusable loading widgets and state management patterns for async operations
class LoadingWidgets {
  LoadingWidgets._();
  
  /// Standard loading indicator with optional message
  static Widget loadingIndicator({String? message}) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
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
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: color,
      ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline, 
              size: 48, 
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade400
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon, 
              size: 64, 
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade400
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