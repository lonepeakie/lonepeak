```mermaid
graph TB
    subgraph "Treasury Management Components"
        subgraph "UI Layer"
            TreasuryScreen[estate_treasury_screen.dart<br/>Treasury Screen]
            TransactionCard[transaction_card.dart<br/>Transaction Display Card]
            TreasuryViewModel[treasury_viewmodel.dart<br/>Treasury State Management]
        end
        
        subgraph "Domain Layer"
            TreasuryFeatures[treasury_features.dart<br/>Treasury Business Logic]
        end
        
        subgraph "Data Layer"
            TreasuryRepository[treasury_repository_firestore.dart<br/>Treasury Repository]
            TreasuryProvider[treasury_provider.dart<br/>Treasury Repository Provider]
            TreasuryService[treasury_service.dart<br/>Firestore Treasury Service]
        end
        
        subgraph "Models"
            TreasuryTransaction[treasury_transaction.dart<br/>Transaction Model]
            TransactionType[Transaction Type Enum<br/>Income/Expense]
        end
        
        subgraph "External Dependencies"
            Firestore[Firebase Firestore<br/>Transaction Database]
        end
    end
    
    %% Treasury Management Flow Sequence
    TreasuryScreen -->|1. Uses| TransactionCard
    TreasuryScreen -->|2. Uses| TreasuryViewModel
    
    TreasuryViewModel -->|3. Uses| TreasuryFeatures
    
    %% Domain Layer Flow
    TreasuryFeatures -->|4. Uses| TreasuryRepository
    TreasuryFeatures -->|5. Uses| TreasuryTransaction
    
    %% Data Layer Flow
    TreasuryRepository -->|6. Uses| TreasuryService
    TreasuryProvider -->|7. Provides| TreasuryRepository
    
    %% External Dependencies Flow
    TreasuryService -->|8. Stores Data| Firestore
    
    %% Model Usage
    TreasuryTransaction -->|9. Used by| TreasuryFeatures
    TransactionType -->|10. Used by| TreasuryTransaction
    
    %% State Management Integration
    TreasuryViewModel -->|11. Updates| UI State
    TreasuryFeatures -->|12. Uses| AppStateProvider
    
    %% Transaction Operations
    TreasuryScreen -->|13. Views| TreasuryTransaction
    TransactionCard -->|14. Displays| TreasuryTransaction
    TreasuryViewModel -->|15. Calculates| Summary
    
    %% Styling
    classDef ui fill:#e3f2fd,stroke:#1565c0,stroke-width:2px
    classDef domain fill:#f3e5f5,stroke:#7b1fa2,stroke-width:2px
    classDef data fill:#e8f5e8,stroke:#388e3c,stroke-width:2px
    classDef model fill:#fff3e0,stroke:#f57c00,stroke-width:2px
    classDef external fill:#ffebee,stroke:#c62828,stroke-width:2px
    
    class TreasuryScreen,TransactionCard,TreasuryViewModel ui
    class TreasuryFeatures domain
    class TreasuryRepository,TreasuryProvider,TreasuryService data
    class TreasuryTransaction,TransactionType model
    class Firestore external
``` 