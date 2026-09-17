import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../components/user_avatar.dart';
import '../../../models/user_model.dart';
import '../../edit_profile.dart';
import '../../../utils/next_screen.dart';

class UserInfo extends StatelessWidget {
  const UserInfo({super.key, required this.user, required this.ref});

  final UserModel user;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final cardBgColor = isDarkMode ? const Color(0xFF1E202C) : Colors.white;

    return Column(
      children: [
        // Main User Card
        Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: cardBgColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: isDarkMode
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.indigo.withValues(alpha: 0.05),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              // Avatar
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: primaryColor.withValues(alpha: 0.3), width: 2),
                ),
                child: UserAvatar(imageUrl: user.imageUrl, radius: 52, iconSize: 26),
              ),
              const SizedBox(width: 16),

              // User details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // Edit Button
              GestureDetector(
                onTap: () => NextScreen.openBottomSheet(context, EditProfile(user: user), maxHeight: 0.80),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    FeatherIcons.edit3,
                    size: 18,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

