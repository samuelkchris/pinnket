import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

class Review {
  final String id;
  final String eventId;
  final String userId;  // Add this field
  final String reviewerName;
  final String reviewText;
  final double rating;
  final DateTime datePosted;

  Review({
    required this.id,
    required this.eventId,
    required this.userId,  // Add this field
    required this.reviewerName,
    required this.reviewText,
    required this.rating,
    required this.datePosted,
  });

  factory Review.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Review(
      id: doc.id,
      eventId: data['eventId'] ?? '',
      userId: data['userId'] ?? '',  // Add this field
      reviewerName: data['reviewerName'] ?? '',
      reviewText: data['reviewText'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      datePosted: (data['datePosted'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'userId': userId,  // Add this field
      'reviewerName': reviewerName,
      'reviewText': reviewText,
      'rating': rating,
      'datePosted': Timestamp.fromDate(datePosted),
    };
  }
}

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> hasUserReviewedEvent(String userId, String eventId) async {
    final QuerySnapshot result = await _firestore
        .collection('reviews')
        .where('userId', isEqualTo: userId)
        .where('eventId', isEqualTo: eventId)
        .limit(1)
        .get();

    return result.docs.isNotEmpty;
  }

  Future<void> addReview(Review review) async {
    try {
      bool hasReviewed = await hasUserReviewedEvent(review.userId, review.eventId);
      if (hasReviewed) {
        throw Exception('User has already reviewed this event');
      }
      await _firestore.collection('reviews').add(review.toMap());
      developer.log('Review added successfully', name: 'ReviewService');
    } catch (e) {
      developer.log('Error adding review: $e', name: 'ReviewService', error: e);
      throw Exception('Failed to add review');
    }
  }

  Stream<List<Review>> getReviewsForEvent(String eventId, {int limit = 3}) {
    developer.log('Fetching reviews for eventId: $eventId', name: 'ReviewService');

    return _firestore
        .collection('reviews')
        .where('eventId', isEqualTo: eventId)
        .orderBy('datePosted', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      developer.log('Received snapshot with ${snapshot.docs.length} documents', name: 'ReviewService');

      if (snapshot.docs.isEmpty) {
        developer.log('No reviews found for eventId: $eventId', name: 'ReviewService');
        return <Review>[];
      }

      return snapshot.docs.map((doc) {
        try {
          Review review = Review.fromFirestore(doc);
          developer.log('Parsed review: ${review.id}', name: 'ReviewService');
          return review;
        } catch (e) {
          developer.log('Error parsing review document: $e', name: 'ReviewService', error: e);
          return null;
        }
      }).where((review) => review != null).cast<Review>().toList();
    }).handleError((error) {
      developer.log('Error in stream: $error', name: 'ReviewService', error: error);
      return <Review>[];
    });
  }

  // review  count
  Future<int> getReviewCountForEvent(String eventId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('reviews')
          .where('eventId', isEqualTo: eventId)
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      developer.log('Error getting review count: $e', name: 'ReviewService', error: e);
      return 0;
    }
  }

  Future<double> getAverageRatingForEvent(String eventId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('reviews')
          .where('eventId', isEqualTo: eventId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return 0.0;
      }

      double totalRating = 0.0;
      for (var doc in querySnapshot.docs) {
        totalRating += (doc.data() as Map<String, dynamic>)['rating'] ?? 0.0;
      }

      return totalRating / querySnapshot.docs.length;
    } catch (e) {
      developer.log('Error getting average rating: $e', name: 'ReviewService', error: e);
      return 0.0;
    }
  }
}