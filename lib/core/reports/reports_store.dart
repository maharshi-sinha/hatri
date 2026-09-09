import 'package:flutter/foundation.dart';

/// What kind of thing is being reported. Add more types as new surfaces get
/// the report flow.
enum ReportTarget { wallPost, maker, scene, comment, other }

/// Preset reasons. Order matters — most common first.
enum ReportReason {
  spam,           // spam / self-promotion
  offTopic,       // doesn't belong in this scene / space
  inappropriate,  // nsfw, offensive imagery
  harassment,     // bullying / targeted attacks
  misleading,     // fake, scam, misleading claims
  hateSpeech,     // slurs, discrimination
  other,          // something else — free text required
}

extension ReportReasonX on ReportReason {
  String get label {
    switch (this) {
      case ReportReason.spam:
        return 'Spam or self-promotion';
      case ReportReason.offTopic:
        return "Doesn't belong here";
      case ReportReason.inappropriate:
        return 'Inappropriate content';
      case ReportReason.harassment:
        return 'Harassment or bullying';
      case ReportReason.misleading:
        return 'Fake or misleading';
      case ReportReason.hateSpeech:
        return 'Hate speech';
      case ReportReason.other:
        return 'Something else';
    }
  }

  String get emoji {
    switch (this) {
      case ReportReason.spam:
        return '🚫';
      case ReportReason.offTopic:
        return '📍';
      case ReportReason.inappropriate:
        return '⚠️';
      case ReportReason.harassment:
        return '🛑';
      case ReportReason.misleading:
        return '🎭';
      case ReportReason.hateSpeech:
        return '🚨';
      case ReportReason.other:
        return '📝';
    }
  }
}

class Report {
  final String id;
  final ReportTarget target;
  final String targetId;
  final ReportReason reason;
  final String details;    // free text — always saved even for preset reasons
  final DateTime createdAt;

  Report({
    required this.id,
    required this.target,
    required this.targetId,
    required this.reason,
    required this.details,
    required this.createdAt,
  });
}

/// In-memory report log. Same ChangeNotifier pattern as ReviewsStore /
/// SavedEventsStore — swap for backend later. Admin dashboard would read from
/// this to moderate.
class ReportsStore extends ChangeNotifier {
  ReportsStore._();
  static final ReportsStore instance = ReportsStore._();

  final List<Report> _reports = [];

  List<Report> get all => List.unmodifiable(_reports);

  bool hasReported(ReportTarget target, String targetId) => _reports.any(
        (r) => r.target == target && r.targetId == targetId,
      );

  void submit({
    required ReportTarget target,
    required String targetId,
    required ReportReason reason,
    required String details,
  }) {
    _reports.add(Report(
      id: 'r-${_reports.length + 1}',
      target: target,
      targetId: targetId,
      reason: reason,
      details: details.trim(),
      createdAt: DateTime.now(),
    ));
    notifyListeners();
  }
}
