import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pinnket/utils/hider.dart';
import 'package:pinnket/widgets/bus_search_filter_column.dart';
import 'package:pinnket/widgets/bus_search_summary.dart';
import 'package:pinnket/widgets/bus_result_card.dart';
import 'package:pinnket/utils/layout.dart';
import 'package:iconsax/iconsax.dart';

import '../../widgets/header.dart';
import '../../widgets/shimmer_effect.dart';


class BusTypeGroup {
  final String type;
  final List<BusCompanyGroup> companies;

  BusTypeGroup({required this.type, required this.companies});
}

class BusCompanyGroup {
  final String companyName;
  final List<BusResult> buses;
  bool isExpanded;

  BusCompanyGroup({required this.companyName, required this.buses, this.isExpanded = true});
}

class BusResult {
  final String companyName;
  final double rating;
  final int reviewCount;
  final double price;
  final String departureTime;
  final String arrivalTime;
  final String duration;
  final List<String> amenities;
  final List<String> boardingPoints;
  final List<String> droppingPoints;
  final String cancellationPolicy;

  BusResult({
    required this.companyName,
    required this.rating,
    required this.reviewCount,
    required this.price,
    required this.departureTime,
    required this.arrivalTime,
    required this.duration,
    required this.amenities,
    required this.boardingPoints,
    required this.droppingPoints,
    required this.cancellationPolicy,
  });
}

class BusSearchResultsScreen extends StatefulWidget {
  final String from;
  final String to;
  final DateTime date;
  final int passengers;

  const BusSearchResultsScreen({
    Key? key,
    required this.from,
    required this.to,
    required this.date,
    required this.passengers,
  }) : super(key: key);

  @override
  _BusSearchResultsScreenState createState() => _BusSearchResultsScreenState();
}

class _BusSearchResultsScreenState extends State<BusSearchResultsScreen> with SingleTickerProviderStateMixin {
  String _sortBy = 'Price';
  bool _isLoading = false;
  List<BusTypeGroup> _busTypeGroups = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    callJavaScriptMethods();
    _loadBusGroups();
    _tabController = TabController(length: _busTypeGroups.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadBusGroups() {
    // Simulated data loading
    _busTypeGroups = [
      BusTypeGroup(
        type: 'Standard',
        companies: [
          BusCompanyGroup(
            companyName: 'Express Bus Co.',
            buses: List.generate(2, (index) => _createMockBusResult('Express Bus Co.')),
          ),
          BusCompanyGroup(
            companyName: 'City Transit',
            buses: List.generate(1, (index) => _createMockBusResult('City Transit')),
          ),
        ],
      ),
      BusTypeGroup(
        type: 'Executive',
        companies: [
          BusCompanyGroup(
            companyName: 'Luxury Lines',
            buses: List.generate(2, (index) => _createMockBusResult('Luxury Lines')),
          ),
        ],
      ),
      BusTypeGroup(
        type: 'Luxury',
        companies: [
          BusCompanyGroup(
            companyName: 'VIP Coaches',
            buses: List.generate(1, (index) => _createMockBusResult('VIP Coaches')),
          ),
        ],
      ),
    ];
  }

  BusResult _createMockBusResult(String companyName) {
    return BusResult(
      companyName: companyName,
      rating: 4.5,
      reviewCount: 120,
      price: 50.0,
      departureTime: '08:00 AM',
      arrivalTime: '02:00 PM',
      duration: '6h 00m',
      amenities: const ['Wifi', 'AC', 'TV', 'Charging Port', 'Water Bottle'],
      boardingPoints: const [
        'Central Bus Station, Platform 3',
        'City Mall Entrance',
        'University Campus Gate',
      ],
      droppingPoints: const [
        'City Center Bus Stop',
        'Airport Terminal 1',
        'Beach Resort Entrance',
      ],
      cancellationPolicy: 'Free cancellation up to 24 hours before departure. 50% refund for cancellations made within 24 hours of departure.',
    );
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
      body:CustomScrollView(
          slivers: [
        SliverToBoxAdapter(
          child: BusSearchSummary(
            from: widget.from,
            to: widget.to,
            date: widget.date,
            passengers: widget.passengers,
            onSortChanged: (String newSortBy) {
              setState(() {
                _sortBy = newSortBy;
              });
              _applySorting();
            },
            onEditSearch: () {  },
          ),
        ),
        SliverToBoxAdapter(
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: _busTypeGroups.map((group) => Tab(text: group.type)).toList(),
          ),
        ),
        SliverFillRemaining(
          child: TabBarView(
            controller: _tabController,
            children: _busTypeGroups.map((group) => _buildTypeGroupContent(context, group)).toList(),
          ),
        ),
      ],
    ));
  }

  Widget _buildTypeGroupContent(BuildContext context, BusTypeGroup group) {
    return isDisplayDesktop(context)
        ? _buildWideScreenLayout(context, group)
        : _buildNarrowScreenLayout(context, group);
  }

  Widget _buildWideScreenLayout(BuildContext context, BusTypeGroup group) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: BusSearchFilterColumn(
                onFiltersApplied: _applyFilters,
                onFiltersReset: _resetFilters,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _isLoading
                      ? const SortingOptionsShimmer()
                      : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${group.companies.fold(0, (sum, company) => sum + company.buses.length)} buses found',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      _buildSortingOptions(context),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: _buildGroupedResultsList(context, group),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowScreenLayout(BuildContext context, BusTypeGroup group) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _isLoading
                ? const SortingOptionsShimmer()
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${group.companies.fold(0, (sum, company) => sum + company.buses.length)} buses found',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Iconsax.filter),
                      label: const Text('Filters'),
                      onPressed: () {
                        _showFilterDialog(context);
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Theme.of(context).primaryColor,
                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSortingOptions(context),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16.0),
          sliver: _buildGroupedResultsList(context, group),
        ),
      ],
    );
  }

  Widget _buildSortingOptions(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildSortChip('Price', Iconsax.money),
        _buildSortChip('Duration', Iconsax.timer),
        _buildSortChip('Departure', Iconsax.timer_start),
        _buildSortChip('Arrival', Iconsax.timer_pause),
        _buildSortChip('Rating', Iconsax.star),
      ],
    );
  }

  Widget _buildSortChip(String label, IconData icon) {
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: _sortBy == label,
      onSelected: (bool selected) {
        setState(() {
          _sortBy = selected ? label : 'Price';
        });
        _applySorting();
      },
    );
  }



  Widget _buildGroupedResultsList(BuildContext context, BusTypeGroup group) {
    if (_isLoading) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, index) => const BusResultShimmer(),
          childCount: 5,
        ),
      );
    }


    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, companyIndex) {
          final companyGroup = group.companies[companyIndex];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCompanyGroupHeader(context, companyGroup, companyIndex),
              if (companyGroup.isExpanded) ...[
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: companyGroup.buses.length,
                  itemBuilder: (context, busIndex) {
                    final bus = companyGroup.buses[busIndex];
                    return BusResultCard(
                      companyName: bus.companyName,
                      rating: bus.rating,
                      reviewCount: bus.reviewCount,
                      price: bus.price,
                      departureTime: bus.departureTime,
                      arrivalTime: bus.arrivalTime,
                      duration: bus.duration,
                      amenities: bus.amenities,
                      boardingPoints: bus.boardingPoints,
                      droppingPoints: bus.droppingPoints,
                      cancellationPolicy: bus.cancellationPolicy,
                      onTap: () {
                        _navigateToBusDetails(context, bus);
                      },
                    );
                  },
                ),
              ],
            ],
          );
        },
        childCount: group.companies.length,
      ),
    );
  }

  Widget _buildCompanyGroupHeader(BuildContext context, BusCompanyGroup group, int groupIndex) {
    return InkWell(
      onTap: () {
        setState(() {
          group.isExpanded = !group.isExpanded;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              group.companyName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Row(
              children: [
                Text(
                  '${group.buses.length} buses',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(width: 8),
                Icon(
                  group.isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filter Options'),
          content: SingleChildScrollView(
            child: BusSearchFilterColumn(
              onFiltersApplied: () {
                _applyFilters();
                Navigator.of(context).pop();
              },
              onFiltersReset: () {
                _resetFilters();
                Navigator.of(context).pop();
              },
            ),
          ),
        );
      },
    );
  }

  void _applyFilters() {
    setState(() {
      _isLoading = true;
    });
    // Simulate API call
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  void _resetFilters() {
    setState(() {
      // Reset filter states here
    });
    _applyFilters();
  }

  void _applySorting() {
    setState(() {
      _isLoading = true;
    });
    // Simulate API call
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  void _navigateToBusDetails(BuildContext context, BusResult bus) {
    print("Navigating to bus details");
    print("Bus: ${bus.companyName}");
    print("Departure Time: ${bus.departureTime}");
    print("Arrival Time: ${bus.arrivalTime}");
    print("Price: ${bus.price}");
    print("From: ${widget.from}");
    print("To: ${widget.to}");
    context.go('/bus-details', extra: {
      'from': widget.from,
      'to': widget.to,
      'departureTime': bus.departureTime,
      'arrivalTime': bus.arrivalTime,
      'price': bus.price,
    });
  }
}