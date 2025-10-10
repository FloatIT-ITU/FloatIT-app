import 'package:flutter/material.dart';
import 'package:floatit/src/shared/errors/failures.dart';
import 'package:floatit/src/shared/utils/error_message_utils.dart';

/// Error boundary widget that catches and handles errors gracefully
class FloatITErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(BuildContext context, dynamic error, StackTrace? stackTrace)? errorBuilder;
  final void Function(dynamic error, StackTrace? stackTrace)? onError;

  const FloatITErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
    this.onError,
  });

  @override
  State<FloatITErrorBoundary> createState() => _FloatITErrorBoundaryState();
}

class _FloatITErrorBoundaryState extends State<FloatITErrorBoundary> {
  dynamic _error;
  StackTrace? _stackTrace;

  @override
  void initState() {
    super.initState();
    // Set up error handling for this subtree
    ErrorWidget.builder = (FlutterErrorDetails details) {
      _handleError(details.exception, details.stack);
      return _buildErrorWidget(details.exception, details.stack);
    };
  }

  void _handleError(dynamic error, StackTrace? stackTrace) {
    setState(() {
      _error = error;
      _stackTrace = stackTrace;
    });

    widget.onError?.call(error, stackTrace);
  }

  Widget _buildErrorWidget(dynamic error, StackTrace? stackTrace) {
    if (widget.errorBuilder != null) {
      return widget.errorBuilder!(context, error, stackTrace);
    }

    return _defaultErrorWidget(error);
  }

  Widget _defaultErrorWidget(dynamic error) {
    return Material(
      child: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.red.shade50,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.red,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _error = null;
                  _stackTrace = null;
                });
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return _buildErrorWidget(_error, _stackTrace);
    }

    return widget.child;
  }
}

/// Error dialog utility
class FloatITErrorDialog {
  /// Show error dialog with user-friendly message from Failure
  static Future<void> showFromFailure(
    BuildContext context,
    Failure failure, {
    String? title,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final userMessage = ErrorMessageUtils.getUserFriendlyMessage(failure);
    final retryMessage = ErrorMessageUtils.getRetryActionMessage(failure);

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title ?? 'Error'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(userMessage),
            const SizedBox(height: 8),
            Text(
              retryMessage,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onAction();
              },
              child: Text(actionLabel),
            ),
        ],
      ),
    );
  }

  /// Show generic error dialog
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onAction();
              },
              child: Text(actionLabel),
            ),
        ],
      ),
    );
  }
}

/// Loading overlay widget
class FloatITLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? loadingMessage;

  const FloatITLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.loadingMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      if (loadingMessage != null) ...[
                        const SizedBox(height: 16),
                        Text(loadingMessage!),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Retry widget for failed operations
class FloatITRetryWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final String retryLabel;

  const FloatITRetryWidget({
    super.key,
    required this.message,
    required this.onRetry,
    this.retryLabel = 'Try Again',
  });

  /// Create retry widget from Failure with user-friendly messages
  factory FloatITRetryWidget.fromFailure({
    Key? key,
    required Failure failure,
    required VoidCallback onRetry,
    String retryLabel = 'Try Again',
  }) {
    final userMessage = ErrorMessageUtils.getUserFriendlyMessage(failure);
    final retryMessage = ErrorMessageUtils.getRetryActionMessage(failure);

    return FloatITRetryWidget(
      key: key,
      message: '$userMessage\n\n$retryMessage',
      onRetry: onRetry,
      retryLabel: retryLabel,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.refresh,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              child: Text(retryLabel),
            ),
          ],
        ),
      ),
    );
  }
}