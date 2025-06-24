```mermaid
graph TB
    subgraph "App Core Components"
        subgraph "Main Entry Point"
            Main[main.dart<br/>App Initialization]
            FirebaseConfig[firebase_options.dart<br/>Firebase Configuration]
        end
        
        subgraph "State Management"
            AppStateProvider[app_state_provider.dart<br/>Global App State]
            AuthStateProvider[auth_state_provider.dart<br/>Authentication State]
            SecureStorage[FlutterSecureStorage<br/>Device Storage]
        end
        
        subgraph "Navigation"
            Router[router.dart<br/>GoRouter Configuration]
            Routes[routes.dart<br/>Route Definitions]
        end
        
        subgraph "UI Core"
            Themes[themes.dart<br/>App Themes & Colors]
            UIState[ui_state.dart<br/>UI State Management]
            AppButtons[app_buttons.dart<br/>Common Buttons]
            AppInputs[app_inputs.dart<br/>Common Inputs]
        end
        
        subgraph "Utilities"
            LogPrinter[log_printer.dart<br/>Logging Utility]
            Result[result.dart<br/>Result Pattern]
        end
    end
    
    %% Relationships
    Main -->|1. Initialize| FirebaseConfig
    Main -->|2. Setup| AppStateProvider
    Main -->|3. Setup| AuthStateProvider
    Main -->|4. Configure| Router
    
    AppStateProvider -->|Uses| SecureStorage
    AuthStateProvider -->|Depends on| AppStateProvider
    
    Router -->|Uses| Routes
    Router -->|Watches| AuthStateProvider
    Router -->|Reads| AppStateProvider
    
    %% UI Dependencies
    Themes -->|Provides| UIState
    UIState -->|Uses| Result
    AppButtons -->|Uses| Themes
    AppInputs -->|Uses| Themes
    
    %% Utility Usage
    LogPrinter -->|Used by| All Components
    Result -->|Used by| All Components
    
    %% Styling
    classDef core fill:#e1f5fe,stroke:#01579b,stroke-width:2px
    classDef state fill:#f3e5f5,stroke:#4a148c,stroke-width:2px
    classDef nav fill:#e8f5e8,stroke:#1b5e20,stroke-width:2px
    classDef ui fill:#fff3e0,stroke:#e65100,stroke-width:2px
    classDef util fill:#fce4ec,stroke:#880e4f,stroke-width:2px
    
    class Main,FirebaseConfig core
    class AppStateProvider,AuthStateProvider,SecureStorage state
    class Router,Routes nav
    class Themes,UIState,AppButtons,AppInputs ui
    class LogPrinter,Result util
``` 