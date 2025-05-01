import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lonepeak/domain/features/estate_features.dart';
import 'package:lonepeak/domain/models/estate.dart';
import 'package:lonepeak/router/routes.dart';
import 'package:lonepeak/ui/core/constants/constants.dart';
import 'package:lonepeak/ui/core/themes/themes.dart';
import 'package:lonepeak/ui/core/widgets/app_buttons.dart';
import 'package:lonepeak/ui/core/widgets/app_inputs.dart';

class EstateCreateScreen extends ConsumerStatefulWidget {
  const EstateCreateScreen({super.key});

  @override
  ConsumerState<EstateCreateScreen> createState() => _EstateCreateScreenState();
}

class _EstateCreateScreenState extends ConsumerState<EstateCreateScreen> {
  final estateNameController = TextEditingController();
  final estateAddressController = TextEditingController();
  final estateEircodeController = TextEditingController();
  final estateDescriptionController = TextEditingController();
  final estateCountyController = TextEditingController();
  final estateLogoController = TextEditingController();
  final estateCityController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Estate'),
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Set up your estate community with basic information',
                  style: AppStyles.subtitleText,
                ),
                const SizedBox(height: 24),
                AppTextInput(
                  controller: estateNameController,
                  labelText: 'Estate Name',
                  hintText: 'e.g. Oakwood Residences',
                  required: true,
                  errorText: 'Estate name is required',
                ),
                const SizedBox(height: 16),
                AppTextInput(
                  controller: estateCityController,
                  labelText: 'Address (Optional)',
                  hintText: 'Street Address',
                ),
                const SizedBox(height: 16),
                AppTextInput(
                  controller: estateCityController,
                  labelText: 'City',
                  hintText: 'e.g. Dublin',
                  required: true,
                  errorText: 'City is required',
                ),
                const SizedBox(height: 16),
                AppDropdown<String>(
                  labelText: 'County',
                  required: true,
                  errorText: 'County is required',
                  items:
                      Constants.counties
                          .map(
                            (county) => DropdownItem<String>(
                              value: county,
                              label: "Co. $county",
                            ),
                          )
                          .toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        estateCountyController.text = newValue;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                AppTextInput(
                  controller: estateDescriptionController,
                  labelText: 'Description (Optional)',
                  hintText: 'A brief description of your estate community',
                  maxLines: 3,
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
                    side: const BorderSide(color: Colors.grey, width: 1.2),
                    elevation: 0,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AppElevatedButton(
                      onPressed: () {
                        if (!formKey.currentState!.validate()) {
                          return;
                        }
                        final result = ref
                            .read(estateFeaturesProvider)
                            .createEstateAndAddMember(
                              Estate(
                                name: estateNameController.text,
                                description: estateDescriptionController.text,
                                address: estateAddressController.text,
                                city: estateCityController.text,
                                county: estateCountyController.text,
                                logoUrl: estateLogoController.text,
                              ),
                            );
                        result.then((value) {
                          if (context.mounted) {
                            if (value.isFailure) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: ${value.error}'),
                                ),
                              );
                            } else {
                              context.go(Routes.estateHome);
                            }
                          }
                        });
                      },
                      buttonText: 'Create',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
