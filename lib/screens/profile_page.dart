import 'package:easy_localization/easy_localization.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lms_app/components/user_avatar.dart';
import 'package:lms_app/mixins/user_mixin.dart';
import 'package:lms_app/models/user_model.dart';
import 'package:lms_app/services/auth_service.dart';
import 'package:lms_app/services/firebase_service.dart';
import 'package:lms_app/utils/logout_dialog.dart';
import 'package:lms_app/utils/snackbars.dart';

import '../providers/user_data_provider.dart';

/// PROFILE EDIT — exact match to Photo 2 (right screen).
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

  Future _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image =
        await picker.pickImage(source: ImageSource.gallery, maxHeight: 400, maxWidth: 400);
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

  Future _saveAll() async {
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
                  : 'profile-update-failed'.tr());
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
    } catch (e) {
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
      'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
      'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'
    ];
    const kkMonths = [
      'қаңтар', 'ақпан', 'наурыз', 'сәуір', 'мамыр', 'маусым',
      'шілде', 'тамыз', 'қыркүйек', 'қазан', 'қараша', 'желтоқсан'
    ];
    const enMonths = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final m = d.month.clamp(1, 12) - 1;
    if (lang == 'kk') return 'member-since'.tr(namedArgs: {'date': '${kkMonths[m]} ${d.year}'});
    if (lang == 'ru') return 'member-since'.tr(namedArgs: {'date': '${ruMonths[m]} ${d.year}'});
    return 'member-since'.tr(namedArgs: {'date': '${enMonths[m]} ${d.year}'});
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userDataProvider);
    _syncFromUser(user);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDarkMode ? _darkCard : Colors.white;
    final lang = context.locale.languageCode;

    return Scaffold(
      backgroundColor: isDarkMode ? _darkBg : _lightBg,
      body: Stack(
        children: [
          // Background decor: soft pink gradient (фотосыз)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 280,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDarkMode
                      ? [_darkBg, _darkBg]
                      : [const Color(0xFFFFE9F3), _lightBg],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 40),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Airy header: circular back button + title + 3D cap asset
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: cardBg,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 14,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 18,
                              color: isDarkMode ? Colors.white : _navy,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'profile'.tr(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 26,
                                  letterSpacing: -0.5,
                                  color: isDarkMode ? Colors.white : _navy,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'edit-your-data'.tr(),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDarkMode ? Colors.grey[400] : const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Graduation cap icon (фотосыз)
                        Container(
                          width: 56,
                          height: 56,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _pink.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(
                            Icons.school_rounded,
                            size: 30,
                            color: Color(0xFFF50078),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Centered Avatar & Name
                    Center(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: _pickImage,
                            child: Stack(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isDarkMode ? const Color(0xFF262B40) : Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: _pink.withValues(alpha: 0.16),
                                        blurRadius: 24,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: UserAvatar(
                                    imageUrl: _imageUrl,
                                    imageFile: _selectedImageFile,
                                    radius: 50,
                                    iconSize: 28,
                                  ),
                                ),
                                Positioned(
                                  bottom: 2,
                                  right: 2,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: _pink,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2.2),
                                    ),
                                    child: const Icon(FeatherIcons.camera,
                                        size: 13, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _nameController.text.isEmpty
                                ? (user?.name ?? '')
                                : _nameController.text,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 20,
                              letterSpacing: -0.3,
                              color: isDarkMode ? Colors.white : _navy,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _memberSince(user, lang),
                            style: TextStyle(
                              fontSize: 12.5,
                              color: isDarkMode ? Colors.grey[400] : const Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Personal data fields: Name & Email
                    _WhiteCard(
                      bg: cardBg,
                      isDark: isDarkMode,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FieldLabel(FeatherIcons.user, 'name'.tr(), isDarkMode),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _nameController,
                            onChanged: (_) => setState(() {}),
                            style: TextStyle(
                                color: isDarkMode ? Colors.white : Colors.black87),
                            decoration: _inputDeco(isDarkMode, 'enter-name'.tr()),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'name-required'.tr()
                                : null,
                          ),
                          const SizedBox(height: 16),
                          _FieldLabel(FeatherIcons.mail, 'email'.tr(), isDarkMode),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? const Color(0xFF0F111A)
                                  : const Color(0xFFF6F7FB),
                              borderRadius: BorderRadius.circular(16),
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

                    // Password change card: Light pink background container
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDarkMode ? const Color(0xFF232738) : const Color(0xFFFFE9F3),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(FeatherIcons.lock, size: 16, color: _pink),
                              const SizedBox(width: 8),
                              Text(
                                'change-password'.tr(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15.5,
                                  color: isDarkMode ? Colors.white : _navy,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _pwdField(
                            controller: _currentPasswordController,
                            hint: 'current-password'.tr(),
                            obscure: _obscureCurrent,
                            onToggle: () =>
                                setState(() => _obscureCurrent = !_obscureCurrent),
                            isDarkMode: isDarkMode,
                            requiredIfAny: false,
                          ),
                          const SizedBox(height: 12),
                          _pwdField(
                            controller: _newPasswordController,
                            hint: 'new-password'.tr(),
                            obscure: _obscureNew,
                            onToggle: () =>
                                setState(() => _obscureNew = !_obscureNew),
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
                            onToggle: () =>
                                setState(() => _obscureConfirm = !_obscureConfirm),
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
                    const SizedBox(height: 20),

                    // Main Pink CTA Button
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
                              color: _pink.withValues(alpha: 0.32),
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
                                      strokeWidth: 2, color: Colors.white),
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
                    const SizedBox(height: 18),

                    // Divider with "или" (Photo 2)
                    Row(
                      children: [
                        Expanded(
                            child: Divider(
                                thickness: 1,
                                color: isDarkMode ? Colors.grey[800] : const Color(0xFFE5E7EB))),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Text(
                            'or'.tr().isEmpty ? 'или' : 'or'.tr(),
                            style: TextStyle(
                              fontSize: 12.5,
                              color: isDarkMode ? Colors.grey[400] : const Color(0xFF9CA3AF),
                            ),
                          ),
                        ),
                        Expanded(
                            child: Divider(
                                thickness: 1,
                                color: isDarkMode ? Colors.grey[800] : const Color(0xFFE5E7EB))),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Google Sign-In Button (Photo 2)
                    Container(
                      width: double.infinity,
                      height: 54,
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          AuthService().signInWithGoogle();
                        },
                         child: Row(
                           mainAxisAlignment: MainAxisAlignment.center,
                           children: [
                             const FaIcon(FontAwesomeIcons.google,
                                 size: 18, color: Color(0xFF4285F4)),
                             const SizedBox(width: 10),
                            Text(
                              'continue-with-google'.tr().isEmpty
                                  ? 'Продолжить с Google'
                                  : 'continue-with-google'.tr(),
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14.5,
                                color: isDarkMode ? Colors.white : _navy,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Logout link (Photo 2)
                    Center(
                      child: TextButton(
                        onPressed: () => openLogoutDialog(
                            context, () => handleLogout(context, ref: ref)),
                        child: Text(
                          'logout-from-account'.tr(),
                          style: const TextStyle(
                            color: _pink,
                            fontWeight: FontWeight.w700,
                            fontSize: 14.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDeco(bool isDarkMode, String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
          color: isDarkMode ? Colors.grey[500] : const Color(0xFF9CA3AF), fontSize: 14),
      filled: true,
      fillColor: isDarkMode ? const Color(0xFF0F111A) : const Color(0xFFF8F9FE),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _pink, width: 1.6),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        fillColor: isDarkMode ? const Color(0xFF0F111A) : Colors.white,
        suffixIcon: IconButton(
          icon: Icon(obscure ? FeatherIcons.eyeOff : FeatherIcons.eye,
              size: 18, color: const Color(0xFF9CA3AF)),
          onPressed: onToggle,
        ),
      ),
      validator: validator ??
          (v) {
            if (!_wantsPasswordChange) return null;
            if (v == null || v.isEmpty) return 'required'.tr();
            return null;
          },
    );
  }
}

class _WhiteCard extends StatelessWidget {
  const _WhiteCard({required this.bg, required this.isDark, required this.child});
  final Color bg;
  final bool isDark;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
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

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.icon, this.text, this.isDark);
  final IconData icon;
  final String text;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: _ProfilePageState._pink),
        const SizedBox(width: 6),
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
