import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:iconsax/iconsax.dart';

import '../../models/event_models.dart';

class EmbeddableEventCard extends StatefulWidget {
  final Event event;

  const EmbeddableEventCard({super.key, required this.event});

  @override
  _EmbeddableEventCardState createState() => _EmbeddableEventCardState();
}

class _EmbeddableEventCardState extends State<EmbeddableEventCard> {
  bool _isHovered = false;
  bool _isBookmarked = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: 300,
        height: _isHovered ? 400 : 350,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isHovered ? 0.2 : 0.1),
              blurRadius: _isHovered ? 16 : 8,
              offset: Offset(0, _isHovered ? 8 : 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.event.name!,
                      style: Theme.of(context).textTheme.titleLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.event.eventdescription!,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: _isHovered ? null : 2,
                      overflow: _isHovered ? null : TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    _buildInfoRow(Iconsax.calendar, _formatDate(widget.event.eventDate)),
                    const SizedBox(height: 4),
                    _buildInfoRow(Iconsax.location, "${widget.event.location} - ${widget.event.venue}"),
                  ],
                ),
              ),
            ),
            _buildViewDetailsButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: Image.network(
            widget.event.evLogo ?? '',
            height: 150,
            width: 300,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 8,
          left: 8,
          child: _buildCategoryChip(),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: _buildBookmarkButton(),
        ),
      ],
    );
  }

  Widget _buildCategoryChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        widget.event.eventSubCategory?.name ?? '',
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  Widget _buildBookmarkButton() {
    return GestureDetector(
      onTap: () => setState(() => _isBookmarked = !_isBookmarked),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(
          _isBookmarked ? Iconsax.bookmark_2 : Iconsax.bookmark,
          color: _isBookmarked ? Colors.blue : Colors.grey,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildViewDetailsButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: ElevatedButton(
        onPressed: () {
          // TODO: Implement view details action
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: const Text('View Details'),
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    final date = DateTime.parse(dateString);
    return DateFormat('EEEE, yyyy-MM-dd – kk:mm').format(date);
  }
}
