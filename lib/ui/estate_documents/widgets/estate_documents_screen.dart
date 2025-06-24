import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/domain/models/document.dart';
import 'package:lonepeak/ui/core/themes/themes.dart';
import 'package:lonepeak/ui/core/ui_state.dart';
import 'package:lonepeak/ui/core/widgets/appbar_title.dart';
import 'package:lonepeak/ui/estate_documents/view_models/estate_documents_viewmodel.dart';
import 'package:lonepeak/ui/estate_documents/widgets/create_folder_dialog.dart';
import 'package:lonepeak/ui/estate_documents/widgets/document_breadcrumbs.dart';
import 'package:lonepeak/ui/estate_documents/widgets/document_tile.dart';

class EstateDocumentsScreen extends ConsumerStatefulWidget {
  const EstateDocumentsScreen({super.key});

  @override
  ConsumerState<EstateDocumentsScreen> createState() =>
      _EstateDocumentsScreenState();
}

class _EstateDocumentsScreenState extends ConsumerState<EstateDocumentsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load documents when the screen initializes
    Future.microtask(
      () => ref.read(estateDocumentsViewModelProvider.notifier).loadDocuments(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(estateDocumentsViewModelProvider);
    final viewModel = ref.read(estateDocumentsViewModelProvider.notifier);
    final documents = viewModel.documents;
    final breadcrumbs = viewModel.breadcrumbs;

    return Scaffold(
      appBar: AppBar(
        title: const AppbarTitle(text: 'Documents'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _showSearchDialog(context);
            },
          ),
        ],
      ),
      body:
          state is UIStateLoading
              ? const Center(child: CircularProgressIndicator())
              : state is UIStateFailure
              ? Center(child: Text('Error: ${state.error}'))
              : Column(
                children: [
                  // Breadcrumb navigation
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: DocumentBreadcrumbs(
                      breadcrumbs: breadcrumbs,
                      onBreadcrumbTap: (doc) {
                        viewModel.navigateToFolder(doc);
                      },
                      onHomePressed: () {
                        viewModel.loadDocuments();
                      },
                    ),
                  ),

                  // Documents list
                  Expanded(
                    child:
                        documents.isEmpty
                            ? _buildEmptyState()
                            : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: documents.length,
                              itemBuilder: (context, index) {
                                final document = documents[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: DocumentTile(
                                    document: document,
                                    isSelected: false, // No selection needed
                                    onTap: () {
                                      if (document.type ==
                                          DocumentType.folder) {
                                        viewModel.navigateToFolder(document);
                                      } else {
                                        // Show a quick preview or actions for files
                                        _showFileOptions(context, document);
                                      }
                                    },
                                  ),
                                );
                              },
                            ),
                  ),
                ],
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreateOptions(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text('No documents yet', style: AppStyles.titleTextSmall(context)),
          const SizedBox(height: 8),
          Text(
            'Create a folder or upload a document to get started',
            style: AppStyles.subtitleText(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              // If screen is too narrow, stack the buttons vertically
              if (constraints.maxWidth < 300) {
                return Column(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _showCreateFolderDialog(context),
                      icon: const Icon(Icons.create_new_folder),
                      label: const Text('New Folder'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => _handleFileUpload(),
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Upload File'),
                    ),
                  ],
                );
              } else {
                // Otherwise use the row layout
                return Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16,
                  runSpacing: 12,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _showCreateFolderDialog(context),
                      icon: const Icon(Icons.create_new_folder),
                      label: const Text('New Folder'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _handleFileUpload(),
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Upload File'),
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // Methods for document details panel have been removed as they're no longer needed

  void _showCreateOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  Icons.create_new_folder,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text('Create New Folder'),
                onTap: () {
                  Navigator.pop(context);
                  _showCreateFolderDialog(context);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.upload_file,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text('Upload File'),
                onTap: () {
                  Navigator.pop(context);
                  _handleFileUpload();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCreateFolderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return CreateFolderDialog(
          onCreateFolder: (name) {
            ref
                .read(estateDocumentsViewModelProvider.notifier)
                .createFolder(name);
          },
        );
      },
    );
  }

  void _handleFileUpload() async {
    final viewModel = ref.read(estateDocumentsViewModelProvider.notifier);

    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            CircularProgressIndicator(strokeWidth: 2),
            SizedBox(width: 16),
            Text('Selecting and uploading file...'),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );

    // Pick and upload file
    final success = await viewModel.pickAndUploadFile();

    if (success) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File uploaded successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File upload canceled or failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _confirmDelete(BuildContext context, Document document) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete ${document.type.name}?'),
          content: Text(
            'Are you sure you want to delete "${document.name}"? '
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ref
                    .read(estateDocumentsViewModelProvider.notifier)
                    .deleteDocument(document.id!);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // Permission dialog removed as it's no longer needed

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Search Documents'),
          content: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Enter search term',
              prefixIcon: Icon(Icons.search),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _searchController.clear();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                final query = _searchController.text.trim();
                if (query.isNotEmpty) {
                  ref
                      .read(estateDocumentsViewModelProvider.notifier)
                      .searchDocuments(query);
                }
                _searchController.clear();
              },
              child: const Text('Search'),
            ),
          ],
        );
      },
    );
  }

  void _showFileOptions(BuildContext context, Document document) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  Icons.download_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text('Download File'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Downloading file...')),
                  );
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.delete_outline,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: const Text('Delete File'),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(context, document);
                },
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  document.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
