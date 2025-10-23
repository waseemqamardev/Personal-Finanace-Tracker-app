import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_providers.dart';
import '../../providers/profile_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/validators.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final profile = context.watch<ProfileProvider>();
    final user = auth.user;

    final nameC = TextEditingController(text: user?.name ?? '');
    final emailC = TextEditingController(text: user?.email ?? '');

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          child: Column(
            children: [
              GestureDetector(
                onTap: profile.pickImage,
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: AppColors.accent.withOpacity(0.1),
                  backgroundImage: profile.avatarPath != null
                      ? FileImage(File(profile.avatarPath!))
                      : (user?.avatar != null
                      ? FileImage(File(user!.avatar!))
                      : null),
                  child: (profile.avatarPath == null && user?.avatar == null)
                      ? const Icon(Icons.person,
                      size: 55, color: AppColors.primary)
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: nameC,
                validator: Validators.validateName,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: emailC,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Email (cannot be changed)',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Save Changes'),
                onPressed: () async {
                  if (user != null) {
                    await auth.updateProfile(
                      name: nameC.text.trim(),
                      avatar: profile.avatarPath ?? user.avatar,
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Profile updated successfully')));
                      Navigator.pop(context);
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
