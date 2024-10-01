import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../models/event_models.dart';
import '../providers/event_provider.dart';
import '../providers/selectedevent_provider.dart';
import '../services/firebase_service.dart'; // New import

class EventCard extends StatefulWidget {
  final Event? event;
  final bool isLoading;

  const EventCard({
    super.key,
    this.event,
    this.isLoading = false,
  });

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> with TickerProviderStateMixin {
  bool _isHovered = false;
  bool _showAdditionalInfo = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });
    if (isHovered) {
      _controller.forward();
      Future.delayed(const Duration(seconds: 2), () {
        if (_isHovered) {
          setState(() {
            _showAdditionalInfo = true;
          });

          // New analytics event
          FirebaseService.analytics.logEvent(
            name: 'event_card_hover',
            parameters: {
              'event_id': widget.event?.eid ?? '',
              'event_name': widget.event?.name ?? '',
            },
          );
        }
      });
    } else {
      _controller.reverse();
      setState(() {
        _showAdditionalInfo = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.isLoading) {
      return _buildShimmerCard(theme);
    }

    final eventProvider = Provider.of<EventProvider>(context);

    return MouseRegion(
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          height: _showAdditionalInfo ? 450 : 300,
          width: 300,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.onSurface
                    .withOpacity(_isHovered ? 0.2 : 0.1),
                blurRadius: _isHovered ? 16 : 12,
                offset: Offset(0, _isHovered ? 6 : 4),
              ),
            ],
          ),
          child: InkWell(
            onTap: () => _navigateToEventDetails(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Event Image
                Container(
                  height: 300,
                  width: 300,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: 'event-image-${widget.event?.eid}-${UniqueKey()}',
                        child: FittedBox(
                          fit: BoxFit.fill,
                          child: Image.network(
                            widget.event?.evLogo ?? '',
                            fit: BoxFit.fill,
                            filterQuality: FilterQuality.high,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        left: 12,
                        child: _buildDateChip(theme),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: _buildCategoryChip(theme),
                      ),
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: _buildBookmarkIcon(theme, eventProvider),
                      ),
                    ],
                  ),
                ),
                // Event Details
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          widget.event?.name ?? '',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.event?.eventdescription ?? '',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.8),
                          ),
                          maxLines: _isHovered ? null : 2,
                          overflow: _isHovered ? null : TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Iconsax.calendar,
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.8)),
                            const SizedBox(width: 4),
                            Text(
                              widget.event?.eventDate != null
                                  ? DateFormat('EEEE, yyyy-MM-dd – kk:mm')
                                  .format(DateTime.parse(
                                  widget.event!.eventDate!))
                                  : '',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Iconsax.location,
                                color: theme.colorScheme.secondary, size: 18),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                "${widget.event?.location} - ${widget.event?.venue}" ??
                                    '',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.7),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerCard(ThemeData theme) {
    return Shimmer.fromColors(
      baseColor: theme.colorScheme.surface,
      highlightColor: theme.colorScheme.surface.withOpacity(0.3),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1 / 1,
              child: Container(color: Colors.white),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 20,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 150,
                    height: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    height: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 200,
                    height: 16,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateChip(ThemeData theme) {
    final eventDate = widget.event?.eventDate != null
        ? DateTime.parse(widget.event!.eventDate!)
        : null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            eventDate != null ? DateFormat('MMM').format(eventDate) : '',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            eventDate != null ? DateFormat('dd').format(eventDate) : '',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            eventDate != null ? DateFormat('EE').format(eventDate) : '',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        widget.event?.eventSubCategory?.name ?? '',
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSecondaryContainer,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBookmarkIcon(ThemeData theme, EventProvider eventProvider) {
    final isBookmarked =
    eventProvider.isEventBookmarked(widget.event?.eid ?? '');

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.onSurface.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        tooltip: "Bookmark this event",
        color: isBookmarked
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface.withOpacity(0.6),
        style: ButtonStyle(
          shadowColor: MaterialStateProperty.all(
            isBookmarked
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface,
          ),
        ),
        splashColor: isBookmarked
            ? theme.colorScheme.primary.withOpacity(0.1)
            : theme.colorScheme.onSurface.withOpacity(0.1),
        icon: Icon(
          isBookmarked ? Iconsax.bookmark_2 : Iconsax.bookmark,
          color: isBookmarked
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface.withOpacity(0.6),
          size: 20,
        ),
        onPressed: () async {
          if (widget.event != null) {
            await eventProvider.toggleBookmark(widget.event!);

            // New analytics event
            FirebaseService.analytics.logEvent(
              name: 'toggle_event_bookmark',
              parameters: {
                'event_id': widget.event!.eid ?? '',
                'event_name': widget.event!.name ?? '',
                'is_bookmarked': !isBookmarked,
              },
            );
          }
        },
      ),
    );
  }

  void _navigateToEventDetails(BuildContext context) {
    final selectedEventProvider =
    Provider.of<SelectedEventProvider>(context, listen: false);
    if (widget.event != null) {
      // Preload the event details page
      precacheImage(NetworkImage(widget.event!.evLogo!), context);
      selectedEventProvider.setSelectedEvent(widget.event!);

      // New analytics event
      FirebaseService.analytics.logEvent(
        name: 'view_event_details',
        parameters: {
          'event_id': widget.event!.eid?? '',
          'event_name': widget.event!.name ?? '',
          'event_date': widget.event!.eventDate ?? '',
          'event_location': widget.event!.location ?? '',
        },
      );

      // Navigate to the event details page
      context.go('/events/${widget.event!.eid}');
    }
  }
}