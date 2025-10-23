import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_providers.dart';
import '../../providers/profile_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../core/constants/app_colors.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final profile = context.watch<ProfileProvider>();
    final txProv = context.read<TransactionProvider>();
    final user = auth.user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('No user logged in')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 🧑 Profile Card
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 55,
                            backgroundImage: profile.avatarPath != null
                                ? FileImage(File(profile.avatarPath!))
                                : (user.avatar != null
                                ? FileImage(File(user.avatar!))
                                : null),
                            backgroundColor:
                            AppColors.accent.withOpacity(0.15),
                            child: (profile.avatarPath == null &&
                                user.avatar == null)
                                ? const Icon(Icons.person,
                                size: 60, color: AppColors.primary)
                                : null,
                          ),
                          Positioned(
                            bottom: 5,
                            right: 5,
                            child: InkWell(
                              onTap: () => profile.pickImage().then((_) {
                                if (profile.avatarPath != null) {
                                  profile.saveAvatarToUser(user);
                                }
                              }),
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(6),
                                child: const Icon(Icons.edit,
                                    color: Colors.white, size: 18),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user.name,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(user.email,
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 14)),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit Profile'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const EditProfileScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 🔔 Notifications
              Card(
                child: SwitchListTile(
                  title: const Text('Enable Daily Expense Reminder'),
                  value: profile.notificationsEnabled,
                  onChanged: (v) =>
                      profile.toggleNotifications(context, v),
                ),
              ),

              ListTile(
                leading: const Icon(Icons.access_time,
                    color: AppColors.primary),
                title: const Text('Reminder Time'),
                subtitle: Text(profile.remindTime.format(context)),
                trailing: TextButton(
                    onPressed: () => profile.pickReminderTime(context),
                    child: const Text('Pick',
                        style: TextStyle(color: AppColors.primary))),
              ),
              const SizedBox(height: 12),

              // 🔁 Sync button
              ElevatedButton.icon(
                icon: const Icon(Icons.sync),
                label: const Text('Sync Expenses to Supabase'),
                onPressed: () async {
                  await txProv.syncAllExpensesToSupabase();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Expenses synced successfully')));
                  }
                },
              ),
              const SizedBox(height: 12),

              // 🔒 Change Password
              OutlinedButton.icon(
                icon: const Icon(Icons.lock_outline),
                label: const Text('Change Password'),
                onPressed: () => _openPasswordChange(context, profile, user),
              ),
              const SizedBox(height: 12),

              // 🚪 Logout
              ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: () async {
                  await auth.logout();
                  if (context.mounted) {
                    Navigator.of(context)
                        .popUntil((route) => route.isFirst);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openPasswordChange(
      BuildContext context, ProfileProvider profile, user) async {
    final oldPass = TextEditingController();
    final newPass = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: oldPass,
                decoration: const InputDecoration(labelText: 'Old Password'),
                obscureText: true),
            TextField(
                controller: newPass,
                decoration: const InputDecoration(labelText: 'New Password'),
                obscureText: true),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () async {
                final message = await profile.changePassword(
                    user: user,
                    oldPassword: oldPass.text.trim(),
                    newPassword: newPass.text.trim());
                if (context.mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(message)));
                }
                Navigator.pop(context);
              },
              child: const Text('Save')),
        ],
      ),
    );
  }
}
