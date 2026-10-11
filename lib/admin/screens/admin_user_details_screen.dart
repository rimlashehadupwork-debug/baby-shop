
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../services/firebase_supabase_service.dart';
import '../widgets/admin_widgets.dart';

class AdminUserDetailsScreen extends StatefulWidget {
  final String userId;

  const AdminUserDetailsScreen({
    super.key,
    required this.userId,
  });

  @override
  State<AdminUserDetailsScreen> createState() =>
      _AdminUserDetailsScreenState();
}

class _AdminUserDetailsScreenState
    extends State<AdminUserDetailsScreen> {
  final FirebaseSupabaseService _service = FirebaseSupabaseService();

  Map<String, dynamic>? _user;
  bool _loading = true;
  bool _updating = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await _service.read(tableName: 'users');

      Map<String, dynamic>? foundUser;

      if (result is Map) {
        final record = result[widget.userId];

        if (record is Map) {
          foundUser = Map<String, dynamic>.from(record);
        } else {
          for (final entry in result.entries) {
            if (entry.key.toString() == widget.userId &&
                entry.value is Map) {
              foundUser =
              Map<String, dynamic>.from(entry.value as Map);
              break;
            }
          }
        }
      }

      if (!mounted) return;

      setState(() {
        _user = foundUser;
        _loading = false;
        if (foundUser == null) {
          _error = 'User record was not found.';
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  String _value(List<String> keys, {String fallback = 'Not provided'}) {
    for (final key in keys) {
      final value = _user?[key];

      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }

    return fallback;
  }

  bool get _isActive =>
      (_user?['status'] ?? 'active').toString().toLowerCase() ==
          'active';

  String _formatLabel(String key) {
    return key
        .replaceAll('_', ' ')
        .replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
          (match) => '${match[1]} ${match[2]}',
    )
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map((word) =>
    '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }

  bool _isPrivateField(String key) {
    final normalized = key.toLowerCase();

    return normalized.contains('password') ||
        normalized.contains('token') ||
        normalized.contains('secret') ||
        normalized.contains('credential') ||
        normalized.contains('apikey') ||
        normalized.contains('api_key') ||
        normalized.contains('authorization');
  }

  Future<void> _toggleStatus() async {
    if (_user == null || _updating) return;

    final active = _isActive;

    final confirmed = await showAdminConfirm(
      context,
      title: active ? 'Suspend account?' : 'Activate account?',
      message: active
          ? 'This user will no longer be able to use their account.'
          : 'This user will regain access to their account.',
      confirmLabel: active ? 'Suspend' : 'Activate',
      destructive: active,
    );

    if (confirmed != true || !mounted) return;

    setState(() => _updating = true);

    try {
      await _service.update(
        tableName: 'users',
        id: widget.userId,
        data: {
          'status': active ? 'suspended' : 'active',
        },
      );

      await _loadUser();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            active
                ? 'User account suspended.'
                : 'User account activated.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update user: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _updating = false);
      }
    }
  }

  Widget _detailTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.softBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppColors.primaryBlue,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 5),
                SelectableText(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetails() {
    final name = _value(['name', 'fullName', 'full_name'],
        fallback: 'Unknown User');
    final email = _value(['email', 'emailAddress', 'email_address'],
        fallback: 'No email available');
    final active = _isActive;

    final excludedFields = <String>{
      'name',
      'fullname',
      'full_name',
      'email',
      'emailaddress',
      'email_address',
      'status',
      'password',
      'token',
      'apikey',
      'api_key',
      'secret',
      'authorization',
    };

    final extraEntries = _user!.entries.where((entry) {
      final key = entry.key.toString();
      final normalized = key.toLowerCase();

      return !excludedFields.contains(normalized) &&
          !_isPrivateField(key) &&
          entry.value != null &&
          entry.value is! Map &&
          entry.value is! List &&
          entry.value.toString().trim().isNotEmpty;
    }).toList();

    return RefreshIndicator(
      onRefresh: _loadUser,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.all(20),
        children: [
          AdminCard(
            padding: const EdgeInsets.all(22),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 38,
                  backgroundColor: AppColors.softBlue,
                  child: Text(
                    name
                        .trim()
                        .split(RegExp(r'\s+'))
                        .where((part) => part.isNotEmpty)
                        .take(2)
                        .map((part) => part[0].toUpperCase())
                        .join(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  email,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 14),
                StatusBadge(
                  label: active ? 'Active' : 'Suspended',
                  color: active ? AppColors.success : AppColors.error,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          AdminCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'User Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 10),
                _detailTile(
                  icon: Icons.badge_outlined,
                  label: 'User ID',
                  value: widget.userId,
                ),
                const Divider(height: 1),
                _detailTile(
                  icon: Icons.person_outline_rounded,
                  label: 'Full Name',
                  value: name,
                ),
                const Divider(height: 1),
                _detailTile(
                  icon: Icons.email_outlined,
                  label: 'Email Address',
                  value: email,
                ),
                const Divider(height: 1),
                _detailTile(
                  icon: Icons.verified_user_outlined,
                  label: 'Account Status',
                  value: active ? 'Active' : 'Suspended',
                ),
                for (final entry in extraEntries) ...[
                  const Divider(height: 1),
                  _detailTile(
                    icon: Icons.info_outline_rounded,
                    label: _formatLabel(entry.key.toString()),
                    value: entry.value.toString(),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _updating ? null : _toggleStatus,
              icon: _updating
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
                  : Icon(
                active
                    ? Icons.block_rounded
                    : Icons.check_circle_outline_rounded,
              ),
              label: Text(
                _updating
                    ? 'Updating...'
                    : active
                    ? 'Suspend Account'
                    : 'Activate Account',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                active ? AppColors.error : AppColors.success,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('User Details'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.primaryText,
        actions: [
          IconButton(
            onPressed: _loading ? null : _loadUser,
            tooltip: 'Refresh user',
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 42,
                color: AppColors.error,
              ),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.secondaryText,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadUser,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      )
          : _user == null
          ? const Center(child: Text('User not found.'))
          : _buildDetails(),
    );
  }
}
