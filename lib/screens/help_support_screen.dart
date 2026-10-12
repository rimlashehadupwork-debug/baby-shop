import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/feedback_service.dart';
import '../theme/app_theme.dart';

class HelpSupportScreen extends StatefulWidget {
  final int initialTabIndex;

  const HelpSupportScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Help & Support',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.primaryBlue,
          unselectedLabelColor: AppColors.secondaryText,
          indicatorColor: AppColors.primaryBlue,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: 'Help / FAQ'),
            Tab(text: 'Contact Support'),
            Tab(text: 'Report Issue'),
            Tab(text: 'Feedback'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFaqTab(),
          _ContactSupportTabWidget(
            onSuccess: (title, message) => _showSuccessDialog(title: title, message: message),
          ),
          _ReportIssueTabWidget(
            onSuccess: (title, message) => _showSuccessDialog(title: title, message: message),
          ),
          _FeedbackTabWidget(
            onSuccess: (title, message) => _showSuccessDialog(title: title, message: message),
          ),
        ],
      ),
    );
  }

  // 1. HELP / FAQ TAB
  Widget _buildFaqTab() {
    final faqs = [
      {
        'question': 'How to browse products?',
        'answer':
            'Explore baby care products directly from the Home screen categories or tap "Categories" in the bottom navigation bar. You can view diapers, organic baby food, apparel, toys, and care essentials.',
      },
      {
        'question': 'How to search for specific items?',
        'answer':
            'Tap the prominent Search bar on the Home screen or tap the Search icon. Type product names, categories, or brand names (like Pampers or Gerber) and use filter chips to refine search results.',
      },
      {
        'question': 'How to add products to cart?',
        'answer':
            'Tap the "Add to Cart" button on any product card or open the Product Details page and tap "Add to Cart". The shopping cart icon at the top right will immediately update.',
      },
      {
        'question': 'How checkout works?',
        'answer':
            'Open your Cart, verify quantities and totals, and tap "Proceed to Checkout". Select your delivery address and payment option, then confirm your payment to complete the order.',
      },
      {
        'question': 'How to view orders?',
        'answer':
            'Tap the "Orders" tab in the bottom navigation bar to view your full order history, order status badges, purchased item summaries, and total amounts.',
      },
      {
        'question': 'How order tracking works?',
        'answer':
            'Open any order from your Order History and tap "Track Delivery Progress". The interactive 5-stage timeline shows real-time progress from Order Placed to Shipped, Out for Delivery, and Delivered.',
      },
      {
        'question': 'How to update personal profile & delivery address?',
        'answer':
            'Go to Profile > Personal Information to update your full name, phone number, and profile picture. To edit your address, go to Profile > Delivery Address.',
      },
      {
        'question': 'How to submit feedback or report issues?',
        'answer':
            'Use the "Report Issue" or "Feedback" tab right here in Help & Support, or navigate to Profile > Feedback to send us your thoughts directly.',
      },
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Frequently Asked Questions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Find answers to common questions about using BabyShopHub.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 16),
          ...faqs.map((faq) => _buildFaqCard(faq['question']!, faq['answer']!)),
        ],
      ),
    );
  }

  Widget _buildFaqCard(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            iconColor: AppColors.primaryBlue,
            collapsedIconColor: AppColors.secondaryText,
            title: Text(
              question,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(
                  answer,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.secondaryText,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog({required String title, required String message}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 40),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryText),
              ),
            ],
          ),
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: AppColors.secondaryText, height: 1.4),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('OK', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        );
      },
    );
  }
}

// 2. CONTACT SUPPORT TAB WIDGET
class _ContactSupportTabWidget extends StatefulWidget {
  final Function(String title, String message) onSuccess;

  const _ContactSupportTabWidget({required this.onSuccess});

  @override
  State<_ContactSupportTabWidget> createState() => _ContactSupportTabWidgetState();
}

class _ContactSupportTabWidgetState extends State<_ContactSupportTabWidget> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      if (user.displayName != null && user.displayName!.isNotEmpty) {
        _nameController.text = user.displayName!;
      }
      if (user.email != null) {
        _emailController.text = user.email!;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final ok = await FeedbackService.instance.submitSupportTicket(
      name: _nameController.text,
      email: _emailController.text,
      category: 'General Support',
      message: _messageController.text,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (ok) {
      final email = _emailController.text;
      _messageController.clear();

      widget.onSuccess(
        'Support Ticket Created',
        'Thank you! Your enquiry has been submitted. Our customer care team will respond to $email shortly.',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Support ticket submitted successfully!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to submit support ticket. Try again.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contact Cards
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: const Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.headset_mic_rounded, color: AppColors.primaryBlue, size: 22),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Customer Care: +1 (800) 555-BABY',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.email_outlined, color: AppColors.primaryBlue, size: 22),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Email: support@babyshophub.com',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Send Us a Message',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Have a question or need assistance? Fill out the form below.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.secondaryText,
              ),
            ),
            const SizedBox(height: 16),

            // Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person_outline_rounded, color: AppColors.primaryBlue),
              ),
              validator: (v) => v == null || v.trim().isEmpty ? 'Please enter your name' : null,
            ),
            const SizedBox(height: 14),

            // Email
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                prefixIcon: Icon(Icons.email_outlined, color: AppColors.primaryBlue),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Please enter your email';
                if (!v.contains('@')) return 'Enter a valid email address';
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Message
            TextFormField(
              controller: _messageController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Message / Enquiry',
                hintText: 'Type your question or enquiry here...',
                alignLabelWithHint: true,
              ),
              validator: (v) => v == null || v.trim().isEmpty ? 'Please describe your request' : null,
            ),
            const SizedBox(height: 24),

            // Submit Request Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _isSubmitting ? null : _submitRequest,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.send_rounded, size: 18),
                label: Text(
                  _isSubmitting ? 'Submitting...' : 'Submit Request',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 3. REPORT AN ISSUE TAB WIDGET
class _ReportIssueTabWidget extends StatefulWidget {
  final Function(String title, String message) onSuccess;

  const _ReportIssueTabWidget({required this.onSuccess});

  @override
  State<_ReportIssueTabWidget> createState() => _ReportIssueTabWidgetState();
}

class _ReportIssueTabWidgetState extends State<_ReportIssueTabWidget> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _emailController = TextEditingController();

  String _selectedCategory = 'Order Issue';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email != null) {
      _emailController.text = user.email!;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submitIssue() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName ?? 'Valued Customer';

    final ok = await FeedbackService.instance.submitSupportTicket(
      name: name,
      email: _emailController.text,
      category: _selectedCategory,
      message: _descriptionController.text,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (ok) {
      _descriptionController.clear();

      widget.onSuccess(
        'Issue Reported',
        'Your issue report for "$_selectedCategory" has been saved. Our support team will investigate promptly.',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Issue report submitted successfully!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to submit issue report. Try again.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Report an Issue',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Facing a problem with an order, payment, or product? Let us know.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.secondaryText,
              ),
            ),
            const SizedBox(height: 20),

            // Issue Category Dropdown
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Issue Category',
                prefixIcon: Icon(Icons.report_problem_outlined, color: AppColors.primaryBlue),
              ),
              items: const [
                DropdownMenuItem(value: 'Order Issue', child: Text('Order Issue')),
                DropdownMenuItem(value: 'Payment Problem', child: Text('Payment Problem')),
                DropdownMenuItem(value: 'Damaged or Wrong Product', child: Text('Damaged or Wrong Product')),
                DropdownMenuItem(value: 'App Technical Bug', child: Text('App Technical Bug')),
                DropdownMenuItem(value: 'Other', child: Text('Other')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _selectedCategory = val);
              },
            ),
            const SizedBox(height: 14),

            // Email
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Your Email Address',
                prefixIcon: Icon(Icons.email_outlined, color: AppColors.primaryBlue),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Please enter your email';
                if (!v.contains('@')) return 'Enter a valid email address';
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Description
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Issue Description',
                hintText: 'Provide details about what went wrong...',
                alignLabelWithHint: true,
              ),
              validator: (v) => v == null || v.trim().isEmpty ? 'Please describe the issue' : null,
            ),
            const SizedBox(height: 24),

            // Submit Report Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _isSubmitting ? null : _submitIssue,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.report_gmailerrorred_rounded, size: 20),
                label: Text(
                  _isSubmitting ? 'Submitting...' : 'Submit Report',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 4. FEEDBACK TAB WIDGET
class _FeedbackTabWidget extends StatefulWidget {
  final Function(String title, String message) onSuccess;

  const _FeedbackTabWidget({required this.onSuccess});

  @override
  State<_FeedbackTabWidget> createState() => _FeedbackTabWidgetState();
}

class _FeedbackTabWidgetState extends State<_FeedbackTabWidget> {
  final _formKey = GlobalKey<FormState>();
  final _feedbackController = TextEditingController();
  final _emailController = TextEditingController();

  String _selectedCategory = 'General Inquiry';
  double _selectedRating = 5.0;
  bool _isSubmitting = false;

  final List<String> _categories = [
    'General Inquiry',
    'Bug Report',
    'Feature Request',
    'App Improvement',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email != null) {
      _emailController.text = user.email!;
    }
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final ok = await FeedbackService.instance.submitFeedback(
      category: _selectedCategory,
      message: _feedbackController.text,
      rating: _selectedRating,
      email: _emailController.text,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (ok) {
      _feedbackController.clear();

      widget.onSuccess(
        'Thank You for Your Feedback!',
        'We appreciate your feedback regarding "$_selectedCategory". It helps us build a better shopping experience for all parents.',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Feedback submitted successfully!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Could not submit feedback. Try again.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'App Feedback',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Select a category and rate your experience to help us improve.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.secondaryText,
              ),
            ),
            const SizedBox(height: 20),

            // Category Choice Chips
            const Text(
              'Category',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  selectedColor: AppColors.primaryBlue,
                  backgroundColor: AppColors.surface,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.primaryText,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 12,
                  ),
                  side: BorderSide(
                    color: isSelected ? AppColors.primaryBlue : AppColors.border,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Star Rating Picker
            Center(
              child: Column(
                children: [
                  const Text(
                    'Rating',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starVal = (index + 1).toDouble();
                      return IconButton(
                        iconSize: 36,
                        icon: Icon(
                          starVal <= _selectedRating ? Icons.star_rounded : Icons.star_border_rounded,
                          color: AppColors.warning,
                        ),
                        onPressed: () {
                          setState(() => _selectedRating = starVal);
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Email Address
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Your Email Address',
                prefixIcon: Icon(Icons.email_outlined, color: AppColors.primaryBlue),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Please enter your email';
                if (!v.contains('@')) return 'Enter a valid email address';
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Feedback Message Field
            TextFormField(
              controller: _feedbackController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Your Feedback Message',
                hintText: 'Share what you love or how we can improve...',
                alignLabelWithHint: true,
              ),
              validator: (v) => v == null || v.trim().isEmpty ? 'Please enter your feedback message' : null,
            ),
            const SizedBox(height: 24),

            // Submit Feedback Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _isSubmitting ? null : _submitFeedback,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.thumb_up_rounded, size: 18),
                label: Text(
                  _isSubmitting ? 'Submitting...' : 'Submit Feedback',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
