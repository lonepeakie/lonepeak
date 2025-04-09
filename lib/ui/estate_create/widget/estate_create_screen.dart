import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lonepeak/domain/models/estate.dart';
import 'package:lonepeak/router/routes.dart';
import 'package:lonepeak/ui/core/themes/colors.dart';
import 'package:lonepeak/ui/estate_create/view_models/estate_create_viewmodel.dart';
import 'package:lonepeak/utils/ui_state.dart';

class EstateCreateScreen extends ConsumerStatefulWidget {
  const EstateCreateScreen({super.key});

  @override
  ConsumerState<EstateCreateScreen> createState() => _EstateCreateScreenState();
}

class _EstateCreateScreenState extends ConsumerState<EstateCreateScreen> {
  final TextEditingController estateNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController eircodeController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  String? selectedCounty;

  @override
  Widget build(BuildContext context) {
    final uiState = ref.watch(estateCreateViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Estate'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: const Color(0xFFF8FAFC), // Light background color
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (uiState is UIStateLoading)
                const Center(child: CircularProgressIndicator()),
              if (uiState is! UIStateLoading) ...[
                const Text(
                  'Set up your estate community with basic information',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: estateNameController,
                  decoration: const InputDecoration(
                    labelText: 'Estate Name',
                    hintText: 'e.g. Oakwood Residences',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    hintText: 'Street Address',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: eircodeController,
                  decoration: const InputDecoration(
                    labelText: 'Eircode (Optional)',
                    hintText: 'e.g. D04 V2N1',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'County',
                    border: OutlineInputBorder(),
                  ),
                  items:
                      <String>['County 1', 'County 2', 'County 3'].map((
                        String value,
                      ) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedCounty = newValue;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    hintText: 'A brief description of your estate community',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Estate Logo (Optional)',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    // Handle logo upload
                  },
                  icon: const Icon(Icons.upload, size: 20),
                  label: const Text('Upload logo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    side: const BorderSide(color: Colors.grey),
                    elevation: 0,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        side: const BorderSide(color: Colors.grey),
                      ),
                      child: const Text('Back'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final estate = Estate(
                          name: estateNameController.text.trim(),
                          description: descriptionController.text.trim(),
                          address: addressController.text.trim(),
                          city: '',
                          county: selectedCounty ?? '',
                        );

                        final result = await ref
                            .read(estateCreateViewModelProvider.notifier)
                            .createEstate(estate);

                        if (result.isSuccess) {
                          if (context.mounted) {
                            context.go(Routes.dashboard);
                          }
                        } else if (result.isFailure) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Error creating estate',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Create Estate'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
