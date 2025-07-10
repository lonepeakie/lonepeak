import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lonepeak/domain/models/estate.dart';
import 'package:lonepeak/router/routes.dart';
import 'package:lonepeak/ui/core/themes/themes.dart';
import 'package:lonepeak/ui/core/ui_state.dart';
import 'package:lonepeak/ui/core/widgets/app_buttons.dart';
import 'package:lonepeak/ui/core/widgets/member_tile.dart';
import 'package:lonepeak/ui/core/widgets/notice_card.dart';
import 'package:lonepeak/ui/estate_dashboard/view_models/estate_dashboard_viewmodel.dart';
import 'package:lonepeak/ui/estate_dashboard/widgets/dashboard_button.dart';
import 'package:url_launcher/url_launcher.dart';

class EstateDashboardScreen extends ConsumerStatefulWidget {
  const EstateDashboardScreen({super.key});

  @override
  ConsumerState<EstateDashboardScreen> createState() =>
      _EstateDashboardScreenState();
}

class _EstateDashboardScreenState extends ConsumerState<EstateDashboardScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  bool _isEditingLinks = false;

  List<Map<String, String>> _editableLinks = [];

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _countyController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _addressController = TextEditingController();
    _cityController = TextEditingController();
    _countyController = TextEditingController();

    Future.microtask(
      () => ref.read(estateDashboardViewModelProvider.notifier).getEstate(),
    );
    Future.microtask(
      () =>
          ref.read(estateDashboardViewModelProvider.notifier).getMembersCount(),
    );
    Future.microtask(
      () =>
          ref
              .read(estateDashboardViewModelProvider.notifier)
              .getCommitteeMembers(),
    );
    Future.microtask(
      () =>
          ref
              .read(estateDashboardViewModelProvider.notifier)
              .getLatestNotices(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _countyController.dispose();
    super.dispose();
  }

  Widget _buildContextMenu(
    BuildContext context,
    EditableTextState editableTextState,
  ) {
    final List<ContextMenuButtonItem> buttonItems =
        editableTextState.contextMenuButtonItems;
    return AdaptiveTextSelectionToolbar.buttonItems(
      anchors: editableTextState.contextMenuAnchors,
      buttonItems: buttonItems,
    );
  }

  void _toggleEditMode(dynamic estate) {
    setState(() {
      if (_isEditing) {
        _isEditing = false;
      } else {
        _isEditing = true;
        _nameController.text = estate.name ?? '';
        _descriptionController.text = estate.description ?? '';
        _addressController.text = estate.address ?? '';
        _cityController.text = estate.city ?? '';
        _countyController.text = estate.county ?? '';
      }
    });
  }

  void _toggleLinksEditMode() {
    final viewModel = ref.read(estateDashboardViewModelProvider.notifier);
    setState(() {
      _isEditingLinks = !_isEditingLinks;
      if (_isEditingLinks) {
        final currentLinks = viewModel.estate.webLinks ?? [];
        _editableLinks =
            currentLinks.map((link) => Map<String, String>.from(link)).toList();
      }
    });
  }

  Future<void> _saveLinks() async {
    await ref
        .read(estateDashboardViewModelProvider.notifier)
        .updateEstateLinks(_editableLinks);
  }

  Future<void> _showAddLinkDialog() async {
    final titleController = TextEditingController();
    final urlController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add New Link'),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                      validator:
                          (value) =>
                              value!.isEmpty ? 'Please enter a title' : null,
                      contextMenuBuilder: _buildContextMenu,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: urlController,
                      keyboardType: TextInputType.url,
                      decoration: const InputDecoration(
                        labelText: 'URL (e.g., https://...)',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a URL';
                        }
                        if (!Uri.tryParse(value)!.isAbsolute) {
                          return 'Please enter a valid URL';
                        }
                        return null;
                      },
                      contextMenuBuilder: _buildContextMenu,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    Navigator.of(context).pop({
                      'title': titleController.text,
                      'url': urlController.text,
                      'subtitle': 'Custom',
                    });
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
    );

    if (result != null) {
      setState(() {
        _editableLinks.add(result);
      });
    }
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final updatedData = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'address': _addressController.text,
        'city': _cityController.text,
        'county': _countyController.text,
      };

      await ref
          .read(estateDashboardViewModelProvider.notifier)
          .updateEstate(updatedData);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<UIState>(estateDashboardViewModelProvider, (previous, next) {
      if (next is UIStateSuccess) {
        if (_isEditing) {
          setState(() {
            _isEditing = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Information Saved!'),
              backgroundColor: Colors.green,
            ),
          );
        }
        if (_isEditingLinks) {
          setState(() {
            _isEditingLinks = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Links updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      if (next is UIStateFailure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${next.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    final state = ref.watch(estateDashboardViewModelProvider);
    final viewModel = ref.read(estateDashboardViewModelProvider.notifier);
    final estate = viewModel.estate;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (state is UIStateLoading && !_isEditing)
                const Center(child: CircularProgressIndicator())
              else if (state is UIStateFailure && (estate.id ?? '').isEmpty)
                Center(child: Text('Error: ${state.error}'))
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.blue[70],
                            child: Icon(
                              Icons.home,
                              color: AppColors.primary,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  estate.name,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      color: Colors.grey,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 2),
                                    Expanded(
                                      child: Text(
                                        '${estate.address} ${estate.city} Co.${estate.county}',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.person, size: 22),
                      iconSize: 40,
                      onPressed: () {
                        GoRouter.of(context).go(Routes.userProfile);
                      },
                    ),
                  ],
                ),
              const SizedBox(height: 32),
              basicInformationCard(estate, context, state),
              const SizedBox(height: 16),
              webLinksCard(),
              const SizedBox(height: 16),
              latestNoticesCard(),
              const SizedBox(height: 16),
              committeCard(),
              const SizedBox(height: 16),
              communityHubCard(),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  DashboardButton(
                    title: 'Documents',
                    subtitle: 'View and manage estate documents',
                    icon: Icons.description,
                    onTap: () {
                      GoRouter.of(
                        context,
                      ).go(Routes.estateHome + Routes.estateDocuments);
                    },
                  ),
                  DashboardButton(
                    title: 'Notices',
                    subtitle: 'View and manage estate notices',
                    icon: Icons.notifications,
                    onTap: () {
                      GoRouter.of(
                        context,
                      ).go(Routes.estateHome + Routes.estateNotices);
                    },
                  ),
                  DashboardButton(
                    title: 'Members',
                    subtitle: 'View and manage estate members',
                    icon: Icons.groups,
                    onTap: () {
                      GoRouter.of(
                        context,
                      ).go(Routes.estateHome + Routes.estateMembers);
                    },
                  ),
                  DashboardButton(
                    title: 'Treasury',
                    subtitle: 'View and manage estate treasury',
                    icon: Icons.account_balance_wallet,
                    onTap: () {
                      GoRouter.of(
                        context,
                      ).go(Routes.estateHome + Routes.estateTreasury);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Card basicInformationCard(
    Estate estate,
    BuildContext context,
    UIState state,
  ) {
    final bool isSaving = state is UIStateLoading && _isEditing;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0.2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.apartment_rounded, color: AppColors.primary),
                      const SizedBox(width: 8),
                      const Text(
                        'Basic Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (_isEditing)
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.cancel_outlined,
                            color: Colors.grey.shade600,
                          ),
                          onPressed:
                              isSaving ? null : () => _toggleEditMode(estate),
                        ),
                        if (isSaving)
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.0),
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 3),
                            ),
                          )
                        else
                          IconButton(
                            icon: Icon(
                              Icons.save_outlined,
                              color: AppColors.primary,
                            ),
                            onPressed: _saveChanges,
                          ),
                      ],
                    )
                  else
                    IconButton(
                      icon: Icon(Icons.edit_outlined, color: AppColors.primary),
                      onPressed: () => _toggleEditMode(estate),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              if (_isEditing) ...[
                _buildInfoTextField(label: 'Name', controller: _nameController),
                const SizedBox(height: 16),
                _buildInfoTextField(
                  label: 'Description',
                  controller: _descriptionController,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                _buildInfoTextField(
                  label: 'Address',
                  controller: _addressController,
                ),
                const SizedBox(height: 16),
                _buildInfoTextField(label: 'City', controller: _cityController),
                const SizedBox(height: 16),
                _buildInfoTextField(
                  label: 'County',
                  controller: _countyController,
                ),
              ] else ...[
                _buildInfoDetail('Name', estate.name),
                const SizedBox(height: 16),
                _buildInfoDetail(
                  'Description',
                  estate.description ?? 'No description provided.',
                ),
                const SizedBox(height: 16),
                _buildInfoDetail('Address', estate.address ?? 'Not specified'),
                const SizedBox(height: 16),
                _buildInfoDetail('City', estate.city),
                const SizedBox(height: 16),
                _buildInfoDetail('County', estate.county),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildInfoTextField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          contextMenuBuilder: _buildContextMenu,
          decoration: const InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a $label';
            }
            return null;
          },
        ),
      ],
    );
  }

  Card webLinksCard() {
    final viewModel = ref.read(estateDashboardViewModelProvider.notifier);
    final List<Map<String, dynamic>> savedLinks =
        viewModel.estate.webLinks ?? [];

    final List<Map<String, String>> linksToRender =
        _isEditingLinks
            ? _editableLinks
            : savedLinks.map((link) => Map<String, String>.from(link)).toList();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0.2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.language, color: Colors.blue),
                    const SizedBox(width: 8),
                    const Text(
                      'Web Links',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (_isEditingLinks)
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.cancel_outlined,
                          color: Colors.grey.shade600,
                        ),
                        onPressed: _toggleLinksEditMode,
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.save_outlined,
                          color: AppColors.primary,
                        ),
                        onPressed: _saveLinks,
                      ),
                    ],
                  )
                else
                  IconButton(
                    icon: Icon(Icons.edit_outlined, color: AppColors.primary),
                    onPressed: _toggleLinksEditMode,
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Useful links related to your estate',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            if (linksToRender.isEmpty && !_isEditingLinks)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text('No web links have been added.'),
                ),
              ),
            ListView.separated(
              itemCount: linksToRender.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final link = linksToRender[index];
                return _webLinkTile(
                  link['title']!,
                  link['subtitle'] ?? link['url']!,
                  link['url'],
                  isEditing: _isEditingLinks,
                  onRemove: () {
                    setState(() {
                      _editableLinks.removeAt(index);
                    });
                  },
                );
              },
            ),
            if (_isEditingLinks) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add New Link'),
                  onPressed: _showAddLinkDialog,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _webLinkTile(
    String title,
    String subtitle,
    String? url, {
    bool isEditing = false,
    VoidCallback? onRemove,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: InkWell(
        onTap:
            !isEditing && url != null && url.isNotEmpty
                ? () => launchUrl(Uri.parse(url))
                : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue.shade50,
                radius: 18,
                child: Icon(Icons.language, color: Colors.blue, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      isEditing ? (url ?? 'No URL') : subtitle,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (isEditing)
                IconButton(
                  icon: Icon(
                    Icons.remove_circle_outline,
                    color: Colors.red.shade700,
                  ),
                  onPressed: onRemove,
                  tooltip: 'Remove Link',
                ),
            ],
          ),
        ),
      ),
    );
  }

  Card latestNoticesCard() {
    final notices =
        ref
            .watch(estateDashboardViewModelProvider.notifier)
            .latestNoticesForDashboard;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 0.2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.notifications_outlined,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Latest Notices',
                      style: AppStyles.titleTextMedium(context),
                    ),
                  ],
                ),
                AppTextIconButton(
                  onPressed: () {
                    GoRouter.of(
                      context,
                    ).go(Routes.estateHome + Routes.estateNotices);
                  },
                  icon: Icons.arrow_forward_ios,
                ),
              ],
            ),
            Text(
              'Recent announcements from your estate',
              style: AppStyles.subtitleText(context),
            ),
            const SizedBox(height: 32),
            if (notices.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text('No recent notices to display.'),
                ),
              )
            else
              Column(
                children:
                    notices.map((notice) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            NoticeWidget(notice: notice, displayActions: false),
                            if (notices.last != notice) const Divider(),
                          ],
                        ),
                      );
                    }).toList(),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Card committeCard() {
    final committeeMembers =
        ref.watch(estateDashboardViewModelProvider.notifier).committeeMembers;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 0.2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.groups_outlined, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Committee',
                      style: AppStyles.titleTextMedium(context),
                    ),
                  ],
                ),
                AppTextIconButton(
                  onPressed: () {
                    GoRouter.of(
                      context,
                    ).go(Routes.estateHome + Routes.estateMembers);
                  },
                  icon: Icons.arrow_forward_ios,
                ),
              ],
            ),
            Text(
              'Quickly reachout to your commitee',
              style: AppStyles.subtitleText(context),
            ),
            const SizedBox(height: 32),
            if (committeeMembers.isEmpty)
              const Center(
                child: Text(
                  'No committee members available',
                  style: TextStyle(color: Color.fromARGB(255, 42, 17, 17)),
                ),
              )
            else
              ...committeeMembers.map((member) {
                final isLast =
                    committeeMembers.indexOf(member) ==
                    committeeMembers.length - 1;
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      MemberTile(
                        name: member.displayName,
                        role: member.role.name,
                        padding: EdgeInsets.zero,
                      ),
                      if (!isLast) const Divider(),
                    ],
                  ),
                );
              }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Card communityHubCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 0.2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.hub_outlined, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Community Hub',
                  style: AppStyles.titleTextMedium(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Connect with your community',
              style: AppStyles.subtitleText(context),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildHubButton(
                  icon: Icons.forum_outlined,
                  label: 'Forum',
                  onTap: () {},
                ),
                _buildHubButton(
                  icon: Icons.event_outlined,
                  label: 'Events',
                  onTap: () {},
                ),
                _buildHubButton(
                  icon: Icons.warning_amber_rounded,
                  label: 'Alerts',
                  onTap: () => context.go(Routes.alerts),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHubButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
