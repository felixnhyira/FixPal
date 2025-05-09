import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fixpal/models/user_model.dart';

class UsersManagementScreen extends StatefulWidget {
  const UsersManagementScreen({super.key});

  @override
  State<UsersManagementScreen> createState() => _UsersManagementScreenState();
}

class _UsersManagementScreenState extends State<UsersManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _searchController = TextEditingController();
   String _searchQuery = '';
  String _selectedFilter = 'All';
  String _selectedVerificationFilter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: _showFiltersDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search users',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                ),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _buildUsersStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final users = snapshot.data!.docs.map((doc) {
                  return UserModel.fromFirestore(doc.data() as DocumentSnapshot<Object?>);
                }).toList();

                if (users.isEmpty) {
                  return const Center(child: Text('No users found'));
                }

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return _buildUserCard(user);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Stream<QuerySnapshot> _buildUsersStream() {
    Query query = _firestore.collection('users');

    if (_searchQuery.isNotEmpty) {
      query = query
          .where('email', isGreaterThanOrEqualTo: _searchQuery)
          .where('email', isLessThanOrEqualTo: '$_searchQuery\uf8ff');
    }

    if (_selectedFilter != 'All') {
      query = query.where('role', isEqualTo: _selectedFilter.toLowerCase());
    }

    if (_selectedVerificationFilter != 'All') {
      query = query.where('verificationStatus', 
          isEqualTo: _selectedVerificationFilter.toLowerCase());
    }

    return query.snapshots();
  }

  Widget _buildUserCard(UserModel user) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: user.profilePhotoUrl != null
                      ? NetworkImage(user.profilePhotoUrl!)
                      : const AssetImage('assets/default_profile.png')
                          as ImageProvider,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${user.firstName} ${user.lastName}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(user.email),
                      Text(user.phoneNumber),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  label: Text(user.role),
                  backgroundColor: _getRoleColor(user.role),
                ),
                Chip(
                  label: Text(
                    user.verificationStatus.toUpperCase(),
                  ),
                  backgroundColor: _getVerificationColor(user.verificationStatus),
                ),
                if (user.jobCategory != null)
                  Chip(
                    label: Text(user.jobCategory!),
                    backgroundColor: Colors.blue[100],
                  ),
                if (user.region != null && user.city != null)
                  Chip(
                    label: Text('${user.region}, ${user.city}'),
                    backgroundColor: Colors.green[100],
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (user.verificationStatus != 'approved')
                  TextButton(
                    onPressed: () => _verifyUser(user.userId, true),
                    child: const Text('Approve'),
                  ),
                if (user.verificationStatus != 'rejected')
                  TextButton(
                    onPressed: () => _verifyUser(user.userId, false),
                    child: const Text('Reject'),
                  ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: const Text('View Details'),
                      onTap: () => _showUserDetails(user),
                    ),
                    PopupMenuItem(
                      child: const Text('Edit User'),
                      onTap: () => _editUser(user),
                    ),
                    PopupMenuItem(
                      child: const Text('Delete User'),
                      onTap: () => _confirmDeleteUser(user.userId),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color? _getRoleColor(String? role) {
    switch (role?.toLowerCase()) {
      case 'freelancer':
        return Colors.purple[100];
      case 'client':
        return Colors.orange[100];
      case 'admin':
        return Colors.red[100];
      default:
        return Colors.grey[200];
    }
  }

  Color? _getVerificationColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
        return Colors.green[100];
      case 'pending':
        return Colors.yellow[100];
      case 'rejected':
        return Colors.red[100];
      default:
        return Colors.grey[200];
    }
  }

  Future<void> _showFiltersDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Users'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedFilter,
              items: ['All', 'Freelancer', 'Client', 'Admin'].map((role) {
                return DropdownMenuItem(
                  value: role,
                  child: Text(role),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedFilter = value!),
              decoration: const InputDecoration(
                labelText: 'Filter by Role',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedVerificationFilter,
              items: ['All', 'Pending', 'Approved', 'Rejected'].map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
              onChanged: (value) => 
                  setState(() => _selectedVerificationFilter = value!),
              decoration: const InputDecoration(
                labelText: 'Filter by Verification',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Apply Filters'),
          ),
        ],
      ),
    );
  }

  Future<void> _verifyUser(String userId, bool approve) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'verificationStatus': approve ? 'approved' : 'rejected',
        'verifiedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(approve 
              ? 'User approved successfully' 
              : 'User rejected'),
          backgroundColor: approve ? Colors.green : Colors.orange,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating verification: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showUserDetails(UserModel user) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${user.firstName} ${user.lastName}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (user.profilePhotoUrl != null)
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(user.profilePhotoUrl!),
                  ),
                ),
              const SizedBox(height: 16),
              _buildDetailRow('Email', user.email),
              _buildDetailRow('Phone', user.phoneNumber),
              _buildDetailRow('Role', user.role),
              _buildDetailRow('Location', 
                  '${user.region}, ${user.city}'),
              _buildDetailRow('Verification', 
                  user.verificationStatus.toUpperCase()),
              if (user.role == 'Freelancer') ...[
                _buildDetailRow('Job Category', user.jobCategory),
                if (user.cvUrl != null)
                  TextButton(
                    onPressed: () => _viewDocument(user.cvUrl!),
                    child: const Text('View CV'),
                  ),
                if (user.certificateUrl != null)
                  TextButton(
                    onPressed: () => _viewDocument(user.certificateUrl!),
                    child: const Text('View Certificate'),
                  ),
              ],
              if (user.idImageUrl != null)
                TextButton(
                  onPressed: () => _viewDocument(user.idImageUrl!),
                  child: const Text('View ID Document'),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value ?? 'Not provided'),
          ),
        ],
      ),
    );
  }

  Future<void> _viewDocument(String url) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Document Viewer'),
        content: SizedBox(
          width: double.maxFinite,
          child: Image.network(url),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _editUser(UserModel user) async {
    final formKey = GlobalKey<FormState>();
    final firstNameController = TextEditingController(text: user.firstName);
    final lastNameController = TextEditingController(text: user.lastName);
    final emailController = TextEditingController(text: user.email);
    final phoneController = TextEditingController(text: user.phoneNumber);
    String? selectedRole = user.role;
    String? selectedStatus = user.verificationStatus;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Edit User'),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: firstNameController,
                      decoration: const InputDecoration(labelText: 'First Name'),
                      validator: (value) =>
                          value!.isEmpty ? 'Required field' : null,
                    ),
                    TextFormField(
                      controller: lastNameController,
                      decoration: const InputDecoration(labelText: 'Last Name'),
                      validator: (value) =>
                          value!.isEmpty ? 'Required field' : null,
                    ),
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (value) =>
                          value!.isEmpty ? 'Required field' : null,
                    ),
                    TextFormField(
                      controller: phoneController,
                      decoration: const InputDecoration(labelText: 'Phone'),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      items: ['Freelancer', 'Client', 'Admin'].map((role) {
                        return DropdownMenuItem(
                          value: role,
                          child: Text(role),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => selectedRole = value),
                      decoration: const InputDecoration(labelText: 'Role'),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      items: ['pending', 'approved', 'rejected'].map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(status.capitalize()),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => selectedStatus = value),
                      decoration: const InputDecoration(
                        labelText: 'Verification Status'),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    await _updateUser(
                      user.userId,
                      firstNameController.text,
                      lastNameController.text,
                      emailController.text,
                      phoneController.text,
                      selectedRole!,
                      selectedStatus!,
                    );
                    if (!mounted) return;
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _updateUser(
    String userId,
    String firstName,
    String lastName,
    String email,
    String phone,
    String role,
    String verificationStatus,
  ) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phoneNumber': phone,
        'role': role,
        'verificationStatus': verificationStatus,
      });

      // Update auth email if changed
      if (email != _auth.currentUser!.email) {
        await _auth.currentUser!.verifyBeforeUpdateEmail(email);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User updated successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating user: $e')),
      );
    }
  }

  Future<void> _confirmDeleteUser(String userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ?? false;

    if (confirmed) {
      await _deleteUser(userId);
    }
  }

  Future<void> _deleteUser(String userId) async {
    try {
      // Delete from Firestore
      await _firestore.collection('users').doc(userId).delete();

      // Delete auth account - Note: This requires admin privileges
      // Typically done via a Cloud Function
      final user = _auth.currentUser;
      if (user != null && user.uid == userId) {
        await user.delete();
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User deleted successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting user: $e')),
      );
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}