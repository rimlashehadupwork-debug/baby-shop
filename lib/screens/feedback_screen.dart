import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  double _selectedRating = 5.0;
  final _feedbackController = TextEditingController();

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _submitFeedback() {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (dialogContext) {
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
                const Text(
                  'Thank You for Your Feedback!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryText),
                ),
              ],
            ),
            content: const Text(
              'Your feedback has been received. Thank you for helping us improve BabyShopHub!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.secondaryText, height: 1.4),
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    Navigator.pop(context);
                  },
                  child: const Text('Done'),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Share Feedback',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Experience Matters',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Tell us what you love or how we can make BabyShopHub even better.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.secondaryText,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 24),

                // Star Rating Container
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Overall Rating',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryText,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          final starVal = (index + 1).toDouble();
                          return IconButton(
                            iconSize: 38,
                            icon: Icon(
                              starVal <= _selectedRating ? Icons.star_rounded : Icons.star_border_rounded,
                              color: AppColors.warning,
                            ),
                            onPressed: () {
                              setState(() {
                                _selectedRating = starVal;
                              });
                            },
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Feedback Field
                TextFormField(
                  controller: _feedbackController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Your Feedback Message',
                    hintText: 'Share your shopping experience, suggestions, or ideas...',
                    alignLabelWithHint: true,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Please enter your feedback message';
                    if (v.trim().length < 5) return 'Feedback must be at least 5 characters long';
                    return null;
                  },
                ),
                const SizedBox(height: 28),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _submitFeedback,
                    icon: const Icon(Icons.send_rounded, size: 18),
                    label: const Text(
                      'Submit Feedback',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
