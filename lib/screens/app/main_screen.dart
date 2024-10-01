import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:wiredash/wiredash.dart';

import '../../providers/selectedevent_provider.dart';
import '../../utils/hider.dart';
import '../../utils/layout.dart';
import '../../widgets/footer.dart';
import '../../widgets/footer_widget.dart';
import '../../widgets/header.dart';
import '../../providers/event_provider.dart';

class MainScreen extends StatefulWidget {
  final List<Widget> bodySliver;
  final String title;
  final bool showSearchFAB;
  final bool isScrollable;
  final bool showFooter;
  final ScrollController? scrollController;
  final Widget? bottomNavigationBar;

  const MainScreen({
    super.key,
    required this.bodySliver,
    this.title = '',
    this.showSearchFAB = true,
    this.isScrollable = true,
    this.showFooter = true,
    this.scrollController,
    this.bottomNavigationBar,
  });

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final TextEditingController _searchController = TextEditingController();
  final PanelController _panelController = PanelController();
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Wiredash.of(context).showPromoterSurvey(
        inheritMaterialTheme: true,
      );
    });
    callJavaScriptMethods();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _showSearch = !_showSearch;
    });
  }

  void _performSearch(BuildContext context, String query) async {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    await eventProvider.setSearchQuery(query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: widget.bottomNavigationBar,
      body: Stack(
        children: [
          CustomScrollView(
            physics: widget.isScrollable
                ? null
                : const NeverScrollableScrollPhysics(),
            controller: widget.scrollController,
            slivers: [
              SliverAppBar(
                toolbarHeight: 80.0,
                leading: const SizedBox(),
                flexibleSpace: _showSearch && isDisplayMobile(context)
                    ? _buildMobileSearchBar()
                    : const PinnKETHeader(),
                backgroundColor: Colors.transparent,
                elevation: 0,
                floating: true,
                pinned: true,
              ),
              ...widget.bodySliver,
              SliverToBoxAdapter(
                child: Visibility(
                  visible: widget.showFooter,
                  child: Footer(),
                ),
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
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget? _buildFloatingActionButton() {
    if (!widget.showSearchFAB || !isDisplayMobile(context)) {
      return null;
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          heroTag: 'searchFAB',
          onPressed: _toggleSearch,
          child: Icon(_showSearch ? Icons.close : Iconsax.search_normal),
        ),
      ],
    );
  }

  Widget _buildMobileSearchBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: SearchAnchor(
          builder: (BuildContext context, SearchController controller) {
            return SearchBar(
              controller: controller,
              hintText: 'Search events...',
              leading: const Icon(Iconsax.search_normal),
              trailing: [
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    controller.clear();
                    Provider.of<EventProvider>(context, listen: false)
                        .setSearchQuery('');
                  },
                ),
              ],
              onChanged: (_) => _performSearch(context, controller.text),
              onSubmitted: (_) => _performSearch(context, controller.text),
            );
          },
          suggestionsBuilder:
              (BuildContext context, SearchController controller) {
            final eventProvider = Provider.of<EventProvider>(context);
            final selectedEventProvider =
                Provider.of<SelectedEventProvider>(context, listen: false);
            final events = eventProvider.events;
            return List<ListTile>.generate(5, (int index) {
              final item = events[index].name;
              final event = events[index];
              return ListTile(
                title: Text(item!),
                onTap: () {
                  setState(() {
                    controller.closeView(item ?? '');
                    precacheImage(NetworkImage(event.evLogo!), context);
                    selectedEventProvider.setSelectedEvent(event);
                    context.go('/events/${event.eid}');
                    eventProvider.setSearchQuery('');
                  });
                },
              );
            });
          },
        ),
      ),
    );
  }
}
