import 'package:flutter/material.dart';
import '../utils/validation_utils.dart';

/// Utility class for creating common dialogs with consistent styling and reduced boilerplate
class DialogUtils {
  DialogUtils._();

  /// Show a simple confirmation dialog
  static Future<bool> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool destructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: destructive
                ? ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                  )
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Show a simple info dialog
  static Future<void> showInfoDialog(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'OK',
  }) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  /// Show an error dialog
  static Future<void> showErrorDialog(
    BuildContext context, {
    String title = 'Error',
    required String message,
    String buttonText = 'OK',
  }) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: Theme.of(context).colorScheme.error),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  /// Show a loading dialog
  static Future<void> showLoadingDialog(
    BuildContext context, {
    String message = 'Loading...',
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(message),
          ],
        ),
      ),
    );
  }

  /// Show a text input dialog
  static Future<String?> showTextInputDialog(
    BuildContext context, {
    required String title,
    required String label,
    String? initialValue,
    String? hintText,
    String? Function(String?)? validator,
    int? maxLength,
    bool multiline = false,
    String confirmText = 'Save',
    String cancelText = 'Cancel',
  }) async {
    final controller = TextEditingController(text: initialValue);
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(title),
          content: Form(
            key: formKey,
            child: ValidationUtils.buildTextFormField(
              label: label,
              controller: controller,
              validator: validator,
              hintText: hintText,
              maxLength: maxLength,
              maxLines: multiline ? null : 1,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(cancelText),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.of(context).pop(controller.text.trim());
                }
              },
              child: Text(confirmText),
            ),
          ],
        ),
      ),
    );

    controller.dispose();
    return result;
  }

  /// Show a selection dialog from a list of options
  static Future<T?> showSelectionDialog<T>(
    BuildContext context, {
    required String title,
    required List<T> options,
    required String Function(T) getDisplayText,
    T? initialSelection,
  }) async {
    return await showDialog<T>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: options.length,
            itemBuilder: (context, index) {
              final option = options[index];
              final isSelected = option == initialSelection;

              return ListTile(
                title: Text(getDisplayText(option)),
                leading: isSelected
                    ? Icon(Icons.radio_button_checked,
                        color: Theme.of(context).colorScheme.primary)
                    : const Icon(Icons.radio_button_off),
                onTap: () => Navigator.of(context).pop(option),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  /// Show a color picker dialog (if needed for swimmer icon picker)
  static Future<Color?> showColorPickerDialog(
    BuildContext context, {
    required String title,
    required Color initialColor,
    required Widget colorPicker,
  }) async {
    return await showDialog<Color>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: colorPicker,
      ),
    );
  }

  /// Show a form dialog with multiple fields
  static Future<Map<String, dynamic>?> showFormDialog(
    BuildContext context, {
    required String title,
    required List<FormField> fields,
    String confirmText = 'Save',
    String cancelText = 'Cancel',
  }) async {
    final formKey = GlobalKey<FormState>();
    final controllers = <String, TextEditingController>{};

    // Initialize controllers
    for (final field in fields) {
      controllers[field.key] = TextEditingController(text: field.initialValue);
    }

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: double.maxFinite,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: fields
                  .map((field) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: ValidationUtils.buildTextFormField(
                          label: field.label,
                          controller: controllers[field.key]!,
                          validator: field.validator,
                          hintText: field.hintText,
                          maxLength: field.maxLength,
                          obscureText: field.obscureText,
                        ),
                      ))
                  .toList(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                final result = <String, dynamic>{};
                for (final field in fields) {
                  result[field.key] = controllers[field.key]!.text.trim();
                }
                Navigator.of(context).pop(result);
              }
            },
            child: Text(confirmText),
          ),
        ],
      ),
    );

    // Dispose controllers
    for (final controller in controllers.values) {
      controller.dispose();
    }

    return result;
  }
}

/// Configuration class for form fields in dialogs
class FormField {
  final String key;
  final String label;
  final String? initialValue;
  final String? hintText;
  final String? Function(String?)? validator;
  final int? maxLength;
  final bool obscureText;

  const FormField({
    required this.key,
    required this.label,
    this.initialValue,
    this.hintText,
    this.validator,
    this.maxLength,
    this.obscureText = false,
  });
}
