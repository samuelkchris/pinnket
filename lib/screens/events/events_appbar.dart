import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pinnket/models/event_models.dart';
import 'package:intl/intl.dart';
import 'package:pinnket/utils/layout.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:math';
import '../../services/toast_service.dart';
import '../../widgets/share_dialog.dart';
import '../../services/like_service.dart';

class EventSliverAppBar extends StatefulWidget {
  final Event? event;

  const EventSliverAppBar({super.key, this.event});

  @override
  _EventSliverAppBarState createState() => _EventSliverAppBarState();
}

class _EventSliverAppBarState extends State<EventSliverAppBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isLiked = false;
  bool _isDisliked = false;
  int _likeCount = 0;
  final LikeService _likeService = LikeService();
  late String _userEmail;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _userEmail = _generateRandomEmail();
    _initializeLikeStatus();
    _likeCount = widget.event?.likes ?? 0;
  }

  String _generateRandomEmail() {
    final random = Random();
    const String chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final randomString =
    List.generate(10, (index) => chars[random.nextInt(chars.length)])
        .join();
    return '$randomString@example.com';
  }

  Future<void> _initializeLikeStatus() async {
    if (widget.event?.eid == null) return;

    try {
      final likedDislikedEvents =
      await _likeService.getLikedDislikedEvents(_userEmail);
      if (mounted) {
        setState(() {
          _isLiked = likedDislikedEvents['likedEventIds']
              ?.contains(widget.event?.eid) ??
              false;
          _isDisliked = likedDislikedEvents['dislikedEventIds']
              ?.contains(widget.event?.eid) ??
              false;
        });
      }
    } catch (e) {
      debugPrint('Error initializing like status: $e');
    }
  }

  Future<void> _toggleLike() async {
    if (widget.event?.eid == null) return;

    final wasLiked = _isLiked;
    final wasDisliked = _isDisliked;

    setState(() {
      _isLiked = !_isLiked;
      if (_isDisliked) _isDisliked = false;
      _likeCount += _isLiked ? 1 : -1;
      if (wasDisliked) _likeCount += 1; // Additional increment if it was disliked before
    });

    _animationController.forward().then((_) => _animationController.reverse());

    try {
      await _likeService.likeEvent(widget.event!.eid!, _userEmail, _isLiked);
    } catch (e) {
      debugPrint('Error toggling like: $e');
      if (mounted) {
        setState(() {
          _isLiked = wasLiked;
          _isDisliked = wasDisliked;
          _likeCount = widget.event?.likes ?? 0;
        });
      }
      _showErrorSnackBar('Failed to update like status');
    }
  }

  Future<void> _toggleDislike() async {
    if (widget.event?.eid == null) return;

    final wasLiked = _isLiked;
    final wasDisliked = _isDisliked;

    setState(() {
      _isDisliked = !_isDisliked;
      if (_isLiked) {
        _isLiked = false;
        _likeCount -= 1;
      }
    });

    _animationController.forward().then((_) => _animationController.reverse());

    try {
      await _likeService.likeEvent(widget.event!.eid!, _userEmail, _isDisliked);
    } catch (e) {
      debugPrint('Error toggling dislike: $e');
      if (mounted) {
        setState(() {
          _isLiked = wasLiked;
          _isDisliked = wasDisliked;
          _likeCount = widget.event?.likes ?? 0;
        });
      }
      _showErrorSnackBar('Failed to update dislike status');
    }
  }

  void _showErrorSnackBar(String message) {
    ToastManager().showErrorToast(context, message);
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 400.0,
      floating: false,
      pinned: true,
      stretch: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground
        ],
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        collapseMode: CollapseMode.pin,
        title: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: constraints.biggest.height <= kToolbarHeight ? 1.0 : 0.0,
              child: Text(
                widget.event?.name ?? 'No Event Selected',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: isDisplayDesktop(context) ? null : 15,
                ),
              ),
            );
          },
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            _buildEventImage(),
            _buildGradientOverlay(),
            if (widget.event != null) _buildEventDateWidget(),
          ],
        ),
      ),
      actions: [
        _buildLikeButton(),
        _buildDislikeButton(),
        _buildShareButton(),
      ],
    );
  }

  Widget _buildEventImage() {
    bool isDesktop = isDisplayDesktop(context);
    return AspectRatio(
      aspectRatio: 3 / 1,
      child: ClipRRect(
        child: Image.network(
          isDesktop ? widget.event!.bannerURL ?? "" : widget.event!.evLogo ?? "",
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return ShimmerEffect(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Icon(Iconsax.close_square,
                  size: 48, color: Theme.of(context).colorScheme.error),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.7),
          ],
        ),
      ),
    );
  }

  Widget _buildEventDateWidget() {
    return Positioned(
      bottom: 16,
      left: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Iconsax.calendar, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(
              _formatEventDateRange(
                  widget.event?.eventDate, widget.event?.endtime),
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLikeButton() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: IconButton(
        icon: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Icon(
                _isLiked ? Iconsax.heart5 : Iconsax.heart,
                key: ValueKey<bool>(_isLiked),
                color:
                _isLiked ? Colors.red : Theme.of(context).iconTheme.color,
                size: 24,
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  _likeCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
        onPressed: _toggleLike,
      ),
    );
  }

  Widget _buildDislikeButton() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: IconButton(
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child: Icon(
            _isDisliked ? Iconsax.dislike5 : Iconsax.dislike,
            key: ValueKey<bool>(_isDisliked),
            color:
            _isDisliked ? Colors.blue : Theme.of(context).iconTheme.color,
          ),
        ),
        onPressed: _toggleDislike,
      ),
    );
  }

  Widget _buildShareButton() {
    return IconButton(
      icon: Icon(Iconsax.share, color: Theme.of(context).colorScheme.primary),
      onPressed: () => _showSlidingShareDrawer(context),
    );
  }

  void _showSlidingShareDrawer(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (BuildContext buildContext, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(animation),
          child: SlidingShareDrawer(
            eventImageUrl: widget.event?.bannerURL ?? '',
            eventName: widget.event?.name ?? 'Event',
            baseUrl: "https://pinnket.com/#/events/${widget.event?.eid}",
            eventDescription:
            widget.event?.eventdescription ?? 'Event Description',
          ),
        );
      },
    );
  }

  String _formatEventDateRange(String? startDateString, String? endDateString) {
    if (startDateString == null || startDateString.isEmpty) {
      return 'Date not available';
    }

    try {
      DateTime startDate = _parseDateTime(startDateString);
      String formattedStart = DateFormat('MMM d, yyyy').format(startDate);

      if (endDateString != null && endDateString.isNotEmpty) {
        DateTime endDate = _parseDateTime(endDateString);
        String formattedEnd = DateFormat('MMM d, yyyy').format(endDate);

        if (formattedStart == formattedEnd) {
          // Single day event
          return '$formattedStart • ${DateFormat('h:mm a').format(startDate)} - ${DateFormat('h:mm a').format(endDate)}';
        } else {
          // Multi-day event
          return '$formattedStart - $formattedEnd';
        }
      } else {
        // Only start date available
        return formattedStart;
      }
    } catch (e) {
      debugPrint('Error parsing date: $e');
      return 'Invalid date format';
    }
  }

  DateTime _parseDateTime(String dateTimeString) {
    try {
      return DateFormat("yyyy-MM-ddTHH:mm:ss.SSS").parse(dateTimeString, true);
    } catch (e) {
      debugPrint('Error parsing date: $e : $dateTimeString');
      throw FormatException('Invalid date format: $dateTimeString');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

class ShimmerEffect extends StatelessWidget {
  final Widget child;

  const ShimmerEffect({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      period: const Duration(seconds: 2),
      child: child,
    );
  }
}