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

  bool _isWebLinksEditing = false;
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

  Future<void> _onWebLinksSave() async {
    await FirebaseFirestore.instance
        .collection('estates')
        .doc(widget.estate.id)
        .update({'webLinks': _currentWebLinks});
    setState(() {
      _isWebLinksEditing = false;
      _savedWebLinks = List<Map<String, String>>.from(_currentWebLinks);
    });
  }

  void _onWebLinksCancel() {
    setState(() {
      _isWebLinksEditing = false;
      _currentWebLinks = List<Map<String, String>>.from(_savedWebLinks);
    });
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      hintText: 'e.g., Estate Website',
                    ),
                    validator:
                        (value) =>
                            value!.isEmpty ? 'Please enter a title' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: urlController,
                    decoration: const InputDecoration(
                      labelText: 'URL',
                      hintText: 'e.g., https://...',
                    ),
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
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('CANCEL'),
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
                child: const Text('ADD'),
              ),
            ],
          ),
    );

    if (result != null) {
      setState(() {
        _currentWebLinks.add(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) {
          return;
        }
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
    required bool isEditing,
    required VoidCallback onEdit,
    required VoidCallback onSave,
    required VoidCallback onCancel,
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
        isEditing
            ? Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  color: AppColors.primary,
                  tooltip: 'Cancel',
                  onPressed: onCancel,
                ),
                IconButton(
                  icon: const Icon(Icons.save_outlined),
                  color: AppColors.primary,
                  tooltip: 'Save',
                  onPressed: onSave,
                ),
              ],
            )
            : IconButton(
              icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
              tooltip: 'Edit',
              onPressed: onEdit,
            ),
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
                isEditing: _isBasicInfoEditing,
                onEdit: () => setState(() => _isBasicInfoEditing = true),
                onSave: _onBasicInfoSave,
                onCancel: _onBasicInfoCancel,
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
              isEditing: _isWebLinksEditing,
              onEdit: () => setState(() => _isWebLinksEditing = true),
              onSave: _onWebLinksSave,
              onCancel: _onWebLinksCancel,
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
                    _isWebLinksEditing
                        ? 'No links. Add one below.'
                        : 'No web links have been added.',
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
                    trailing:
                        _isWebLinksEditing
                            ? IconButton(
                              icon: Icon(
                                Icons.remove_circle_outline,
                                color: Colors.red.shade400,
                              ),
                              tooltip: 'Delete Link',
                              onPressed:
                                  () => setState(
                                    () => _currentWebLinks.removeAt(index),
                                  ),
                            )
                            : null,
                    onTap:
                        _isWebLinksEditing
                            ? null
                            : () => _launchUrl(link['url'] ?? ''),
                  );
                },
              ),
            if (_isWebLinksEditing) ...[
              const SizedBox(height: 16),
              Center(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add New Link'),
                  onPressed: _showAddLinkDialog,
                ),
              ),
            ],
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
    final errorBorder = UnderlineInputBorder(
      borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
    );

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
                  errorBorder: errorBorder,
                  focusedErrorBorder: errorBorder,
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
