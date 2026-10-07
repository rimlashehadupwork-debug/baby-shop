import 'package:flutter/material.dart';
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
          _buildContactSupportTab(),
          _buildReportIssueTab(),
          _buildFeedbackTab(),
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
            'Open your Cart, verify quantities and totals, and tap "Proceed to Checkout". Select your delivery address and demo payment option, then confirm your payment to complete the order.',
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

  // 2. CONTACT SUPPORT TAB
  Widget _buildContactSupportTab() {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: 'Sarah Khan');
    final emailController = TextEditingController(text: 'sarah@example.com');
    final messageController = TextEditingController();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contact Support Team',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Have a question or need assistance? Send us a message.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.secondaryText,
              ),
            ),
            const SizedBox(height: 20),

            // Name
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person_outline_rounded, color: AppColors.primaryBlue),
              ),
              validator: (v) => v == null || v.trim().isEmpty ? 'Please enter your name' : null,
            ),
            const SizedBox(height: 14),

            // Email
            TextFormField(
              controller: emailController,
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
              controller: messageController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Message / Question',
                hintText: 'Type your message or enquiry here...',
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
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    _showSuccessDialog(
                      title: 'Support Request Sent',
                      message: 'Thank you! Your support ticket has been submitted. Our customer care team will respond to ${emailController.text} within 24 hours.',
                    );
                    messageController.clear();
                  }
                },
                icon: const Icon(Icons.send_rounded, size: 18),
                label: const Text(
                  'Submit Request',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 3. REPORT AN ISSUE TAB
  Widget _buildReportIssueTab() {
    final formKey = GlobalKey<FormState>();
    String selectedCategory = 'Order Issue';
    final descriptionController = TextEditingController();

    return StatefulBuilder(
      builder: (context, setReportState) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: formKey,
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
                  value: selectedCategory,
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
                    if (val != null) setReportState(() => selectedCategory = val);
                  },
                ),
                const SizedBox(height: 14),

                // Description
                TextFormField(
                  controller: descriptionController,
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
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        _showSuccessDialog(
                          title: 'Issue Reported',
                          message: 'Your issue report for "$selectedCategory" has been submitted. Reference Ticket #SUP-3921 created.',
                        );
                        descriptionController.clear();
                      }
                    },
                    icon: const Icon(Icons.report_gmailerrorred_rounded, size: 20),
                    label: const Text(
                      'Submit Report',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 4. FEEDBACK TAB
  Widget _buildFeedbackTab() {
    final formKey = GlobalKey<FormState>();
    double selectedRating = 5.0;
    final feedbackController = TextEditingController();

    return StatefulBuilder(
      builder: (context, setFeedbackState) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: formKey,
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
                  'Rate your experience and help us improve BabyShopHub.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 20),

                // Star Rating Picker
                Center(
                  child: Column(
                    children: [
                      const Text(
                        'How would you rate BabyShopHub?',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          final starVal = (index + 1).toDouble();
                          return IconButton(
                            iconSize: 38,
                            icon: Icon(
                              starVal <= selectedRating ? Icons.star_rounded : Icons.star_border_rounded,
                              color: AppColors.warning,
                            ),
                            onPressed: () {
                              setFeedbackState(() => selectedRating = starVal);
                            },
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Feedback Message Field
                TextFormField(
                  controller: feedbackController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Your Feedback',
                    hintText: 'Share what you love or how we can improve...',
                    alignLabelWithHint: true,
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Please enter your feedback' : null,
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
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        _showSuccessDialog(
                          title: 'Thank You for Your Feedback!',
                          message: 'We appreciate your feedback. It helps us build a better shopping experience for all parents.',
                        );
                        feedbackController.clear();
                      }
                    },
                    icon: const Icon(Icons.thumb_up_rounded, size: 18),
                    label: const Text(
                      'Submit Feedback',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ),
          ],
        );
      },
    );
  }
}
