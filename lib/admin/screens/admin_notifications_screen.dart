import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../../services/notification_service.dart';
import '../../theme/app_theme.dart';
import '../widgets/admin_widgets.dart';

class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  State<AdminNotificationsScreen> createState() => _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen> {
  final _service = NotificationService.instance;

  String _formatDate(String iso) {
    final d = DateTime.tryParse(iso);
    if (d == null) return '';
    final local = d.toLocal();
    final h = local.hour.toString().padLeft(2, '0');
    final m = local.minute.toString().padLeft(2, '0');
    return '${local.day}/${local.month}/${local.year} at $h:$m';
  }

  void _showNotificationForm({NotificationModel? existingNotification}) {
    final isEditing = existingNotification != null;
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: existingNotification?.title ?? '');
    final bodyController = TextEditingController(text: existingNotification?.body ?? '');
    final uidController = TextEditingController(text: existingNotification?.targetUserId ?? '');

    String targetType = existingNotification?.targetType ?? 'all';
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
              child: Form(
                key: formKey,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isEditing ? 'Edit Notification' : 'Create Notification',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryText,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => Navigator.pop(modalContext),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Notification Title
                      TextFormField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Notification Title',
                          hintText: 'e.g. Flash Sale Live! 20% Off Baby Care',
                          prefixIcon: Icon(Icons.title_rounded, color: AppColors.primaryBlue),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Notification Body
                      TextFormField(
                        controller: bodyController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Notification Message Body',
                          hintText: 'Enter the message content to send to users...',
                          alignLabelWithHint: true,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter message body';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Target Type Radio Selection
                      const Text(
                        'Target Audience',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryText,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.inputBackground,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          children: [
                            RadioListTile<String>(
                              title: const Text(
                                'Broadcast to All Users',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                              subtitle: const Text(
                                'Sends to everyone using the app',
                                style: TextStyle(fontSize: 12, color: AppColors.secondaryText),
                              ),
                              value: 'all',
                              groupValue: targetType,
                              activeColor: AppColors.primaryBlue,
                              onChanged: (val) {
                                if (val != null) {
                                  setModalState(() => targetType = val);
                                }
                              },
                            ),
                            const Divider(height: 1),
                            RadioListTile<String>(
                              title: const Text(
                                'Target Specific User UID',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                              subtitle: const Text(
                                'Sends only to a single specific user account',
                                style: TextStyle(fontSize: 12, color: AppColors.secondaryText),
                              ),
                              value: 'specific',
                              groupValue: targetType,
                              activeColor: AppColors.primaryBlue,
                              onChanged: (val) {
                                if (val != null) {
                                  setModalState(() => targetType = val);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Specific User UID Field
                      if (targetType == 'specific') ...[
                        TextFormField(
                          controller: uidController,
                          decoration: const InputDecoration(
                            labelText: 'Target User UID',
                            hintText: 'Enter user UID or select below',
                            prefixIcon: Icon(Icons.person_pin_rounded, color: AppColors.primaryBlue),
                          ),
                          validator: (value) {
                            if (targetType == 'specific' && (value == null || value.trim().isEmpty)) {
                              return 'Please specify a User UID';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),

                        // Quick User UID Selector
                        StreamBuilder<DatabaseEvent>(
                          stream: FirebaseDatabase.instance.ref('users').onValue,
                          builder: (context, snapshot) {
                            if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                              return const SizedBox.shrink();
                            }
                            final raw = snapshot.data!.snapshot.value;
                            if (raw is! Map) return const SizedBox.shrink();

                            final usersList = <Map<String, String>>[];
                            raw.forEach((k, v) {
                              if (v is Map) {
                                usersList.add({
                                  'uid': k.toString(),
                                  'name': (v['name'] ?? 'User').toString(),
                                  'email': (v['email'] ?? '').toString(),
                                });
                              }
                            });

                            if (usersList.isEmpty) return const SizedBox.shrink();

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Quick Select Registered User:',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.secondaryText),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      isExpanded: true,
                                      hint: const Text('Tap to choose a user', style: TextStyle(fontSize: 13)),
                                      items: usersList.map((u) {
                                        return DropdownMenuItem<String>(
                                          value: u['uid'],
                                          child: Text(
                                            '${u['name']} (${u['email']})',
                                            style: const TextStyle(fontSize: 13),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (selectedUid) {
                                        if (selectedUid != null) {
                                          setModalState(() {
                                            uidController.text = selectedUid;
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                      ],

                      const SizedBox(height: 12),

                      // Submit Button
                      SizedBox(
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
                                    setModalState(() => isSubmitting = true);

                                    final bool ok;
                                    if (isEditing) {
                                      ok = await _service.updateNotification(
                                        id: existingNotification.id,
                                        title: titleController.text,
                                        body: bodyController.text,
                                        targetType: targetType,
                                        targetUserId: uidController.text,
                                      );
                                    } else {
                                      ok = await _service.createNotification(
                                        title: titleController.text,
                                        body: bodyController.text,
                                        targetType: targetType,
                                        targetUserId: uidController.text,
                                      );
                                    }

                                    if (!context.mounted) return;
                                    Navigator.pop(modalContext);

                                    ScaffoldMessenger.of(this.context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          ok
                                              ? (isEditing
                                                  ? 'Notification updated successfully!'
                                                  : 'Notification created & published!')
                                              : 'Failed to save notification.',
                                        ),
                                        backgroundColor: ok ? AppColors.success : AppColors.error,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                              : Icon(isEditing ? Icons.save_rounded : Icons.send_rounded, size: 20),
                          label: Text(
                            isSubmitting
                                ? 'Saving...'
                                : (isEditing ? 'Save Changes' : 'Publish Notification'),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _deleteNotification(NotificationModel notification) async {
    final confirmed = await showAdminConfirm(
      context,
      title: 'Delete Notification?',
      message: 'Are you sure you want to delete "${notification.title}"?',
      confirmLabel: 'Delete',
      destructive: true,
    );

    if (confirmed && mounted) {
      final ok = await _service.deleteNotification(notification.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? 'Notification deleted.' : 'Failed to delete notification.'),
          backgroundColor: ok ? AppColors.secondaryText : AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notification Management',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryText,
                    letterSpacing: -0.4,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Create, broadcast & edit push notifications',
                  style: TextStyle(fontSize: 13, color: AppColors.secondaryText),
                ),
              ],
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                minimumSize: const Size(120, 44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => _showNotificationForm(),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Create', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Notifications List Stream
        StreamBuilder<List<NotificationModel>>(
          stream: _service.watchAllNotifications(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final notifications = snapshot.data ?? [];

            if (notifications.isEmpty) {
              return AdminCard(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
                  child: Column(
                    children: [
                      const Icon(Icons.notifications_off_outlined, size: 48, color: AppColors.secondaryText),
                      const SizedBox(height: 12),
                      const Text(
                        'No notifications created yet',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryText),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Click "Create" above to broadcast messages to your users.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: AppColors.secondaryText),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              children: notifications.map((notification) {
                final isBroadcast = notification.targetType == 'all';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AdminCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isBroadcast
                                    ? AppColors.primaryBlue.withValues(alpha: 0.12)
                                    : Colors.purple.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isBroadcast ? Icons.campaign_rounded : Icons.person_rounded,
                                    size: 14,
                                    color: isBroadcast ? AppColors.primaryBlue : Colors.purple,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    isBroadcast ? 'Broadcast to All' : 'Target: ${notification.targetUserId}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isBroadcast ? AppColors.primaryBlue : Colors.purple,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Text(
                              _formatDate(notification.timestamp),
                              style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          notification.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notification.body,
                          style: const TextStyle(
                            fontSize: 13.5,
                            color: AppColors.primaryText,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () => _showNotificationForm(existingNotification: notification),
                              icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.primaryBlue),
                              label: const Text('Edit', style: TextStyle(color: AppColors.primaryBlue, fontSize: 13)),
                            ),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              onPressed: () => _deleteNotification(notification),
                              icon: const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.error),
                              label: const Text('Delete', style: TextStyle(color: AppColors.error, fontSize: 13)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
