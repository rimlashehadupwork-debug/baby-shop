import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';

class PaymentMethodItem {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isCard;
  final String? last4Digits;
  bool isSelected;

  PaymentMethodItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.isCard = false,
    this.last4Digits,
    this.isSelected = false,
  });
}

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final List<PaymentMethodItem> _methods = [
    PaymentMethodItem(
      id: '1',
      title: 'Cash on Delivery',
      subtitle: 'Pay with cash upon package delivery',
      icon: Icons.payments_outlined,
      isSelected: true,
    ),
    PaymentMethodItem(
      id: '2',
      title: 'Credit / Debit Card',
      subtitle: 'Visa •••• 4242 (Default dummy card)',
      icon: Icons.credit_card_rounded,
      isCard: true,
      last4Digits: '4242',
      isSelected: false,
    ),
    PaymentMethodItem(
      id: '3',
      title: 'Dummy Online Payment',
      subtitle: 'Simulated online wallet gateway',
      icon: Icons.account_balance_wallet_outlined,
      isSelected: false,
    ),
  ];

  void _selectMethod(String id) {
    setState(() {
      for (var item in _methods) {
        item.isSelected = (item.id == id);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Default payment method updated'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showAddPaymentDialog() {
    final formKey = GlobalKey<FormState>();
    final cardHolderController = TextEditingController();
    final cardNumberController = TextEditingController();
    final expiryController = TextEditingController();
    final cvvController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
            left: 24,
            right: 24,
            top: 24,
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
                    children: const [
                      Icon(Icons.add_card_rounded, color: AppColors.primaryBlue, size: 24),
                      SizedBox(width: 10),
                      Text(
                        'Add Payment Method',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Enter dummy card details for testing',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Cardholder Name
                  CustomTextField(
                    label: 'Cardholder Name',
                    hintText: 'e.g. Sarah Khan',
                    controller: cardHolderController,
                    prefixIcon: Icons.person_outlined,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Name required';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Card Number
                  CustomTextField(
                    label: 'Card Number (Dummy)',
                    hintText: '4242 4242 4242 4242',
                    controller: cardNumberController,
                    prefixIcon: Icons.credit_card_outlined,
                    keyboardType: TextInputType.number,
                    validator: (val) {
                      if (val == null || val.trim().length < 12) return 'Enter a valid card number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Expiry and CVV Row
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          label: 'Expiry Date',
                          hintText: 'MM/YY',
                          controller: expiryController,
                          prefixIcon: Icons.calendar_today_outlined,
                          keyboardType: TextInputType.datetime,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return 'Required';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomTextField(
                          label: 'CVV',
                          hintText: '123',
                          controller: cvvController,
                          prefixIcon: Icons.lock_outline,
                          obscureText: true,
                          keyboardType: TextInputType.number,
                          validator: (val) {
                            if (val == null || val.trim().length < 3) return 'Invalid';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  PrimaryButton(
                    text: 'Add Dummy Card',
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        final cardNum = cardNumberController.text.trim();
                        final last4 = cardNum.length >= 4 ? cardNum.substring(cardNum.length - 4) : '9999';

                        setState(() {
                          final newItem = PaymentMethodItem(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            title: 'Credit / Debit Card',
                            subtitle: 'Card •••• $last4 (${cardHolderController.text.trim()})',
                            icon: Icons.credit_card_rounded,
                            isCard: true,
                            last4Digits: last4,
                            isSelected: true,
                          );
                          for (var m in _methods) {
                            m.isSelected = false;
                          }
                          _methods.add(newItem);
                        });

                        Navigator.pop(sheetContext);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('New dummy payment method added successfully!'),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Methods'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Informational Demo Banner
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.accentBlue.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.accentBlue.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.info_outline_rounded, color: AppColors.primaryBlue, size: 22),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'This application uses dummy payment simulation for eProject testing.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.primaryText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Payment List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _methods.length,
                separatorBuilder: (context, index) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final item = _methods[index];
                  return _buildPaymentCard(item);
                },
              ),
            ),

            // Add Payment Method Button
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: PrimaryButton(
                text: 'Add Payment Method',
                onPressed: _showAddPaymentDialog,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentCard(PaymentMethodItem item) {
    final isSelected = item.isSelected;

    return InkWell(
      onTap: () => _selectMethod(item.id),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isSelected ? 0.05 : 0.02),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon Badge
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryBlue.withValues(alpha: 0.1)
                    : AppColors.background,
                shape: BoxShape.circle,
              ),
              child: Icon(
                item.icon,
                color: isSelected ? AppColors.primaryBlue : AppColors.secondaryText,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            // Text Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            // Radio Choice
            Radio<bool>(
              value: true,
              groupValue: isSelected,
              activeColor: AppColors.primaryBlue,
              onChanged: (val) => _selectMethod(item.id),
            ),
          ],
        ),
      ),
    );
  }
}
