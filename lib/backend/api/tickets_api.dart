import 'package:dio/dio.dart';

import '../models/ticket_models.dart';
import 'http_client.dart';

class TicketsApi {
  final HttpClient _http;
  TicketsApi(this._http);

  Future<ApiTicket> rsvp(String eventId) async {
    try {
      final res = await _http.dio.post<Map<String, dynamic>>(
        '/api/v1/events/$eventId/rsvp',
      );
      return ApiTicket.fromJson(res.data!);
    } on DioException catch (e) {
      throw _http.translate(e);
    }
  }

  Future<void> cancel(String eventId) async {
    try {
      await _http.dio.delete('/api/v1/events/$eventId/rsvp');
    } on DioException catch (e) {
      throw _http.translate(e);
    }
  }

  /// Returns null when the user has no ticket for the event.
  Future<ApiTicket?> myTicketForEvent(String eventId) async {
    try {
      final res = await _http.dio.get<dynamic>(
        '/api/v1/events/$eventId/my-ticket',
      );
      if (res.data == null) return null;
      return ApiTicket.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _http.translate(e);
    }
  }

  Future<List<ApiTicket>> listMine() async {
    try {
      final res = await _http.dio.get<List<dynamic>>('/api/v1/me/tickets');
      return res.data!
          .map((e) => ApiTicket.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _http.translate(e);
    }
  }
}
