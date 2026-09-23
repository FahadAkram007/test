import 'package:flutter/material.dart';

/// Opening hours for a specific day of the week
class DayHours {
  final int openHour;
  final int openMinute;
  final int closeHour;
  final int closeMinute;
  final bool isClosed;

  const DayHours({
    required this.openHour,
    required this.openMinute,
    required this.closeHour,
    required this.closeMinute,
    this.isClosed = false,
  });

  const DayHours.closed()
      : openHour = 0,
        openMinute = 0,
        closeHour = 0,
        closeMinute = 0,
        isClosed = true;

  String format() {
    if (isClosed) return 'Closed';
    final openStr = _formatTime(openHour, openMinute);
    final closeStr = _formatTime(closeHour, closeMinute);
    return '$openStr - $closeStr';
  }

  static String _formatTime(int hour, int minute) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final displayMin = minute.toString().padLeft(2, '0');
    return '$displayHour:$displayMin $period';
  }
}

/// Represents a corporate benefit partner merchant/venue.
class PartnerModel {
  final String id;
  final String name;
  final String category;
  final IconData icon;
  final Color categoryColor;
  final String address;
  final double latitude;
  final double longitude;
  final Map<int, DayHours> weeklyOpeningHours; // 1 = Monday ... 7 = Sunday
  final double? distanceInKm;

  const PartnerModel({
    required this.id,
    required this.name,
    required this.category,
    required this.icon,
    required this.categoryColor,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.weeklyOpeningHours,
    this.distanceInKm,
  });

  PartnerModel copyWithDistance(double? newDistance) {
    return PartnerModel(
      id: id,
      name: name,
      category: category,
      icon: icon,
      categoryColor: categoryColor,
      address: address,
      latitude: latitude,
      longitude: longitude,
      weeklyOpeningHours: weeklyOpeningHours,
      distanceInKm: newDistance,
    );
  }

  /// Evaluates whether the venue is currently open based on current device time
  bool isOpenNow(DateTime now) {
    final weekday = now.weekday; // 1 = Monday, 7 = Sunday
    final hours = weeklyOpeningHours[weekday];
    if (hours == null || hours.isClosed) return false;

    final currentTotalMins = now.hour * 60 + now.minute;
    final openTotalMins = hours.openHour * 60 + hours.openMinute;
    final closeTotalMins = hours.closeHour * 60 + hours.closeMinute;

    return currentTotalMins >= openTotalMins && currentTotalMins < closeTotalMins;
  }

  /// Generates a friendly status string (e.g., "Open now • Closes 9:00 PM")
  String getOpenStatus(DateTime now) {
    final weekday = now.weekday;
    final hours = weeklyOpeningHours[weekday];
    if (hours == null || hours.isClosed) return 'Closed today';

    final currentTotalMins = now.hour * 60 + now.minute;
    final openTotalMins = hours.openHour * 60 + hours.openMinute;
    final closeTotalMins = hours.closeHour * 60 + hours.closeMinute;

    if (currentTotalMins < openTotalMins) {
      return 'Closed • Opens ${DayHours._formatTime(hours.openHour, hours.openMinute)}';
    } else if (currentTotalMins < closeTotalMins) {
      return 'Open now • Closes ${DayHours._formatTime(hours.closeHour, hours.closeMinute)}';
    } else {
      return 'Closed for today';
    }
  }

  /// Day names helper
  static const List<String> dayNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  /// Standard business hours (e.g. 8:00 AM - 9:00 PM)
  static Map<int, DayHours> standardHours({
    int openHour = 8,
    int closeHour = 21,
    bool closeSunday = false,
  }) {
    return {
      1: DayHours(openHour: openHour, openMinute: 0, closeHour: closeHour, closeMinute: 0),
      2: DayHours(openHour: openHour, openMinute: 0, closeHour: closeHour, closeMinute: 0),
      3: DayHours(openHour: openHour, openMinute: 0, closeHour: closeHour, closeMinute: 0),
      4: DayHours(openHour: openHour, openMinute: 0, closeHour: closeHour, closeMinute: 0),
      5: DayHours(openHour: openHour, openMinute: 0, closeHour: closeHour + 1, closeMinute: 0),
      6: DayHours(openHour: openHour + 1, openMinute: 0, closeHour: closeHour, closeMinute: 0),
      7: closeSunday
          ? const DayHours.closed()
          : DayHours(openHour: 10, openMinute: 0, closeHour: 18, closeMinute: 0),
    };
  }

  /// Sample partner locations situated in and around 01968 Senftenberg, Germany
  static List<PartnerModel> samplePartners = [
    PartnerModel(
      id: 'p1',
      name: 'Markt-Café & Bäckerei Senftenberg',
      category: 'Food & Dining',
      icon: Icons.restaurant_rounded,
      categoryColor: const Color(0xFF0F766E),
      address: 'Markt 14, 01968 Senftenberg',
      latitude: 51.51950,
      longitude: 14.00480,
      weeklyOpeningHours: standardHours(openHour: 7, closeHour: 20),
    ),
    PartnerModel(
      id: 'p2',
      name: 'Vital Sport- & Fitnessclub',
      category: 'Fitness',
      icon: Icons.fitness_center_rounded,
      categoryColor: const Color(0xFF0F766E),
      address: 'Bahnhofstraße 22, 01968 Senftenberg',
      latitude: 51.52350,
      longitude: 14.00850,
      weeklyOpeningHours: standardHours(openHour: 6, closeHour: 22),
    ),
    PartnerModel(
      id: 'p3',
      name: 'Ristorante Da Olindo',
      category: 'Food & Dining',
      icon: Icons.local_pizza_rounded,
      categoryColor: const Color(0xFF0F766E),
      address: 'Schloßstraße 7, 01968 Senftenberg',
      latitude: 51.51780,
      longitude: 14.00320,
      weeklyOpeningHours: standardHours(openHour: 11, closeHour: 22),
    ),
    PartnerModel(
      id: 'p4',
      name: 'SeeCampus Buch & Technik',
      category: 'Education & Tech',
      icon: Icons.menu_book_rounded,
      categoryColor: const Color(0xFF0F766E),
      address: 'Laugkfeld 28, 01968 Senftenberg',
      latitude: 51.52850,
      longitude: 13.99800,
      weeklyOpeningHours: standardHours(openHour: 9, closeHour: 19),
    ),
    PartnerModel(
      id: 'p5',
      name: 'KollektivO Bio-Rösterei & Café',
      category: 'Coffee & Cafe',
      icon: Icons.coffee_rounded,
      categoryColor: const Color(0xFF0F766E),
      address: 'Kreuzstraße 18, 01968 Senftenberg',
      latitude: 51.52100,
      longitude: 14.00650,
      weeklyOpeningHours: standardHours(openHour: 8, closeHour: 18),
    ),
    PartnerModel(
      id: 'p6',
      name: 'Senftenberger See Radler & Verleih',
      category: 'Commute',
      icon: Icons.pedal_bike_rounded,
      categoryColor: const Color(0xFF0F766E),
      address: 'Steindamm 12, 01968 Senftenberg',
      latitude: 51.51600,
      longitude: 14.00900,
      weeklyOpeningHours: standardHours(openHour: 9, closeHour: 19),
    ),
    PartnerModel(
      id: 'p7',
      name: 'Erlebnisbad & Aktivpark Senftenberg',
      category: 'Fitness',
      icon: Icons.pool_rounded,
      categoryColor: const Color(0xFF0F766E),
      address: 'Briesker Straße 35, 01968 Senftenberg',
      latitude: 51.51400,
      longitude: 13.98500,
      weeklyOpeningHours: standardHours(openHour: 8, closeHour: 21),
    ),
  ];
}
