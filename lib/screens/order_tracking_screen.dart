import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../theme/app_theme.dart';

class OrderTrackingScreen extends StatelessWidget {
  final OrderModel order;

  const OrderTrackingScreen({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final currentStepIndex = order.status.stepIndex;

    final List<Map<String, String>> steps = [
      {
        'title': 'Order Placed',
        'subtitle': 'Order received and confirmed by store',
        'time': '12 Oct, 09:30 AM',
      },
      {
        'title': 'Processing',
        'subtitle': 'Items inspected & packed at fulfillment warehouse',
        'time': '12 Oct, 10:15 AM',
      },
      {
        'title': 'Shipped',
        'subtitle': 'Handed over to courier driver for transit',
        'time': '12 Oct, 01:00 PM',
      },
      {
        'title': 'Out for Delivery',
        'subtitle': 'Delivery driver is nearby in your area',
        'time': 'Today, 08:30 AM',
      },
      {
        'title': 'Delivered',
        'subtitle': 'Package delivered to address',
        'time': order.status == OrderStatus.delivered ? '28 Sep, 02:00 PM' : 'Estimated Today by 3:30 PM',
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Track Order ${order.id}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ESTIMATED DELIVERY SUMMARY CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.access_time_filled_rounded,
                        color: AppColors.primaryBlue,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Estimated Delivery Time',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.secondaryText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            order.estimatedDelivery,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryText,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Status: ${order.status.displayName}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // DELIVERY TIMELINE SECTION
              const Text(
                'Delivery Timeline',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 16),

              // TIMELINE CARD
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: List.generate(steps.length, (index) {
                    final isCompleted = index <= currentStepIndex;
                    final isCurrent = index == currentStepIndex;
                    final isLast = index == steps.length - 1;
                    final stepData = steps[index];

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Circle & Vertical Line
                        Column(
                          children: [
                            // Step Circle Icon
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isCompleted
                                    ? (isCurrent ? AppColors.primaryBlue : AppColors.success)
                                    : AppColors.border,
                                border: isCurrent
                                    ? Border.all(color: AppColors.accentBlue, width: 3)
                                    : null,
                              ),
                              child: Center(
                                child: isCompleted
                                    ? Icon(
                                        isCurrent ? Icons.directions_bike_rounded : Icons.check_rounded,
                                        color: Colors.white,
                                        size: 18,
                                      )
                                    : Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: AppColors.secondaryText,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                              ),
                            ),
                            // Connecting Line
                            if (!isLast)
                              Container(
                                width: 2.5,
                                height: 50,
                                color: isCompleted ? AppColors.success : AppColors.border,
                              ),
                          ],
                        ),
                        const SizedBox(width: 16),

                        // Right Step Title & Details
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      stepData['title']!,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                                        color: isCompleted ? AppColors.primaryText : AppColors.secondaryText,
                                      ),
                                    ),
                                    if (isCompleted)
                                      Text(
                                        stepData['time']!,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.secondaryText,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  stepData['subtitle']!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isCompleted ? AppColors.secondaryText : AppColors.border,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
              const SizedBox(height: 20),

              // COURIER DRIVER CARD
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.15),
                      child: const Icon(
                        Icons.person_pin_circle_rounded,
                        color: AppColors.primaryBlue,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Delivery Courier',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.secondaryText,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'BabyShopHub Express Logistics',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
