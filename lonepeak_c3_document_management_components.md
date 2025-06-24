```mermaid
graph TB
    subgraph "Document Management Components"
        subgraph "UI Layer"
            DocumentsScreen[estate_documents_screen.dart<br/>Documents Screen]
            DocumentDetails[document_details.dart<br/>Document Details]
            CreateFolderDialog[create_folder_dialog.dart<br/>Create Folder Dialog]
            DocumentBreadcrumbs[document_breadcrumbs.dart<br/>Navigation Breadcrumbs]
            DocumentsViewModel[estate_documents_viewmodel.dart<br/>Documents State Management]
        end
        
        subgraph "Domain Layer"
            DocumentFeatures[document_features.dart<br/>Document Business Logic]
        end
        
        subgraph "Data Layer"
            DocumentsRepository[documents_repository_firestore.dart<br/>Documents Repository]
            DocumentsProvider[documents_provider.dart<br/>Documents Repository Provider]
            DocumentsService[documents_service.dart<br/>Firestore Documents Service]
        end
        
        subgraph "Models"
            Document[document.dart<br/>Document Model]
            DocumentType[Document Type Enum<br/>File Types]
        end
        
        subgraph "External Dependencies"
            Firestore[Firebase Firestore<br/>Document Database]
            FirebaseStorage[Firebase Storage<br/>File Storage]
            FilePicker[File Picker<br/>File Selection]
        end
    end
    
    %% Document Management Flow Sequence
    DocumentsScreen -->|1. Uses| DocumentDetails
    DocumentsScreen -->|2. Uses| CreateFolderDialog
    DocumentsScreen -->|3. Uses| DocumentBreadcrumbs
    DocumentsScreen -->|4. Uses| DocumentsViewModel
    
    DocumentsViewModel -->|5. Uses| DocumentFeatures
    
    %% Domain Layer Flow
    DocumentFeatures -->|6. Uses| DocumentsRepository
    DocumentFeatures -->|7. Uses| Document
    
    %% Data Layer Flow
    DocumentsRepository -->|8. Uses| DocumentsService
    DocumentsProvider -->|9. Provides| DocumentsRepository
    
    %% External Dependencies Flow
    DocumentsService -->|10. Stores Files| FirebaseStorage
    DocumentsService -->|11. Stores Metadata| Firestore
    DocumentsViewModel -->|12. Picks Files| FilePicker
    
    %% Model Usage
    Document -->|13. Used by| DocumentFeatures
    DocumentType -->|14. Used by| Document
    
    %% State Management Integration
    DocumentsViewModel -->|15. Updates| UI State
    DocumentFeatures -->|16. Uses| AppStateProvider
    
    %% File Operations
    CreateFolderDialog -->|17. Creates| Document
    DocumentDetails -->|18. Views| Document
    DocumentBreadcrumbs -->|19. Navigates| Document
    
    %% Styling
    classDef ui fill:#e3f2fd,stroke:#1565c0,stroke-width:2px
    classDef domain fill:#f3e5f5,stroke:#7b1fa2,stroke-width:2px
    classDef data fill:#e8f5e8,stroke:#388e3c,stroke-width:2px
    classDef model fill:#fff3e0,stroke:#f57c00,stroke-width:2px
    classDef external fill:#ffebee,stroke:#c62828,stroke-width:2px
    
    class DocumentsScreen,DocumentDetails,CreateFolderDialog,DocumentBreadcrumbs,DocumentsViewModel ui
    class DocumentFeatures domain
    class DocumentsRepository,DocumentsProvider,DocumentsService data
    class Document,DocumentType model
    class Firestore,FirebaseStorage,FilePicker external
``` 