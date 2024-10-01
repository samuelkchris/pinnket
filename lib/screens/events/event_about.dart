import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:pinnket/models/donation_models.dart';
import 'package:pinnket/utils/layout.dart';
import 'dart:html' as html;

import '../../models/event_models.dart';
import '../../utils/generate_share_image.dart';

class AboutEvent extends StatelessWidget {
  final Event? event;
  final DonationDetails? donationDetails;

  const AboutEvent({super.key, this.event, this.donationDetails});

  @override
  Widget build(BuildContext context) {
    final ticketCategories = event?.eventZones
        ?.where((zone) => zone.isactive == true && zone.cost != 0)
        .toList() ??
        [];
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme
                .of(context)
                .colorScheme
                .primary
                .withOpacity(0.05),
            Theme
                .of(context)
                .colorScheme
                .secondary
                .withOpacity(0.05),
          ],
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event?.name ?? 'Event Name',
            style: Theme
                .of(context)
                .textTheme
                .headlineMedium!
                .copyWith(
              fontWeight: FontWeight.bold,
              color: Theme
                  .of(context)
                  .colorScheme
                  .primary,
              fontSize: isDisplayDesktop(context) ? null : 15,
            ),
          ),
          const SizedBox(height: 16),
          buildInfoRow(context, Iconsax.calendar, _formatEventDateTime()),
          const SizedBox(height: 12),
          buildInfoRow(context, Iconsax.location,
              "${event!.location!} - ${event?.venue}"),
          if (event?.eventNumber != null &&
              event!.eventZones!.isNotEmpty &&
              event?.eventZones!.every((zone) => zone.cost == 0) == false) ...[
            const SizedBox(height: 12),
            buildInfoRow(
              context,
              Iconsax.note,
              "Dial *217*413# Enter ${event?.eventNumber} as Event ID",
              style: Theme
                  .of(context)
                  .textTheme
                  .bodyLarge!
                  .copyWith(
                color: Theme
                    .of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(0.8),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          const SizedBox(height: 12),
          buildOrganizerRow(context),
          const SizedBox(height: 12),
          buildInfoRow(context, Iconsax.document,
              event?.eventdescription ?? 'No description available.'),
          const SizedBox(height: 24),
          buildAddToCalendarButton(context),
          const SizedBox(height: 24),
          Visibility(
              visible: ticketCategories.isNotEmpty,
              child: buildShareImageButton(context)),
          const SizedBox(height: 24),
          buildCountdown(context),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget buildInfoRow(BuildContext context, IconData icon, String text,
      {TextStyle? style}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme
                .of(context)
                .colorScheme
                .primary
                .withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon,
              size: 20, color: Theme
                  .of(context)
                  .colorScheme
                  .primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: style ??
                Theme
                    .of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(
                  color: Theme
                      .of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.8),
                ),
          ),
        ),
      ],
    );
  }

  Widget buildOrganizerRow(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme
                .of(context)
                .colorScheme
                .primary
                .withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Iconsax.user,
              size: 20, color: Theme
                  .of(context)
                  .colorScheme
                  .primary),
        ),
        const SizedBox(width: 12),
        Text(
          'Organized by: ',
          style: Theme
              .of(context)
              .textTheme
              .bodyLarge!
              .copyWith(
            color: Theme
                .of(context)
                .colorScheme
                .onSurface
                .withOpacity(0.8),
          ),
        ),
        Expanded(
          child: InkWell(
            onTap: () {
              context.go('/event-owner', extra: event?.registration);
            },
            child: Text(
              event?.registration?.regname ?? 'Organizer',
              style: Theme
                  .of(context)
                  .textTheme
                  .bodyLarge!
                  .copyWith(
                color: Theme
                    .of(context)
                    .colorScheme
                    .primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildCountdown(BuildContext context) {
    final eventDateTime = _parseEventDateTime();
    final eventEndDateTime = DateTime.parse(event!.endtime!);
    if (eventDateTime == null) {
      return Container();
    }

    final now = DateTime.now();
    final isEnded = eventEndDateTime.isBefore(now);
    final isOngoing = eventDateTime.isBefore(now) && !isEnded;

    Color containerColor;
    String statusText;
    IconData statusIcon;

    if (isEnded) {
      containerColor = Colors.red;
      statusText = 'Event Ended';
      statusIcon = Iconsax.timer_pause;
    } else if (isOngoing) {
      containerColor = Theme
          .of(context)
          .colorScheme
          .primary;
      statusText = 'Event Ongoing';
      statusIcon = Iconsax.timer1;
    } else {
      containerColor = Colors.transparent;
      statusText = 'Event Starts In';
      statusIcon = Iconsax.timer_1;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        gradient: isEnded || isOngoing
            ? null
            : LinearGradient(
          colors: [
            Theme
                .of(context)
                .colorScheme
                .primary,
            Theme
                .of(context)
                .colorScheme
                .secondary,
          ],
        ),
        color: isEnded || isOngoing ? containerColor : null,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color:
            (isEnded ? Colors.red : Theme
                .of(context)
                .colorScheme
                .primary)
                .withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Text(
            statusText,
            style: Theme
                .of(context)
                .textTheme
                .titleSmall!
                .copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          if (!isEnded) ...[
            CountdownTimer(
              endTime: eventDateTime.millisecondsSinceEpoch,
              widgetBuilder: (_, time) {
                if (time == null) {
                  return Text(
                    'Now',
                    style: Theme
                        .of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }
                return Text(
                  '${time.days ?? 0}d ${time.hours ?? 0}h ${time.min ??
                      0}m ${time.sec}s',
                  style: Theme
                      .of(context)
                      .textTheme
                      .titleSmall!
                      .copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget buildAddToCalendarButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _downloadIcsFile(),
      icon: const Icon(Iconsax.calendar_add),
      label: const Text('Add to Calendar'),
      style: ElevatedButton.styleFrom(
        foregroundColor: Theme
            .of(context)
            .colorScheme
            .onPrimary,
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _downloadIcsFile() {
    final eventDateTime = _parseEventDateTime();
    final eventEndDateTime = DateTime.parse(event!.endtime!);

    if (eventDateTime != null) {
      final String icsContent =
      _generateIcsContent(eventDateTime, eventEndDateTime);
      final blob = html.Blob([icsContent], 'text/calendar');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", "${event?.name ?? 'Event'}.ics")
        ..click();
      html.Url.revokeObjectUrl(url);
    }
  }

  Widget buildShareImageButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _generateShareImage(context),
      icon: const Icon(Iconsax.share),
      label: const Text('Share Event Banner'),
      style: ElevatedButton.styleFrom(
        foregroundColor: Theme
            .of(context)
            .colorScheme
            .onPrimary,
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _generateShareImage(BuildContext context) {
    final title = event?.name ?? 'Event';
    final eventUrl = 'https://pinnket.com/#/events/${event?.eid}';
    final bannerImageUrl =
        event?.evLogo ?? 'https://example.com/default-banner.jpg';

    final eventDate = DateTime.parse(event!.eventDate!);
    final isDonate = event?.acceptDonations ?? false;
    final eventCode = event?.eventNumber;

    generateAndDownloadShareImage(
        context, title, eventUrl, bannerImageUrl, isDonate, eventCode!);
  }

  String _generateIcsContent(DateTime start, DateTime end) {

    print('Event start: $start');
    print('Event end: $end');
    final now = DateTime.now().toUtc();
    final formattedNow = _formatDateForIcs(now);
    final formattedStart = _formatDateForIcs(start);
    final formattedEnd = _formatDateForIcs(end);

    print('Now: $formattedNow');
    print('Start: $formattedStart');
    print('End: $formattedEnd');

    if (end.isAfter(now)) {
      print('Event has ended');
    } else {
      print('Event is still on');
    }

    return '''BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//hacksw/handcal//NONSGML v1.0//EN
BEGIN:VEVENT
UID:${now.millisecondsSinceEpoch}@pinnket.com
DTSTAMP:$formattedNow
DTSTART:$formattedStart
DTEND:$formattedEnd
SUMMARY:${event?.name ?? 'Event'}
DESCRIPTION:${event?.eventdescription ?? 'No description available.'}
LOCATION:${event!.location!} - ${event?.venue}
END:VEVENT
END:VCALENDAR''';
  }

  String _formatDateForIcs(DateTime date) {
    // Ensure the date is in UTC
    final utcDate = date.toUtc();

    // Format the date components
    final year = utcDate.year.toString();
    final month = utcDate.month.toString().padLeft(2, '0');
    final day = utcDate.day.toString().padLeft(2, '0');
    final hour = utcDate.hour.toString().padLeft(2, '0');
    final minute = utcDate.minute.toString().padLeft(2, '0');
    final second = utcDate.second.toString().padLeft(2, '0');

    // Combine the components into the correct format
    return '$year$month${day}T$hour$minute${second}Z';
  }

  DateTime? _parseEventDateTime() {
    if (event?.eventDate == null) {
      return null;
    }

    try {
      return DateTime.parse(event!.eventDate!);
    } catch (e) {
      print('Error parsing event date/time: $e');
      return null;
    }
  }

  String _formatEventDateTime() {
    final eventDateTime = _parseEventDateTime();
    if (eventDateTime == null) {
      return 'Date and time TBA';
    }

    final date =
        '${eventDateTime.year}-${eventDateTime.month.toString().padLeft(
        2, '0')}-${eventDateTime.day.toString().padLeft(2, '0')}';
    final time =
        '${eventDateTime.hour.toString().padLeft(2, '0')}:${eventDateTime.minute
        .toString().padLeft(2, '0')}';

    return '$date • $time';
  }
}
