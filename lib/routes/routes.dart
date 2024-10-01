import 'dart:math';

import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../database/sample_data.dart';
import '../models/bus_type.dart';
import '../models/event_models.dart';
import '../policies/references.dart';
import '../screens/auth/login.dart';
import '../screens/bus/booking_confirmation.dart';
import '../screens/bus/bus_screen.dart';
import '../screens/bus/search_results.dart';
import '../screens/bus/seat_selection.dart';
import '../screens/donation/donation_page.dart';
import '../screens/events/event_details.dart';
import '../screens/events/event_owner.dart';
import '../screens/home/embed.dart';
import '../screens/home/home_screen.dart';
import '../screens/home/intro.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/ticket_utils/download_ticket.dart';
import '../screens/ticket_utils/failure_ticketpurchase.dart';
import '../screens/ticket_utils/pass_screen.dart';
import '../screens/ticket_utils/successfull_ticketpurchase.dart';
import '../screens/ticket_utils/ticket_purchase_screen.dart';
import '../screens/ticket_utils/ticket_transfer_screen.dart';
import '../screens/ticket_utils/ticket_verification.dart';
import '../services/firebase_service.dart';

final GoRouter goRouter = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const HomeScreen();
      },
    ),
    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) {
        return const EmailOtpLoginScreen();
      },
    ),
    GoRoute(
      path: '/events/:id',
      builder: (BuildContext context, GoRouterState state) {
        return const EventDetailsPage();
      },
    ),
    GoRoute(
      path: '/ticket-transfer',
      builder: (BuildContext context, GoRouterState state) {
        return const TicketTransfer();
      },
    ),
    GoRoute(
      path: '/ticket-download',
      builder: (BuildContext context, GoRouterState state) {
        return const TicketDownloadScreen();
      },
    ),
    GoRoute(
      path: '/ticket-verification',
      builder: (BuildContext context, GoRouterState state) {
        return const TicketVerificationScreen();
      },
    ),
    GoRoute(
      path: '/event-owner',
      builder: (BuildContext context, GoRouterState state) {
        return const EventOwnerScreen();
      },
    ),
    GoRoute(
      path: '/donate',
      builder: (context, state) {
        final eventName = state.uri.queryParameters['eventName'] ?? '';
        final goalAmount =
            double.tryParse(state.uri.queryParameters['goalAmount'] ?? '0') ??
                0;
        final raisedAmount =
            double.tryParse(state.uri.queryParameters['raisedAmount'] ?? '0') ??
                0;
        final eid = state.uri.queryParameters['eid'] ?? '';
        final evLogo = state.uri.queryParameters['evLogo'] ?? '';
        return DonationPage(
          eid: eid,
          eventName: eventName,
          goalAmount: goalAmount,
          raisedAmount: raisedAmount,
          evLogo: evLogo,
        );
      },
    ),
    GoRoute(
      path: '/intro',
      builder: (BuildContext context, GoRouterState state) {
        return const Intro();
      },
    ),
    GoRoute(
      path: '/ticket-purchase/:id',
      builder: (BuildContext context, GoRouterState state) {
        return const TicketPayment();
      },
    ),
    GoRoute(
      path: '/pass',
      builder: (BuildContext context, GoRouterState state) {
        final tagCode = state.uri.queryParameters['tagCode'] ?? '';
        return PassScreen(
          tagCode: tagCode,
        );
      },
    ),
    GoRoute(
      path: '/payment-success',
      builder: (BuildContext context, GoRouterState state) {
        final amount = state.uri.queryParameters['amount'] ?? '';
        final eventName = state.uri.queryParameters['eventName'] ?? '';
        return PaymentSuccessScreen(amount: amount, eventName: eventName);
      },
    ),
    GoRoute(
      path: '/payment-failure',
      builder: (BuildContext context, GoRouterState state) {
        final errorMessage = state.uri.queryParameters['errorMessage'] ?? '';
        final onRetry = state.extra as VoidCallback?;
        return PaymentFailureScreen(
          errorMessage: errorMessage,
          onTryAgain: onRetry ?? () {},
        );
      },
    ),
    GoRoute(
      path: '/reference',
      builder: (BuildContext context, GoRouterState state) {
        return const ReferenceScreen();
      },
    ),
    GoRoute(
        path: '/profile',
        builder: (BuildContext context, GoRouterState state) {
          return const ProfileScreen();
        }),
    GoRoute(
        path: '/bus',
        builder: (BuildContext context, GoRouterState state) {
          return const BusScreen();
        }),
    GoRoute(
      path: '/embed/event/:id',
      builder: (BuildContext context, GoRouterState state) {
        final eventId = state.uri.queryParameters['id'] ?? '';
        final name = state.uri.queryParameters['name'] ?? '';
        final evLogo = state.uri.queryParameters['evLogo'] ?? '';
        final eventSubCategoryName =
            state.uri.queryParameters['eventSubCategoryName'] ?? '';
        final eventdescription =
            state.uri.queryParameters['eventdescription'] ?? '';
        final eventDate = state.uri.queryParameters['eventDate'] ?? '';
        final location = state.uri.queryParameters['location'] ?? '';
        final venue = state.uri.queryParameters['venue'] ?? '';

        final event = Event(
          eid: eventId ?? '',
          name: name,
          evLogo: evLogo,
          eventSubCategory: EventSubCategory(name: eventSubCategoryName),
          eventdescription: eventdescription,
          eventDate: eventDate,
          location: location,
          venue: venue,
        );
        return EmbeddableEventCard(event: event);
      },
    ),
    GoRoute(
      path: '/search-results',
      builder: (BuildContext context, GoRouterState state) {
        final Map<String, String> params =
            state.extra as Map<String, String>? ?? {};
        return BusSearchResultsScreen(
          from: params['from'] ?? '',
          to: params['to'] ?? '',
          date: params.containsKey('date')
              ? DateTime.parse(params['date']!)
              : DateTime.now(),
          passengers: int.tryParse(params['passengers'] ?? '1') ?? 1,
        );
      },
    ),
    GoRoute(
      path: '/bus-details',
      builder: (BuildContext context, GoRouterState state) {
        final Map<String, dynamic> params =
            state.extra as Map<String, dynamic> ?? {};

        // Randomly select a bus type for demonstration
        final random = Random();
        final Bus selectedBus = sampleBuses[random.nextInt(sampleBuses.length)];

        return BusDetailsAndSeatSelection(
          bus: selectedBus,
          from: params['from'] ?? 'Sample Origin',
          to: params['to'] ?? 'Sample Destination',
          departureTime: params['departureTime'] ??
              DateTime.now().add(const Duration(hours: 2)),
          arrivalTime: params['arrivalTime'] ??
              DateTime.now().add(const Duration(hours: 8)),
          price: (params['price'] as num?)?.toDouble() ?? 50.0,
        );
      },
    ),
    GoRoute(
      path: '/booking-confirmation',
      builder: (BuildContext context, GoRouterState state) {
        final Map<String, dynamic> params = state.extra as Map<String, dynamic>;
        return BookingConfirmationScreen(
          busCompany: params['busCompany'],
          from: params['from'],
          to: params['to'],
          departureTime: params['departureTime'],
          arrivalTime: params['arrivalTime'],
          price: params['price'],
          selectedSeats: params['selectedSeats'],
        );
      },
    ),
  ],
  observers: [
    FirebaseAnalyticsObserver(analytics: FirebaseService.analytics),
  ],
  redirect: (BuildContext context, GoRouterState state) {
    FirebaseService.analytics.logEvent(
      name: 'screen_view',
      parameters: {
        'screen_name': state.uri.toString(),
        'screen_class': state.name ?? 'Unknown',
      },
    );
    return null;
  },
);
