import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:flutter_animate/flutter_animate.dart';

class BusScreen extends StatefulWidget {
  const BusScreen({super.key});

  @override
  _BusScreenState createState() => _BusScreenState();
}

class _BusScreenState extends State<BusScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _from;
  String? _to;
  DateTime? _date;
  int _passengers = 1;
  bool _isRoundTrip = false;
  DateTime? _returnDate;
  bool _showRecentSearches = false;
  String _selectedAmenity = '';
  final List<String> _amenities = [
    'WiFi',
    'AC',
    'TV',
    'Snacks',
    'Drinks',
    'Restroom',
  ];

  final List<String> _cities = [
    'Nairobi',
    'Mombasa',
    'Kampala',
    'Entebbe',
    'Dar es Salaam',
    'Arusha',
    'Dodoma',
    'Kigali',
    'Bujumbura',
    'Juba'
  ];

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        if (sizingInformation.deviceScreenType == DeviceScreenType.desktop) {
          return _buildDesktopLayout();
        } else {
          return _buildMobileLayout();
        }
      },
    );
  }

  Widget _buildDesktopLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeroSection(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: _buildSearchSection(),
              ),
              Expanded(
                flex: 2,
                child: _buildInfoSection(),
              ),
            ],
          ),
          _buildPromotionsSection(),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeroSection(),
          _buildSearchSection(),
          _buildInfoSection(),
          _buildPromotionsSection(),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(
              'https://picsum.photos/1600/900?random=${DateTime.now().second}'),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
              ),
            ),
          ),
          Center(
            child: Text(
              'Discover Your Next Adventure',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuad);
  }

  Widget _buildSearchSection() {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Find Your Journey',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                  ),
                  TextButton.icon(
                    icon: Icon(_showRecentSearches
                        ? Iconsax.arrow_up_2
                        : Iconsax.arrow_down_1),
                    label: Text(
                        _showRecentSearches ? 'Hide Recent' : 'Show Recent'),
                    onPressed: () {
                      setState(() {
                        _showRecentSearches = !_showRecentSearches;
                      });
                    },
                  ),
                ],
              ),
              if (_showRecentSearches) _buildRecentSearches(),
              const SizedBox(height: 24),
              _buildTripTypeSelector(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                      child: _buildCityDropdown(
                          'From', _from, (val) => setState(() => _from = val))),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildCityDropdown(
                          'To', _to, (val) => setState(() => _to = val))),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                      child: _buildDatePicker('Departure', _date,
                          (val) => setState(() => _date = val))),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _isRoundTrip
                          ? _buildDatePicker('Return', _returnDate,
                              (val) => setState(() => _returnDate = val))
                          : const SizedBox()),
                ],
              ),
              const SizedBox(height: 16),
              _buildPassengerSelector(),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _searchBuses,
                  icon: const Icon(Iconsax.search_normal),
                  label: const Text('Search Buses'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuad);
  }

  Widget _buildRecentSearches() {
    final recentSearches = [
      {'from': 'Nairobi', 'to': 'Mombasa', 'date': '2023-09-25'},
      {'from': 'Kampala', 'to': 'Entebbe', 'date': '2023-10-01'},
      {'from': 'Dar es Salaam', 'to': 'Arusha', 'date': '2023-10-05'},
    ];

    return Column(
      children: recentSearches.map((search) {
        return ListTile(
          leading: const Icon(Iconsax.clock),
          title: Text('${search['from']} to ${search['to']}'),
          subtitle: Text(search['date']!),
          trailing: const Icon(Iconsax.arrow_right_3),
          onTap: () {
            setState(() {
              _from = search['from'];
              _to = search['to'];
              _date = DateFormat('yyyy-MM-dd').parse(search['date']!);
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildTripTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isRoundTrip = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_isRoundTrip
                      ? Theme.of(context).primaryColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'One Way',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: !_isRoundTrip ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isRoundTrip = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _isRoundTrip
                      ? Theme.of(context).primaryColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Round Trip',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _isRoundTrip ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Popular Routes',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildPopularRoutesList(),
            const SizedBox(height: 24),
            Text(
              'Why Choose Us?',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildFeaturesList(),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuad);
  }

  Widget _buildCityDropdown(
      String label, String? value, Function(String?) onChanged) {
    final uniqueCities = _cities.toSet().toList(); // Remove duplicates

    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon:
            Icon(label == 'From' ? Iconsax.location : Iconsax.location_add),
      ),
      value: uniqueCities.contains(value) ? value : null,
      // Ensure value is in the list
      items: uniqueCities.map((String city) {
        return DropdownMenuItem<String>(
          value: city,
          child: Text(city),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Please select a city' : null,
    );
  }

  Widget _buildDatePicker(
      String label, DateTime? date, Function(DateTime) onChanged) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: const Icon(Iconsax.calendar),
      ),
      readOnly: true,
      controller: TextEditingController(
        text: date == null ? '' : DateFormat('MMM dd, yyyy').format(date),
      ),
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null && picked != date) {
          onChanged(picked);
        }
      },
      validator: (value) => value!.isEmpty ? 'Please select a date' : null,
    );
  }

  Widget _buildPassengerSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Passengers'),
          Row(
            children: [
              IconButton(
                icon: const Icon(Iconsax.minus_cirlce),
                onPressed: _passengers > 1
                    ? () => setState(() => _passengers--)
                    : null,
              ),
              Text('$_passengers', style: const TextStyle(fontSize: 18)),
              IconButton(
                icon: const Icon(Iconsax.add_circle),
                onPressed: () => setState(() => _passengers++),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPopularRoutesList() {
    final List<Map<String, String>> popularRoutes = [
      {'from': 'Nairobi', 'to': 'Mombasa'},
      {'from': 'Kampala', 'to': 'Entebbe'},
      {'from': 'Dar es Salaam', 'to': 'Arusha'},
    ];

    return Column(
      children: popularRoutes.map((route) {
        return ListTile(
          leading: const Icon(Iconsax.routing),
          title: Text('${route['from']} to ${route['to']}'),
          onTap: () {
            setState(() {
              _from = route['from'];
              _to = route['to'];
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildFeaturesList() {
    final List<Map<String, dynamic>> features = [
      {'icon': Iconsax.shield_tick, 'text': 'Safe and Secure'},
      {'icon': Iconsax.timer_1, 'text': 'Punctual Service'},
      {'icon': Iconsax.dollar_circle, 'text': 'Best Prices'},
      {'icon': Iconsax.support, 'text': '24/7 Customer Support'},
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: features.map((feature) {
        return Container(
          width: 150,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(feature['icon'],
                  size: 32, color: Theme.of(context).primaryColor),
              const SizedBox(height: 8),
              Text(feature['text'], textAlign: TextAlign.center),
            ],
          ),
        ).animate().scale(delay: 200.ms, duration: 300.ms);
      }).toList(),
    );
  }

  Widget _buildPromotionsSection() {
    final List<Map<String, String>> promotions = [
      {
        'title': 'Summer Sale',
        'description': 'Get 20% off on all routes',
        'image': 'https://picsum.photos/400/300?random=1'
      },
      {
        'title': 'Student Discount',
        'description': '15% off for students',
        'image': 'https://picsum.photos/400/300?random=2'
      },
      {
        'title': 'Group Booking',
        'description': 'Special rates for groups',
        'image': 'https://picsum.photos/400/300?random=3'
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Special Promotions',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        SizedBox(
          height: 200,
          child: CarouselView(
            itemExtent: 300,
            itemSnapping: true,
            scrollDirection: Axis.horizontal,
            children: promotions.map((promotion) {
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: NetworkImage(promotion['image']!),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7)
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            promotion['title']!,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            promotion['description']!,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.white,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuad);
  }

  void _searchBuses() {
    if (_formKey.currentState!.validate()) {
      context.go('/search-results', extra: {
        'from': _from!,
        'to': _to!,
        'date': _date!.toIso8601String(),
        'passengers': _passengers.toString(),
      });
    }
  }
}

// Add this extension method at the end of the file
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
}
