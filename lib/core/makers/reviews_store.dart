import 'package:flutter/foundation.dart';

import '../models/makers.dart';

/// In-memory review store keyed by maker id. Same pattern as TicketsStore /
/// SavedEventsStore — swap for backend later. New reviews show up on the
/// profile as soon as the user submits.
class ReviewsStore extends ChangeNotifier {
  ReviewsStore._();
  static final ReviewsStore instance = ReviewsStore._();

  final Map<String, List<Review>> _byMaker = {};

  List<Review> forMaker(String makerId) =>
      List.unmodifiable(_byMaker[makerId] ?? const []);

  void addReview(String makerId, Review review) {
    (_byMaker[makerId] ??= []).insert(0, review);
    notifyListeners();
  }
}
