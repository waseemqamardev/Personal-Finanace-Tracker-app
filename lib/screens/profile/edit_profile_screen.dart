import 'dart:io';
import 'package:flutter/material.dart';
import 'package:peronaltracker/core/constants/app_colors.dart';
import 'package:peronaltracker/core/models/user_model.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_providers.dart';
import '../../../providers/profile_provider.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../core/utils/validators.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_input_field.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        final user = auth.user;
        if (user == null) {
          return const Scaffold(
            body: Center(child: Text('No user logged in')),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Edit Profile')),
          body: Consumer<ProfileProvider>(
            builder: (context, profile, child) {
              return _buildEditProfileContent(context, auth, profile, user);
            },
          ),
        );
      },
    );
  }

  Widget _buildEditProfileContent(BuildContext context, AuthProvider auth, ProfileProvider profile, UserModel user) {
    final isMobile = ResponsiveUtils.isMobile(context);
    final nameC = TextEditingController(text: user.name);
    final emailC = TextEditingController(text: user.email);

    return SingleChildScrollView(
      padding: ResponsiveUtils.responsivePadding(context),
      child: Column(
        children: [
          // Profile Picture
          GestureDetector(
            onTap: profile.pickImage,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: isMobile ? 55 : 65,
                  backgroundColor: AppColors.accent.withOpacity(0.1),
                  backgroundImage: profile.avatarPath != null
                      ? FileImage(File(profile.avatarPath!))
                      : (user.avatar != null
                      ? FileImage(File(user.avatar!))
                      : null),
                  child: (profile.avatarPath == null && user.avatar == null)
                      ? Icon(
                    Icons.person,
                    size: isMobile ? 60 : 70,
                    color: AppColors.primary,
                  )
                      : null,
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap to change photo',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 32),

          // Form
          Form(
            child: Column(
              children: [
                CustomInputField(
                  controller: nameC,
                  label: 'Full Name',
                  validator: Validators.validateName,
                ),
                const SizedBox(height: 16),
                CustomInputField(
                  controller: emailC,
                  label: 'Email',
                  readOnly: true,
                  validator: Validators.validateEmail,
                ),
                const SizedBox(height: 32),
                CustomButton(
                  text: 'Save Changes',
                  onPressed: () async {
                    if (nameC.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter your name')),
                      );
                      return;
                    }

                    final success = await auth.updateProfile(
                      name: nameC.text.trim(),
                      avatar: profile.avatarPath ?? user.avatar,
                    );

                    if (success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Profile updated successfully')),
                      );
                      Navigator.pop(context);
                    } else if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to update profile')),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}