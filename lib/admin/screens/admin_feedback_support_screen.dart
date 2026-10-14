import 'package:flutter/material.dart';
import '../../services/feedback_service.dart';
import '../../theme/app_theme.dart';
import '../services/admin_user_service.dart';
import '../widgets/admin_widgets.dart';

class AdminFeedbackSupportScreen extends StatefulWidget {
  const AdminFeedbackSupportScreen({super.key});

  @override
  State<AdminFeedbackSupportScreen> createState() => _AdminFeedbackSupportScreenState();
}

class _AdminFeedbackSupportScreenState extends State<AdminFeedbackSupportScreen> {
  final _feedbackService = FeedbackService.instance;

  String _selectedStatusFilter = 'all'; // 'all', 'new', 'in_progress', 'resolved'
  String _searchQuery = '';

  String _formatDate(String iso) {
    final d = DateTime.tryParse(iso);
    if (d == null) return 'N/A';
    final local = d.toLocal();
    final h = local.hour.toString().padLeft(2, '0');
    final m = local.minute.toString().padLeft(2, '0');
    return '${local.day}/${local.month}/${local.year} at $h:$m';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'new':
      case 'unassigned':
        return AppColors.error;
      case 'in_progress':
      case 'assigned':
        return AppColors.warning;
      case 'resolved':
        return AppColors.success;
      default:
        return AppColors.primaryBlue;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'new':
      case 'unassigned':
        return 'NEW';
      case 'in_progress':
      case 'assigned':
        return 'IN PROGRESS';
      case 'resolved':
        return 'RESOLVED';
      default:
        return status.toUpperCase();
    }
  }

  void _openTicketDetailModal(SupportInquiryModel inquiry, List<SupportInquiryModel> allInquiries) {
    final formKey = GlobalKey<FormState>();
    final replyController = TextEditingController(text: inquiry.adminReply);
    final notesController = TextEditingController(text: inquiry.internalNotes);

    String currentStatus = inquiry.status;
    if (currentStatus != 'new' && currentStatus != 'in_progress' && currentStatus != 'resolved') {
      currentStatus = 'new';
    }

    bool isSubmitting = false;

    // Filter historical support logs for this specific user account
    final userHistory = allInquiries.where((i) {
      if (inquiry.userId.isNotEmpty && inquiry.userId != 'guest') {
        return i.userId == inquiry.userId;
      }
      return i.userEmail.toLowerCase() == inquiry.userEmail.toLowerCase();
    }).toList();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final mediaWidth = MediaQuery.of(context).size.width;
            final isWide = mediaWidth >= 800;

            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Container(
                width: isWide ? 850 : mediaWidth * 0.95,
                height: 680,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Modal Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: _getStatusColor(currentStatus).withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.support_agent_rounded,
                                color: _getStatusColor(currentStatus),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Ticket #${inquiry.id.substring(0, inquiry.id.length > 8 ? 8 : inquiry.id.length)}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryText,
                                  ),
                                ),
                                Text(
                                  'Category: ${inquiry.category}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.secondaryText,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(dialogContext),
                        ),
                      ],
                    ),
                    const Divider(height: 24),

                    // Split-Pane Layout
                    Expanded(
                      child: Form(
                        key: formKey,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            if (isWide) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Left Side: Inquiry Details & User Monitoring
                                  Expanded(
                                    flex: 5,
                                    child: _buildLeftMonitoringPane(inquiry, userHistory),
                                  ),
                                  const VerticalDivider(width: 24),
                                  // Right Side: Action Center
                                  Expanded(
                                    flex: 5,
                                    child: _buildRightActionPane(
                                      inquiry: inquiry,
                                      replyController: replyController,
                                      notesController: notesController,
                                      currentStatus: currentStatus,
                                      onStatusChanged: (val) => setDialogState(() => currentStatus = val),
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              return SingleChildScrollView(
                                child: Column(
                                  children: [
                                    _buildLeftMonitoringPane(inquiry, userHistory),
                                    const SizedBox(height: 20),
                                    const Divider(),
                                    const SizedBox(height: 10),
                                    _buildRightActionPane(
                                      inquiry: inquiry,
                                      replyController: replyController,
                                      notesController: notesController,
                                      currentStatus: currentStatus,
                                      onStatusChanged: (val) => setDialogState(() => currentStatus = val),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 12),

                    // Primary Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                if (formKey.currentState!.validate()) {
                                  setDialogState(() => isSubmitting = true);

                                  final ok = await _feedbackService.updateInquiryResolution(
                                    node: inquiry.node,
                                    id: inquiry.id,
                                    userId: inquiry.userId,
                                    userEmail: inquiry.userEmail,
                                    status: currentStatus,
                                    adminReply: replyController.text,
                                    internalNotes: notesController.text,
                                  );

                                  if (!context.mounted) return;
                                  Navigator.pop(dialogContext);

                                  ScaffoldMessenger.of(this.context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          Icon(
                                            ok ? Icons.check_circle_rounded : Icons.error_outline_rounded,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              ok
                                                  ? 'Ticket status updated & user notified via email!'
                                                  : 'Failed to update ticket. Please try again.',
                                            ),
                                          ),
                                        ],
                                      ),
                                      backgroundColor: ok ? AppColors.success : AppColors.error,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                }
                              },
                        icon: isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.mark_email_read_rounded, size: 20),
                        label: Text(
                          isSubmitting
                              ? 'Processing Resolution...'
                              : 'Update Status & Send Email Notification',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
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

  // Left Side: Inquiry Message, Account Metadata & Support History Logs
  Widget _buildLeftMonitoringPane(SupportInquiryModel inquiry, List<SupportInquiryModel> history) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Submitted Message Card
          const Text(
            'User Submitted Message',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryText),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              inquiry.message.isNotEmpty ? inquiry.message : '(No message text provided)',
              style: const TextStyle(fontSize: 13.5, color: AppColors.primaryText, height: 1.45),
            ),
          ),
          const SizedBox(height: 18),

          // Account Metadata & Activity Monitoring Card
          const Text(
            'User Account Metadata & Activity',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryText),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _buildMetaRow(Icons.person_rounded, 'User Name', inquiry.userName),
                const SizedBox(height: 8),
                _buildMetaRow(Icons.email_rounded, 'User Email', inquiry.userEmail),
                const SizedBox(height: 8),
                _buildMetaRow(Icons.fingerprint_rounded, 'User ID', inquiry.userId),
                const SizedBox(height: 8),
                _buildMetaRow(Icons.calendar_today_rounded, 'Submitted Date', _formatDate(inquiry.timestamp)),
                if (inquiry.rating != null) ...[
                  const SizedBox(height: 8),
                  _buildMetaRow(Icons.star_rounded, 'App Rating Given', '${inquiry.rating!.toStringAsFixed(1)} ★'),
                ],
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Historical Support Logs
          Text(
            'Account History Logs (${history.length} items)',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryText),
          ),
          const SizedBox(height: 8),
          if (history.isEmpty)
            const Text('No previous ticket history.', style: TextStyle(fontSize: 12, color: AppColors.secondaryText))
          else
            Column(
              children: history.map((item) {
                final isCurrent = item.id == inquiry.id;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isCurrent ? AppColors.softBlue : AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isCurrent ? AppColors.primaryBlue : AppColors.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getStatusColor(item.status).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _getStatusLabel(item.status),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(item.status),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.category,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Text(
                        _formatDate(item.timestamp).split(' at ').first,
                        style: const TextStyle(fontSize: 10, color: AppColors.secondaryText),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  // Right Side: Action Center (Status Toggle, Admin Reply & Internal Staff Notes)
  Widget _buildRightActionPane({
    required SupportInquiryModel inquiry,
    required TextEditingController replyController,
    required TextEditingController notesController,
    required String currentStatus,
    required ValueChanged<String> onStatusChanged,
  }) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Action Center & Response Module',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryText),
          ),
          const SizedBox(height: 12),

          // Status Toggle Dropdown
          const Text(
            'Inquiry Status',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.secondaryText),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: currentStatus,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.toggle_on_rounded, color: AppColors.primaryBlue),
            ),
            items: const [
              DropdownMenuItem(value: 'new', child: Text('New / Unassigned')),
              DropdownMenuItem(value: 'in_progress', child: Text('In Progress / Staff Assigned')),
              DropdownMenuItem(value: 'resolved', child: Text('Resolved Feedbacks')),
            ],
            onChanged: (val) {
              if (val != null) onStatusChanged(val);
            },
          ),
          const SizedBox(height: 16),

          // Administrative Reply Text Area
          TextFormField(
            controller: replyController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Administrative Response / Email Reply',
              hintText: 'Type your official response to send to the user via email notification...',
              alignLabelWithHint: true,
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Please enter an administrative reply before resolving';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Internal Staff Notes Field (Private to Staff)
          TextFormField(
            controller: notesController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Internal Staff Notes (Private to Admin Staff)',
              hintText: 'Secure staff-only notes (never visible to end-user)...',
              alignLabelWithHint: true,
              prefixIcon: Icon(Icons.lock_outline_rounded, color: AppColors.secondaryText),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primaryBlue),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.secondaryText),
        ),
        Expanded(
          child: Text(
            value.isNotEmpty ? value : 'N/A',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryText),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SupportInquiryModel>>(
      stream: _feedbackService.watchAllInquiries(),
      builder: (context, snapshot) {
        final inquiries = snapshot.data ?? [];

        final newCount = inquiries.where((i) => i.status == 'new').length;
        final inProgressCount = inquiries.where((i) => i.status == 'in_progress').length;
        final resolvedCount = inquiries.where((i) => i.status == 'resolved').length;

        // Apply Status Filter
        final filteredByStatus = inquiries.where((i) {
          if (_selectedStatusFilter == 'all') return true;
          return i.status == _selectedStatusFilter;
        }).toList();

        // Apply Search Query
        final filteredInquiries = filteredByStatus.where((i) {
          if (_searchQuery.trim().isEmpty) return true;
          final q = _searchQuery.toLowerCase().trim();
          return i.userName.toLowerCase().contains(q) ||
              i.userEmail.toLowerCase().contains(q) ||
              i.userId.toLowerCase().contains(q) ||
              i.category.toLowerCase().contains(q) ||
              i.message.toLowerCase().contains(q);
        }).toList();

        return ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          children: [
            // Title Header
            const Text(
              'User Inquiries & Feedback Management',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryText,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Monitor user activity, manage account inquiries, and address support requests.',
              style: TextStyle(fontSize: 13, color: AppColors.secondaryText),
            ),
            const SizedBox(height: 20),

            // Live Status Grid / Color-Coded Filter Cards
            LayoutBuilder(
              builder: (context, constraints) {
                const spacing = 10.0;
                final columns = constraints.maxWidth >= 640 ? 4 : 2;
                final cardWidth = (constraints.maxWidth - spacing * (columns - 1)) / columns;

                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: [
                    SizedBox(
                      width: cardWidth,
                      child: _buildFilterCard(
                        filterKey: 'all',
                        label: 'All Inquiries',
                        count: inquiries.length,
                        color: AppColors.primaryBlue,
                        icon: Icons.all_inbox_rounded,
                      ),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: _buildFilterCard(
                        filterKey: 'new',
                        label: 'Unassigned / New',
                        count: newCount,
                        color: AppColors.error,
                        icon: Icons.mark_email_unread_rounded,
                      ),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: _buildFilterCard(
                        filterKey: 'in_progress',
                        label: 'In Progress',
                        count: inProgressCount,
                        color: AppColors.warning,
                        icon: Icons.hourglass_top_rounded,
                      ),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: _buildFilterCard(
                        filterKey: 'resolved',
                        label: 'Resolved Feedbacks',
                        count: resolvedCount,
                        color: AppColors.success,
                        icon: Icons.check_circle_rounded,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),

            // Search Filter
            TextFormField(
              initialValue: _searchQuery,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: const InputDecoration(
                hintText: 'Search inquiries by User ID, Name, Email or Message...',
                prefixIcon: Icon(Icons.search_rounded, color: AppColors.secondaryText),
              ),
            ),
            const SizedBox(height: 20),

            // Interactive Data Table / Cards List
            if (snapshot.connectionState == ConnectionState.waiting)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (filteredInquiries.isEmpty)
              AdminCard(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                  child: Column(
                    children: const [
                      Icon(Icons.inbox_rounded, size: 48, color: AppColors.secondaryText),
                      SizedBox(height: 12),
                      Text(
                        'No inquiries found',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryText),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'No user support requests match the selected filter criteria.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: AppColors.secondaryText),
                      ),
                    ],
                  ),
                ),
              )
            else
              Column(
                children: filteredInquiries.map((inquiry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AdminCard(
                      onTap: () => _openTicketDetailModal(inquiry, inquiries),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // Status Badge
                              StatusBadge(
                                label: _getStatusLabel(inquiry.status),
                                color: _getStatusColor(inquiry.status),
                              ),
                              const SizedBox(width: 10),
                              // Category Badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  inquiry.category,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                _formatDate(inquiry.timestamp),
                                style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // User Info Row (User ID, Name, Email linked to User Profile)
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.12),
                                child: Text(
                                  inquiry.userName.isNotEmpty
                                      ? inquiry.userName.substring(0, 1).toUpperCase()
                                      : 'U',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      inquiry.userName,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryText,
                                      ),
                                    ),
                                    Text(
                                      '${inquiry.userEmail}  •  UID: ${inquiry.userId}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.secondaryText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Submitted Message Preview
                          Text(
                            inquiry.message,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.primaryText,
                              height: 1.35,
                            ),
                          ),
                          if (inquiry.adminReply.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.softBlue,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.reply_rounded, size: 14, color: AppColors.primaryBlue),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Admin Reply: ${inquiry.adminReply}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primaryBlue,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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

  Widget _buildFilterCard({
    required String filterKey,
    required String label,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    final isSelected = _selectedStatusFilter == filterKey;

    return InkWell(
      onTap: () => setState(() => _selectedStatusFilter = filterKey),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.12) : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? color : AppColors.primaryText,
                    ),
                  ),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
