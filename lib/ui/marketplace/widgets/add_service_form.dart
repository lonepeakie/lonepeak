import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/domain/models/service.dart';
import 'package:lonepeak/ui/marketplace/view_models/marketplace_viewmodel.dart';

class AddServiceForm extends ConsumerStatefulWidget {
  const AddServiceForm({super.key});

  @override
  ConsumerState<AddServiceForm> createState() => _AddServiceFormState();
}

class _AddServiceFormState extends ConsumerState<AddServiceForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _providerNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _priceController = TextEditingController();
  final _availabilityController = TextEditingController();

  String? _selectedCategory;
  final _categories = [
    'Plumbing',
    'Carpentry',
    'Electrical',
    'Gardening',
    'Cleaning',
    'Other',
  ];
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _providerNameController.dispose();
    _emailController.dispose();
    _priceController.dispose();
    _availabilityController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final newService = Service(
        id: null,
        title: _titleController.text.trim(),
        category: _selectedCategory!,
        description: _descriptionController.text.trim(),
        providerName: _providerNameController.text.trim(),
        contactEmail: _emailController.text.trim(),
        price:
            _priceController.text.trim().isNotEmpty
                ? _priceController.text.trim()
                : null,
        availability: _availabilityController.text.trim(),
        createdAt: DateTime.now(),
        rating: 3.5 + Random().nextDouble() * 1.5,
        estateId: '',
      );

      await ref
          .read(marketplaceViewModelProvider.notifier)
          .addService(newService);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Service added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add New Service',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Service Title *'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                hint: const Text('Select a category *'),
                items:
                    _categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                onChanged: (v) => setState(() => _selectedCategory = v!),
                validator: (v) => v == null ? 'Please select a category' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _providerNameController,
                decoration: const InputDecoration(labelText: 'Provider Name *'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Contact Email *'),
                keyboardType: TextInputType.emailAddress,
                validator:
                    (v) =>
                        (v == null || !v.contains('@'))
                            ? 'Enter a valid email'
                            : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price (Optional)',
                  hintText: 'e.g., €50/hour, €200 fixed',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _availabilityController,
                decoration: const InputDecoration(
                  labelText: 'Availability *',
                  hintText: 'e.g., Weekdays 9AM-6PM',
                ),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    child:
                        _isLoading
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Text('Add Service'),
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
}
