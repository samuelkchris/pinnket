import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pinnket/widgets/theme_button.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:html' as html;

import '../providers/selectedevent_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/user_provider.dart';
import '../models/event_models.dart';
import '../screens/events/bookmarked_events.dart';
import '../services/onboarding_service.dart';

class PinnKETHeader extends StatefulWidget {
  const PinnKETHeader({super.key});

  @override
  State<PinnKETHeader> createState() => _PinnKETHeaderState();
}

class _PinnKETHeaderState extends State<PinnKETHeader> {
  String _location = 'Loading...';
  final SearchController _searchController = SearchController();
  final OnboardingService _onboardingService = OnboardingService();

  // Keys for onboarding
  final GlobalKey _logoKey = GlobalKey();
  final GlobalKey _searchKey = GlobalKey();
  final GlobalKey _locationKey = GlobalKey();
  final GlobalKey _bookmarkKey = GlobalKey();
  final GlobalKey _profileKey = GlobalKey();
  final GlobalKey _themeKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _initOnboarding();
  }

  void _initOnboarding() {
    _onboardingService.addFeatureHighlight(
      FeatureHighlight(
        targetKey: _logoKey,
        title: 'PinnKET Logo',
        description: 'Click here to return to the home page.',
        icon: Iconsax.home,
      ),
    );
    _onboardingService.addFeatureHighlight(
      FeatureHighlight(
        targetKey: _searchKey,
        title: 'Search Events',
        description: 'Find events, concerts, and activities here.',
        icon: Iconsax.search_normal,
      ),
    );
    _onboardingService.addFeatureHighlight(
      FeatureHighlight(
        targetKey: _locationKey,
        title: 'Your Location',
        description: 'This shows your current location for local events.',
        icon: Iconsax.location,
      ),
    );
    _onboardingService.addFeatureHighlight(
      FeatureHighlight(
        targetKey: _bookmarkKey,
        title: 'Bookmarked Events',
        description: 'View your saved events here.',
        icon: Iconsax.bookmark,
      ),
    );
    _onboardingService.addFeatureHighlight(
      FeatureHighlight(
        targetKey: _profileKey,
        title: 'User Profile',
        description: 'Access your profile or sign in here.',
        icon: Iconsax.profile_circle,
      ),
    );
    _onboardingService.addFeatureHighlight(
      FeatureHighlight(
        targetKey: _themeKey,
        title: 'Theme Toggle',
        description: 'Switch between light and dark themes.',
        icon: Iconsax.sun_1,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      await html.window.navigator.geolocation
          .getCurrentPosition(
        enableHighAccuracy: true,
      )
          .then((position) async {
        final lat = position.coords!.latitude;
        final lon = position.coords!.longitude;
        final locationName =
        await _getLocationName(lat!.toDouble(), lon!.toDouble());
        setState(() {
          _location = locationName;
        });
      });
    } catch (e) {
      setState(() {
        _location = '';
      });
    }
  }

  Future<String> _getLocationName(double lat, double lon) async {
    final url =
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon&zoom=10';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['address']['city'] ??
          data['address']['town'] ??
          data['address']['country'] ??
          'Unknown';
    } else {
      return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context);
    final selectedEventProvider =
    Provider.of<SelectedEventProvider>(context, listen: false);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isMobile = width < 600;
        final isTablet = width >= 600 && width < 1024;

        return Container(
          height: isMobile ? 200 : 150,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: const BorderRadius.all(Radius.circular(15)),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          margin:
          EdgeInsets.symmetric(horizontal: isMobile ? 16 : 30, vertical: 8),
          padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 30, vertical: 12),
          child: isMobile
              ? _buildMobileLayout(
              theme, eventProvider, userProvider, selectedEventProvider)
              : _buildDesktopLayout(theme, isTablet, eventProvider,
              userProvider, selectedEventProvider),
        );
      },
    );
  }

  Widget _buildMobileLayout(ThemeData theme, EventProvider eventProvider,
      UserProvider userProvider, SelectedEventProvider selectedEventProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            MouseRegion(
                key: _logoKey,
                onHover: (_) {},
                child: GestureDetector(
                  onTap: () {
                    context.go('/');
                  },
                  child: Image.asset(
                    'assets/images/sc.png',
                    height: 30,
                  ),
                )),
            const Spacer(),
            Row(
              key: _locationKey,
              children: [
                Icon(Iconsax.location, color: theme.colorScheme.onPrimary),
                const SizedBox(width: 10),
                Text(
                  _location,
                  style: TextStyle(color: theme.colorScheme.onPrimary),
                ),
              ],
            ),
            IconButton(
              key: _bookmarkKey,
              tooltip: 'Bookmarked Events',
              icon:
              Icon(Iconsax.bookmark_2, color: theme.colorScheme.onPrimary),
              onPressed: () => _showSlidingBookmarkDrawer(context),
            ),
            IconButton(
              key: _profileKey,
              tooltip: 'Profile',
              icon: Icon(Iconsax.profile_circle,
                  color: theme.colorScheme.onPrimary),
              onPressed: () {
                if (userProvider.loginResponse == null) {
                  _showSignInMenu(context);
                } else {
                  context.go('/profile');
                }
              },
            ),
            ThemeButton(
              key: _themeKey,
              onChanged: (value) {
                Provider.of<ThemeProvider>(context, listen: false)
                    .setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
              },
            )
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(
      ThemeData theme,
      bool isTablet,
      EventProvider eventProvider,
      UserProvider userProvider,
      SelectedEventProvider selectedEventProvider) {
    return Row(
      children: [
        MouseRegion(
            key: _logoKey,
            onHover: (_) {},
            child: GestureDetector(
              onTap: () {
                context.go('/');
              },
              child: Image.asset(
                'assets/images/sc.png',
                height: 30,
              ),
            )),
        const Spacer(),
        Expanded(
          child:
          _buildSearchAnchor(theme, eventProvider, selectedEventProvider),
        ),
        const SizedBox(width: 30),
        Row(
          key: _locationKey,
          children: [
            Icon(Iconsax.location, color: theme.colorScheme.onPrimary),
            const SizedBox(width: 4),
            Text(
              _location,
              style: TextStyle(color: theme.colorScheme.onPrimary),
            ),
          ],
        ),
        const SizedBox(width: 16),
        TextButton(
          onPressed: () {
            openUrl('http://c.pinnitags.com/');
          },
          child: Text(
            'Create Events',
            style: TextStyle(color: theme.colorScheme.onPrimary),
          ),
        ),
        const SizedBox(width: 16),
        if (userProvider.loginResponse == null)
          ElevatedButton(
            key: _profileKey,
            onPressed: () {
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(150, 50),
              foregroundColor: theme.colorScheme.onSecondary,
              backgroundColor: theme.colorScheme.secondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Iconsax.login, size: 18),
                SizedBox(width: 4),
                Text('|', style: TextStyle(fontSize: 12)),
                SizedBox(width: 4),
                Text('Sign In'),
              ],
            ),
          )
        else
          IconButton(
            key: _profileKey,
            tooltip: 'Profile',
            icon: Icon(Iconsax.profile_circle,
                color: theme.colorScheme.onPrimary),
            onPressed: () {
              context.go('/profile');
            },
          ),
        const SizedBox(width: 16),
        IconButton(
          key: _bookmarkKey,
          tooltip: 'Bookmarked Events',
          icon: Icon(Iconsax.bookmark_2, color: theme.colorScheme.onPrimary),
          onPressed: () => _showSlidingBookmarkDrawer(context),
        ),
        ThemeButton(
          key: _themeKey,
          onChanged: (value) {
            Provider.of<ThemeProvider>(context, listen: false)
                .setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
          },
        )
      ],
    );
  }

  Widget _buildSearchAnchor(ThemeData theme, EventProvider eventProvider,
      SelectedEventProvider selectedEventProvider) {
    return SearchAnchor(
      key: _searchKey,
      builder: (BuildContext context, SearchController controller) {
        return SearchBar(
          controller: controller,
          padding: const WidgetStatePropertyAll<EdgeInsets>(
            EdgeInsets.symmetric(horizontal: 16.0),
          ),
          onTap: () {
            controller.openView();
          },
          onChanged: (_) {
            controller.openView();
          },
          onSubmitted: (_) {
            controller.closeView(_);
            controller.clear(); // Reset the search
            eventProvider.setSearchQuery(''); // Clear the search query
          },
          leading: const Icon(Iconsax.search_favorite),
          hintText: 'Find events, concerts, activities...',
          hintStyle: WidgetStateProperty.all(
            TextStyle(
              color: theme.hintColor,
              fontSize: 13,
            ),
          ),
        );
      },
      suggestionsBuilder:
          (BuildContext context, SearchController controller) async {
        await eventProvider.setSearchQuery(controller.text);
        final events = eventProvider.events;

        return events
            .map((Event event) => ListTile(
          leading: const Icon(Iconsax.calendar),
          title: Text(event.name ?? ''),
          subtitle: Text(event.location ?? ''),
          onTap: () {
            setState(() {
              controller.closeView(event.name ?? '');
              precacheImage(NetworkImage(event.evLogo!), context);
              selectedEventProvider.setSelectedEvent(event);
              context.go('/events/${event.eid}');
              eventProvider.setSearchQuery('');
            });
          },
        ))
            .toList();
      },
    );
  }

  void _showSignInMenu(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sign In'),
          content: const Text('Would you like to sign in?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Sign In'),
              onPressed: () {
                Navigator.of(context).pop();
                context.go('/login');
              },
            ),
          ],
        );
      },
    );
  }

  void _showSlidingBookmarkDrawer(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (BuildContext buildContext, Animation<double> animation,
          Animation secondaryAnimation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1.0, 0.0),
            end: Offset.zero,
          ).animate(animation),
          child: const BookmarkedEventsDrawer(),
        );
      },
    );
  }

  void openUrl(String s) {
    html.window.open(s, 'new tab');
  }

  void startOnboarding() {
    _onboardingService.startOnboarding(context);
  }
}