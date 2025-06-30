import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/domain/models/listing.dart';
import 'package:lonepeak/ui/core/themes/themes.dart';
import 'package:lonepeak/ui/core/widgets/app_buttons.dart';
import 'package:lonepeak/ui/core/widgets/app_inputs.dart';
import 'package:lonepeak/ui/marketplace/view_models/marketplace_viewmodel.dart';

class CreateListingForm extends ConsumerStatefulWidget {
  const CreateListingForm({super.key});

  @override
  ConsumerState<CreateListingForm> createState() => _CreateListingFormState();
}

class _CreateListingFormState extends ConsumerState<CreateListingForm> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final contactInfoController = TextEditingController();
  
  ListingCategory selectedCategory = ListingCategory.items;

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    contactInfoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 24), // Placeholder for alignment
                Text(
                  'Create New Listing',
                  style: AppStyles.titleTextSmall(context),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Share items and services with your community.',
                style: AppStyles.subtitleText(context),
              ),
            ),
            const SizedBox(height: 16),
            AppDropdown<ListingCategory>(
              labelText: 'Category',
              initialValue: selectedCategory,
              required: true,
              errorText: 'Please select a category',
              items: ListingCategory.values
                  .map(
                    (category) => DropdownItem<ListingCategory>(
                      value: category,
                      label: category.displayName,
                    ),
                  )
                  .toList(),
              onChanged: (ListingCategory? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedCategory = newValue;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            AppTextInput(
              controller: titleController,
              labelText: 'Title',
              hintText: 'e.g. iPhone 12 for sale',
              required: true,
              errorText: 'Title is required',
            ),
            const SizedBox(height: 16),
            AppTextInput(
              controller: descriptionController,
              labelText: 'Description',
              maxLines: 3,
              hintText: 'Describe your item or service...',
              required: true,
              errorText: 'Description is required',
            ),
            const SizedBox(height: 16),
            AppTextInput(
              controller: priceController,
              labelText: 'Price',
              hintText: 'e.g. €150 or Free',
              required: true,
              errorText: 'Price is required',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a price or "Free"';
                }
                
                // Allow "Free" or "free" case insensitive
                if (value.toLowerCase() == 'free') {
                  return null;
                }
                
                // Check if it's a valid price format (allowing currency symbols)
                final cleanValue = value.replaceAll(RegExp(r'[€$£,\s]'), '');
                if (cleanValue.isEmpty) {
                  return 'Please enter a valid price or "Free"';
                }
                
                // Try to parse as number
                final numValue = double.tryParse(cleanValue);
                if (numValue == null || numValue < 0) {
                  return 'Please enter a valid price or "Free"';
                }
                
                return null;
              },
            ),
            const SizedBox(height: 16),
            AppTextInput(
              controller: contactInfoController,
              labelText: 'Contact Info',
              hintText: 'Phone number, email, or other contact details',
              required: true,
              errorText: 'Contact information is required',
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppElevatedButton(
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) {
                      return;
                    }

                    final newListing = Listing(
                      title: titleController.text.trim(),
                      description: descriptionController.text.trim(),
                      price: priceController.text.trim(),
                      contactInfo: contactInfoController.text.trim(),
                      category: selectedCategory,
                      ownerId: '', // Will be populated by repository
                      ownerName: '', // Will be populated by repository
                      ownerInitials: '', // Will be populated by repository
                      estateId: '', // Will be populated by repository
                    );

                    final success = await ref
                        .read(marketplaceViewModelProvider.notifier)
                        .addListing(newListing);

                    if (mounted) {
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Listing created successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.of(context).pop();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Failed to create listing. Please try again.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  buttonText: 'Create Listing',
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}