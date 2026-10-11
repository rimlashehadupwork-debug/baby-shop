import 'package:flutter/material.dart';
import '../services/delivery_info.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_button.dart';

class DeliveryAddressesScreen extends StatefulWidget {
  const DeliveryAddressesScreen({super.key});

  @override
  State<DeliveryAddressesScreen> createState() => _DeliveryAddressesScreenState();
}

class _DeliveryAddressesScreenState extends State<DeliveryAddressesScreen> {
  final _info = DeliveryInfo.instance;

  @override
  void initState() {
    super.initState();
    _info.load();
  }

  bool get _hasAddress => _info.address.trim().isNotEmpty;

  void _deleteAddress() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Address'),
        content: const Text('Are you sure you want to delete your delivery address?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: AppColors.secondaryText)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              minimumSize: const Size(80, 40),
            ),
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _info.save(name: _info.name, phone: _info.phone, address: '');
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Address removed'),
                  backgroundColor: AppColors.secondaryText,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Address'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _info,
          builder: (context, _) {
            return Column(
              children: [
                Expanded(
                  child: !_hasAddress
                      ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_off_outlined,
                          size: 64,
                          color: AppColors.secondaryText,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No address saved yet',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  )
                      : ListView(
                    padding: const EdgeInsets.all(20),
                    children: [_buildAddressCard()],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: PrimaryButton(
                    text: _hasAddress ? 'Edit Address' : 'Add Address',
                    onPressed: () => Navigator.pushNamed(context, '/add-edit-address'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAddressCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryBlue, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.home_rounded, size: 14, color: AppColors.primaryBlue),
                    SizedBox(width: 6),
                    Text(
                      'Delivery',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Default',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _info.name.isEmpty ? '-' : _info.name,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _info.address,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.secondaryText,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _info.phone.isEmpty ? '-' : _info.phone,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/add-edit-address'),
                icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.primaryBlue),
                label: const Text(
                  'Edit',
                  style: TextStyle(color: AppColors.primaryBlue, fontSize: 13),
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: _deleteAddress,
                icon: const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.error),
                label: const Text(
                  'Delete',
                  style: TextStyle(color: AppColors.error, fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}