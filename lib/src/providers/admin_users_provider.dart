import 'package:flutter/material.dart';
import '../services/firebase_service.dart';

/// Provider for managing admin users with caching to eliminate repeated FutureBuilder patterns
class AdminUsersProvider extends ChangeNotifier {
  static final AdminUsersProvider _instance = AdminUsersProvider._internal();
  factory AdminUsersProvider() => _instance;
  AdminUsersProvider._internal();

  List<AdminUser>? _adminUsers;
  bool _loading = false;
  String? _error;
  DateTime? _lastFetch;

  // Cache duration - refetch after 5 minutes
  static const Duration _cacheDuration = Duration(minutes: 5);

  /// Current admin users (cached)
  List<AdminUser>? get adminUsers => _adminUsers;

  /// Whether currently loading admin users
  bool get loading => _loading;

  /// Any error from the last fetch
  String? get error => _error;

  /// Whether we have cached data
  bool get hasData => _adminUsers != null;

  /// Whether cache is still valid
  bool get _isCacheValid {
    if (_lastFetch == null) return false;
    return DateTime.now().difference(_lastFetch!) < _cacheDuration;
  }

  /// Get admin users (from cache if valid, otherwise fetch)
  Future<List<AdminUser>> getAdminUsers({bool forceRefresh = false}) async {
    // Return cached data if valid and not forcing refresh
    if (!forceRefresh && _isCacheValid && _adminUsers != null) {
      return _adminUsers!;
    }

    // Fetch from Firebase
    return await fetchAdminUsers();
  }

  /// Fetch admin users from Firebase
  Future<List<AdminUser>> fetchAdminUsers() async {
    if (_loading) {
      // If already loading, wait for completion
      while (_loading) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return _adminUsers ?? [];
    }

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final querySnapshot = await FirebaseService.adminUsersFuture;
      final adminUsersList = <AdminUser>[];

      // Get admin UIDs
      final adminUids = querySnapshot.docs.map((doc) => doc.id).toList();

      // Fetch public profiles for these admins
      for (final uid in adminUids) {
        try {
          final publicDoc = await FirebaseService.publicUserDoc(uid).get();
          if (publicDoc.exists) {
            final publicData = publicDoc.data() as Map<String, dynamic>;
            adminUsersList.add(AdminUser(
              uid: uid,
              displayName: publicData['displayName'] ?? 'Unknown',
              email: publicData['email'] ?? '',
            ));
          } else {
            // Fallback: create entry with UID only
            adminUsersList.add(AdminUser(
              uid: uid,
              displayName: 'Admin ($uid)',
              email: '',
            ));
          }
        } catch (e) {
          // Skip this admin if we can't fetch their data
        }
      }

      _adminUsers = adminUsersList;
      _lastFetch = DateTime.now();
      _error = null;
    } catch (e) {
      _error = 'Failed to load admin users: ${e.toString()}';
    } finally {
      _loading = false;
      notifyListeners();
    }

    return _adminUsers ?? [];
  }

  /// Clear cache (force next fetch to reload from Firebase)
  void clearCache() {
    _adminUsers = null;
    _lastFetch = null;
    _error = null;
    notifyListeners();
  }

  /// Find admin by UID
  AdminUser? findAdminByUid(String uid) {
    return _adminUsers?.firstWhere(
      (admin) => admin.uid == uid,
      orElse: () =>
          AdminUser(uid: uid, displayName: 'Unknown Admin', email: ''),
    );
  }

  /// Get admin UIDs list
  List<String> get adminUids =>
      _adminUsers?.map((admin) => admin.uid).toList() ?? [];

  /// Check if a user is an admin (by UID)
  bool isAdmin(String uid) {
    return adminUids.contains(uid);
  }
}

/// Model class for admin user data
class AdminUser {
  final String uid;
  final String displayName;
  final String email;

  const AdminUser({
    required this.uid,
    required this.displayName,
    required this.email,
  });

  @override
  String toString() => displayName.isNotEmpty ? displayName : uid;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminUser &&
          runtimeType == other.runtimeType &&
          uid == other.uid;

  @override
  int get hashCode => uid.hashCode;
}
