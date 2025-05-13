// widgets/countdown_timer.dart

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import '../utils/date_formatter.dart';

class CountdownTimer extends StatefulWidget {
  final DateTime? deadline;

  const CountdownTimer({super.key, required this.deadline});

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Timer _timer;
  late DateTime? _deadline;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _deadline = widget.deadline;
    _updateRemainingTime();

    // Update every minute
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      _updateRemainingTime();
    });
  }

  void _updateRemainingTime() {
    if (_deadline == null) return;

    final now = DateTime.now();
    final remaining = _deadline!.isAfter(now)
        ? _deadline!.difference(now)
        : Duration.zero;

    setState(() {
      _remaining = remaining;
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours.remainder(24);
    final minutes = duration.inMinutes.remainder(60);

    if (days > 0) {
      return '$days d $hours h';
    } else if (hours > 0) {
      return '$hours h $minutes min';
    } else {
      return '$minutes min';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_deadline == null || _deadline!.isBefore(DateTime.now())) {
      return Text(
        'Deadline passed',
        style: TextStyle(color: Colors.red.shade300),
      );
    }

    return Row(
      children: [
        Icon(Icons.timer, size: 16, color: DateFormatter.getDeadlineColor(_deadline)),
        const SizedBox(width: 4),
        Text(
          _formatDuration(_remaining),
          style: TextStyle(
            color: DateFormatter.getDeadlineColor(_deadline),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}