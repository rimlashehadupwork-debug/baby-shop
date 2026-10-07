import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';
import 'delivery_addresses_screen.dart';

class AddEditAddressScreen extends StatefulWidget {
  const AddEditAddressScreen({super.key});

  @override
  State<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _recipientNameController;
  late TextEditingController _streetController;
  late TextEditingController _cityStateZipController;
  late TextEditingController _phoneController;

  String _selectedLabel = 'Home';
  bool _isDefault = false;
  bool _isEditMode = false;
  String? _addressId;

  @override
  void initState() {
    super.initState();
    _recipientNameController = TextEditingController(text: 'Sarah Khan');
    _streetController = TextEditingController();
    _cityStateZipController = TextEditingController();
    _phoneController = TextEditingController(text: '+92 300 1234567');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is AddressItem) {
      _isEditMode = true;
      _addressId = args.id;
      _selectedLabel = args.label;
      _recipientNameController.text = args.recipientName;
      _streetController.text = args.street;
      _cityStateZipController.text = args.cityStateZip;
      _phoneController.text = args.phone;
      _isDefault = args.isDefault;
    }
  }

  @override
  void dispose() {
    _recipientNameController.dispose();
    _streetController.dispose();
    _cityStateZipController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      final newAddress = AddressItem(
        id: _addressId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        label: _selectedLabel,
        recipientName: _recipientNameController.text.trim(),
        street: _streetController.text.trim(),
        cityStateZip: _cityStateZipController.text.trim(),
        phone: _phoneController.text.trim(),
        isDefault: _isDefault,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditMode ? 'Address updated successfully' : 'Address added successfully'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      Navigator.pop(context, newAddress);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Address' : 'Add New Address'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Address Label Selector Chips
                const Text(
                  'Address Label',
                  style: TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: ['Home', 'Work', 'Other'].map((label) {
                    final isSelected = _selectedLabel == label;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: ChoiceChip(
                        label: Text(label),
                        selected: isSelected,
                        selectedColor: AppColors.primaryBlue,
                        backgroundColor: AppColors.surface,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.primaryText,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: isSelected ? AppColors.primaryBlue : AppColors.border,
                          ),
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedLabel = label;
                            });
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Full Name / Recipient
                CustomTextField(
                  label: 'Recipient Full Name',
                  hintText: 'e.g. Sarah Khan',
                  controller: _recipientNameController,
                  prefixIcon: Icons.person_outlined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Recipient name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Street Address
                CustomTextField(
                  label: 'Street Address',
                  hintText: 'House/Apt No., Street Name, Area',
                  controller: _streetController,
                  prefixIcon: Icons.location_on_outlined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Street address is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // City / State / Zip
                CustomTextField(
                  label: 'City, State & Zip Code',
                  hintText: 'e.g. Islamabad, Pakistan 44000',
                  controller: _cityStateZipController,
                  prefixIcon: Icons.map_outlined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'City & Zip code is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Phone Number
                CustomTextField(
                  label: 'Phone Number',
                  hintText: '+92 300 0000000',
                  controller: _phoneController,
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  onEditingComplete: _handleSave,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Phone number is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Set as Default Address Switch
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Set as Default Delivery Address',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryText,
                    ),
                  ),
                  activeColor: AppColors.primaryBlue,
                  value: _isDefault,
                  onChanged: (bool value) {
                    setState(() {
                      _isDefault = value;
                    });
                  },
                ),
                const SizedBox(height: 28),

                // Save Button
                PrimaryButton(
                  text: _isEditMode ? 'Save Changes' : 'Save Address',
                  onPressed: _handleSave,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
