import 'package:cloud_firestore/cloud_firestore.dart';

class TripModel {
  final String id;
  final String title;
  final String description;
  final String destination;
  final int durationDays;
  final String ownerId;
  final String creatorId;
  final String? creatorName;
  final String? coverUrl;
  final String? parentId;
  final DateTime? startDate;
  final String tripStatus;
  final List<String> memberIds;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TripModel({
    required this.id,
    required this.title,
    required this.description,
    required this.destination,
    required this.durationDays,
    required this.ownerId,
    required this.creatorId,
    this.creatorName,
    this.coverUrl,
    this.parentId,
    this.startDate,
    required this.tripStatus,
    required this.memberIds,
    this.createdAt,
    this.updatedAt,
  });

  factory TripModel.fromMap(String id, Map<String, dynamic> data) {
    return TripModel(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      destination: data['destination'] ?? '',
      durationDays: (data['durationDays'] as num?)?.toInt() ?? 0,
      ownerId: data['ownerId'] ?? '',
      creatorId: data['creatorId'] ?? '',
      creatorName: data['creatorName'],
      coverUrl: data['coverUrl'],
      parentId: data['parentId'],
      startDate: _parseDate(data['startDate']),
      tripStatus: data['tripStatus'] ?? 'planned',
      memberIds: List<String>.from(data['memberIds'] ?? []),
      createdAt: _parseDate(data['createdAt']),
      updatedAt: _parseDate(data['updatedAt']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}


class DayModel {
  final String id;
  final String tripId;
  final int dayNumber;
  final DateTime? date;

  DayModel({
    required this.id,
    required this.tripId,
    required this.dayNumber,
    this.date,
  });

  factory DayModel.fromMap(
    String id,
    Map<String, dynamic> data,
  ) {
    return DayModel(
      id: id,
      tripId: data['tripId'] ?? '',
      dayNumber: (data['dayNumber'] as num?)?.toInt() ?? 1,
      date: TripModel._parseDate(data['date']),
    );
  }
}


class StopModel {
  final String id;
  final String tripId;
  final String dayId;
  final String placeName;
  final String description;
  final String? category;
  final String? startTime;
  final int? durationMinutes;
  final double? cost;
  final String? note;
  final double? latitude;
  final double? longitude;
  final int order;

  StopModel({
    required this.id,
    required this.tripId,
    required this.dayId,
    required this.placeName,
    required this.description,
    this.category,
    this.startTime,
    this.durationMinutes,
    this.cost,
    this.note,
    this.latitude,
    this.longitude,
    required this.order,
  });

  factory StopModel.fromMap(
    String id,
    Map<String, dynamic> data,
  ) {
    final location = data['location'] as Map<String, dynamic>? ?? {};

    return StopModel(
      id: id,
      tripId: data['tripId'] ?? '',
      dayId: data['dayId'] ?? '',
      placeName: data['placeName'] ?? '',
      description: data['description'] ?? '',
      category: data['category'],
      startTime: data['startTime'],
      durationMinutes:
          (data['durationMinutes'] as num?)?.toInt(),
      cost: (data['cost'] as num?)?.toDouble(),
      note: data['note'],
      latitude: (location['lat'] as num?)?.toDouble(),
      longitude: (location['lng'] as num?)?.toDouble(),
      order: (data['order'] as num?)?.toInt() ?? 0,
    );
  }
}


class CheckInModel {
  final String id;
  final String stopId;
  final String userId;
  final double? latitude;
  final double? longitude;
  final String? photoUrl;
  final DateTime? checkedAt;

  CheckInModel({
    required this.id,
    required this.stopId,
    required this.userId,
    this.latitude,
    this.longitude,
    this.photoUrl,
    this.checkedAt,
  });

  factory CheckInModel.fromMap(
    String id,
    Map<String, dynamic> data,
  ) {
    final location =
        data['location'] as Map<String, dynamic>? ?? {};

    return CheckInModel(
      id: id,
      stopId: data['stopId'] ?? '',
      userId: data['userId'] ?? '',
      latitude: (location['lat'] as num?)?.toDouble(),
      longitude: (location['lng'] as num?)?.toDouble(),
      photoUrl: data['photoUrl'],
      checkedAt: TripModel._parseDate(data['checkedAt']),
    );
  }
}


class ExpenseModel {
  final String id;
  final String title;
  final double amount;
  final String paidBy;
  final List<String> splitAmong;
  final bool isSettled;

  ExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.paidBy,
    required this.splitAmong,
    required this.isSettled,
  });

  factory ExpenseModel.fromMap(
    String id,
    Map<String, dynamic> data,
  ) {
    return ExpenseModel(
      id: id,
      title: data['title'] ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      paidBy: data['paidBy'] ?? '',
      splitAmong: List<String>.from(
        data['splitAmong'] ?? [],
      ),
      isSettled: data['isSettled'] ?? false,
    );
  }
}

