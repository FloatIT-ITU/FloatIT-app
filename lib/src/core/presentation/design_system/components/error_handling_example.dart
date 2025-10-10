import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:floatit/src/core/presentation/providers/events_provider.dart';
import 'package:floatit/src/core/presentation/design_system/design_system.dart';

/// Example widget demonstrating error handling integration
class ErrorHandlingExample extends StatelessWidget {
  const ErrorHandlingExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EventsProvider>(
      builder: (context, eventsProvider, child) {
        // Show loading overlay during operations
        return FloatITLoadingOverlay(
          isLoading: eventsProvider.isLoading,
          loadingMessage: 'Loading events...',
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Events'),
            ),
            body: _buildBody(context, eventsProvider),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _refreshEvents(context, eventsProvider),
              child: const Icon(Icons.refresh),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, EventsProvider eventsProvider) {
    // Show error state with retry option
    if (eventsProvider.hasError) {
      return FloatITRetryWidget.fromFailure(
        failure: eventsProvider.error!,
        onRetry: () => _refreshEvents(context, eventsProvider),
      );
    }

    // Show empty state
    if (eventsProvider.events.isEmpty) {
      return const Center(
        child: Text('No events found'),
      );
    }

    // Show events list
    return ListView.builder(
      itemCount: eventsProvider.events.length,
      itemBuilder: (context, index) {
        final event = eventsProvider.events[index];
        return ListTile(
          title: Text(event.name),
          subtitle: Text(event.description ?? ''),
          onTap: () => _handleEventTap(context, eventsProvider, event.id),
        );
      },
    );
  }

  void _refreshEvents(BuildContext context, EventsProvider eventsProvider) async {
    try {
      await eventsProvider.refreshEvents();
    } catch (error) {
      // Error is already handled by the provider and shown in the UI
      // But we could show a snackbar or dialog if needed
      if (context.mounted && eventsProvider.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(eventsProvider.errorMessage ?? 'An error occurred'),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () => _refreshEvents(context, eventsProvider),
            ),
          ),
        );
      }
    }
  }

  void _handleEventTap(BuildContext context, EventsProvider eventsProvider, String eventId) async {
    final event = await eventsProvider.loadEventById(eventId);

    if (event != null) {
      // Navigate to event details
      // Navigator.push(context, MaterialPageRoute(builder: (_) => EventDetailsPage(event: event)));
    } else if (eventsProvider.hasError && context.mounted) {
      // Show error dialog for specific operation
      FloatITErrorDialog.showFromFailure(
        context,
        eventsProvider.error!,
        title: 'Failed to Load Event',
        actionLabel: 'Retry',
        onAction: () => _handleEventTap(context, eventsProvider, eventId),
      );
    }
  }
}