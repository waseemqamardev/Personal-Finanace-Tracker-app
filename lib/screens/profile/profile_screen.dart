import 'dart:io';
import 'package:flutter/material.dart';
import 'package:peronaltracker/core/utils/app_routes.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_providers.dart';
import '../../../providers/profile_provider.dart';
import '../../../providers/transaction_provider.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../core/constants/app_colors.dart';
import '../../core/models/user_model.dart';
import '../../widgets/custom_button.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
          appBar: AppBar(
            title: const Text('Profile'),
            centerTitle: true,
          ),
          body: Consumer<ProfileProvider>(
            builder: (context, profile, child) {
              return _buildProfileContent(context, auth, profile, user);
            },
          ),
        );
      },
    );
  }

  Widget _buildProfileContent(BuildContext context, AuthProvider auth, ProfileProvider profile, UserModel user) {
    final isMobile = ResponsiveUtils.isMobile(context);

    return SingleChildScrollView(
      padding: ResponsiveUtils.responsivePadding(context),
      child: Column(
        children: [
          // Profile Card
          _buildProfileCard(context, user, profile, isMobile),
          const SizedBox(height: 24),

          // Notifications Section
          _buildNotificationSection(context, profile, isMobile),
          const SizedBox(height: 16),

          // Sync Button
          _buildSyncButton(context, isMobile),
          const SizedBox(height: 16),

          // Change Password
          _buildChangePasswordButton(context, profile, user, isMobile),
          const SizedBox(height: 16),

          // Logout
          _buildLogoutButton(context, auth, isMobile),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, UserModel user, ProfileProvider profile, bool isMobile) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 20 : 24),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: isMobile ? 55 : 65,
                  backgroundImage: profile.avatarPath != null
                      ? FileImage(File(profile.avatarPath!))
                      : (user.avatar != null
                      ? FileImage(File(user.avatar!))
                      : null),
                  backgroundColor: AppColors.accent.withOpacity(0.15),
                  child: (profile.avatarPath == null && user.avatar == null)
                      ? Icon(
                    Icons.person,
                    size: isMobile ? 60 : 70,
                    color: AppColors.primary,
                  )
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
                      padding: EdgeInsets.all(isMobile ? 6 : 8),
                      child: Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: isMobile ? 18 : 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              user.name,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: ResponsiveUtils.responsiveFontSize(
                  context,
                  mobile: 20,
                  tablet: 22,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user.email,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: ResponsiveUtils.responsiveFontSize(
                  context,
                  mobile: 14,
                  tablet: 15,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: isMobile ? double.infinity : null,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text('Edit Profile'),
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.editProfile);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSection(BuildContext context, ProfileProvider profile, bool isMobile) {
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            title: Text(
              'Enable Daily Expense Reminder',
              style: TextStyle(
                fontSize: ResponsiveUtils.responsiveFontSize(
                  context,
                  mobile: 16,
                  tablet: 17,
                ),
              ),
            ),
            value: profile.notificationsEnabled,
            onChanged: (v) => profile.toggleNotifications(context, v),
          ),
          ListTile(
            leading: Icon(
              Icons.access_time,
              color: AppColors.primary,
              size: ResponsiveUtils.responsiveIconSize(context),
            ),
            title: Text(
              'Reminder Time',
              style: TextStyle(
                fontSize: ResponsiveUtils.responsiveFontSize(
                  context,
                  mobile: 16,
                  tablet: 17,
                ),
              ),
            ),
            subtitle: Text(profile.remindTime.format(context)),
            trailing: TextButton(
              onPressed: () => profile.pickReminderTime(context),
              child: Text(
                'Change',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: ResponsiveUtils.responsiveFontSize(
                    context,
                    mobile: 14,
                    tablet: 15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncButton(BuildContext context, bool isMobile) {
    return Consumer<TransactionProvider>(
      builder: (context, txProv, child) {
        return SizedBox(
          width: isMobile ? double.infinity : null,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.sync),
            label: const Text('Sync Expenses to Supabase'),
            onPressed: () async {
              await txProv.syncAllExpensesToSupabase();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Expenses synced successfully')),
                );
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildChangePasswordButton(BuildContext context, ProfileProvider profile, UserModel user, bool isMobile) {
    return SizedBox(
      width: isMobile ? double.infinity : null,
      child: OutlinedButton.icon(
        icon: const Icon(Icons.lock_outline),
        label: const Text('Change Password'),
        onPressed: () => _openPasswordChange(context, profile, user),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, AuthProvider auth, bool isMobile) {
    return SizedBox(
      width: isMobile ? double.infinity : null,
      child: CustomButton(
        text: 'Logout',
        onPressed: () => _confirmLogout(context, auth),
        backgroundColor: Colors.redAccent,
        fullWidth: true,
      ),
    );
  }

  Future<void> _openPasswordChange(BuildContext context, ProfileProvider profile, UserModel user) async {
    final oldPass = TextEditingController();
    final newPass = TextEditingController();
    final confirmPass = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPass,
              decoration: const InputDecoration(labelText: 'Current Password'),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPass,
              decoration: const InputDecoration(labelText: 'New Password'),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmPass,
              decoration: const InputDecoration(labelText: 'Confirm New Password'),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newPass.text != confirmPass.text) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('New passwords do not match')),
                  );
                }
                return;
              }

              final message = await profile.changePassword(
                user: user,
                oldPassword: oldPass.text.trim(),
                newPassword: newPass.text.trim(),
              );

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, AuthProvider auth) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await auth.logout();
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.login,
                (route) => false
        );
      }
    }
  }
}