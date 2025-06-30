import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/domain/models/listing.dart';
import 'package:lonepeak/providers/app_state_provider.dart';
import 'package:lonepeak/ui/core/widgets/app_buttons.dart';
import 'package:lonepeak/ui/core/widgets/app_inputs.dart';
import 'package:lonepeak/ui/marketplace/view_models/marketplace_viewmodel.dart';

class CreateListingForm extends ConsumerStatefulWidget {
  final Listing? existingListing;

  const CreateListingForm({
    super.key,
    this.existingListing,
  });

  @override
  ConsumerState<CreateListingForm> createState() => _CreateListingFormState();
}

class _CreateListingFormState extends ConsumerState<CreateListingForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  
  ListingCategory _selectedCategory = ListingCategory.other;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _populateFormIfEditing();
  }

  void _populateFormIfEditing() {
    if (widget.existingListing != null) {
      final listing = widget.existingListing!;
      _titleController.text = listing.title;
      _descriptionController.text = listing.description;
      _priceController.text = listing.price.toStringAsFixed(2);
      _selectedCategory = listing.category;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingListing != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Listing' : 'Create Listing'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextFormField(
                controller: _titleController,
                labelText: 'Title',
                hintText: 'Enter listing title',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  if (value.trim().length < 3) {
                    return 'Title must be at least 3 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              AppTextFormField(
                controller: _descriptionController,
                labelText: 'Description',
                hintText: 'Enter listing description',
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  if (value.trim().length < 10) {
                    return 'Description must be at least 10 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              AppTextFormField(
                controller: _priceController,
                labelText: 'Price (€)',
                hintText: '0.00',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a price';
                  }
                  final price = double.tryParse(value);
                  if (price == null || price < 0) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<ListingCategory>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: ListingCategory.values.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category.name),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 32),
              
              AppElevatedButton(
                onPressed: _isLoading ? null : _handleSubmit,
                buttonText: isEditing ? 'Update Listing' : 'Create Listing',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final appState = ref.read(appStateProvider);
      final currentUser = appState.getCurrentUser();
      
      if (currentUser == null) {
        _showError('User not found');
        return;
      }

      final listing = Listing(
        id: widget.existingListing?.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text),
        category: _selectedCategory,
        ownerId: appState.getUserId(),
        ownerName: currentUser.displayName ?? 'Unknown',
        ownerEmail: currentUser.email ?? '',
        imageUrls: widget.existingListing?.imageUrls ?? [],
        metadata: widget.existingListing?.metadata,
      );

      if (widget.existingListing != null) {
        await ref
            .read(marketplaceViewModelProvider.notifier)
            .updateListing(listing);
      } else {
        await ref
            .read(marketplaceViewModelProvider.notifier)
            .createListing(listing);
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.existingListing != null
                  ? 'Listing updated successfully'
                  : 'Listing created successfully',
            ),
          ),
        );
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $message'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}