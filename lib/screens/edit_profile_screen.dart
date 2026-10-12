import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../services/delivery_info.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _pictureController = TextEditingController();
  final _info = DeliveryInfo.instance;

  bool _isLoading = false;
  bool _isFetching = true;

  final List<Map<String, String>> _presetAvatars = [
    {
      'label': 'Baby Bear',
      'url': 'https://images.unsplash.com/photo-1519689680058-324335c77eba?w=150',
    },
    {
      'label': 'Cute Kid',
      'url': 'https://images.unsplash.com/photo-1502086223501-7ea6ecd79368?w=150',
    },
    {
      'label': 'Parent Care',
      'url': 'https://images.unsplash.com/photo-1544717305-2782549b5136?w=150',
    },
    {
      'label': 'Stroller Avatar',
      'url': 'https://images.unsplash.com/photo-1515488042361-ee00e0ddd4e4?w=150',
    },
  ];

  String get _email => FirebaseAuth.instance.currentUser?.email ?? 'Guest account';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final snap = await FirebaseDatabase.instance.ref('users/${user.uid}').get();
        if (snap.exists && snap.value is Map) {
          final data = Map<String, dynamic>.from(snap.value as Map);
          _nameController.text = (data['name'] ?? '').toString();
          _phoneController.text = (data['phone'] ?? '').toString();
          _pictureController.text = (data['profilePicture'] ?? data['photoUrl'] ?? '').toString();
        }
      } catch (e) {
        debugPrint('Error fetching user data directly: $e');
      }
    }

    if (_nameController.text.isEmpty) {
      _nameController.text = _info.name;
    }
    if (_phoneController.text.isEmpty) {
      _phoneController.text = _info.phone;
    }
    if (_pictureController.text.isEmpty) {
      _pictureController.text = _info.profilePicture;
    }

    if (mounted) {
      setState(() => _isFetching = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _pictureController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Please login to update your profile'),
            backgroundColor: AppColors.error,
          ),
        );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final name = _nameController.text.trim();
      final phone = _phoneController.text.trim();
      final picture = _pictureController.text.trim();

      // 1. Update Firebase Realtime Database
      await FirebaseDatabase.instance.ref('users/${user.uid}').update({
        'name': name,
        'phone': phone,
        'profilePicture': picture,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      // 2. Update local DeliveryInfo instance
      await _info.save(
        name: name,
        phone: phone,
        address: _info.address,
        profilePicture: picture,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Expanded(child: Text('Profile updated successfully!')),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text('Failed to update profile: ${e.toString()}')),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: _isFetching
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Avatar Preview Header
                      Center(
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            ValueListenableBuilder<TextEditingValue>(
                              valueListenable: _pictureController,
                              builder: (context, value, _) {
                                final url = value.text.trim();
                                final hasUrl = url.isNotEmpty &&
                                    (url.startsWith('http://') || url.startsWith('https://'));

                                return Container(
                                  width: 104,
                                  height: 104,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.primaryBlue.withValues(alpha: 0.3),
                                        AppColors.secondaryPink.withValues(alpha: 0.3),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primaryBlue.withValues(alpha: 0.15),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(3.0),
                                    child: ClipOval(
                                      child: hasUrl
                                          ? Image.network(
                                              url,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) =>
                                                  _buildAvatarFallback(),
                                              loadingBuilder: (context, child, loadingProgress) {
                                                if (loadingProgress == null) return child;
                                                return const Center(
                                                  child: SizedBox(
                                                    width: 24,
                                                    height: 24,
                                                    child: CircularProgressIndicator(strokeWidth: 2),
                                                  ),
                                                );
                                              },
                                            )
                                          : _buildAvatarFallback(),
                                    ),
                                  ),
                                );
                              },
                            ),
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: const BoxDecoration(
                                color: AppColors.primaryBlue,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Preset Avatars Selection
                      const Text(
                        'Choose Preset Avatar',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondaryText,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 52,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: _presetAvatars.length,
                          separatorBuilder: (context, index) => const SizedBox(width: 10),
                          itemBuilder: (context, index) {
                            final preset = _presetAvatars[index];
                            final url = preset['url']!;
                            final isSelected = _pictureController.text.trim() == url;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _pictureController.text = url;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? AppColors.primaryBlue : AppColors.border,
                                    width: isSelected ? 2.5 : 1,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundImage: NetworkImage(url),
                                  backgroundColor: AppColors.softBlue,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Full Name Field
                      CustomTextField(
                        label: 'Full Name',
                        hintText: 'Enter your full name',
                        controller: _nameController,
                        prefixIcon: Icons.person_outlined,
                        keyboardType: TextInputType.name,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Full name is required';
                          }
                          if (value.trim().length < 2) {
                            return 'Full name must be at least 2 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Email Address Field (Read Only)
                      const Text(
                        'Email Address',
                        style: TextStyle(
                          color: AppColors.primaryText,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        initialValue: _email,
                        readOnly: true,
                        style: const TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 15,
                        ),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.email_outlined, color: AppColors.secondaryText),
                          fillColor: AppColors.border.withValues(alpha: 0.3),
                          hintText: 'Email address',
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Phone Field
                      CustomTextField(
                        label: 'Phone Number',
                        hintText: '+92 300 0000000',
                        controller: _phoneController,
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Phone number is required';
                          }
                          if (value.trim().length < 7) {
                            return 'Please enter a valid phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Profile Picture URL Custom Field
                      CustomTextField(
                        label: 'Profile Picture URL',
                        hintText: 'https://example.com/photo.jpg',
                        controller: _pictureController,
                        prefixIcon: Icons.image_outlined,
                        keyboardType: TextInputType.url,
                        textInputAction: TextInputAction.done,
                        onEditingComplete: _handleSaveChanges,
                      ),
                      const SizedBox(height: 32),

                      // Save Button
                      PrimaryButton(
                        text: 'Save Changes',
                        isLoading: _isLoading,
                        onPressed: _handleSaveChanges,
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildAvatarFallback() {
    return Container(
      color: AppColors.softBlue,
      child: const Center(
        child: Icon(
          Icons.person_rounded,
          size: 56,
          color: AppColors.primaryBlue,
        ),
      ),
    );
  }
}
