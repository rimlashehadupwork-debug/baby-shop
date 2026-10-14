import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/user_db_service.dart';
import '../../theme/app_theme.dart';
import '../widgets/admin_widgets.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final _dbService = UserDbService.instance;
  final _searchController = TextEditingController();

  String _searchQuery = '';
  String _selectedFilter = 'All'; // 'All', 'Active', 'Suspended', 'Unverified'

  @override
  void initState() {
    super.initState();
    // Pre-populate seed prototype test accounts on first view
    _dbService.seedPrototypeAccounts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showUserControlPanel(UserModel user) {
    bool isUpdating = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final isSuspended = user.isSuspended;

            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 20,
              ),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Avatar & Title Header
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: isSuspended
                              ? AppColors.error.withValues(alpha: 0.15)
                              : AppColors.primaryBlue.withValues(alpha: 0.15),
                          child: Text(
                            user.name.isNotEmpty
                                ? user.name.substring(0, 1).toUpperCase()
                                : 'U',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: isSuspended ? AppColors.error : AppColors.primaryBlue,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryText,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                user.email,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(sheetContext),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 16),

                    // Metadata Section
                    _buildMetaTile(Icons.fingerprint_rounded, 'User UID', user.uid),
                    _buildMetaTile(
                      user.isCustomVerified ? Icons.verified_user_rounded : Icons.gpp_maybe_rounded,
                      'Verification Status',
                      user.isCustomVerified ? 'Verified Email' : 'Unverified Email',
                      color: user.isCustomVerified ? AppColors.success : AppColors.warning,
                    ),
                    _buildMetaTile(
                      isSuspended ? Icons.block_rounded : Icons.check_circle_rounded,
                      'Account Status',
                      isSuspended ? 'SUSPENDED' : 'ACTIVE',
                      color: isSuspended ? AppColors.error : AppColors.success,
                    ),
                    if (user.createdAt.isNotEmpty)
                      _buildMetaTile(Icons.calendar_today_rounded, 'Joined Date', user.createdAt.split('T').first),

                    const SizedBox(height: 16),

                    // Activity Logs History
                    if (user.activityLog.isNotEmpty) ...[
                      const Text(
                        'Recent Activity Log',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.inputBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          children: user.activityLog.take(4).map((log) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.history_rounded, size: 14, color: AppColors.primaryBlue),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      (log['action'] ?? '').toString(),
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // SUSPEND / UNSUSPEND Action Button
                    SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSuspended ? AppColors.success : AppColors.error,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: isUpdating
                            ? null
                            : () async {
                                final nav = Navigator.of(sheetContext);
                                final messenger = ScaffoldMessenger.of(this.context);
                                setSheetState(() => isUpdating = true);

                                final newStatus = isSuspended ? 'active' : 'suspended';
                                await _dbService.setUserAccountStatus(user.uid, newStatus);

                                if (!mounted) return;
                                nav.pop();

                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        Icon(
                                          newStatus == 'suspended'
                                              ? Icons.block_rounded
                                              : Icons.check_circle_rounded,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            newStatus == 'suspended'
                                                ? '${user.name} has been suspended.'
                                                : '${user.name} has been unsuspended.',
                                          ),
                                        ),
                                      ],
                                    ),
                                    backgroundColor:
                                        newStatus == 'suspended' ? AppColors.error : AppColors.success,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                );
                              },
                        icon: isUpdating
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Icon(isSuspended ? Icons.check_circle_rounded : Icons.block_rounded, size: 20),
                        label: Text(
                          isUpdating
                              ? 'Updating Status...'
                              : (isSuspended ? 'UNSUSPEND USER' : 'SUSPEND USER'),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Delete User Account Option
                    SizedBox(
                      height: 48,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: isUpdating
                            ? null
                            : () async {
                                final nav = Navigator.of(sheetContext);
                                final messenger = ScaffoldMessenger.of(this.context);

                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Delete User Account?'),
                                    content: Text('Are you sure you want to delete ${user.name}? Their record will be permanently deleted and they will have to register again.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx, false),
                                        child: const Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                                        onPressed: () => Navigator.pop(ctx, true),
                                        child: const Text('Delete Account'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  setSheetState(() => isUpdating = true);

                                  await _dbService.deleteUserAccount(user.uid);

                                  if (!mounted) return;
                                  nav.pop();

                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text('${user.name}\'s account has been deleted. They must register again.'),
                                      backgroundColor: AppColors.error,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              },
                        icon: const Icon(Icons.delete_forever_rounded, size: 20),
                        label: const Text('DELETE USER ACCOUNT', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMetaTile(IconData icon, String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color ?? AppColors.primaryBlue),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.secondaryText),
          ),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color ?? AppColors.primaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<UserModel>>(
      stream: _dbService.watchAllUsers(),
      builder: (context, snapshot) {
        final users = snapshot.data ?? [];

        final totalCount = users.length;
        final activeCount = users.where((u) => u.isActive).length;
        final suspendedCount = users.where((u) => u.isSuspended).length;

        // Apply filter
        final filteredList = users.where((u) {
          if (_selectedFilter == 'Active') return u.isActive;
          if (_selectedFilter == 'Suspended') return u.isSuspended;
          if (_selectedFilter == 'Unverified') return !u.isCustomVerified;
          return true; // 'All'
        }).where((u) {
          if (_searchQuery.trim().isEmpty) return true;
          final q = _searchQuery.toLowerCase().trim();
          return u.name.toLowerCase().contains(q) ||
              u.email.toLowerCase().contains(q) ||
              u.uid.toLowerCase().contains(q);
        }).toList();

        return ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          children: [
            // Header Row with Prototype Accounts Seed Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User Management Directory',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryText,
                        letterSpacing: -0.4,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Monitor accounts, verify emails & enforce suspension locks',
                      style: TextStyle(fontSize: 13, color: AppColors.secondaryText),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    minimumSize: const Size(120, 42),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    await _dbService.seedPrototypeAccounts();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Prototype test accounts (John, Jane, Bad Actor) synced!'),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  },
                  icon: const Icon(Icons.people_outline_rounded, size: 16),
                  label: const Text('Seed Test Accounts', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Summary Metrics Cards
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard('Total Users', '$totalCount', AppColors.primaryBlue, Icons.group_rounded),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricCard('Active Users', '$activeCount', AppColors.success, Icons.check_circle_rounded),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricCard('Suspended', '$suspendedCount', AppColors.error, Icons.block_rounded),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Search Bar & Filter Chips
            TextFormField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: const InputDecoration(
                hintText: 'Search by User Name, Email, or UID...',
                prefixIcon: Icon(Icons.search_rounded, color: AppColors.secondaryText),
              ),
            ),
            const SizedBox(height: 14),

            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: ['All', 'Active', 'Suspended', 'Unverified'].map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: isSelected,
                      selectedColor: AppColors.primaryBlue,
                      backgroundColor: AppColors.surface,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.primaryText,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 12.5,
                      ),
                      side: BorderSide(
                        color: isSelected ? AppColors.primaryBlue : AppColors.border,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedFilter = filter);
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // User Directory List
            if (snapshot.connectionState == ConnectionState.waiting)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (filteredList.isEmpty)
              AdminCard(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                  child: Column(
                    children: const [
                      Icon(Icons.people_outline_rounded, size: 48, color: AppColors.secondaryText),
                      SizedBox(height: 12),
                      Text(
                        'No matching users found',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryText),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Try adjusting your filter or search query.',
                        style: TextStyle(fontSize: 13, color: AppColors.secondaryText),
                      ),
                    ],
                  ),
                ),
              )
            else
              Column(
                children: filteredList.map((user) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AdminCard(
                      onTap: () => _showUserControlPanel(user),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: user.isSuspended
                                ? AppColors.error.withValues(alpha: 0.15)
                                : AppColors.primaryBlue.withValues(alpha: 0.15),
                            child: Text(
                              user.name.isNotEmpty ? user.name.substring(0, 1).toUpperCase() : 'U',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: user.isSuspended ? AppColors.error : AppColors.primaryBlue,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        user.name,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primaryText,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (user.isCustomVerified) ...[
                                      const SizedBox(width: 6),
                                      const Icon(Icons.verified_rounded, size: 16, color: AppColors.success),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  user.email,
                                  style: const TextStyle(fontSize: 12.5, color: AppColors.secondaryText),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          StatusBadge(
                            label: user.isSuspended ? 'Suspended' : 'Active',
                            color: user.isSuspended ? AppColors.error : AppColors.success,
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.chevron_right_rounded, color: AppColors.secondaryText, size: 20),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}
