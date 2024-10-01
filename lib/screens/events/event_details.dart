import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pinnket/services/toast_service.dart';
import 'package:pinnket/utils/hider.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:html' as html;

import '../../models/event_models.dart';
import '../../models/donation_models.dart';
import '../../providers/selectedevent_provider.dart';
import '../../providers/selectedzone_provider.dart';
import '../../services/events_service.dart';
import '../../services/donation_service.dart';
import '../../services/review_service.dart';
import '../../widgets/donation_card.dart';
import '../../widgets/footer.dart';
import '../../widgets/footer_widget.dart';
import '../../widgets/header.dart';
import '../../widgets/rating_widget.dart';
import '../../widgets/review_dialog.dart';
import '../../widgets/review_widget.dart';
import 'event_about.dart';
import 'events_appbar.dart';
import 'events_highlights.dart';
import 'events_sponsor.dart';
import 'events_summarycard.dart';
import 'tickets_stepper.dart';

class EventDetailsPage extends StatefulWidget {
  const EventDetailsPage({Key? key}) : super(key: key);

  @override
  _EventDetailsPageState createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  final EventsService _eventsService = EventsService();
  final DonationService _donationService = DonationService();
  final ReviewService _reviewService = ReviewService();
  bool _isLoading = true;
  bool _isDonationLoading = true;
  DonationDetails? _donationDetails;
  String? _currentEventId;
  bool _showAllReviews = false;
  final int _initialReviewCount = 3;

  @override
  void initState() {
    super.initState();
    callJavaScriptMethods();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAndHydrate();
    });
  }

  Future<void> _initializeAndHydrate() async {
    final selectedEventProvider =
        Provider.of<SelectedEventProvider>(context, listen: false);
    Event? selectedEvent = selectedEventProvider.selectedEvent;

    // TODO: reset the TicketSelectionProvider when the page is loaded
    final ticketSelectionProvider =
        Provider.of<TicketSelectionProvider>(context, listen: false);
    ticketSelectionProvider.reset();

    if (selectedEvent == null) {
      final eid = _getEventIdFromUrl();
      if (eid != null) {
        await _fetchEventAndDonationDetails(eid);
      }
    } else {
      await _fetchDonationDetails(selectedEvent.eid!);
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<double> _fetchAverageRating(String eventId) async {
    return await _reviewService.getAverageRatingForEvent(eventId);
  }

  Future<int> _fetchReviewCount(String eventId) async {
    return await _reviewService.getReviewCountForEvent(eventId);
  }

  Future<void> _fetchEventAndDonationDetails(String eid) async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _isDonationLoading = true;
      });
    }

    try {
      final event = await _eventsService.getEventDetails(eid);
      final selectedEventProvider =
          Provider.of<SelectedEventProvider>(context, listen: false);
      selectedEventProvider.setSelectedEvent(event);
      await _fetchDonationDetails(eid);
    } catch (e) {
      print('Error fetching event details: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchDonationDetails(String eid) async {
    if (mounted) {
      setState(() {
        _isDonationLoading = true;
      });
    }

    try {
      _donationDetails = await _donationService.getDonationDetails(eid);
    } catch (e) {
      print('Error fetching donation details: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isDonationLoading = false;
        });
      }
    }
  }

  String? _getEventIdFromUrl() {
    final String location = html.window.location.href;
    final uri = Uri.parse(location);
    final fragment = uri.fragment;
    final pathSegments = Uri.parse(fragment).pathSegments;
    if (pathSegments.length >= 2 && pathSegments[0] == 'events') {
      return pathSegments[1];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80.0,
        flexibleSpace: const PinnKETHeader(),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<SelectedEventProvider>(
        builder: (context, selectedEventProvider, child) {
          final selectedEvent = selectedEventProvider.selectedEvent;
          final newEventId = _getEventIdFromUrl();
          if (newEventId != null && newEventId != _currentEventId) {
            _currentEventId = newEventId;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _fetchEventAndDonationDetails(newEventId);
            });
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 600) {
                return _buildWideLayout(selectedEvent);
              } else {
                return _buildNarrowLayout(selectedEvent);
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildRatingAndReviews(String? eventId) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.05),
            Theme.of(context).colorScheme.secondary.withOpacity(0.05),
          ],
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FutureBuilder<List<dynamic>>(
                future: Future.wait([
                  _fetchAverageRating(eventId ?? ''),
                  _fetchReviewCount(eventId ?? ''),
                ]),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildShimmerWidget(height: 50);
                  }
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  final double averageRating = snapshot.data?[0] ?? 0.0;
                  final int reviewCount = snapshot.data?[1] ?? 0;

                  return RatingWidget(
                    rating: averageRating,
                    reviewCount: reviewCount,
                  );
                },
              ),
              ElevatedButton.icon(
                onPressed: () => _showReviewDialog(context, eventId ?? ''),
                icon: const Icon(Icons.rate_review),
                label: const Text('Write a Review'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          StreamBuilder<List<Review>>(
            stream: _reviewService.getReviewsForEvent(eventId ?? '',
                limit: _showAllReviews ? 1000 : _initialReviewCount),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildShimmerWidget(height: 200);
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Text('No reviews yet.');
              }

              List<Review> reviews = snapshot.data!;
              return Column(
                children: [
                  ...reviews.map((review) => ReviewWidget(
                        reviewerName: review.reviewerName,
                        reviewText: review.reviewText,
                        rating: review.rating,
                        datePosted: review.datePosted,
                      )),
                  if (reviews.length == _initialReviewCount && !_showAllReviews)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _showAllReviews = true;
                        });
                      },
                      child: const Text('Show More Reviews'),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _showReviewDialog(BuildContext context, String eventId) async {
    // Fetch the user's IP address
    String currentUserId;
    try {
      final response = await Dio().get('https://api.ipify.org?format=json');
      if (response.statusCode == 200) {
        currentUserId = response.data['ip'];
      } else {
        throw Exception('Failed to get IP address');
      }
    } catch (e) {
      print('Error fetching IP address: $e');
      ToastManager().showErrorToast(
          context, 'Failed to get IP address. Please try again.');
      return;
    }

    // Fetch the device name using userAgent
    String deviceName = html.window.navigator.userAgent;
    String deviceMacAddress = html.window.navigator.appVersion;
    String? devicePlatform = html.window.navigator.platform;
    String deviceLanguage = html.window.navigator.language;
    String deviceVendor = html.window.navigator.vendor;
    String deviceProduct = html.window.navigator.product;
    String deviceAppVersion = html.window.navigator.appVersion;
    String deviceAppName = html.window.navigator.appName;
    String deviceAppCodeName = html.window.navigator.appCodeName;
    String? deviceProductSub = html.window.navigator.productSub;
    String deviceVendorSub = html.window.navigator.vendorSub;
    String deviceCookieEnabled = html.window.navigator.cookieEnabled.toString();
    String deviceOnLine = html.window.navigator.onLine.toString();
    String deviceDoNotTrack = html.window.navigator.doNotTrack.toString();
    String deviceMaxTouchPoints =
        html.window.navigator.maxTouchPoints.toString();
    String deviceHardwareConcurrency =
        html.window.navigator.hardwareConcurrency.toString();
    String deviceMediaCapabilities =
        html.window.navigator.mediaCapabilities.hashCode.toString();
    String devicePermissions = html.window.navigator.permissions.toString();
    String deviceStorage = html.window.navigator.storage.toString();
    String deviceServiceWorker = html.window.navigator.serviceWorker.toString();

    print(
        'Device Name: $deviceName - Device Mac Address: $deviceMacAddress - Device Platform: $devicePlatform - Device Language: $deviceLanguage - Device Vendor: $deviceVendor - Device Product: $deviceProduct - Device App Version: $deviceAppVersion - Device App Name: $deviceAppName - Device App Code Name: $deviceAppCodeName - Device Product Sub: $deviceProductSub - Device Vendor Sub: $deviceVendorSub - Device Cookie Enabled: $deviceCookieEnabled - Device On Line: $deviceOnLine - Device Do Not Track: $deviceDoNotTrack - Device Max Touch Points: $deviceMaxTouchPoints - Device Hardware Concurrency: $deviceHardwareConcurrency - Device Media Capabilities: $deviceMediaCapabilities - Device Permissions: $devicePermissions - Device Storage: $deviceStorage - Device Service Worker: $deviceServiceWorker');

    // Concatenate IP address with device name
    currentUserId =
        '$currentUserId - $deviceName - $deviceMacAddress - $devicePlatform - $deviceLanguage - $deviceVendor - $deviceProduct - $deviceAppVersion - $deviceAppName - $deviceAppCodeName - $deviceProductSub - $deviceVendorSub - $deviceCookieEnabled - $deviceOnLine - $deviceDoNotTrack - $deviceMaxTouchPoints - $deviceHardwareConcurrency - $deviceMediaCapabilities - $devicePermissions - $deviceStorage - $deviceServiceWorker';

    bool hasReviewed =
        await _reviewService.hasUserReviewedEvent(currentUserId, eventId);
    if (hasReviewed) {
      ToastManager()
          .showSuccessToast(context, 'You have already reviewed this event.');
      return;
    }

    showDialog(
      context: context,
      builder: (context) =>
          ReviewSubmissionDialog(eventId: eventId, userId: currentUserId),
    );
  }

  Widget _buildWideLayout(Event? selectedEvent) {
    return CustomScrollView(
      slivers: [
        _isLoading
            ? SliverToBoxAdapter(child: _buildShimmerWidget(height: 200))
            : EventSliverAppBar(event: selectedEvent),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _isDonationLoading
                          ? _buildShimmerWidget(height: 200)
                          : AboutEvent(
                              event: selectedEvent,
                            ),
                      if (selectedEvent?.acceptDonations ?? false) ...[
                        _isDonationLoading
                            ? _buildShimmerWidget(height: 150)
                            : DonationCard(
                                goalAmount:
                                    _donationDetails!.requiredAmount.toDouble(),
                                raisedAmount:
                                    _donationDetails!.totalCollected.toDouble(),
                                donorsCount: _donationDetails!.totalDonations,
                                eventName: selectedEvent?.name ?? 'Event Name',
                                eid: selectedEvent?.eid ?? '',
                                evLogo: selectedEvent?.evLogo ?? '',
                                event: selectedEvent,
                              ),
                        const SizedBox(height: 24),
                      ],
                      const SizedBox(height: 24),
                      _isLoading || selectedEvent == null
                          ? _buildShimmerWidget(height: 200)
                          : EventHighlights(events: selectedEvent),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _isLoading || selectedEvent == null
                          ? _buildShimmerWidget(height: 300)
                          : TicketStepper(
                              key: ValueKey(selectedEvent.eid),
                              event: selectedEvent),
                      const SizedBox(height: 24),
                      _isLoading
                          ? _buildShimmerWidget(height: 200)
                          : EventSummaryCard(event: selectedEvent),
                      const SizedBox(height: 24),
                      _isLoading || selectedEvent == null
                          ? _buildShimmerWidget(height: 200)
                          : _buildRatingAndReviews(selectedEvent.eid),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
            child: _isLoading
                ? _buildShimmerWidget(height: 200)
                : SponsorSection(sponsors: selectedEvent?.eventSponsors ?? [])),
        SliverToBoxAdapter(
          child: Footer(),
        ),
        SliverFillRemaining(
          hasScrollBody: false,
          child: FooterWidget(
            fontSize: 10,
            url: Uri.parse('https://pinnitags.com'),
            url1: Uri.parse('https://pinnisoft.com'),
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout(Event? selectedEvent) {
    return CustomScrollView(
      slivers: [
        _isLoading
            ? SliverToBoxAdapter(child: _buildShimmerWidget(height: 200))
            : EventSliverAppBar(event: selectedEvent),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _isDonationLoading
                    ? _buildShimmerWidget(height: 200)
                    : AboutEvent(
                        event: selectedEvent,
                      ),
                if (selectedEvent?.acceptDonations ?? false) ...[
                  _isDonationLoading
                      ? _buildShimmerWidget(height: 150)
                      : DonationCard(
                          goalAmount:
                              _donationDetails!.requiredAmount.toDouble(),
                          raisedAmount:
                              _donationDetails!.totalCollected.toDouble(),
                          donorsCount: _donationDetails!.totalDonations,
                          eventName: selectedEvent?.name ?? 'Event Name',
                          eid: selectedEvent?.eid ?? '',
                          evLogo: selectedEvent?.evLogo ?? '',
                          event: selectedEvent,
                        ),
                  const SizedBox(height: 24),
                ],
                const SizedBox(height: 24),
                _isLoading || selectedEvent == null
                    ? _buildShimmerWidget(height: 300)
                    : TicketStepper(
                        key: ValueKey(selectedEvent.eid), event: selectedEvent),
                const SizedBox(height: 24),
                _isLoading
                    ? _buildShimmerWidget(height: 200)
                    : EventSummaryCard(event: selectedEvent),
                const SizedBox(height: 24),
                _isLoading || selectedEvent == null
                    ? _buildShimmerWidget(height: 200)
                    : _buildRatingAndReviews(selectedEvent.eid),
                _isLoading || selectedEvent == null
                    ? _buildShimmerWidget(height: 200)
                    : EventHighlights(events: selectedEvent),
                const SizedBox(height: 24),
                _isLoading
                    ? _buildShimmerWidget(height: 200)
                    : SponsorSection(
                        sponsors: selectedEvent?.eventSponsors ?? []),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerWidget({required double height}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
