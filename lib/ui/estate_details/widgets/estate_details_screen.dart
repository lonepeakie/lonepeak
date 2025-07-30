import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/domain/models/estate.dart';
import 'package:lonepeak/providers/estate_provider.dart';
import 'package:lonepeak/ui/core/themes/themes.dart';
import 'package:lonepeak/ui/core/widgets/app_buttons.dart';
import 'package:lonepeak/ui/core/widgets/app_cards.dart';
import 'package:lonepeak/ui/core/widgets/app_chip.dart';
import 'package:lonepeak/ui/core/widgets/app_inputs.dart';
import 'package:lonepeak/ui/core/widgets/app_labels.dart';
import 'package:lonepeak/ui/core/ui_state.dart';
import 'package:lonepeak/ui/estate_details/view_models/estate_details_viewmodel.dart';
import 'package:lonepeak/ui/estate_details/widgets/weblink_category.dart';
import 'package:url_launcher/url_launcher.dart';

class EstateDetailsScreen extends ConsumerStatefulWidget {
  const EstateDetailsScreen({super.key});

  @override
  ConsumerState<EstateDetailsScreen> createState() =>
      _EstateDetailsScreenState();
}

class _EstateDetailsScreenState extends ConsumerState<EstateDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    ref.listen<UIState>(estateDetailsViewModelProvider, (previous, next) {
      if (next is UIStateFailure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error), backgroundColor: Colors.red),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const AppbarTitle(text: 'Details')),
      body: Consumer(
        builder: (context, ref, child) {
          final detailsState = ref.watch(estateDetailsViewModelProvider);

          return SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildBasicInfoCard(),
                      const SizedBox(height: 16),
                      _buildWebLinksCard(),
                    ],
                  ),
                ),
                if (detailsState is UIStateLoading)
                  Container(
                    color: Colors.black54,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    return Consumer(
      builder: (context, ref, child) {
        final currentEstate = ref.watch(estateProvider.notifier).estate;

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          elevation: AppStyles.cardElevation,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppCardHeader(
                  title: 'Basic Information',
                  icon: Icons.business_outlined,
                  subtitle: 'Manage your estate details',
                  actions: [
                    IconButton(
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: AppColors.primary,
                      ),
                      tooltip: 'Edit',
                      onPressed:
                          () => _showEditEstateBottomSheet(currentEstate),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                AppInfoField(
                  label: 'Estate Name',
                  value:
                      currentEstate.name.isEmpty
                          ? 'Unknown Estate'
                          : currentEstate.name,
                ),
                const SizedBox(height: 16),
                AppInfoField(
                  label: 'Address',
                  value:
                      currentEstate.displayAddress.isEmpty
                          ? 'Unknown Address'
                          : currentEstate.displayAddress,
                ),
                const SizedBox(height: 16),
                AppInfoField(
                  label: 'Description',
                  value:
                      currentEstate.description?.isEmpty ?? true
                          ? 'Unknown Description'
                          : currentEstate.description!,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWebLinksCard() {
    final estate = ref.watch(estateProvider.notifier).estate;
    var webLinks = estate.webLinks ?? [];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: AppStyles.cardElevation,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCardHeader(
              title: 'Web Links',
              icon: Icons.language_outlined,
              subtitle: 'Useful links related to your estate',
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.add_circle_outline,
                    color: AppColors.primary,
                  ),
                  tooltip: 'Add New Link',
                  onPressed: _showAddLinkBottomSheet,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (webLinks.isEmpty)
              _buildEmptyWebLinksState()
            else
              ...webLinks.map((link) => _buildWebLinkTile(link)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWebLinksState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      width: double.infinity,
      child: Column(
        children: [
          Icon(Icons.link_off_outlined, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No web links added yet',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildWebLinkTile(EstateWebLink link) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: link.url.isNotEmpty ? () => _launchUrl(link.url) : null,
        onLongPress: () => _showDeleteLinkDialog(link),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  WeblinkCategoryUI.getCategoryIcon(link.category),
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      link.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      link.url.length > 30
                          ? '${link.url.substring(0, 30)}...'
                          : link.url,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () => _showDeleteLinkDialog(link),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.delete_outline,
                        color: AppColors.red,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    try {
      final Uri url = Uri.parse(urlString);
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (!mounted) return;

      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Unable to Open Link'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Could not open: $urlString'),
                  const SizedBox(height: 16),
                  const Text('You can copy the link and open it manually.'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    final navigator = Navigator.of(context);
                    final scaffoldMessenger = ScaffoldMessenger.of(context);

                    await Clipboard.setData(ClipboardData(text: urlString));
                    if (!mounted) return;

                    navigator.pop();
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(
                        content: Text('Link copied to clipboard'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  child: const Text('Copy Link'),
                ),
              ],
            ),
      );
    }
  }

  void _showEditEstateBottomSheet(Estate estate) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: estate.name);
    final addressController = TextEditingController(text: estate.address);
    final descriptionController = TextEditingController(
      text: estate.description,
    );

    showModalBottomSheet<Estate>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              return Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(width: 24),
                            Text(
                              'Edit Estate Details',
                              style: AppStyles.titleTextSmall(context),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                        Center(
                          child: Text(
                            'Edit the details of your estate.',
                            style: AppStyles.subtitleText(context),
                          ),
                        ),
                        const SizedBox(height: 16),
                        AppTextInput(
                          controller: nameController,
                          labelText: 'Estate Name',
                          hintText: 'Enter estate name',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Link title is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        AppTextInput(
                          controller: addressController,
                          labelText: 'Address',
                          hintText: 'Enter estate address',
                        ),
                        const SizedBox(height: 16),
                        AppTextInput(
                          controller: descriptionController,
                          labelText: 'Description',
                          hintText: 'Enter estate description',
                          maxLines: 3,
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            AppElevatedButton(
                              onPressed: () async {
                                if (formKey.currentState?.validate() ?? false) {
                                  final notifier = ref.read(
                                    estateDetailsViewModelProvider.notifier,
                                  );

                                  await notifier.updateBasicInfo(
                                    name: nameController.text.trim(),
                                    address: addressController.text.trim(),
                                    description:
                                        descriptionController.text.trim(),
                                  );

                                  if (!context.mounted) return;
                                  Navigator.of(context).pop();
                                }
                              },
                              buttonText: 'Update',
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
    );
  }

  void _showAddLinkBottomSheet() {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final urlController = TextEditingController();
    EstateWebLinkCategory selectedCategory = EstateWebLinkCategory.website;

    showModalBottomSheet<EstateWebLink>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              return Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(width: 24),
                            Text(
                              'Add New Web Link',
                              style: AppStyles.titleTextSmall(context),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                        Center(
                          child: Text(
                            'Add a new web link related to your estate.',
                            style: AppStyles.subtitleText(context),
                          ),
                        ),
                        const SizedBox(height: 16),
                        AppTextInput(
                          controller: titleController,
                          labelText: 'Link Title',
                          hintText: 'Enter link title',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Link title is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        AppTextInput(
                          controller: urlController,
                          labelText: 'Link URL',
                          hintText:
                              'Enter link URL (e.g., example.com or https://example.com)',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Link URL is required';
                            }

                            String urlString = value.trim();

                            // Auto-prepend https:// if no protocol is provided
                            if (!urlString.startsWith('http://') &&
                                !urlString.startsWith('https://')) {
                              urlString = 'https://$urlString';
                            }

                            // Try to parse the URL
                            try {
                              final uri = Uri.parse(urlString);

                              // Check if the URI has a valid host
                              if (uri.host.isEmpty) {
                                return 'Please enter a valid URL';
                              }

                              // Check if host contains at least one dot (basic domain validation)
                              if (!uri.host.contains('.')) {
                                return 'Please enter a valid domain name';
                              }

                              // Check if scheme is http or https
                              if (uri.scheme != 'http' &&
                                  uri.scheme != 'https') {
                                return 'URL must use http or https protocol';
                              }

                              // Basic length check
                              if (uri.host.length < 4) {
                                return 'Domain name is too short';
                              }
                            } catch (e) {
                              return 'Please enter a valid URL';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8.0,
                          children:
                              EstateWebLinkCategory.values.map((category) {
                                final chipColor =
                                    WeblinkCategoryUI.getCategoryColor(
                                      category,
                                    );
                                return AppChoiceChip(
                                  label: category.name,
                                  color: chipColor,
                                  selected: selectedCategory == category,
                                  onSelected: (isSelected) {
                                    setState(() {
                                      selectedCategory = category;
                                    });
                                  },
                                );
                              }).toList(),
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            AppElevatedButton(
                              onPressed: () {
                                if (formKey.currentState?.validate() ?? false) {
                                  // Normalize the URL
                                  String normalizedUrl =
                                      urlController.text.trim();
                                  if (!normalizedUrl.startsWith('http://') &&
                                      !normalizedUrl.startsWith('https://')) {
                                    normalizedUrl = 'https://$normalizedUrl';
                                  }

                                  final result = EstateWebLink(
                                    title: titleController.text.trim(),
                                    url: normalizedUrl,
                                    category: selectedCategory,
                                  );
                                  final notifier = ref.read(
                                    estateDetailsViewModelProvider.notifier,
                                  );
                                  notifier.addWebLink(result);
                                  Navigator.of(context).pop(result);
                                }
                              },
                              buttonText: 'Add',
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
    );
  }

  void _showDeleteLinkDialog(EstateWebLink link) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Web Link'),
            content: Text(
              'Are you sure you want to delete "${link.title}"? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  final notifier = ref.read(
                    estateDetailsViewModelProvider.notifier,
                  );
                  notifier.deleteWebLink(link);
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}
