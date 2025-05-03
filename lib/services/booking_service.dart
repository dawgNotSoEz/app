import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/booking.dart';

class BookingService extends ChangeNotifier {
  final List<Booking> _bookings = [];
  bool _isLoading = true;
  final _uuid = const Uuid();

  BookingService() {
    _loadBookings();
  }

  bool get isLoading => _isLoading;
  List<Booking> get bookings => List.unmodifiable(_bookings);

  List<Booking> getUserBookings(String username) {
    return _bookings.where((booking) => booking.username == username).toList();
  }

  Future<void> _loadBookings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookingsJson = prefs.getStringList('bookings') ?? [];
      
      _bookings.clear();
      for (final json in bookingsJson) {
        _bookings.add(Booking.fromJson(jsonDecode(json)));
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading bookings: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveBookings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookingsJson = _bookings.map((b) => jsonEncode(b.toJson())).toList();
      await prefs.setStringList('bookings', bookingsJson);
    } catch (e) {
      debugPrint('Error saving bookings: $e');
    }
  }

  Future<Booking> createBooking({
    required String spotId,
    required String spotName,
    required String username,
    required DateTime date,
    required String sessionType,
    required int duration,
    String? instructorName,
    String? notes,
  }) async {
    final booking = Booking(
      id: _uuid.v4(),
      spotId: spotId,
      spotName: spotName,
      username: username,
      date: date,
      sessionType: sessionType,
      duration: duration,
      status: BookingStatus.pending,
      createdAt: DateTime.now(),
      instructorName: instructorName,
      notes: notes,
    );
    
    _bookings.add(booking);
    await _saveBookings();
    notifyListeners();
    
    return booking;
  }

  Future<void> cancelBooking(String bookingId) async {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index >= 0) {
      final booking = _bookings[index];
      _bookings[index] = booking.copyWith(status: BookingStatus.cancelled);
      await _saveBookings();
      notifyListeners();
    }
  }

  Future<void> confirmBooking(String bookingId) async {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index >= 0) {
      final booking = _bookings[index];
      _bookings[index] = booking.copyWith(status: BookingStatus.confirmed);
      await _saveBookings();
      notifyListeners();
    }
  }

  List<Booking> getBookingsForUser(String username) {
    return _bookings.where((b) => b.username == username).toList();
  }

  List<Booking> getBookingsForSpot(String spotId) {
    return _bookings.where((b) => b.spotId == spotId).toList();
  }

  List<Booking> getUpcomingBookings(String username) {
    final now = DateTime.now();
    return _bookings.where((b) => 
      b.username == username && 
      b.date.isAfter(now) && 
      b.status != BookingStatus.cancelled
    ).toList();
  }
}
