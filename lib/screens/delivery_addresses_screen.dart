import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_button.dart';

class AddressItem {
  final String id;
  String label;
  String recipientName;
  String street;
  String cityStateZip;
  String phone;
  bool isDefault;

  AddressItem({
    required this.id,
    required this.label,
    required this.recipientName,
    required this.street,
    required this.cityStateZip,
    required this.phone,
    this.isDefault = false,
  });
}

class DeliveryAddressesScreen extends StatefulWidget {
  const DeliveryAddressesScreen({super.key});

  @override
  State<DeliveryAddressesScreen> createState() => _DeliveryAddressesScreenState();
}

class _DeliveryAddressesScreenState extends State<DeliveryAddressesScreen> {
  final List<AddressItem> _addresses = [
    AddressItem(
      id: '1',
      label: 'Home',
      recipientName: 'Sarah Khan',
      street: '123 Palm Street, Bahria Town',
      cityStateZip: 'Islamabad, Pakistan',
      phone: '+92 300 1234567',
      isDefault: true,
    ),
    AddressItem(
      id: '2',
      label: 'Work',
      recipientName: 'Sarah Khan',
      street: 'Office No. 3, Business Center',
      cityStateZip: 'Islamabad, Pakistan',
      phone: '+92 316 9876543',
      isDefault: false,
    ),
  ];

  void _setDefaultAddress(String id) {
    setState(() {
      for (var addr in _addresses) {
        addr.isDefault = (addr.id == id);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Default delivery address updated'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _deleteAddress(AddressItem address) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Address'),
        content: Text('Are you sure you want to delete "${address.label}" address?'),
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
            onPressed: () {
              Navigator.pop(dialogContext);
              setState(() {
                _addresses.removeWhere((a) => a.id == address.id);
                if (address.isDefault && _addresses.isNotEmpty) {
                  _addresses.first.isDefault = true;
                }
              });
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

  void _navigateToAddAddress() async {
    final result = await Navigator.pushNamed(context, '/add-edit-address');
    if (result != null && result is AddressItem) {
      setState(() {
        if (result.isDefault) {
          for (var a in _addresses) {
            a.isDefault = false;
          }
        }
        _addresses.add(result);
      });
    }
  }

  void _navigateToEditAddress(AddressItem address) async {
    final result = await Navigator.pushNamed(
      context,
      '/add-edit-address',
      arguments: address,
    );
    if (result != null && result is AddressItem) {
      setState(() {
        final index = _addresses.indexWhere((a) => a.id == result.id);
        if (index != -1) {
          _addresses[index] = result;
          if (result.isDefault) {
            for (var a in _addresses) {
              if (a.id != result.id) a.isDefault = false;
            }
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Addresses'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _addresses.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.location_off_outlined,
                            size: 64,
                            color: AppColors.secondaryText,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No addresses saved yet',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: _addresses.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final address = _addresses[index];
                        return _buildAddressCard(address);
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: PrimaryButton(
                text: 'Add New Address',
                onPressed: _navigateToAddAddress,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard(AddressItem address) {
    final isSelected = address.isDefault;

    return Container(
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
            color: Colors.black.withValues(alpha: isSelected ? 0.06 : 0.02),
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
              // Label Badge (Home, Work, etc.)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: address.label.toLowerCase() == 'home'
                      ? AppColors.primaryBlue.withValues(alpha: 0.1)
                      : AppColors.secondaryPink.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      address.label.toLowerCase() == 'home'
                          ? Icons.home_rounded
                          : Icons.work_rounded,
                      size: 14,
                      color: address.label.toLowerCase() == 'home'
                          ? AppColors.primaryBlue
                          : AppColors.secondaryPink,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      address.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: address.label.toLowerCase() == 'home'
                            ? AppColors.primaryBlue
                            : AppColors.secondaryPink,
                      ),
                    ),
                  ],
                ),
              ),
              if (address.isDefault) ...[
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
              const Spacer(),
              // Select Radio / Checkmark
              Radio<bool>(
                value: true,
                groupValue: isSelected,
                activeColor: AppColors.primaryBlue,
                onChanged: (val) {
                  if (!address.isDefault) {
                    _setDefaultAddress(address.id);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Recipient Name
          Text(
            address.recipientName,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 4),
          // Street Address
          Text(
            '${address.street}, ${address.cityStateZip}',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.secondaryText,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 4),
          // Phone Number
          Text(
            address.phone,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 8),
          // Action Buttons: Edit & Delete
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => _navigateToEditAddress(address),
                icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.primaryBlue),
                label: const Text(
                  'Edit',
                  style: TextStyle(color: AppColors.primaryBlue, fontSize: 13),
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => _deleteAddress(address),
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
