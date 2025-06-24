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
    
    %% UI Flow
    UserProfileScreen -->|Uses| UserProfileViewModel
    WelcomeScreen -->|Entry Point| User Journey
    
    UserProfileViewModel -->|Uses| UserSignInFeature
    
    %% Domain Layer
    UserSignInFeature -->|Uses| UsersRepository
    UserSignInFeature -->|Uses| User
    
    %% Data Layer
    UsersRepository -->|Uses| UsersService
    UsersProvider -->|Provides| UsersRepository
    
    %% External Dependencies
    UsersService -->|Stores Data| Firestore
    UserSignInFeature -->|Authenticates| FirebaseAuth
    
    %% Model Usage
    User -->|Used by| UserSignInFeature
    Role -->|Used by| User
    
    %% State Management Integration
    UserProfileViewModel -->|Updates| UI State
    UserSignInFeature -->|Updates| AppStateProvider
    UserSignInFeature -->|Updates| AuthStateProvider
    
    %% User Operations
    UserProfileScreen -->|Views| User
    UserProfileViewModel -->|Manages| User Data
    WelcomeScreen -->|Initiates| Authentication
    
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