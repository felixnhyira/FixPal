import 'dart:async';
import 'package:fixpal/models/job_model.dart';
import 'package:fixpal/screens/admin_dashboard.dart';
import 'package:fixpal/screens/hired_freelancers_screen.dart';
import 'package:fixpal/screens/job_details_screen.dart';
import 'package:fixpal/screens/job_posting_screen.dart';
import 'package:fixpal/screens/login_screen.dart';
import 'package:fixpal/screens/messages_screen.dart';
import 'package:fixpal/screens/my_jobs_screen.dart';
import 'package:fixpal/screens/notifications_screen.dart';
import 'package:fixpal/screens/profile_screen.dart';
import 'package:fixpal/screens/proposals_received_screen.dart';
import 'package:fixpal/screens/proposals_screen.dart';
import 'package:fixpal/screens/settings_screen.dart';
import 'package:fixpal/utils/constants.dart';
import 'package:fixpal/widgets/recent_activity_feed.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Firebase Services
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Search Functionality
  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  final SpeechToText _speechToText = SpeechToText();
  Timer? _debounceTimer;

  // App State
  String? _userRole;
  String? _userName;
  String _searchQuery = '';
  Query _jobsQuery = FirebaseFirestore.instance.collection('jobs');
  int _unreadNotificationsCount = 0;
  bool _showSearchBar = false;
  bool _isListening = false;
  bool _speechEnabled = false;
  final bool _isFeaturedSectionVisible = true;
  bool _isLoading = false;

  // Search History & Filters
  List<String> _searchHistory = [];
  List<String> _searchSuggestions = [];
  final Map<String, dynamic> _activeFilters = {
    'priceMin': null,
    'priceMax': null,
    'locationRadius': null,
    'jobType': null,
    'experienceLevel': null
  };
  final String _selectedSortOption = 'Most Relevant';

  @override
  void initState() {
    super.initState();
    _initializeApp();
    _searchFocusNode.addListener(_handleSearchFocusChange);
    _loadSearchHistory();
  }

  Future<void> _initializeApp() async {
    await _fetchUserRole();
    await _fetchUnreadNotifications();
    await _checkSpeechAvailability();
  }

  Future<void> _fetchUserRole() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists && mounted) {
        setState(() {
          _userRole = doc.data()?['role'];
          _userName = doc.data()?['firstName'] ?? 'User'; // Assumes firstName exists in Firestore
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error fetching user role: $e');
    }
  }

  Future<void> _fetchUnreadNotifications() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: user.uid)
          .where('isRead', isEqualTo: false)
          .get();
      if (mounted) {
        setState(() => _unreadNotificationsCount = snapshot.docs.length);
      }
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
    }
  }

  Future<void> _checkSpeechAvailability() async {
    final available = await _speechToText.initialize();
    if (mounted) {
      setState(() => _speechEnabled = available);
    }
  }

  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _searchHistory = prefs.getStringList('searchHistory') ?? []);
  }

  Future<void> _saveSearchHistory(String query) async {
    if (!_searchHistory.contains(query)) {
      setState(() {
        _searchHistory.insert(0, query);
        if (_searchHistory.length > 5) {
          _searchHistory.removeLast();
        }
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('searchHistory', _searchHistory);
    }
  }

  void _handleSearchFocusChange() {
    if (!_searchFocusNode.hasFocus && _searchController.text.isEmpty) {
      setState(() => _showSearchBar = false);
    }
  }

  void _toggleSearch() {
    setState(() {
      _showSearchBar = !_showSearchBar;
      if (_showSearchBar) {
        FocusScope.of(context).requestFocus(_searchFocusNode);
      } else {
        _searchFocusNode.unfocus();
      }
    });
  }

  void _toggleVoiceSearch() async {
    if (!_speechEnabled) return;
    setState(() => _isListening = !_isListening);
    if (_isListening) {
      await _speechToText.listen(
        onResult: (result) {
          if (result.finalResult && mounted) {
            setState(() {
              _searchController.text = result.recognizedWords;
              _filterJobs(result.recognizedWords);
              _isListening = false;
            });
          }
        },
      );
    } else {
      await _speechToText.stop();
    }
  }

  void _filterJobs(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      if (!mounted) return;
      setState(() => _isLoading = true);
      try {
        Query queryRef = _firestore.collection('jobs');

        // Apply search term
        if (query.isNotEmpty) {
          queryRef = queryRef.where('searchKeywords', arrayContains: query.toLowerCase());
        }

        // Apply filters
        if (_activeFilters['priceMin'] != null) {
          queryRef = queryRef.where('price', isGreaterThanOrEqualTo: _activeFilters['priceMin']);
        }
        if (_activeFilters['priceMax'] != null) {
          queryRef = queryRef.where('price', isLessThanOrEqualTo: _activeFilters['priceMax']);
        }

        // Apply sorting
        switch (_selectedSortOption) {
          case 'Newest First':
            queryRef = queryRef.orderBy('createdAt', descending: true);
            break;
          case 'Highest Paying':
            queryRef = queryRef.orderBy('price', descending: true);
            break;
          case 'Most Relevant':
          default:
            break;
        }

        // Save to search history
        if (query.trim().isNotEmpty) {
          _saveSearchHistory(query.trim());
        }

        setState(() {
          _jobsQuery = queryRef;
          _searchQuery = query;
          _isLoading = false;
          _updateSuggestions(query);
        });
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          _showErrorSnackBar('Search error: $e');
        }
      }
    });
  }

  void _updateSuggestions(String query) {
    setState(() {
      _searchSuggestions = _searchHistory
          .where((term) => term.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Jobs'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Price Range:'),
              RangeSlider(
                values: RangeValues(
                  _activeFilters['priceMin']?.toDouble() ?? 0,
                  _activeFilters['priceMax']?.toDouble() ?? 1000,
                ),
                min: 0,
                max: 1000,
                divisions: 10,
                labels: RangeLabels(
                  _activeFilters['priceMin']?.toString() ?? '0',
                  _activeFilters['priceMax']?.toString() ?? '1000',
                ),
                onChanged: (values) {
                  setState(() {
                    _activeFilters['priceMin'] = values.start.toInt();
                    _activeFilters['priceMax'] = values.end.toInt();
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text('Job Type:'),
              DropdownButton<String>(
                value: _activeFilters['jobType'],
                isExpanded: true,
                items: ['All', 'Full-time', 'Part-time', 'Contract']
                    .map((type) => DropdownMenuItem(
                  value: type == 'All' ? null : type,
                  child: Text(type),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() => _activeFilters['jobType'] = value);
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _activeFilters['priceMin'] = null;
                _activeFilters['priceMax'] = null;
                _activeFilters['jobType'] = null;
              });
              Navigator.pop(context);
            },
            child: const Text('Reset'),
          ),
          TextButton(
            onPressed: () {
              _filterJobs(_searchController.text);
              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          decoration: InputDecoration(
            hintText: 'Search jobs...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _filterJobs('');
                    },
                  ),
                IconButton(
                  icon: const Icon(Icons.mic),
                  color: _isListening ? Colors.red : Colors.grey,
                  onPressed: _toggleVoiceSearch,
                ),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: _showFilterDialog,
                ),
              ],
            ),
          ),
          onChanged: (value) {
            _filterJobs(value);
            _updateSuggestions(value);
          },
        ),
        // Search suggestions
        if (_searchSuggestions.isNotEmpty)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: const [BoxShadow(color: Colors.grey, blurRadius: 2)],
            ),
            child: Column(
              children: _searchSuggestions
                  .map((term) => ListTile(
                title: Text(term),
                onTap: () {
                  _searchController.text = term;
                  _filterJobs(term);
                },
              ))
                  .toList(),
            ),
          ),
        // Active filters chips
        Wrap(
          children: _activeFilters.entries
              .where((e) => e.value != null)
              .map((filter) => Chip(
            label: Text('${filter.key}: ${filter.value}'),
            onDeleted: () {
              setState(() => _activeFilters[filter.key] = null);
              _filterJobs(_searchController.text);
            },
          ))
              .toList(),
        ),
        // Loading indicator
        if (_isLoading) const LinearProgressIndicator(),
      ],
    );
  }

  Widget _buildFeaturedJobsSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Featured Jobs',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('jobs')
                .where('isFeatured', isEqualTo: true)
                .limit(5)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No featured jobs available'));
              }
              return _buildJobList(snapshot.data!.docs);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildJobList(List<QueryDocumentSnapshot> jobs) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        final job = JobModel.fromMap(jobs[index].data() as Map<String, dynamic>);
        return _buildJobCard(job, jobs[index].id);
      },
    );
  }

  Widget _buildJobCard(JobModel job, String jobId) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: ListTile(
        leading: Icon(
          job.isFeatured ?? false ? Icons.star : Icons.work,
          color: job.isFeatured ?? false ? Colors.yellow : Colors.blue,
        ),
        title: Text(job.title ?? 'No Title'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category: ${job.category ?? 'N/A'}'),
            Text('Location: ${job.region ?? 'N/A'}, ${job.city ?? 'N/A'}'),
            Text(
              'Deadline: ${DateFormat('yyyy-MM-dd').format(job.deadline ?? DateTime.now())}',
            ),
            if (job.applicantsCount != null)
              Text(
                'Applicants: ${job.applicantsCount}',
                style: const TextStyle(color: Colors.grey),
              ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () => _navigateToJobDetails(jobId),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.primaryBlue,
            foregroundColor: Colors.white,
          ),
          child: const Text('View'),
        ),
      ),
    );
  }

  Widget _buildAllJobsList() {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: _jobsQuery.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No jobs match your search'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final job = JobModel.fromMap(
                  snapshot.data!.docs[index].data() as Map<String, dynamic>);
              return _buildJobCard(job, snapshot.data!.docs[index].id);
            },
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppConstants.primaryBlue, AppConstants.secondaryPurple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      title: _showSearchBar
          ? null
          : const Text('FixPal', style: TextStyle(color: Colors.white)),
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: _toggleSearch,
        ),
        _buildNotificationIcon(),
      ],
    );
  }

  Widget _buildNotificationIcon() {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications, color: Colors.white),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotificationsScreen()),
          ),
        ),
        if (_unreadNotificationsCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: CircleAvatar(
              radius: 8,
              backgroundColor: Colors.red,
              child: Text(
                _unreadNotificationsCount.toString(),
                style: const TextStyle(fontSize: 10, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(),
          ..._buildUserSpecificDrawerItems(),
          const Divider(),
          _buildAppUpdateTile(),
          _buildSettingsTile(),
          _buildLogoutTile(),
          if (_userRole == 'Admin') _buildAdminDashboardTile(),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return DrawerHeader(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppConstants.primaryBlue, AppConstants.secondaryPurple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset('assets/images/logo.png', width: 50, height: 50),
          const SizedBox(height: 10),
          Text(
            'Welcome, ${_userName ?? 'Guest'}',
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          if (_userRole != null)
            Text(
              '(${_userRole!})',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildUserSpecificDrawerItems() {
    if (_userRole == 'Freelancer') {
      return [
        _buildListTile(Icons.work_outline, 'Find Jobs', () => Navigator.pop(context)),
        _buildListTile(Icons.assignment, 'Proposals', _navigateToProposals),
        _buildListTile(Icons.person, 'Profile', _navigateToProfile),
      ];
    } else if (_userRole == 'Client') {
      return [
        _buildListTile(Icons.add_circle, 'Post a Job', _navigateToJobPosting),
        _buildListTile(Icons.inbox, 'Proposals Received', _navigateToProposalsReceived),
        _buildListTile(Icons.people, 'Hired Freelancers', _navigateToHiredFreelancers),
        _buildListTile(Icons.person, 'Profile', _navigateToProfile),
      ];
    }
    return [];
  }

  Widget _buildListTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }

  Widget _buildAppUpdateTile() {
    return ListTile(
      leading: const Icon(Icons.update),
      title: const Text('Check for Updates'),
      onTap: _checkForAppUpdates,
    );
  }

  Future<void> _checkForAppUpdates() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final doc = await _firestore.collection('appConfig').doc('latestVersion').get();
      if (doc.exists) {
        final latestVersion = doc.data()?['version'] ?? '';
        if (latestVersion != packageInfo.version) {
          _showUpdateDialog(latestVersion);
        } else {
          _showSnackBar('You are using the latest version');
        }
      }
    } catch (e) {
      _showErrorSnackBar('Error checking updates: $e');
    }
  }

  void _showUpdateDialog(String version) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Available'),
        content: Text('Version $version is available. Would you like to update now?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          TextButton(
            onPressed: _launchAppStore,
            child: const Text('Update Now'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchAppStore() async {
    const url = 'https://play.google.com/store/apps/details?id=com.fixpal ';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      _showErrorSnackBar('Could not launch app store');
    }
  }

  Widget _buildSettingsTile() {
    return ListTile(
      leading: const Icon(Icons.settings),
      title: const Text('Settings'),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SettingsScreen()),
      ),
    );
  }

  Widget _buildLogoutTile() {
    return ListTile(
      leading: const Icon(Icons.logout),
      title: const Text('Logout'),
      onTap: () async {
        await _auth.signOut();
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      },
    );
  }

  Widget _buildAdminDashboardTile() {
    return ListTile(
      leading: const Icon(Icons.admin_panel_settings),
      title: const Text('Admin Dashboard'),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AdminDashboard()),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: 0,
      selectedItemColor: AppConstants.primaryBlue,
      unselectedItemColor: Colors.grey,
      onTap: _handleBottomNavTap,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Activity'),
        BottomNavigationBarItem(icon: Icon(Icons.work_outline), label: 'Jobs'),
        BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Messages'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
      ],
    );
  }

  void _handleBottomNavTap(int index) {
    switch (index) {
      case 0:
      // Already on home
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RecentActivityFeed(userId: _auth.currentUser?.uid ?? ''),
          ),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MyJobsScreen(
              userId: _auth.currentUser?.uid ?? '',
              isFreelancer: _userRole == 'Freelancer',
            ),
          ),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const MessagesScreen(userId: '', jobId: ''),
          ),
        );
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SettingsScreen()),
        );
        break;
    }
  }

  Widget _buildSupportFAB() {
    return FloatingActionButton(
      onPressed: () => _launchCall('+233546296531'),
      backgroundColor: AppConstants.iconYellow,
      child: const Icon(Icons.support_agent),
    );
  }

  Future<void> _launchCall(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _showErrorSnackBar('Could not launch phone call');
    }
  }

  void _navigateToJobDetails(String jobId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => JobDetailsScreen(
          jobId: jobId,
          userId: _auth.currentUser?.uid ?? '',
          isFreelancer: _userRole == 'Freelancer',
          jobData: {},
        ),
      ),
    );
  }

  void _navigateToProposals() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProposalsScreen(userId: _auth.currentUser?.uid ?? ''),
      ),
    );
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileScreen(userId: _auth.currentUser?.uid ?? ''),
      ),
    );
  }

  void _navigateToJobPosting() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => JobPostingScreen(userId: _auth.currentUser?.uid ?? ''),
      ),
    );
  }

  void _navigateToProposalsReceived() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProposalsReceivedScreen(clientId: _auth.currentUser?.uid ?? ''),
      ),
    );
  }

  void _navigateToHiredFreelancers() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HiredFreelancersScreen(clientId: _auth.currentUser?.uid ?? ''),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: Column(
        children: [
          if (_showSearchBar) _buildSearchBar(),
          if (_searchQuery.isEmpty && _isFeaturedSectionVisible) _buildFeaturedJobsSection(),
          _buildAllJobsList(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _buildSupportFAB(),
    );
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    _speechToText.stop();
    _debounceTimer?.cancel();
    super.dispose();
  }
}