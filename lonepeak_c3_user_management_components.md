```mermaid
graph TB
    subgraph "User Management Components"
        subgraph "UI Layer"
            UserProfileScreen[user_profile_screen.dart<br/>User Profile Screen]
            UserProfileViewModel[user_profile_viewmodel.dart<br/>Profile State Management]
            WelcomeScreen[welcome_screen.dart<br/>Welcome Screen]
        end
        
        subgraph "Domain Layer"
            UserSignInFeature[user_sigin_feature.dart<br/>User Authentication Logic]
        end
        
        subgraph "Data Layer"
            UsersRepository[users_repository_firebase.dart<br/>Users Repository]
            UsersProvider[users_provider.dart<br/>Users Repository Provider]
            UsersService[users_service.dart<br/>Firebase Users Service]
        end
        
        subgraph "Models"
            User[user.dart<br/>User Model]
            Role[role.dart<br/>Role Model]
        end
        
        subgraph "External Dependencies"
            Firestore[Firebase Firestore<br/>User Database]
            FirebaseAuth[Firebase Auth<br/>Authentication]
        end
    end
    
    %% User Management Flow Sequence
    UserProfileScreen -->|1. Uses| UserProfileViewModel
    WelcomeScreen -->|2. Entry Point| User Journey
    
    UserProfileViewModel -->|3. Uses| UserSignInFeature
    
    %% Domain Layer Flow
    UserSignInFeature -->|4. Uses| UsersRepository
    UserSignInFeature -->|5. Uses| User
    
    %% Data Layer Flow
    UsersRepository -->|6. Uses| UsersService
    UsersProvider -->|7. Provides| UsersRepository
    
    %% External Dependencies Flow
    UsersService -->|8. Stores Data| Firestore
    UserSignInFeature -->|9. Authenticates| FirebaseAuth
    
    %% Model Usage
    User -->|10. Used by| UserSignInFeature
    Role -->|11. Used by| User
    
    %% State Management Integration
    UserProfileViewModel -->|12. Updates| UI State
    UserSignInFeature -->|13. Updates| AppStateProvider
    UserSignInFeature -->|14. Updates| AuthStateProvider
    
    %% User Operations
    UserProfileScreen -->|15. Views| User
    UserProfileViewModel -->|16. Manages| User Data
    WelcomeScreen -->|17. Initiates| Authentication
    
    %% Styling
    classDef ui fill:#e3f2fd,stroke:#1565c0,stroke-width:2px
    classDef domain fill:#f3e5f5,stroke:#7b1fa2,stroke-width:2px
    classDef data fill:#e8f5e8,stroke:#388e3c,stroke-width:2px
    classDef model fill:#fff3e0,stroke:#f57c00,stroke-width:2px
    classDef external fill:#ffebee,stroke:#c62828,stroke-width:2px
    
    class UserProfileScreen,UserProfileViewModel,WelcomeScreen ui
    class UserSignInFeature domain
    class UsersRepository,UsersProvider,UsersService data
    class User,Role model
    class Firestore,FirebaseAuth external
``` 