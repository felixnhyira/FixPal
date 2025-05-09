import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/connectivity_snackbar.dart';

class ConnectivityMonitor extends StatefulWidget {
  final Widget child;
  final VoidCallback? onRetry;
  final bool autoRetry;
  
  const ConnectivityMonitor({
    super.key, 
    required this.child,
    this.onRetry,
    this.autoRetry = false,
  });

  @override
  State<ConnectivityMonitor> createState() => _ConnectivityMonitorState();
}

class _ConnectivityMonitorState extends State<ConnectivityMonitor> {
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _hasConnection = true;
  Timer? _autoRetryTimer;

  @override
  void initState() {
    super.initState();
    _initConnectivityMonitoring();
  }

  void _initConnectivityMonitoring() {
    // Listen to connectivity changes
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen(_handleConnectivityChange);

    // Check initial connection
    _checkInitialConnection();
  }

  Future<void> _checkInitialConnection() async {
    final result = await Connectivity().checkConnectivity();
    _handleConnectivityChange(result);
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) {
    final isConnected = results.any((result) => result != ConnectivityResult.none);
    
    if (isConnected != _hasConnection) {
      setState(() => _hasConnection = isConnected);
      
      if (isConnected) {
        _autoRetryTimer?.cancel();
        _autoRetryTimer = null;
      }

      if (mounted) {
        ConnectivitySnackbar.show(
          context: context,
          hasConnection: _hasConnection,
          onRetry: widget.onRetry,
          autoRetry: widget.autoRetry,
        );
      }

      if (!isConnected && widget.autoRetry && widget.onRetry != null) {
        _autoRetryTimer = Timer.periodic(
          const Duration(seconds: 5),
          (_) => widget.onRetry!(),
        );
      }
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _autoRetryTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}