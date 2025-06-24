```mermaid
classDiagram
    %% Domain Models
    class Document {
        +String? id
        +String name
        +String? description
        +DocumentType type
        +String? fileUrl
        +String parentId
        +String? thumbnailUrl
        +int size
        +Metadata? metadata
        +Document.folder()
        +Document.fromFirestore()
        +Map toFirestore()
    }

    class DocumentType {
        <<enumeration>>
        pdf
        image
        word
        excel
        folder
        other
    }

    class Metadata {
        +Timestamp createdAt
        +String? createdBy
        +Timestamp updatedAt
        +String? updatedBy
        +Metadata.fromJson()
        +Map toJson()
    }

    class Result~T~ {
        <<generic>>
        +bool isSuccess
        +bool isFailure
        +T? data
        +String? error
        +Result.success()
        +Result.failure()
    }

    %% Repository Layer
    class DocumentsRepository {
        <<interface>>
        +getDocuments(parentId?)
        +getDocumentById(id)
        +addDocument(document)
        +updateDocument(document)
        +deleteDocument(id)
        +createFolder(name, parentId)
        +searchDocuments(query)
        +uploadFile(file, fileName, type, description?, parentId?)
    }

    class DocumentsRepositoryFirestore {
        -DocumentsService _documentsService
        -AppState _appState
        +getDocuments(parentId?)
        +getDocumentById(id)
        +addDocument(document)
        +updateDocument(document)
        +deleteDocument(id)
        +createFolder(name, parentId)
        +searchDocuments(query)
        +uploadFile(file, fileName, type, description?, parentId?)
    }

    %% Service Layer
    class DocumentsService {
        -FirebaseFirestore _db
        -Logger _log
        +addDocument(estateId, document)
        +getDocuments(estateId, parentId?)
        +getDocumentById(estateId, id)
        +updateDocument(estateId, document)
        +deleteDocument(estateId, id)
        +searchDocuments(estateId, query)
        +uploadFile(estateId, fileName, file, type, parentId)
        -_getContentType(type, fileName)
    }

    %% Domain Features
    class DocumentFeatures {
        -DocumentsRepository _documentsRepository
        +DocumentFeatures(documentsRepository, appState)
        +getDocuments(parentId?)
        +getDocumentById(id)
        +createFolder(name, parentId)
        +addDocument(document)
        +updateDocument(document)
        +deleteDocument(id)
        +searchDocuments(query)
        +uploadFile(file, fileName, type, description?, parentId?)
    }

    %% App State Management
    class AppState {
        -AuthRepository _authRepository
        -UsersRepository _usersRepository
        -FlutterSecureStorage _secureStorage
        -String? _estateId
        -String? _userRole
        +getEstateId()
        +setEstateId(estateId)
        +clearEstateId()
        +getUserId()
        +getUserRole()
        +setUserRole(role)
        +clearUserRole()
    }

    %% Providers
    class documentFeaturesProvider {
        <<provider>>
        +Provider~DocumentFeatures~
    }

    class documentsRepositoryProvider {
        <<provider>>
        +Provider~DocumentsRepository~
    }

    class documentsServiceProvider {
        <<provider>>
        +Provider~DocumentsService~
    }

    class appStateProvider {
        <<provider>>
        +Provider~AppState~
    }

    %% View Models
    class EstateDocumentsViewModel {
        -DocumentFeatures _documentFeatures
        -List~Document~ _documents
        -String? _currentFolderId
        -List~Document~ _breadcrumbs
        -Document? _selectedDocument
        +loadDocuments(folderId?)
        +navigateToFolder(folder)
        +createFolder(name)
        +uploadDocument(document)
        +deleteDocument(documentId)
        +searchDocuments(query)
        +pickAndUploadFile()
    }

    %% UI State
    class UIState {
        <<abstract>>
    }

    class UIStateInitial {
        +extends UIState
    }

    class UIStateLoading {
        +extends UIState
    }

    class UIStateSuccess {
        +extends UIState
    }

    class UIStateFailure {
        +extends UIState
        +String error
    }

    %% Relationships
    DocumentFeatures --> DocumentsRepository : uses
    DocumentFeatures --> AppState : uses
    DocumentsRepositoryFirestore ..|> DocumentsRepository : implements
    DocumentsRepositoryFirestore --> DocumentsService : uses
    DocumentsRepositoryFirestore --> AppState : uses
    DocumentsService --> Document : creates/updates
    Document --> Metadata : contains
    Document --> DocumentType : has

    %% Provider Dependencies
    documentFeaturesProvider --> documentsRepositoryProvider : depends on
    documentFeaturesProvider --> appStateProvider : depends on
    documentsRepositoryProvider --> documentsServiceProvider : depends on
    documentsRepositoryProvider --> appStateProvider : depends on

    %% View Model Dependencies
    EstateDocumentsViewModel --> DocumentFeatures : uses
    EstateDocumentsViewModel --> UIState : manages

    %% UI State Hierarchy
    UIStateInitial --|> UIState
    UIStateLoading --|> UIState
    UIStateSuccess --|> UIState
    UIStateFailure --|> UIState

    %% Result Pattern
    DocumentFeatures --> Result~List~Document~~ : returns
    DocumentFeatures --> Result~Document~ : returns
    DocumentFeatures --> Result~void~ : returns
    DocumentsRepository --> Result~List~Document~~ : returns
    DocumentsRepository --> Result~Document~ : returns
    DocumentsRepository --> Result~void~ : returns
    DocumentsService --> Result~List~Document~~ : returns
    DocumentsService --> Result~Document~ : returns
    DocumentsService --> Result~void~ : returns
    DocumentsService --> Result~Map~String, dynamic~~ : returns

    %% File Operations
    DocumentsService --> File : handles
    DocumentFeatures --> File : validates
} 