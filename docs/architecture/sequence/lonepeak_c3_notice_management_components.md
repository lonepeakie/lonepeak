```mermaid
graph TB
    subgraph "Notice Management Components"
        subgraph "UI Layer"
            NoticesScreen[estate_notices_screen.dart<br/>Notices Screen]
            NoticeColor[notice_color.dart<br/>Notice Color Coding]
            NoticesViewModel[estate_notices_viewmodel.dart<br/>Notices State Management]
        end
        
        subgraph "Domain Layer"
            NoticeFeatures[notice_features.dart<br/>Notice Business Logic]
        end
        
        subgraph "Data Layer"
            NoticesRepository[notices_repository_firestore.dart<br/>Notices Repository]
            NoticesProvider[notices_provider.dart<br/>Notices Repository Provider]
            NoticesService[notices_service.dart<br/>Firestore Notices Service]
        end
        
        subgraph "Models"
            Notice[notice.dart<br/>Notice Model]
            NoticeType[Notice Type Enum<br/>Notice Categories]
        end
        
        subgraph "External Dependencies"
            Firestore[Firebase Firestore<br/>Notice Database]
        end
    end
    
    %% UI Flow
    NoticesScreen -->|Uses| NoticeColor
    NoticesScreen -->|Uses| NoticesViewModel
    
    NoticesViewModel -->|Uses| NoticeFeatures
    
    %% Domain Layer
    NoticeFeatures -->|Uses| NoticesRepository
    NoticeFeatures -->|Uses| Notice
    
    %% Data Layer
    NoticesRepository -->|Uses| NoticesService
    NoticesProvider -->|Provides| NoticesRepository
    
    %% External Dependencies
    NoticesService -->|Stores Data| Firestore
    
    %% Model Usage
    Notice -->|Used by| NoticeFeatures
    NoticeType -->|Used by| Notice
    
    %% State Management Integration
    NoticesViewModel -->|Updates| UI State
    NoticeFeatures -->|Uses| AppStateProvider
    
    %% Notice Operations
    NoticesScreen -->|Views| Notice
    NoticeColor -->|Styles| Notice
    NoticesViewModel -->|Manages| Notice List
    
    %% Styling
    classDef ui fill:#e3f2fd,stroke:#1565c0,stroke-width:2px
    classDef domain fill:#f3e5f5,stroke:#7b1fa2,stroke-width:2px
    classDef data fill:#e8f5e8,stroke:#388e3c,stroke-width:2px
    classDef model fill:#fff3e0,stroke:#f57c00,stroke-width:2px
    classDef external fill:#ffebee,stroke:#c62828,stroke-width:2px
    
    class NoticesScreen,NoticeColor,NoticesViewModel ui
    class NoticeFeatures domain
    class NoticesRepository,NoticesProvider,NoticesService data
    class Notice,NoticeType model
    class Firestore external
``` 