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
    
    %% UI Flow
    EstateHomeScreen -->|Uses| EstateHomeViewModel
    EstateCreateScreen -->|Uses| EstateCreateViewModel
    EstateJoinScreen -->|Uses| EstateJoinViewModel
    EstateSelectScreen -->|Uses| EstateSelectViewModel
    EstateDashboardScreen -->|Uses| EstateDashboardViewModel
    
    EstateHomeViewModel -->|Uses| EstateFeatures
    EstateCreateViewModel -->|Uses| EstateFeatures
    EstateJoinViewModel -->|Uses| EstateFeatures
    EstateSelectViewModel -->|Uses| EstateFeatures
    EstateDashboardViewModel -->|Uses| EstateFeatures
    
    %% Domain Layer
    EstateFeatures -->|Uses| EstateRepository
    EstateFeatures -->|Uses| MembersRepository
    EstateFeatures -->|Uses| Estate
    EstateFeatures -->|Uses| Member
    EstateFeatures -->|Uses| Role
    
    %% Data Layer
    EstateRepository -->|Uses| EstateService
    EstateProvider -->|Provides| EstateRepository
    MembersRepository -->|Uses| MembersService
    MembersProvider -->|Provides| MembersRepository
    
    %% External Dependencies
    EstateService -->|Stores Data| Firestore
    MembersService -->|Stores Data| Firestore
    
    %% Model Usage
    Estate -->|Used by| EstateFeatures
    Member -->|Used by| EstateFeatures
    Role -->|Used by| Member
    Metadata -->|Used by| Estate
    
    %% State Management Integration
    EstateHomeViewModel -->|Updates| UI State
    EstateCreateViewModel -->|Updates| UI State
    EstateJoinViewModel -->|Updates| UI State
    EstateSelectViewModel -->|Updates| UI State
    EstateDashboardViewModel -->|Updates| UI State
    
    EstateFeatures -->|Updates| AppStateProvider
    
    %% Estate Operations
    EstateCreateScreen -->|Creates| Estate
    EstateJoinScreen -->|Joins| Estate
    EstateSelectScreen -->|Selects| Estate
    EstateHomeScreen -->|Views| Estate
    
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