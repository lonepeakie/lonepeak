import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/router/routes.dart';
import 'package:lonepeak/providers/auth_state_provider.dart';
import 'package:lonepeak/ui/user_profile/widgets/user_profile_screen_args.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  final UserProfileScreenArgs args;

  const UserProfileScreen({super.key, required this.args});

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  late TextEditingController _displayNameController;
  late TextEditingController _emailController;
  bool _isEditingPersonalInfo = false;
  bool _isLoading = false;
  bool _isDirty = false;

  @override
  void initState() {
    super.initState();
    final initialUser = widget.args.user;
    _displayNameController =
        TextEditingController(text: initialUser.displayName);
    _emailController = TextEditingController(text: initialUser.email);

    _displayNameController.addListener(_onTextChanged);
    _emailController.addListener(_onTextChanged);
  }

  Color _generateAvatarColor(String name) {
    if (name.isEmpty) return Colors.grey;
    final int hash = name.hashCode.abs();
    final double hue = (hash % 360).toDouble();
    return HSLColor.fromAHSL(1.0, hue, 0.7, 0.5).toColor();
  }

  void _onTextChanged() {
    final authState = ref.read(authStateProvider);
    final currentUser = authState.currentUser ?? widget.args.user;
    final hasChanged =
        _displayNameController.text.trim() != currentUser.displayName ||
            _emailController.text.trim() != currentUser.email;

    setState(() {
      _isDirty = hasChanged;
    });
  }

  @override
  void dispose() {
    _displayNameController.removeListener(_onTextChanged);
    _emailController.removeListener(_onTextChanged);
    _displayNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _cancelEdit() {
    final authState = ref.read(authStateProvider);
    final currentUser = authState.currentUser ?? widget.args.user;

    _displayNameController.text = currentUser.displayName;
    _emailController.text = currentUser.email;
    setState(() {
      _isEditingPersonalInfo = false;
      _isDirty = false;
    });
    FocusScope.of(context).unfocus();
  }

  Future<void> _saveProfile() async {
    if (!_isEditingPersonalInfo || !_isDirty) return;
    final newDisplayName = _displayNameController.text.trim();
    final newEmail = _emailController.text.trim();
    final originalEmail =
        (ref.read(authStateProvider).currentUser ?? widget.args.user).email;
    FocusScope.of(context).unfocus();

    if (newDisplayName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Display name cannot be empty')),
      );
      return;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(newEmail)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid email format')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await ref.read(authStateProvider).updateProfile(
            newDisplayName,
            newEmail,
          );

      if (!mounted) return;

      if (result.isSuccess) {
        String successMessage = 'Profile updated successfully';
        if (newEmail != originalEmail) {
          successMessage += '\nA verification link has been sent to $newEmail.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage),
            duration: const Duration(seconds: 5),
          ),
        );

        setState(() {
          _isEditingPersonalInfo = false;
          _isDirty = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Error: ${result.error ?? "An unknown error occurred"}'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSaveConfirmationDialog() {
    FocusScope.of(context).unfocus();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Changes"),
        content: const Text("Are you sure you want to save the changes?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _saveProfile();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("Yes"),
          ),
        ],
      ),
    );
  }

  void _showExitEstateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Exit Estate"),
        content: const Text("Are you sure you want to exit this estate?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Exited Estate')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authStateProvider).logout();
              GoRouter.of(context).go(Routes.login);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE55D5D),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("Yes"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String nameForAvatar = _displayNameController.text;
    final Color avatarColor = _generateAvatarColor(nameForAvatar);

    final currentEstate = widget.args.estate;
    final fullAddress =
        '${currentEstate.address}, ${currentEstate.city}, Co. ${currentEstate.county}';
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color cardColor = isDarkMode ? Colors.grey[850]! : Colors.white;
    final Color textColor = isDarkMode ? Colors.white : Colors.black;
    final Color subtitleColor =
        isDarkMode ? Colors.grey[400]! : Colors.grey[600]!;
    final Color fieldBackgroundColor =
        isDarkMode ? Colors.grey[700]! : Colors.grey[200]!;
    final Color fieldTextColor = isDarkMode ? Colors.white70 : Colors.black87;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () {
            if (GoRouter.of(context).canPop()) {
              GoRouter.of(context).pop();
            } else {
              GoRouter.of(context).go(Routes.estateHome);
            }
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Profile",
                style: TextStyle(
                    color: textColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
            Text("Manage your account settings",
                style: TextStyle(color: subtitleColor, fontSize: 14)),
          ],
        ),
        toolbarHeight: 80,
        actions: _isEditingPersonalInfo
            ? [
                TextButton(
                  onPressed: _cancelEdit,
                  child: const Text("Cancel"),
                ),
                const SizedBox(width: 8),
              ]
            : null,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionCard(
                    context: context,
                    icon: Icons.person,
                    title: "Personal Information",
                    subtitle: "Your personal account information",
                    cardColor: cardColor,
                    textColor: textColor,
                    subtitleColor: subtitleColor,
                    trailing: ElevatedButton.icon(
                      onPressed: _isEditingPersonalInfo
                          ? (_isDirty ? _showSaveConfirmationDialog : null)
                          : () => setState(() => _isEditingPersonalInfo = true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isDarkMode ? Colors.grey[700] : Colors.grey[200],
                        foregroundColor: textColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        minimumSize: Size.zero,
                        disabledBackgroundColor:
                            isDarkMode ? Colors.grey[800] : Colors.grey[300],
                      ),
                      icon: Icon(
                        _isEditingPersonalInfo ? Icons.check : Icons.edit,
                        size: 18,
                        color: _isEditingPersonalInfo && !_isDirty
                            ? textColor.withAlpha(128)
                            : textColor,
                      ),
                      label: Text(
                        _isEditingPersonalInfo ? "Save" : "Edit",
                        style: TextStyle(
                          fontSize: 14,
                          color: _isEditingPersonalInfo && !_isDirty
                              ? textColor.withAlpha(128)
                              : textColor,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: avatarColor,
                            child: Text(
                              nameForAvatar.isNotEmpty
                                  ? nameForAvatar[0].toUpperCase()
                                  : "",
                              style: const TextStyle(
                                fontSize: 40,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            "Avatar is generated from your name",
                            style:
                                TextStyle(fontSize: 13, color: subtitleColor),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Display Name",
                          style: TextStyle(fontSize: 14, color: subtitleColor),
                        ),
                        const SizedBox(height: 8),
                        _buildEditableField(
                          context,
                          _displayNameController,
                          "Display Name",
                          fieldBackgroundColor,
                          fieldTextColor,
                          _isEditingPersonalInfo,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Email Address",
                          style: TextStyle(fontSize: 14, color: subtitleColor),
                        ),
                        const SizedBox(height: 8),
                        _buildEditableField(
                          context,
                          _emailController,
                          "Email Address",
                          fieldBackgroundColor,
                          fieldTextColor,
                          _isEditingPersonalInfo,
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSectionCard(
                    context: context,
                    icon: Icons.home,
                    title: "Current Estate",
                    subtitle: "The estate you are currently managing",
                    cardColor: cardColor,
                    textColor: textColor,
                    subtitleColor: subtitleColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Estate Name",
                            style:
                                TextStyle(fontSize: 14, color: subtitleColor)),
                        const SizedBox(height: 8),
                        _buildReadOnlyField(context, currentEstate.name,
                            fieldBackgroundColor, fieldTextColor),
                        const SizedBox(height: 16),
                        Text("Address",
                            style:
                                TextStyle(fontSize: 14, color: subtitleColor)),
                        const SizedBox(height: 8),
                        _buildReadOnlyField(context, fullAddress,
                            fieldBackgroundColor, fieldTextColor),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _showExitEstateDialog,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[600],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.arrow_forward),
                            label: const Text("Exit Estate",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSectionCard(
                    context: context,
                    icon: Icons.settings,
                    title: "Account Actions",
                    subtitle: "Manage your account and session",
                    cardColor: cardColor,
                    textColor: textColor,
                    subtitleColor: subtitleColor,
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _showLogoutDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE55D5D),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.logout),
                        label: const Text("Logout",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color cardColor,
    required Color textColor,
    required Color subtitleColor,
    required Widget child,
    Widget? trailing,
  }) {
    return Card(
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      shadowColor: Colors.black.withAlpha(26),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 24, color: textColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 13, color: subtitleColor),
                      ),
                    ],
                  ),
                ),
                if (trailing != null) trailing,
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(
    BuildContext context,
    String value,
    Color bgColor,
    Color textColor,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        value,
        style: TextStyle(
          fontSize: 16,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildEditableField(
    BuildContext context,
    TextEditingController controller,
    String hintText,
    Color bgColor,
    Color textColor,
    bool isEnabled, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      enabled: isEnabled,
      keyboardType: keyboardType,
      style: TextStyle(
        fontSize: 16,
        color: textColor,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: textColor.withAlpha(153)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        filled: true,
        fillColor: bgColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: isEnabled
              ? BorderSide(color: Theme.of(context).primaryColor)
              : BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEnabled
                ? Theme.of(context).primaryColor.withAlpha(100)
                : Colors.transparent,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        isDense: true,
      ),
    );
  }
}
