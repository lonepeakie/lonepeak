import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/domain/models/document.dart';
import 'package:lonepeak/ui/core/themes/themes.dart';
import 'package:lonepeak/ui/core/ui_state.dart';
import 'package:lonepeak/ui/core/widgets/appbar_title.dart';
import 'package:lonepeak/ui/estate_documents/view_models/estate_documents_viewmodel.dart';
import 'package:lonepeak/ui/estate_documents/widgets/create_folder_dialog.dart';
import 'package:lonepeak/ui/estate_documents/widgets/document_breadcrumbs.dart';
import 'package:lonepeak/ui/estate_documents/widgets/document_details.dart';
import 'package:lonepeak/ui/estate_documents/widgets/document_permissions_dialog.dart';
import 'package:lonepeak/ui/estate_documents/widgets/document_tile.dart';

class EstateDocumentsScreen extends ConsumerStatefulWidget {
  const EstateDocumentsScreen({Key? key}) : super(key: key);

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
    final selectedDocument = viewModel.selectedDocument;
    final breadcrumbs = viewModel.breadcrumbs;
    final theme = Theme.of(context);

    // Check for screen width to adjust layout
    final screenWidth = MediaQuery.of(context).size.width;
    final isNarrow = screenWidth < 700;
    final useStack =
        screenWidth < 500; // For very narrow screens, use stacked layout

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
              : useStack && selectedDocument != null
              // For very narrow screens, show only details when a document is selected
              ? _buildFullScreenDetails(selectedDocument)
              : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Documents list(left side)
                  Expanded(
                    flex: isNarrow ? 3 : 2,
                    child: Column(
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
                                        padding: const EdgeInsets.only(
                                          bottom: 8.0,
                                        ),
                                        child: DocumentTile(
                                          document: document,
                                          isSelected:
                                              selectedDocument?.id ==
                                              document.id,
                                          onTap: () {
                                            if (document.type ==
                                                DocumentType.folder) {
                                              viewModel.navigateToFolder(
                                                document,
                                              );
                                            } else {
                                              viewModel.selectDocument(
                                                document,
                                              );
                                            }
                                          },
                                        ),
                                      );
                                    },
                                  ),
                        ),
                      ],
                    ),
                  ),

                  // Divider
                  Container(width: 1, color: theme.colorScheme.outlineVariant),

                  // Details panel (right side)
                  Expanded(
                    flex: isNarrow ? 2 : 1,
                    child: FractionallySizedBox(
                      widthFactor:
                          0.95, // Prevents overflow by using 95% of available width
                      child:
                          selectedDocument != null
                              ? _buildDetailsPanel(selectedDocument)
                              : _buildEmptyDetailsPanel(),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: () => _showCreateFolderDialog(context),
                icon: const Icon(Icons.create_new_folder),
                label: const Text('New Folder'),
              ),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed: () => _handleFileUpload(),
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload File'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsPanel(Document document) {
    final viewModel = ref.read(estateDocumentsViewModelProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    viewModel.clearSelection();
                  },
                ),
              ],
            ),
            DocumentDetails(
              document: document,
              onEdit: () => _showPermissionsDialog(context, document),
              onDelete: () => _confirmDelete(context, document),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyDetailsPanel() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No document selected',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select a document to view details',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Full screen details view for narrow screens
  Widget _buildFullScreenDetails(Document document) {
    final viewModel = ref.read(estateDocumentsViewModelProvider.notifier);

    return Column(
      children: [
        // Back button and document name
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => viewModel.clearSelection(),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  document.name,
                  style: AppStyles.titleTextSmall(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),

        // Document details
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: DocumentDetails(
              document: document,
              onEdit: () => _showPermissionsDialog(context, document),
              onDelete: () => _confirmDelete(context, document),
            ),
          ),
        ),
      ],
    );
  }

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
          onCreateFolder: (name, description) {
            ref
                .read(estateDocumentsViewModelProvider.notifier)
                .createFolder(name, description);
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('File uploaded successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('File upload canceled or failed'),
          backgroundColor: Colors.red,
        ),
      );
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

  void _showPermissionsDialog(BuildContext context, Document document) {
    showDialog(
      context: context,
      builder: (context) {
        return DocumentPermissionsDialog(
          document: document,
          onSave: (permissions) {
            ref
                .read(estateDocumentsViewModelProvider.notifier)
                .updateDocumentPermissions(document.id!, permissions);
          },
        );
      },
    );
  }

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
}
