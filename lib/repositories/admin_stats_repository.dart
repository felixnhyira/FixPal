import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/admin_stats_model.dart';

class AdminStatsRepository {
  final FirebaseFirestore _firestore;

  AdminStatsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<AdminStats> getAdminStats() async {
    final overviewSnapshot = await _firestore.collection('admin_stats').doc('overview').get();
    final weeklySnapshot = await _firestore.collection('admin_stats').doc('weekly').get();

    return AdminStats.fromFirestore(
      overviewSnapshot.data()!,
      weeklySnapshot.data()!,
    );
  }

  Stream<AdminStats> adminStatsStream() {
    return _firestore.collection('admin_stats').snapshots().map((snapshot) {
      final overviewData = snapshot.docs.firstWhere((doc) => doc.id == 'overview').data();
      final weeklyData = snapshot.docs.firstWhere((doc) => doc.id == 'weekly').data();
      return AdminStats.fromFirestore(overviewData, weeklyData);
    });
  }

  Future<void> initializeStats() async {
    final batch = _firestore.batch();
    
    final overviewRef = _firestore.collection('admin_stats').doc('overview');
    batch.set(overviewRef, OverviewStats(
      totalUsers: 0,
      activeUsers: 0,
      totalReports: 0,
      pendingReports: 0,
      resolvedReports: 0,
      newUsersToday: 0,
      lastUpdated: DateTime.now(),
    ).toMap());

    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    
    final weeklyRef = _firestore.collection('admin_stats').doc('weekly');
    batch.set(weeklyRef, WeeklyStats(
      startDate: startOfWeek,
      endDate: startOfWeek.add(Duration(days: 6)),
      newUsers: 0,
      completedJobs: 0,
      revenue: 0,
      avgResolutionTime: 0,
      resolvedReports: 0,
    ).toMap());

    await batch.commit();
  }

  Future<void> incrementStat({
    required String field,
    required int amount,
    bool isWeekly = false,
  }) async {
    final docRef = _firestore.collection('admin_stats').doc(isWeekly ? 'weekly' : 'overview');
    await docRef.update({
      field: FieldValue.increment(amount),
      if (!isWeekly) 'last_updated': FieldValue.serverTimestamp(),
    });
  }
}