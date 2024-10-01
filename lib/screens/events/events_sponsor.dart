import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pinnket/models/event_models.dart';

class SponsorSection extends StatelessWidget {
  final List<EventSponsor> sponsors;

  const SponsorSection({super.key, required this.sponsors});

  @override
  Widget build(BuildContext context) {
    final visibleSponsors =
        sponsors.where((sponsor) => sponsor.active!).toList();
    if(visibleSponsors.isEmpty) {
      return const SizedBox.shrink();
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1200
            ? 4
            : constraints.maxWidth > 800
                ? 3
                : 2;
        return Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Our Sponsors',
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2, end: 0),
              const SizedBox(height: 32),
              if (visibleSponsors.isEmpty)
                Center(
                  child: Text(
                    'No sponsors to display at this time.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 24,
                    childAspectRatio: 1,
                  ),
                  itemCount: visibleSponsors.length,
                  itemBuilder: (context, index) => SponsorCard(
                    sponsor: visibleSponsors[index],
                  )
                      .animate()
                      .fadeIn(duration: 600.ms, delay: (100 * index).ms)
                      .scale(begin: const Offset(0.8, 0.8)),
                ),
            ],
          ),
        );
      },
    );
  }
}

class SponsorCard extends StatelessWidget {
  final EventSponsor sponsor;

  const SponsorCard({super.key, required this.sponsor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: sponsor.url!,
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(),
              ),
              errorWidget: (context, url, error) => const Center(
                child: Icon(Icons.error, color: Colors.red),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
