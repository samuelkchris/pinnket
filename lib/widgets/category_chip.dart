import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'dart:convert';
import 'dart:js' as js;
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:widget_hydrator/widget_hydrator.dart';
import '../models/category_models.dart';
import '../providers/event_provider.dart';
import '../services/events_service.dart';
import '../services/onboarding_service.dart';
import 'category_button.dart';

class CategoryChips extends StatefulWidget {
  const CategoryChips({super.key});

  @override
  _CategoryChipsState createState() => _CategoryChipsState();
}

class _CategoryChipsState extends State<CategoryChips> {
  late ScrollController _scrollController;
  bool _showLeftIndicator = false;
  bool _showRightIndicator = true;
  List<Categories> categories = [];
  String? categoriesJson;
  final EventsService _eventsService = EventsService();
  final OnboardingService _onboardingService = OnboardingService();

  // Keys for onboarding
  final GlobalKey _categoriesKey = GlobalKey();
  final GlobalKey _filterKey = GlobalKey();

  final List<Map<String, dynamic>> sortOptions = [
    {'name': 'Date', 'icon': Iconsax.calendar},
    {'name': 'Upcoming', 'icon': Iconsax.timer},
    {'name': 'This Weekend', 'icon': Iconsax.calendar_1},
    {'name': 'This Week', 'icon': Iconsax.calendar_2},
    {'name': 'Reset Filters', 'icon': Iconsax.refresh},
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_updateScrollIndicators);
    _loadCategories();
    _initOnboarding();
  }

  void _initOnboarding() {
    _onboardingService.addFeatureHighlight(
      FeatureHighlight(
        targetKey: _categoriesKey,
        title: 'Event Categories',
        description: 'Browse events by category. Tap a category to filter the events.',
        icon: Iconsax.category,
      ),
    );
    _onboardingService.addFeatureHighlight(
      FeatureHighlight(
        targetKey: _filterKey,
        title: 'Filter Options',
        description: 'Use advanced filters to sort events by date, upcoming, or specific time periods.',
        icon: Iconsax.filter,
      ),
    );
  }

  void _loadCategories() async {
    try {
      final fetchedCategories = await _eventsService.getEventCategories();
      setState(() {
        categories = [
          Categories(name: 'All', id: "1", eventSubCategories: []),
          ...fetchedCategories,
        ];
      });
    } catch (e) {
      print('Error loading categories: $e');
      // Handle error (e.g., show error message to user)
    }
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'music':
        return Iconsax.music;
      case 'art':
        return Iconsax.brush_1;
      case 'food':
        return Iconsax.cake;
      case 'sports':
        return Iconsax.medal;
      case 'business':
        return Iconsax.briefcase;
      case 'community':
        return Iconsax.people;
      case 'social':
        return Iconsax.user;
      case 'educational':
        return Iconsax.book_1;
      case 'political':
        return Iconsax.flag;
      case 'cultural':
        return Iconsax.global;
      case 'religious':
        return Iconsax.star1;
      default:
        return Iconsax.category;
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollIndicators);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateScrollIndicators() {
    setState(() {
      _showLeftIndicator = _scrollController.position.pixels > 0;
      _showRightIndicator = _scrollController.position.pixels <
          _scrollController.position.maxScrollExtent;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;

    if (categories.isEmpty) {
      return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          height: 40,
          width: 80,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }

    return isLargeScreen ? _buildLargeScreenView() : _buildSmallScreenView();
  }

  Widget _buildLargeScreenView() {
    final totalCategoriesWidth = categories.length * 80.0;

    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Consumer<EventProvider>(
                      builder: (context, eventProvider, child) {
                        return Row(
                          key: _categoriesKey, // Add key for onboarding
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: categories.map((category) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: CategoryButton(
                                category: {
                                  'name': category.name,
                                  'icon': _getCategoryIcon(category.name),
                                  'id': category.id,
                                },
                                isSelected: eventProvider.selectedCategory == category.name,
                                onTap: () {
                                  if (eventProvider.selectedCategory == category.name) {
                                    eventProvider.setCategory(null, null);
                                  } else {
                                    eventProvider.setCategory(category.name, category.id);
                                  }
                                },
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Consumer<EventProvider>(
                  builder: (context, eventProvider, child) {
                    return PopupMenuButton<String>(
                      key: _filterKey, // Add key for onboarding
                      icon: const Icon(Iconsax.filter),
                      onSelected: (String result) {
                        if (result == 'Date') {
                          _showDateRangePicker(context, eventProvider);
                        } else if (result == 'Reset Filters') {
                          eventProvider.resetFilters();
                        } else {
                          eventProvider.setSortBy(result);
                        }
                      },
                      itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                        ...sortOptions.map((option) => PopupMenuItem<String>(
                          value: option['name'],
                          onTap: () {
                            if (option['name'] == 'Date') {
                              eventProvider.setSortBy('Date');
                            }
                          },
                          child: Row(
                            children: [
                              Icon(option['icon'], size: 20),
                              const SizedBox(width: 8),
                              Text(option['name']),
                            ],
                          ),
                        )),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
          if (MediaQuery.of(context).size.width < totalCategoriesWidth) ...[
            if (_showLeftIndicator) _buildScrollIndicator(Alignment.centerLeft),
            if (_showRightIndicator) _buildScrollIndicator(Alignment.centerRight),
          ],
        ],
      ),
    );
  }

  Widget _buildSmallScreenView() {
    return ElevatedButton.icon(
      key: _filterKey, // Add key for onboarding
      icon: const Icon(Iconsax.filter, size: 20, color: Colors.white),
      label: const Text('Filter', style: TextStyle(fontSize: 12, color: Colors.white)),
      onPressed: () => _showFilterModal(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Consumer<EventProvider>(
          builder: (context, eventProvider, child) {
            return DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.2,
              maxChildSize: 0.95,
              expand: false,
              builder: (_, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16,
                        MediaQuery.of(context).viewInsets.bottom + 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Categories',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          key: _categoriesKey, // Add key for onboarding
                          spacing: 8,
                          runSpacing: 8,
                          children: categories.map((category) {
                            return ChoiceChip(
                              label: Text(category.name),
                              selected: eventProvider.selectedCategory == category.name,
                              onSelected: (bool selected) {
                                eventProvider.setCategory(
                                    selected ? category.name : null,
                                    category.id);
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                        _buildIconDropdown(
                          'Sort By',
                          Iconsax.sort,
                          sortOptions,
                          eventProvider.selectedSortBy,
                              (String? newValue) {
                            eventProvider.setSortBy(newValue ?? 'Date');
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildDateRangePicker(eventProvider),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          icon: const Icon(Iconsax.filter),
                          label: const Text('Apply Filters'),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildIconDropdown(
      String label,
      IconData icon,
      List<Map<String, dynamic>> items,
      String value,
      Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      value: value,
      onChanged: onChanged,
      items: items.map<DropdownMenuItem<String>>((Map<String, dynamic> item) {
        return DropdownMenuItem<String>(
          value: item['name'],
          child: Row(
            children: [
              Icon(item['icon'], size: 20),
              const SizedBox(width: 8),
              Text(item['name']),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDateRangePicker(EventProvider eventProvider) {
    return InkWell(
      onTap: () => _showDateRangePicker(context, eventProvider),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Date Range',
          prefixIcon: const Icon(Iconsax.calendar),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(eventProvider.selectedDateRange != null
                ? '${eventProvider.selectedDateRange!.start.toString().split(' ')[0]} - ${eventProvider.selectedDateRange!.end.toString().split(' ')[0]}'
                : 'Select date range'),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  void _showDateRangePicker(
      BuildContext context, EventProvider eventProvider) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: eventProvider.selectedDateRange,
    );
    if (picked != null) {
      eventProvider.setDateRange(picked);
    }
  }

  Widget _buildScrollIndicator(Alignment alignment) {
    return Align(
        alignment: alignment,
        child: GestureDetector(
        onTap: () {
      const scrollAmount = 100.0;
      if (alignment == Alignment.centerLeft) {
        _scrollController.animateTo(
          _scrollController.offset - scrollAmount,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        _scrollController.animateTo(
          _scrollController.offset + scrollAmount,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    },
    child: Container(
    width: 50,
      height: 90,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: alignment == Alignment.centerLeft
              ? Alignment.centerRight
              : Alignment.centerLeft,
          end: alignment == Alignment.centerLeft
              ? Alignment.centerLeft
              : Alignment.centerRight,
          colors: [
            Theme.of(context).scaffoldBackgroundColor.withOpacity(0.0),
            Theme.of(context).scaffoldBackgroundColor,
          ],
        ),
      ),
      child: Center(
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              alignment == Alignment.centerLeft
                  ? Icons.chevron_left
                  : Icons.chevron_right,
              color: Theme.of(context).primaryColor,
              size: 24,
            ),
          ),
        ),
      ),
    ),
        ),
    );
  }
}