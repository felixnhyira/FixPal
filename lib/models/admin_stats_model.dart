import 'package:cloud_firestore/cloud_firestore.dart';

class AdminStats {
  final OverviewStats overview;
  final WeeklyStats weekly;

  AdminStats({required this.overview, required this.weekly});

  factory AdminStats.fromFirestore(Map<String, dynamic> overviewData, Map<String, dynamic> weeklyData) {
    return AdminStats(
      overview: OverviewStats.fromMap(overviewData),
      weekly: WeeklyStats.fromMap(weeklyData),
    );
  }
}

class OverviewStats {
  final int totalUsers;
  final int activeUsers;
  final int totalReports;
  final int pendingReports;
  final int resolvedReports;
  final int newUsersToday;
  final DateTime lastUpdated;

  OverviewStats({
    required this.totalUsers,
    required this.activeUsers,
    required this.totalReports,
    required this.pendingReports,
    required this.resolvedReports,
    required this.newUsersToday,
    required this.lastUpdated,
  });

  factory OverviewStats.fromMap(Map<String, dynamic> data) {
    return OverviewStats(
      totalUsers: data['total_users'] ?? 0,
      activeUsers: data['active_users'] ?? 0,
      totalReports: data['total_reports'] ?? 0,
      pendingReports: data['pending_reports'] ?? 0,
      resolvedReports: data['resolved_reports'] ?? 0,
      newUsersToday: data['new_users_today'] ?? 0,
      lastUpdated: (data['last_updated'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'total_users': totalUsers,
      'active_users': activeUsers,
      'total_reports': totalReports,
      'pending_reports': pendingReports,
      'resolved_reports': resolvedReports,
      'new_users_today': newUsersToday,
      'last_updated': Timestamp.fromDate(lastUpdated),
    };
  }
}

class WeeklyStats {
  final DateTime startDate;
  final DateTime endDate;
  final int newUsers;
  final int completedJobs;
  final double revenue;
  final double avgResolutionTime;
  final int resolvedReports;

  WeeklyStats({
    required this.startDate,
    required this.endDate,
    required this.newUsers,
    required this.completedJobs,
    required this.revenue,
    required this.avgResolutionTime,
    required this.resolvedReports,
  });

  factory WeeklyStats.fromMap(Map<String, dynamic> data) {
    return WeeklyStats(
      startDate: (data['start_date'] as Timestamp).toDate(),
      endDate: (data['end_date'] as Timestamp).toDate(),
      newUsers: data['new_users'] ?? 0,
      completedJobs: data['completed_jobs'] ?? 0,
      revenue: (data['revenue'] ?? 0).toDouble(),
      avgResolutionTime: (data['avg_resolution_time'] ?? 0).toDouble(),
      resolvedReports: data['resolved_reports'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'start_date': Timestamp.fromDate(startDate),
      'end_date': Timestamp.fromDate(endDate),
      'new_users': newUsers,
      'completed_jobs': completedJobs,
      'revenue': revenue,
      'avg_resolution_time': avgResolutionTime,
      'resolved_reports': resolvedReports,
    };
  }
}