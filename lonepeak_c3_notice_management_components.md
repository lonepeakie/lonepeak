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
    
    %% Notice Management Flow Sequence
    NoticesScreen -->|1. Uses| NoticeColor
    NoticesScreen -->|2. Uses| NoticesViewModel
    
    NoticesViewModel -->|3. Uses| NoticeFeatures
    
    %% Domain Layer Flow
    NoticeFeatures -->|4. Uses| NoticesRepository
    NoticeFeatures -->|5. Uses| Notice
    
    %% Data Layer Flow
    NoticesRepository -->|6. Uses| NoticesService
    NoticesProvider -->|7. Provides| NoticesRepository
    
    %% External Dependencies Flow
    NoticesService -->|8. Stores Data| Firestore
    
    %% Model Usage
    Notice -->|9. Used by| NoticeFeatures
    NoticeType -->|10. Used by| Notice
    
    %% State Management Integration
    NoticesViewModel -->|11. Updates| UI State
    NoticeFeatures -->|12. Uses| AppStateProvider
    
    %% Notice Operations
    NoticesScreen -->|13. Views| Notice
    NoticeColor -->|14. Styles| Notice
    NoticesViewModel -->|15. Manages| Notice List
    
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