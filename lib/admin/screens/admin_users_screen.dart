import 'package:flutter/material.dart';
import '../../services/order_service.dart';
import '../../theme/app_theme.dart';
import '../services/admin_user_service.dart';
import '../widgets/admin_widgets.dart';
import 'admin_user_details_screen.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final _service = AdminUserService.instance;
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openDetails(AdminUser user) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AdminUserDetailsScreen(userId: user.id)),
    );
  }

  Future<void> _toggleStatus(AdminUser user) async {
    final suspending = user.status == AdminUserStatus.active;
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
    _service.setStatus(
      user.id,
      suspending ? AdminUserStatus.suspended : AdminUserStatus.active,
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(suspending ? '${user.name} suspended' : '${user.name} activated'),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return AdminLoader(
      load: adminSimulatedLoad,
      skeletonHeight: 84,
      builder: (context) => AnimatedBuilder(
        animation: Listenable.merge([
          _service.usersNotifier,
          OrderService.instance.ordersNotifier,
        ]),
        builder: (context, _) {
          final terms = _query
              .toLowerCase()
              .split(RegExp(r'\s+'))
              .where((t) => t.isNotEmpty)
              .toList();
          final all = _service.users;
          final users = terms.isEmpty
              ? all
              : all.where((u) {
                  final haystack = '${u.name} ${u.email}'.toLowerCase();
                  return terms.every(haystack.contains);
                }).toList();

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
                child: users.isEmpty
                    ? AdminEmptyState(
                        icon: Icons.people_outline_rounded,
                        title: all.isEmpty ? 'No users yet' : 'No users found',
                        message: all.isEmpty
                            ? 'Registered customers will appear here.'
                            : 'Try a different name or email.',
                      )
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                        itemCount: users.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) => _buildItem(users[index]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildItem(AdminUser user) {
    final active = user.status == AdminUserStatus.active;
    final orders = _service.orderCount(user);

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
                  style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    StatusBadge(
                      label: active ? 'Active' : 'Suspended',
                      color: active ? AppColors.success : AppColors.error,
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        '$orders ${orders == 1 ? 'order' : 'orders'}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'Manage user',
            icon: const Icon(Icons.more_vert_rounded, color: AppColors.secondaryText),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            onSelected: (value) {
              if (value == 'view') _openDetails(user);
              if (value == 'toggle') _toggleStatus(user);
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(value: 'view', child: Text('View Details')),
              PopupMenuItem<String>(
                value: 'toggle',
                child: Text(
                  active ? 'Suspend Account' : 'Activate Account',
                  style: TextStyle(color: active ? AppColors.error : AppColors.success),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
