import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../widgets/admin_widgets.dart';
import 'admin_user_details_screen.dart';
import '../services/firebase_supabase_service.dart';

/// Simple model built from Firebase record
class AdminUser {
  final String id;
  final String name;
  final String email;
  final bool active;

  AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.active,
  });

  factory AdminUser.fromMap(String id, Map data) {
    return AdminUser(
      id: id,
      name: (data['name'] ?? 'Unknown').toString(),
      email: (data['email'] ?? '').toString(),
      // status: 'active' / 'suspended' (default active)
      active: (data['status'] ?? 'active').toString() == 'active',
    );
  }
}

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  static const _usersTable = 'users';

  final _service = FirebaseSupabaseService();
  final _searchController = TextEditingController();
  String _query = '';

  bool _loading = true;
  String? _error;
  List<AdminUser> _all = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent) setState(() => _loading = true);
    try {
      final rawUsers = await _service.read(tableName: _usersTable);

      final users = <AdminUser>[];
      if (rawUsers is Map) {
        rawUsers.forEach((key, value) {
          if (value is Map) {
            users.add(AdminUser.fromMap(key.toString(), value));
          }
        });
      }

      if (!mounted) return;
      setState(() {
        _all = users;
        _error = null;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _openDetails(AdminUser user) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AdminUserDetailsScreen(userId: user.id),
      ),
    );

    if (!mounted) return;
    _load(silent: true);
  }

  Future<void> _toggleStatus(AdminUser user) async {
    final suspending = user.active;
    final confirmed = await showAdminConfirm(
      context,
      title: suspending ? 'Suspend account?' : 'Activate account?',
      message: suspending
          ? '${user.name} will no longer be able to use their account.'
          : '${user.name} will regain access to their account.',
      confirmLabel: suspending ? 'Suspend' : 'Activate',
      destructive: suspending,
    );
    if (!confirmed || !mounted) return;

    try {
      await _service.update(
        tableName: _usersTable,
        id: user.id,
        data: {'status': suspending ? 'suspended' : 'active'},
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
                suspending ? '${user.name} suspended' : '${user.name} activated'),
          ),
        );
      _load(silent: true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }

  List<AdminUser> get _filtered {
    final terms = _query
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .toList();
    if (terms.isEmpty) return _all;
    return _all.where((u) {
      final haystack = '${u.name} ${u.email}'.toLowerCase();
      return terms.every(haystack.contains);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 40, color: AppColors.error),
              const SizedBox(height: 12),
              Text(_error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.secondaryText)),
              const SizedBox(height: 16),
              ElevatedButton(
                  onPressed: () => _load(), child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final users = _filtered;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _query = value),
            decoration: InputDecoration(
              hintText: 'Search by name or email...',
              prefixIcon: const Icon(Icons.search_rounded,
                  color: AppColors.secondaryText),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                tooltip: 'Clear',
                icon: const Icon(Icons.close_rounded,
                    size: 20, color: AppColors.secondaryText),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _query = '');
                },
              )
                  : null,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${users.length} ${users.length == 1 ? 'user' : 'users'}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.secondaryText,
              ),
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _load(silent: true),
            child: users.isEmpty
                ? ListView(
              // RefreshIndicator ke liye scrollable chahiye
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: 360,
                  child: AdminEmptyState(
                    icon: Icons.people_outline_rounded,
                    title:
                    _all.isEmpty ? 'No users yet' : 'No users found',
                    message: _all.isEmpty
                        ? 'Registered customers will appear here.'
                        : 'Try a different name or email.',
                  ),
                ),
              ],
            )
                : ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics()),
              keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              itemCount: users.length,
              separatorBuilder: (context, index) =>
              const SizedBox(height: 12),
              itemBuilder: (context, index) => _buildItem(users[index]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItem(AdminUser user) {
    final active = user.active;

    return AdminCard(
      onTap: () => _openDetails(user),
      padding: const EdgeInsets.fromLTRB(14, 14, 6, 14),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.softBlue,
            child: Text(
              initialsOf(user.name),
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.secondaryText),
                ),
                const SizedBox(height: 8),
                StatusBadge(
                  label: active ? 'Active' : 'Suspended',
                  color: active ? AppColors.success : AppColors.error,
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'Manage user',
            icon: const Icon(Icons.more_vert_rounded,
                color: AppColors.secondaryText),
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            onSelected: (value) {
              if (value == 'view') _openDetails(user);
              if (value == 'toggle') _toggleStatus(user);
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                  value: 'view', child: Text('View Details')),
              PopupMenuItem<String>(
                value: 'toggle',
                child: Text(
                  active ? 'Suspend Account' : 'Activate Account',
                  style: TextStyle(
                      color: active ? AppColors.error : AppColors.success),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}