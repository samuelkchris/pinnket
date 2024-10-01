import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pinnket/providers/selectedevent_provider.dart';
import 'package:pinnket/utils/hider.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../models/event_models.dart';
import '../../services/events_service.dart';
import '../../widgets/event_card.dart';
import '../app/main_screen.dart';

class EventOwnerScreen extends StatefulWidget {
  const EventOwnerScreen({
    Key? key,
  }) : super(key: key);

  @override
  _EventOwnerScreenState createState() => _EventOwnerScreenState();
}

class _EventOwnerScreenState extends State<EventOwnerScreen> {
  late Future<List<Event>> _ownerEventsFuture;
  final _eventsService = EventsService();
  late SelectedEventProvider _selectedEvent = SelectedEventProvider();
  Registration? _registration;

  @override
  void initState() {
    super.initState();
    callJavaScriptMethods();

    // _initializeHydration();
    _selectedEvent = Provider.of<SelectedEventProvider>(context, listen: false);
    _registration = _selectedEvent.selectedEvent?.registration;

    _ownerEventsFuture = getEventsByOwner(_registration?.rid ?? '');
  }

  // Future<void> _initializeHydration() async {
  //   await initializeHydration(HydrationConfig(
  //     useCompression: true,
  //     // enableEncryption: true,
  //     // encryptionKey: 'your-secret-key',
  //   ));
  //   await ensureHydrated();
  // }

  Future<List<Event>> getEventsByOwner(String s) async {
    final events = await _eventsService.getAllEvents();
    return events.where((event) => event.rid == s).toList();
  }

Future<String> getLastestEvent(Future<List<Event>> eventsFuture) async {
  final events = await eventsFuture;
  return events.isNotEmpty ? events.first.bannerURL ?? '' : '';
}
  @override
  Widget build(BuildContext context) {
    return MainScreen(
      bodySliver: [
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                _registration == null
                    ? _buildShimmerImage()
                    : FutureBuilder<String>(
                  future: getLastestEvent(_ownerEventsFuture),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildShimmerImage();
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      print("data: ${snapshot.data}");
                      return const Center(child: Text('No image found.'));
                    } else {
                      return Image.network(
                        snapshot.data!,
                        fit: BoxFit.cover,
                      );
                    }
                  },
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            title: _registration == null
                ? _buildShimmerText(100, 20)
                : Text(
              _registration?.regname ?? 'Event Owner',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOwnerInfo(context),
                const SizedBox(height: 24),
                FutureBuilder<List<Event>>(
                  future: _ownerEventsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildShimmerLoading();
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No events found.'));
                    } else {
                      final ownerEvents = snapshot.data!;
                      return Column(
                        children: [
                          _buildEventStats(context, ownerEvents),
                          const SizedBox(height: 24),
                          _buildContactInfo(context),
                          const SizedBox(height: 24),
                          Text(
                            'Events by ${_registration?.regname ?? 'Event Owner'}',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 16),
                          _buildEventGrid(ownerEvents),
                        ],
                      );
                    }
                  },
                ),
              ],
            ).animate().fadeIn(duration: 600.ms, delay: 300.ms),
          ),
        ),
      ],
    );
  }

  Widget _buildOwnerInfo(BuildContext context) {
    if (_registration == null) {
      return _buildShimmerOwnerInfo();
    }
    return Row(
      children: [
        Hero(
          tag: 'avatar_${_registration?.rid}',
          child: CircleAvatar(
            radius: 40,
            backgroundImage: _registration?.logo != null
                ? NetworkImage(_registration!.logo!)
                : null,
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            child: _registration?.logo == null
                ? Icon(Iconsax.user,
                    size: 40, color: Theme.of(context).primaryColor)
                : null,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _registration?.regname ?? 'Event Owner',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Iconsax.location,
                      size: 16, color: Theme.of(context).hintColor),
                  const SizedBox(width: 4),
                  Text(
                    _registration?.location ?? 'Location not specified',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Theme.of(context).hintColor),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEventStats(BuildContext context, List<Event> ownerEvents) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(context, 'Total Events', ownerEvents.length.toString()),
        _buildStatItem(
            context, 'Active Events', getActiveEventCount(ownerEvents)),
      ],
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Theme.of(context).hintColor),
        ),
      ],
    );
  }

  Widget _buildContactInfo(BuildContext context) {
    if (_registration == null) {
      return _buildShimmerCard();
    }
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Information',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
                context, Iconsax.sms, 'Email', _registration?.email ?? 'N/A'),
            _buildInfoRow(
                context, Iconsax.call, 'Phone', _registration?.phone ?? 'N/A'),
            const SizedBox(height: 16),
            if (_registration?.bcard != null)
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement business card view/download
                  },
                  icon: const Icon(Iconsax.card),
                  label: const Text('View Business Card'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    ).animate().slideY(begin: 0.1, end: 0, duration: 500.ms, delay: 400.ms);
  }

  Widget _buildInfoRow(
      BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Theme.of(context).hintColor)),
                Text(value, style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventGrid(List<Event> ownerEvents) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.6,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: ownerEvents.length,
      itemBuilder: (context, index) => EventCard(event: ownerEvents[index])
          .animate()
          .fadeIn(delay: Duration(milliseconds: 100 * index)),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          _buildShimmerRow(),
          const SizedBox(height: 24),
          _buildShimmerCard(),
          const SizedBox(height: 24),
          _buildShimmerGrid(),
        ],
      ),
    );
  }

  Widget _buildShimmerRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildShimmerStatItem(),
        _buildShimmerStatItem(),
      ],
    );
  }

  Widget _buildShimmerStatItem() {
    return Column(
      children: [
        Container(
          width: 60,
          height: 24,
          color: Colors.white,
        ),
        const SizedBox(height: 4),
        Container(
          width: 80,
          height: 16,
          color: Colors.white,
        ),
      ],
    );
  }

  Widget _buildShimmerCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        height: 150,
        width: double.infinity,
        color: Colors.white,
      ),
    );
  }

  Widget _buildShimmerGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.6,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildShimmerOwnerInfo() {
    return Row(
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildShimmerText(150, 20),
              const SizedBox(height: 4),
              _buildShimmerText(100, 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerText(double width, double height) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        color: Colors.white,
      ),
    );
  }

  Widget _buildShimmerImage() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
      ),
    );
  }

  //
  // @override
  // void hydrateFromJson(Map<String, dynamic> json) {
  //   if (json.containsKey('registration')) {
  //     _registration = Registration.fromJson(
  //       Map<String, dynamic>.from(json['registration'] as Map),
  //     );
  //   } else {
  //     _registration = _selectedEvent.selectedEvent?.registration;
  //   }
  //   if (_registration != null) {
  //     _ownerEventsFuture = getEventsByOwner(_registration!.rid ?? '');
  //   }
  // }
  //
  // @override
  // void initializeDefaultState() {
  //   _registration = _selectedEvent.selectedEvent?.registration;
  //   if (_registration != null) {
  //     _ownerEventsFuture = getEventsByOwner(_registration!.rid ?? '');
  //   }
  // }

//   @override
//   Map<String, dynamic> persistToJson() {
//     return {
//       'registration': _registration?.toJson(),
//     };
//   }
// }

  String getActiveEventCount(List<Event> events) {
    final now = DateTime.now();
    final activeEvents = events.where((event) {
      if (event.eventDate == null || event.endtime == null) {
        return false;
      }
      try {
        final eventStart = _parseDateTime(event.eventDate!);
        final eventEnd = _parseDateTime(event.endtime!);
        return eventStart.isBefore(now) && eventEnd.isAfter(now);
      } catch (e) {
        return false;
      }
    }).toList();
    return activeEvents.length.toString();
  }

  DateTime _parseDateTime(String dateTime) {
    return DateTime.parse(dateTime);
  }
}
