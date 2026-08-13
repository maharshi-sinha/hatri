import '../models/models.dart';

abstract class EventRepository {
  Future<List<Event>> getEvents();
}
