import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:pinnket/services/toast_service.dart';
import '../services/review_service.dart';

class ReviewSubmissionDialog extends StatefulWidget {
  final String eventId;
  final String userId;

  const ReviewSubmissionDialog({super.key, required this.eventId, required this.userId});

  @override
  _ReviewSubmissionDialogState createState() => _ReviewSubmissionDialogState();
}

class _ReviewSubmissionDialogState extends State<ReviewSubmissionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _reviewService = ReviewService();
  String _reviewerName = '';
  String _reviewText = '';
  double _rating = 0;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Submit Review'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Your Name'),
              validator: (value) =>
              value!.isEmpty ? 'Please enter your name' : null,
              onSaved: (value) => _reviewerName = value!,
            ),
            const SizedBox(height: 8),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Review'),
              validator: (value) =>
              value!.isEmpty ? 'Please enter your review' : null,
              onSaved: (value) => _reviewText = value!,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Text('Rating: ${_rating.toStringAsFixed(1)}'),
            RatingBar.builder(
              initialRating: _rating,
              minRating: 0,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  _rating = rating;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitReview,
          child: _isSubmitting
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
              : const Text('Submit'),
        ),
      ],
    );
  }

  Future<void> _submitReview() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      _formKey.currentState!.save();
      try {
        await _reviewService.addReview(Review(
          id: '',
          eventId: widget.eventId,
          userId: widget.userId,
          reviewerName: _reviewerName,
          reviewText: _reviewText,
          rating: _rating,
          datePosted: DateTime.now(),
        ));
        Navigator.of(context).pop();
      } catch (e) {
        ToastManager().showErrorToast(context,'Failed to submit review. Please try again.');
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }
}