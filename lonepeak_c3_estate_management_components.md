```mermaid
graph TB
    subgraph "Estate Management Components"
        subgraph "UI Layer"
            EstateHomeScreen[estate_home_screen.dart<br/>Estate Home Screen]
            EstateCreateScreen[estate_create_screen.dart<br/>Estate Creation Screen]
            EstateJoinScreen[estate_join_screen.dart<br/>Estate Join Screen]
            EstateSelectScreen[estate_select_screen.dart<br/>Estate Selection Screen]
            EstateDashboardScreen[estate_dashboard_screen.dart<br/>Estate Dashboard]
            
            EstateHomeViewModel[estate_home_viewmodel.dart<br/>Home State Management]
            EstateCreateViewModel[estate_create_viewmodel.dart<br/>Creation State Management]
            EstateJoinViewModel[estate_join_viewmodel.dart<br/>Join State Management]
            EstateSelectViewModel[estate_select_viewmodel.dart<br/>Selection State Management]
            EstateDashboardViewModel[estate_dashboard_viewmodel.dart<br/>Dashboard State Management]
        end
        
        subgraph "Domain Layer"
            EstateFeatures[estate_features.dart<br/>Estate Business Logic]
        end
        
        subgraph "Data Layer"
            EstateRepository[estate_repository_firebase.dart<br/>Estate Repository]
            EstateProvider[estate_provider.dart<br/>Estate Repository Provider]
            EstateService[estate_service.dart<br/>Firestore Estate Service]
            
            MembersRepository[members_repository_firestore.dart<br/>Members Repository]
            MembersProvider[members_provider.dart<br/>Members Repository Provider]
            MembersService[members_service.dart<br/>Firestore Members Service]
        end
        
        subgraph "Models"
            Estate[estate.dart<br/>Estate Model]
            Member[member.dart<br/>Member Model]
            Role[role.dart<br/>Role Model]
            Metadata[metadata.dart<br/>Metadata Model]
        end
        
        subgraph "External Dependencies"
            Firestore[Firebase Firestore<br/>Estate Database]
        end
    end
    
    %% Estate Management Flow Sequence
    EstateHomeScreen -->|1. Uses| EstateHomeViewModel
    EstateCreateScreen -->|2. Uses| EstateCreateViewModel
    EstateJoinScreen -->|3. Uses| EstateJoinViewModel
    EstateSelectScreen -->|4. Uses| EstateSelectViewModel
    EstateDashboardScreen -->|5. Uses| EstateDashboardViewModel
    
    EstateHomeViewModel -->|6. Uses| EstateFeatures
    EstateCreateViewModel -->|7. Uses| EstateFeatures
    EstateJoinViewModel -->|8. Uses| EstateFeatures
    EstateSelectViewModel -->|9. Uses| EstateFeatures
    EstateDashboardViewModel -->|10. Uses| EstateFeatures
    
    %% Domain Layer Flow
    EstateFeatures -->|11. Uses| EstateRepository
    EstateFeatures -->|12. Uses| MembersRepository
    EstateFeatures -->|13. Uses| Estate
    EstateFeatures -->|14. Uses| Member
    EstateFeatures -->|15. Uses| Role
    
    %% Data Layer Flow
    EstateRepository -->|16. Uses| EstateService
    EstateProvider -->|17. Provides| EstateRepository
    MembersRepository -->|18. Uses| MembersService
    MembersProvider -->|19. Provides| MembersRepository
    
    %% External Dependencies Flow
    EstateService -->|20. Stores Data| Firestore
    MembersService -->|21. Stores Data| Firestore
    
    %% Model Usage
    Estate -->|22. Used by| EstateFeatures
    Member -->|23. Used by| EstateFeatures
    Role -->|24. Used by| Member
    Metadata -->|25. Used by| Estate
    
    %% State Management Integration
    EstateHomeViewModel -->|26. Updates| UI State
    EstateCreateViewModel -->|27. Updates| UI State
    EstateJoinViewModel -->|28. Updates| UI State
    EstateSelectViewModel -->|29. Updates| UI State
    EstateDashboardViewModel -->|30. Updates| UI State
    
    EstateFeatures -->|31. Updates| AppStateProvider
    
    %% Estate Operations
    EstateCreateScreen -->|32. Creates| Estate
    EstateJoinScreen -->|33. Joins| Estate
    EstateSelectScreen -->|34. Selects| Estate
    EstateHomeScreen -->|35. Views| Estate
    
    %% Styling
    classDef ui fill:#e3f2fd,stroke:#1565c0,stroke-width:2px
    classDef domain fill:#f3e5f5,stroke:#7b1fa2,stroke-width:2px
    classDef data fill:#e8f5e8,stroke:#388e3c,stroke-width:2px
    classDef model fill:#fff3e0,stroke:#f57c00,stroke-width:2px
    classDef external fill:#ffebee,stroke:#c62828,stroke-width:2px
    
    class EstateHomeScreen,EstateCreateScreen,EstateJoinScreen,EstateSelectScreen,EstateDashboardScreen,EstateHomeViewModel,EstateCreateViewModel,EstateJoinViewModel,EstateSelectViewModel,EstateDashboardViewModel ui
    class EstateFeatures domain
    class EstateRepository,EstateProvider,EstateService,MembersRepository,MembersProvider,MembersService data
    class Estate,Member,Role,Metadata model
    class Firestore external
``` 