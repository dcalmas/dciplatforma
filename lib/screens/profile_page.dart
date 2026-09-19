import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lms_app/components/user_avatar.dart';
import 'package:lms_app/mixins/user_mixin.dart';
import 'package:lms_app/models/user_model.dart';
import 'package:lms_app/services/auth_service.dart';
import 'package:lms_app/services/firebase_service.dart';
import 'package:lms_app/utils/logout_dialog.dart';
import 'package:lms_app/utils/snackbars.dart';

import '../providers/user_data_provider.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> with UserMixin {
  final _nameController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  XFile? _selectedImageFile;
  String? _imageUrl;
  bool _isSaving = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  static const _pink = Color(0xFFF50078);
  static const _lightBg = Color(0xFFFFF8FC);
  static const _navy = Color(0xFF1B1E2E);
  static const _darkBg = Color(0xFF0F111A);
  static const _darkCard = Color(0xFF1E202C);

  @override
  void initState() {
    super.initState();
    final user = ref.read(userDataProvider);
    _nameController.text = user?.name ?? '';
    _imageUrl = user?.imageUrl;
  }

  void _syncFromUser(UserModel? user) {
    if (user == null) return;
    if (_nameController.text.isEmpty && user.name.isNotEmpty) {
      _nameController.text = user.name;
    }
    if (_imageUrl == null && _selectedImageFile == null && user.imageUrl != null) {
      _imageUrl = user.imageUrl;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 400,
      maxWidth: 400,
    );

    if (image != null) {
      if (await image.length() > 2 * 1024 * 1024) {
        if (mounted) openSnackbarFailure(context, 'image-size-limit'.tr());
        return;
      }
      setState(() => _selectedImageFile = image);
    }
  }

  bool get _wantsPasswordChange =>
      _currentPasswordController.text.isNotEmpty ||
          _newPasswordController.text.isNotEmpty ||
          _confirmPasswordController.text.isNotEmpty;

  Future<void> _saveAll() async {
    if (!_formKey.currentState!.validate()) return;

    final userAtStart = ref.read(userDataProvider);
    if (userAtStart == null) {
      if (mounted) openSnackbarFailure(context, 'login-required'.tr());
      return;
    }

    setState(() => _isSaving = true);
    bool passwordFailed = false;

    try {
      final user = ref.read(userDataProvider);
      if (user == null) {
        if (mounted) openSnackbarFailure(context, 'login-required'.tr());
        return;
      }

      String? imageUrl = _imageUrl;
      if (_selectedImageFile != null) {
        try {
          imageUrl = await FirebaseService().uploadImageToHosting(
            _selectedImageFile!,
            uid: user.id,
            oldImageUrl: _imageUrl,
          );
        } on FormatException catch (e) {
          if (!mounted) return;
          openSnackbarFailure(
            context,
            e.message == 'image_too_large'
                ? 'image-size-limit'.tr()
                : 'profile-update-failed'.tr(),
          );
          return;
        }
      }

      final updatedUser = UserModel(
        id: user.id,
        email: user.email,
        name: _nameController.text.trim(),
        imageUrl: imageUrl,
        updatedAt: DateTime.now().toUtc(),
      );

      await FirebaseService().updateUserProfile(updatedUser);
      await ref.read(userDataProvider.notifier).getData();
      if (mounted) setState(() => _selectedImageFile = null);

      if (_wantsPasswordChange && mounted) {
        final ok = await AuthService().changePassword(
          context,
          _currentPasswordController.text,
          _newPasswordController.text,
        );
        if (ok && mounted) {
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
        } else {
          passwordFailed = true;
        }
      }

      if (!mounted) return;
      if (!passwordFailed) openSnackbar(context, 'profile-updated'.tr());
    } catch (_) {
      if (!mounted) return;
      openSnackbarFailure(context, 'profile-update-failed'.tr());
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String _memberSince(UserModel? user, String lang) {
    final d = user?.createdAt;
    if (d == null) return '';

    const ruMonths = [
      'января',
      'февраля',
      'марта',
      'апреля',
      'мая',
      'июня',
      'июля',
      'августа',
      'сентября',
      'октября',
      'ноября',
      'декабря',
    ];
    const kkMonths = [
      'қаңтар',
      'ақпан',
      'наурыз',
      'сәуір',
      'мамыр',
      'маусым',
      'шілде',
      'тамыз',
      'қыркүйек',
      'қазан',
      'қараша',
      'желтоқсан',
    ];
    const enMonths = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    final m = d.month.clamp(1, 12) - 1;
    if (lang == 'kk') {
      return 'member-since'.tr(namedArgs: {'date': '${kkMonths[m]} ${d.year}'});
    }
    if (lang == 'ru') {
      return 'member-since'.tr(namedArgs: {'date': '${ruMonths[m]} ${d.year}'});
    }
    return 'member-since'.tr(namedArgs: {'date': '${enMonths[m]} ${d.year}'});
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userDataProvider);
    _syncFromUser(user);

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final lang = context.locale.languageCode;
    final cardBg = isDarkMode ? _darkCard : Colors.white;
    final mutedText = isDarkMode ? Colors.grey[400] : const Color(0xFF8A90A2);

    return Scaffold(
      backgroundColor: isDarkMode ? _darkBg : _lightBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _CircleIconButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      isDarkMode: isDarkMode,
                      onTap: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'profile'.tr(),
                            style: TextStyle(
                              fontSize: 27,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.6,
                              color: isDarkMode ? Colors.white : _navy,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'edit-your-data'.tr(),
                            style: TextStyle(
                              fontSize: 13,
                              color: mutedText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Profile hero: only avatar + name + email + 3D study art.
                // No level, XP or gamification here.
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(18, 24, 18, 22),
                  decoration: BoxDecoration(
                    gradient: isDarkMode
                        ? const LinearGradient(
                      colors: [Color(0xFF7B1450), Color(0xFF5B267A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                        : const LinearGradient(
                      colors: [Color(0xFFFF0A78), Color(0xFFFF58A6), Color(0xFFB94CE8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: _pink.withValues(alpha: isDarkMode ? 0.16 : 0.22),
                        blurRadius: 28,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Decorative 3D book + graduation cap: separate image,
                      // never used as the card background.
                      Positioned(
                        right: -2,
                        top: -4,
                        child: IgnorePointer(
                          child: Opacity(
                            opacity: 0.96,
                            child: Image.asset(
                              'assets/images/shapka.png',
                              width: 92,
                              height: 92,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                            ),
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          Center(
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.95),
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.16),
                                          blurRadius: 18,
                                          offset: const Offset(0, 7),
                                        ),
                                      ],
                                    ),
                                    child: UserAvatar(
                                      imageUrl: _imageUrl,
                                      imageFile: _selectedImageFile,
                                      radius: 68,
                                      iconSize: 38,
                                    ),
                                  ),
                                  Positioned(
                                    right: 0,
                                    bottom: 2,
                                    child: Container(
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        color: _pink,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2.5),
                                      ),
                                      child: const Icon(
                                        Icons.edit_rounded,
                                        color: Colors.white,
                                        size: 17,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            _nameController.text.isEmpty ? (user?.name ?? '') : _nameController.text,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 54),
                            child: Text(
                              user?.email ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.88),
                                fontSize: 12.5,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _GlassCard(
                  isDarkMode: isDarkMode,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionTitle(
                        icon: Icons.badge_outlined,
                        title: lang == 'ru'
                            ? 'Личная информация'
                            : lang == 'kk'
                            ? 'Жеке ақпарат'
                            : 'Personal information',
                        isDarkMode: isDarkMode,
                      ),
                      const SizedBox(height: 16),
                      _FieldLabel(Icons.person_outline_rounded, 'name'.tr(), isDarkMode),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        onChanged: (_) => setState(() {}),
                        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
                        decoration: _inputDeco(isDarkMode, 'enter-name'.tr()),
                        validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'name-required'.tr() : null,
                      ),
                      const SizedBox(height: 16),
                      _FieldLabel(Icons.mail_outline_rounded, 'email'.tr(), isDarkMode),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                        decoration: BoxDecoration(
                          color: isDarkMode ? const Color(0xFF141826) : const Color(0xFFF7F8FC),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          user?.email ?? '',
                          style: TextStyle(
                            fontSize: 14.5,
                            color: isDarkMode ? Colors.grey[400] : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _GlassCard(
                  isDarkMode: isDarkMode,
                  tint: isDarkMode ? const Color(0xFF262135) : const Color(0xFFFFEEF6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionTitle(
                        icon: Icons.lock_outline_rounded,
                        title: 'change-password'.tr(),
                        isDarkMode: isDarkMode,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        lang == 'ru'
                            ? 'Заполняйте только если хотите изменить пароль'
                            : lang == 'kk'
                            ? 'Құпиясөзді өзгерткіңіз келсе ғана толтырыңыз'
                            : 'Fill in only if you want to change the password',
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.35,
                          color: mutedText,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _pwdField(
                        controller: _currentPasswordController,
                        hint: 'current-password'.tr(),
                        obscure: _obscureCurrent,
                        onToggle: () => setState(() => _obscureCurrent = !_obscureCurrent),
                        isDarkMode: isDarkMode,
                        requiredIfAny: false,
                      ),
                      const SizedBox(height: 12),
                      _pwdField(
                        controller: _newPasswordController,
                        hint: 'new-password'.tr(),
                        obscure: _obscureNew,
                        onToggle: () => setState(() => _obscureNew = !_obscureNew),
                        isDarkMode: isDarkMode,
                        validator: (v) {
                          if (!_wantsPasswordChange) return null;
                          if (v == null || v.isEmpty) return 'required'.tr();
                          if (v.length < 6) return 'min-6-chars'.tr();
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      _pwdField(
                        controller: _confirmPasswordController,
                        hint: 'confirm-password'.tr(),
                        obscure: _obscureConfirm,
                        onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                        isDarkMode: isDarkMode,
                        validator: (v) {
                          if (!_wantsPasswordChange) return null;
                          if (v == null || v.isEmpty) return 'required'.tr();
                          if (v != _newPasswordController.text) {
                            return 'passwords-no-match'.tr();
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF4D8D), _pink],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: _pink.withValues(alpha: 0.28),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveAll,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : Text(
                        'save-changes'.tr(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () =>
                        openLogoutDialog(context, () => handleLogout(context, ref: ref)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: _pink.withValues(alpha: 0.32), width: 1.2),
                      backgroundColor: cardBg,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                    child: Text(
                      'logout-from-account'.tr(),
                      style: const TextStyle(
                        color: _pink,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco(bool isDarkMode, String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: isDarkMode ? Colors.grey[500] : const Color(0xFF9CA3AF),
        fontSize: 14,
      ),
      filled: true,
      fillColor: isDarkMode ? const Color(0xFF141826) : const Color(0xFFF8F9FE),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: _pink, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
    );
  }

  Widget _pwdField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
    required bool isDarkMode,
    String? Function(String?)? validator,
    bool requiredIfAny = true,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
      decoration: _inputDeco(isDarkMode, hint).copyWith(
        fillColor: isDarkMode ? const Color(0xFF141826) : Colors.white,
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            size: 18,
            color: const Color(0xFF9CA3AF),
          ),
          onPressed: onToggle,
        ),
      ),
      validator: validator ??
              (v) {
            if (!_wantsPasswordChange && requiredIfAny) return null;
            if (!_wantsPasswordChange && !requiredIfAny) return null;
            if (v == null || v.isEmpty) return 'required'.tr();
            return null;
          },
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.isDarkMode,
    required this.onTap,
  });

  final IconData icon;
  final bool isDarkMode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDarkMode ? const Color(0xFF232738) : Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 46,
          height: 46,
          child: Icon(
            icon,
            size: 18,
            color: isDarkMode ? Colors.white : _ProfilePageState._navy,
          ),
        ),
      ),
    );
  }
}

class _HeaderArtCard extends StatelessWidget {
  const _HeaderArtCard({required this.isDarkMode});

  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 86,
      height: 86,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF232738) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _ProfilePageState._pink.withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.asset(
          'assets/images/shapka.png',
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFE2F0), Color(0xFFFFF4FA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Center(
              child: Icon(
                Icons.auto_awesome_rounded,
                color: _ProfilePageState._pink,
                size: 28,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({
    required this.isDarkMode,
    required this.child,
    this.tint,
  });

  final bool isDarkMode;
  final Widget child;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: tint ?? (isDarkMode ? const Color(0xFF1E202C) : Colors.white),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withValues(alpha: 0.26)
                : const Color(0xFFF50078).withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.isDarkMode,
  });

  final IconData icon;
  final String title;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: _ProfilePageState._pink.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, size: 18, color: _ProfilePageState._pink),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.25,
              color: isDarkMode ? Colors.white : _ProfilePageState._navy,
            ),
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.icon, this.text, this.isDark);

  final IconData icon;
  final String text;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: _ProfilePageState._pink),
        const SizedBox(width: 7),
        Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: isDark ? Colors.white : _ProfilePageState._navy,
          ),
        ),
      ],
    );
  }
}
