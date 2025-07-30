import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/ui/core/themes/themes.dart';
import 'package:lonepeak/ui/core/widgets/app_cards.dart';
import 'package:lonepeak/ui/core/widgets/app_inputs.dart';
import 'package:lonepeak/ui/core/widgets/app_labels.dart';
import 'package:lonepeak/ui/core/ui_state.dart';
import 'package:lonepeak/ui/estate_dashboard/view_models/estate_dashboard_viewmodel.dart';
import 'package:lonepeak/ui/estate_details/view_models/estate_details_viewmodel.dart';

class EstateDetailsScreen extends ConsumerStatefulWidget {
  const EstateDetailsScreen({super.key});

  @override
  ConsumerState<EstateDetailsScreen> createState() =>
      _EstateDetailsScreenState();
}

class _EstateDetailsScreenState extends ConsumerState<EstateDetailsScreen> {
  bool _isBasicInfoEditing = false;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _descriptionController;
  late TextEditingController _cityController;
  late TextEditingController _countyController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _addressController = TextEditingController();
    _descriptionController = TextEditingController();
    _cityController = TextEditingController();
    _countyController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _cityController.dispose();
    _countyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dashboardNotifier = ref.watch(
      estateDashboardViewModelProvider.notifier,
    );
    final estate = dashboardNotifier.estate;

    if (_nameController.text.isEmpty) {
      _nameController.text = estate.name;
      _addressController.text = estate.address ?? '';
      _descriptionController.text = estate.description ?? '';
      _cityController.text = estate.city;
      _countyController.text = estate.county;
    }

    ref.listen<UIState>(estateDetailsViewModelProvider, (previous, next) {
      if (next is UIStateSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Estate details updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (next is UIStateFailure) {
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
                      _buildBasicInfoCard(estate),
                      const SizedBox(height: 16),
                      // _buildWebLinksCard(),
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

  void _onBasicInfoCancel() {
    setState(() {
      _isBasicInfoEditing = false;
      // Reset controllers to original values
      final estate = ref.read(estateDashboardViewModelProvider.notifier).estate;
      _nameController.text = estate.name;
      _addressController.text = estate.address ?? '';
      _descriptionController.text = estate.description ?? '';
      _cityController.text = estate.city;
      _countyController.text = estate.county;
    });
  }

  void _onBasicInfoSave() async {
    if (_formKey.currentState?.validate() ?? false) {
      final detailsNotifier = ref.read(estateDetailsViewModelProvider.notifier);

      await detailsNotifier.updateBasicInfo(
        name: _nameController.text,
        address: _addressController.text,
        description: _descriptionController.text,
        // city: _cityController.text,
        // county: _estateCountyController.text,
      );

      setState(() {
        _isBasicInfoEditing = false;
      });
    }
  }

  Widget _buildBasicInfoCard(estate) {
    return Consumer(
      builder: (context, ref, child) {
        final detailsState = ref.watch(estateDetailsViewModelProvider);
        final isLoading = detailsState is UIStateLoading;

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          elevation: AppStyles.cardElevation,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppCardHeader(
                    title: 'Basic Information',
                    icon: Icons.business_outlined,
                    actions: [
                      _isBasicInfoEditing
                          ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.close),
                                color: AppColors.primary,
                                tooltip: 'Cancel',
                                onPressed:
                                    isLoading ? null : _onBasicInfoCancel,
                              ),
                              IconButton(
                                icon:
                                    isLoading
                                        ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                        : const Icon(Icons.save_outlined),
                                color: AppColors.primary,
                                tooltip: 'Save',
                                onPressed: isLoading ? null : _onBasicInfoSave,
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
                                () =>
                                    setState(() => _isBasicInfoEditing = true),
                          ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  AppTextInput(
                    controller: _nameController,
                    labelText: 'Estate Name',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Estate name is required';
                      }
                      return null;
                    },
                    hintText: 'Enter estate name',
                    enabled: _isBasicInfoEditing,
                  ),
                  const SizedBox(height: 16),
                  AppTextInput(
                    controller: _addressController,
                    labelText: 'Address',
                    hintText: 'Enter address',
                    enabled: _isBasicInfoEditing,
                  ),
                  const SizedBox(height: 16),
                  AppTextInput(
                    controller: _descriptionController,
                    labelText: 'Description',
                    hintText: 'Enter description',
                    enabled: _isBasicInfoEditing,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  AppTextInput(
                    controller: _cityController,
                    labelText: 'City',
                    hintText: 'Enter city',
                    enabled: false,
                  ),
                  const SizedBox(height: 16),
                  AppTextInput(
                    controller: _countyController,
                    labelText: 'County',
                    hintText: 'Enter county',
                    enabled: false,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'County is required';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
