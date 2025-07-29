import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lonepeak/domain/models/estate.dart';
import 'package:lonepeak/ui/core/themes/themes.dart';
import 'package:url_launcher/url_launcher.dart';

class EstateDetailsScreen extends StatefulWidget {
  final Estate estate;
  const EstateDetailsScreen({super.key, required this.estate});

  @override
  State<EstateDetailsScreen> createState() => _EstateDetailsScreenState();
}

class _EstateDetailsScreenState extends State<EstateDetailsScreen> {
  bool _isBasicInfoEditing = false;
  final _basicInfoFormKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;
  late final TextEditingController _countyController;

  late List<Map<String, String>> _currentWebLinks;
  late List<Map<String, String>> _savedWebLinks;

  @override
  void initState() {
    super.initState();
    _initializeControllers();

    final webLinksFromEstate =
        widget.estate.webLinks
            ?.map(
              (link) => {
                'title': link['title']?.toString() ?? 'No Title',
                'url': link['url']?.toString() ?? '',
                'subtitle': link['subtitle']?.toString() ?? 'Custom',
              },
            )
            .toList() ??
        [];

    _currentWebLinks = List<Map<String, String>>.from(webLinksFromEstate);
    _savedWebLinks = List<Map<String, String>>.from(webLinksFromEstate);
  }

  void _initializeControllers() {
    final e = widget.estate;
    _nameController = TextEditingController(text: e.name);
    _descriptionController = TextEditingController(text: e.description ?? '');
    _addressController = TextEditingController(text: e.address ?? '');
    _cityController = TextEditingController(text: e.city);
    _countyController = TextEditingController(text: e.county);
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

  Future<void> _onBasicInfoSave() async {
    if (_basicInfoFormKey.currentState?.validate() ?? false) {
      final updatedData = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'address': _addressController.text.trim(),
        'city': _cityController.text.trim(),
        'county': _countyController.text.trim(),
      };
      await FirebaseFirestore.instance
          .collection('estates')
          .doc(widget.estate.id)
          .update(updatedData);
      setState(() {
        _isBasicInfoEditing = false;
      });
    }
  }

  void _onBasicInfoCancel() {
    setState(() {
      _isBasicInfoEditing = false;
      _initializeControllers();
    });
  }

  Future<void> _showAddLinkBottomSheet() async {
    final newLink = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: const _AddLinkBottomSheetContent(),
        );
      },
    );

    if (newLink != null) {
      final updatedLinks = List<Map<String, String>>.from(_currentWebLinks)
        ..add(newLink);

      try {
        await FirebaseFirestore.instance
            .collection('estates')
            .doc(widget.estate.id)
            .update({'webLinks': updatedLinks});

        setState(() {
          _currentWebLinks = updatedLinks;
          _savedWebLinks = updatedLinks;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Link added successfully.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to add link: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _showDeleteLinkConfirmationDialog(int index) async {
    final linkToDelete = _currentWebLinks[index];
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Link?'),
          content: Text(
            "Are you sure you want to delete '${linkToDelete['title']}'?",
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('CANCEL'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('DELETE'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      _deleteLink(index);
    }
  }

  Future<void> _deleteLink(int index) async {
    final updatedLinks = List<Map<String, String>>.from(_currentWebLinks)
      ..removeAt(index);

    try {
      await FirebaseFirestore.instance
          .collection('estates')
          .doc(widget.estate.id)
          .update({'webLinks': updatedLinks});

      setState(() {
        _currentWebLinks = updatedLinks;
        _savedWebLinks = updatedLinks;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Link deleted.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete link: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _popWithResult() {
    final updatedEstate = widget.estate.copyWith(
      name: _nameController.text,
      description: _descriptionController.text,
      address: _addressController.text,
      city: _cityController.text,
      county: _countyController.text,
      webLinks: _savedWebLinks,
    );
    Navigator.of(context).pop(updatedEstate);
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not launch $urlString')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        _popWithResult();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _popWithResult,
          ),
          title: const Text('Estate Details'),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildBasicInfoCard(),
              const SizedBox(height: 16),
              _buildWebLinksCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardHeader({
    required String title,
    required IconData icon,
    Widget? actions,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(title, style: AppStyles.titleTextMedium(context)),
          ],
        ),
        if (actions != null) actions,
      ],
    );
  }

  Widget _buildBasicInfoCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: AppStyles.cardElevation,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _basicInfoFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCardHeader(
                title: 'Basic Information',
                icon: Icons.business_outlined,
                actions:
                    _isBasicInfoEditing
                        ? Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.close),
                              color: AppColors.primary,
                              tooltip: 'Cancel',
                              onPressed: _onBasicInfoCancel,
                            ),
                            IconButton(
                              icon: const Icon(Icons.save_outlined),
                              color: AppColors.primary,
                              tooltip: 'Save',
                              onPressed: _onBasicInfoSave,
                            ),
                          ],
                        )
                        : IconButton(
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: AppColors.primary,
                          ),
                          tooltip: 'Edit',
                          onPressed:
                              () => setState(() => _isBasicInfoEditing = true),
                        ),
              ),
              const SizedBox(height: 24),
              _buildEditableInfoRow('NAME', _nameController, isRequired: true),
              _buildEditableInfoRow(
                'DESCRIPTION',
                _descriptionController,
                maxLines: 3,
              ),
              _buildEditableInfoRow('ADDRESS', _addressController),
              _buildEditableInfoRow('CITY', _cityController, isRequired: true),
              _buildEditableInfoRow(
                'COUNTY',
                _countyController,
                isRequired: true,
                isLast: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebLinksCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: AppStyles.cardElevation,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardHeader(
              title: 'Web Links',
              icon: Icons.link_outlined,
              actions: IconButton(
                icon: const Icon(
                  Icons.add_circle_outline,
                  color: AppColors.primary,
                ),
                tooltip: 'Add New Link',
                onPressed: _showAddLinkBottomSheet,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Useful links related to your estate',
              style: AppStyles.subtitleText(context),
            ),
            const SizedBox(height: 16),
            if (_currentWebLinks.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: Text(
                    'No web links have been added.',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _currentWebLinks.length,
                itemBuilder: (context, index) {
                  final link = _currentWebLinks[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withAlpha(26),
                      child: const Icon(Icons.public, color: AppColors.primary),
                    ),
                    title: Text(link['title'] ?? 'No Title'),
                    subtitle: Text(link['url'] ?? 'No URL'),
                    onTap: () => _launchUrl(link['url'] ?? ''),
                    trailing: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (value) {
                        if (value == 'delete') {
                          _showDeleteLinkConfirmationDialog(index);
                        }
                      },
                      itemBuilder:
                          (BuildContext context) => [
                            PopupMenuItem<String>(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete_outline,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('Delete'),
                                ],
                              ),
                            ),
                          ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableInfoRow(
    String label,
    TextEditingController controller, {
    bool isLast = false,
    bool isRequired = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          _isBasicInfoEditing
              ? TextFormField(
                controller: controller,
                maxLines: maxLines,
                decoration: InputDecoration(
                  isDense: true,
                  errorBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  focusedErrorBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
                validator: (value) {
                  if (isRequired && (value == null || value.isEmpty)) {
                    return 'Please enter a $label';
                  }
                  return null;
                },
              )
              : Padding(
                padding: const EdgeInsets.only(top: 6.0, bottom: 2.0),
                child: Text(
                  controller.text.isEmpty ? 'N/A' : controller.text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _AddLinkBottomSheetContent extends StatefulWidget {
  const _AddLinkBottomSheetContent();

  @override
  State<_AddLinkBottomSheetContent> createState() =>
      _AddLinkBottomSheetContentState();
}

class _AddLinkBottomSheetContentState
    extends State<_AddLinkBottomSheetContent> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _urlController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final result = {
        'title': _titleController.text.trim(),
        'url': _urlController.text.trim(),
        'subtitle': 'Custom',
      };
      Navigator.of(context).pop(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add New Link',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Provide a title and a valid URL for the new link.',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withAlpha(153),
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'e.g., Estate Website',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator:
                  (value) => value!.isEmpty ? 'Please enter a title' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'URL',
                hintText: 'https://www.example.com',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              keyboardType: TextInputType.url,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a URL';
                }
                final uri = Uri.tryParse(value);
                if (uri == null || !uri.isAbsolute) {
                  return 'Please enter a valid URL';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _submit,
                child: const Text('ADD LINK'),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
