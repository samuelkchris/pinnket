import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pinnket/services/toast_service.dart';
import 'package:pinnket/utils/layout.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../models/event_models.dart';
import '../../providers/event_provider.dart';
import '../../providers/selectedevent_provider.dart';
import '../../services/bookmark_services.dart';

class BookmarkedEventsDrawer extends StatelessWidget {
  const BookmarkedEventsDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final eventProvider = Provider.of<EventProvider>(context);

    return Material(
      color: Colors.transparent,
      child: Align(
        alignment: isDisplayDesktop(context)
            ? Alignment.centerLeft
            : Alignment.bottomCenter,
        child: Container(
          width: 400,
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(-5, 0),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDrawerHeader(theme, context),
              Expanded(
                child: FutureBuilder<List<Event>>(
                  future: eventProvider.getBookmarkedEvents(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Text('No bookmarked events',
                            style: theme.textTheme.bodyLarge),
                      );
                    } else {
                      return ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final event = snapshot.data![index];
                          return _buildEventListItem(
                              event, theme, context, eventProvider);
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(ThemeData theme, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bookmarked Events',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: theme.colorScheme.onPrimary),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Your saved events',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimary.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventListItem(Event event, ThemeData theme, BuildContext context,
      EventProvider eventProvider) {
    final BookmarkService bookmarkService = BookmarkService();
    final ToastManager toastManager = ToastManager();
    return Dismissible(
      key: Key(event.eid ?? ''),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) async {
        bookmarkService.removeBookmark(event);

        eventProvider.removeBookmarkedEvent(event);
        toastManager.showSuccessToast(
            context, '${event.name} removed from bookmarks');
      },
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            event.evLogo ?? '',
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 60,
              height: 60,
              color: theme.colorScheme.primary,
              child: Icon(Iconsax.image, color: theme.colorScheme.onPrimary),
            ),
          ),
        ),
        title: Text(
          event.name ?? '',
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Iconsax.calendar,
                    size: 14, color: theme.colorScheme.secondary),
                const SizedBox(width: 4),
                Text(
                  event.eventDate != null
                      ? DateFormat('MMMM dd, yyyy')
                          .format(DateTime.parse(event.eventDate!))
                      : '',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(Iconsax.location,
                    size: 14, color: theme.colorScheme.secondary),
                const SizedBox(width: 4),
                Text(
                  event.location ?? '',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: theme.colorScheme.error),
          onPressed: () async {
            bookmarkService.removeBookmark(event);
            eventProvider.removeBookmarkedEvent(event);
            toastManager.showSuccessToast(
                context, '${event.name} removed from bookmarks');
          },
        ),
        onTap: () {
          final selectedEventProvider =
          Provider.of<SelectedEventProvider>(context, listen: false);
          precacheImage(NetworkImage(event.evLogo!), context);
          selectedEventProvider.setSelectedEvent(event);
          context.go('/events/${event.eid}');

        },
      ),
    );
  }
}
