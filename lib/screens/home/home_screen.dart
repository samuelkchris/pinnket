import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import '../../providers/event_provider.dart';
import '../../utils/hider.dart';
import '../../utils/layout.dart';
import '../../widgets/animated_title.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/events_banner.dart';
import '../../widgets/events_gallery.dart';
import '../../widgets/rail.dart';
import '../../widgets/ticket_utilities.dart';
import '../app/main_screen.dart';
import '../../services/onboarding_service.dart';
import '../bus/bus_screen.dart';
import 'dart:html' as html;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final ScrollController _scrollController = ScrollController();

  // Keys for onboarding
  final GlobalKey _homeNavKey = GlobalKey();
  final GlobalKey _eventsNavKey = GlobalKey();
  final GlobalKey _utilitiesNavKey = GlobalKey();
  final GlobalKey _busNavKey = GlobalKey();

  late OnboardingService _onboardingService;

  @override
  void initState() {
    super.initState();
    callJavaScriptMethods();
    _initOnboarding();
  }

  void _initOnboarding() {
    _onboardingService = OnboardingService();
    _onboardingService.addFeatureHighlight(
      FeatureHighlight(
        targetKey: _homeNavKey,
        title: 'Home',
        description:
            'Access the main page with featured events and promotions.',
        icon: Iconsax.home,
      ),
    );
    _onboardingService.addFeatureHighlight(
      FeatureHighlight(
        targetKey: _eventsNavKey,
        title: 'Events',
        description: 'Browse all available events and filter by category.',
        icon: Iconsax.calendar,
      ),
    );
    _onboardingService.addFeatureHighlight(
      FeatureHighlight(
        targetKey: _utilitiesNavKey,
        title: 'Utilities',
        description:
            'Access ticket-related utilities like transfers and management.',
        icon: Iconsax.ticket,
      ),
    );
    _onboardingService.addFeatureHighlight(
      FeatureHighlight(
        targetKey: _busNavKey,
        title: 'Bus',
        description: 'View and book bus tickets for various routes.',
        icon: Iconsax.bus,
      ),
    );

    // Start onboarding after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onboardingService.startOnboarding(context);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
void _onDestinationSelected(int index) {
  if (index == 3) {
    if (kReleaseMode) {
      _openBusLink();
    } else {
      setState(() {
        _selectedIndex = index;
      });
      _scrollToTop();
    }
  } else {
    setState(() {
      _selectedIndex = index;
    });
    _scrollToTop();
  }
}

  void _openBusLink() {
    const url = 'https://pinnket.com/coming_soon.html';
    html.window.open(url, '_blank');
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = isDisplayMobile(context);

    return Scaffold(
      body: Stack(
        children: [
          MainScreen(
            bodySliver: [
              if (_selectedIndex == 0 || _selectedIndex == 1)
                _buildCategoryHeader(isMobile),
              if (_selectedIndex == 0) ...[
                const SliverToBoxAdapter(
                  child: AnimatedEventsBanner(),
                ),
                _buildEventsTitle(),
                _buildEventsGallery(),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: TicketUtilities(),
                  ),
                ),
              ] else if (_selectedIndex == 1) ...[
                _buildEventsTitle(),
                _buildEventsGallery(),
              ] else if (_selectedIndex == 2) ...[
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: TicketUtilities(),
                  ),
                ),
              ] else if (_selectedIndex == 3) ...[
                _buildBusModule(),
              ],
            ],
            scrollController: _scrollController,
          ),
          if (!isMobile) _buildFloatingNavigationMenu(),
        ],
      ),
      bottomNavigationBar: isMobile ? _buildBottomNavigationBar() : null,
    );
  }

  Widget _buildFloatingNavigationMenu() {
    return Align(
      alignment: Alignment.centerLeft,
      child: CustomFloatingNavigation(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
        items: [
          CustomNavItem(key: _homeNavKey, icon: Iconsax.home, label: 'Home'),
          CustomNavItem(
              key: _eventsNavKey, icon: Iconsax.calendar, label: 'Events'),
          CustomNavItem(
              key: _utilitiesNavKey, icon: Iconsax.ticket, label: 'Utilities'),
          CustomNavItem(key: _busNavKey, icon: Iconsax.bus, label: 'Bus'),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onDestinationSelected,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Iconsax.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Iconsax.calendar),
          label: 'Events',
        ),
        BottomNavigationBarItem(
          icon: Icon(Iconsax.ticket),
          label: 'Utilities',
        ),
        BottomNavigationBarItem(
          icon: Icon(Iconsax.bus),
          label: 'Bus',
        ),
      ],
    );
  }

  Widget _buildCategoryHeader(bool isMobile) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _StickyHeaderDelegate(
        isMobile: isMobile,
        child: Container(
          margin:
              EdgeInsets.symmetric(horizontal: isMobile ? 16 : 30, vertical: 8),
          padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 30, vertical: 12),
          color: Colors.transparent,
          child: const CategoryChips(),
        ),
      ),
    );
  }

  Widget _buildEventsTitle() {
    return SliverToBoxAdapter(
      child: Consumer<EventProvider>(
        builder: (context, eventProvider, child) {
          return AnimatedTitle(
              title: eventProvider.selectedCategory ?? 'All Events');
        },
      ),
    );
  }

  Widget _buildEventsGallery() {
    return const SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
      sliver: SliverToBoxAdapter(
        child: LazyLoadingEventsGallery(),
      ),
    );
  }

  Widget _buildBusModule() {
    return const SliverToBoxAdapter(
      child: BusScreen(),
    );
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final bool isMobile;

  _StickyHeaderDelegate({required this.child, required this.isMobile});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  double get maxExtent => isMobile ? 80.0 : 120.0;

  @override
  double get minExtent => isMobile ? 80.0 : 120.0;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return maxExtent != oldDelegate.maxExtent ||
        minExtent != oldDelegate.minExtent;
  }
}
