```mermaid
classDiagram

%% === UI LAYER ===
class MemberTile {
  +String name
  +String? email
  +String role
  +EdgeInsetsGeometry? padding
  +VoidCallback? onTap
  +build()
}
class AppbarActionButton {
  +IconData icon
  +VoidCallback onPressed
  +build()
}
class AppChip {
  +String label
  +Color color
  +build()
}
class AppElevatedButton {
  +VoidCallback onPressed
  +String buttonText
  +EdgeInsetsGeometry? padding
  +Color? backgroundColor
  +build()
}
class AppTextInput {
  +TextEditingController controller
  +String labelText
  +String hintText
  +int? maxLines
  +bool required
  +String? errorText
  +String? Function(String?)? validator
  +TextInputType? keyboardType
  +createState()
}
class AppDatePicker {
  +TextEditingController controller
  +String labelText
  +String hintText
  +bool required
  +String? errorText
  +TextInputType? keyboardType
  +createState()
}
class AppDropdown~T~ {
  +String labelText
  +T? initialValue
  +List~DropdownItem<T>~ items
  +void Function(T?) onChanged
  +String? Function(T?)? validator
  +bool required
  +String? errorText
  +build()
}
class AppbarTitle {
  +String text
  +build()
}

%% === DOMAIN LAYER ===
class User {
  +String displayName
  +String email
  +String? mobile
  +String? photoUrl
  +String? estateId
  +Metadata? metadata
  +fromFirestore()
  +fromFirebaseUser()
  +copyWith()
  +copyWithEmptyEstateId()
}
class Member {
  +String email
  +String displayName
  +RoleType role
  +MemberStatus status
  +Metadata? metadata
  +copyWith()
  +fromFirestore()
  +toFirestore()
}
class Role {
  +String type
  +List~Permission~ permissions
  +fromFirestore()
  +toFirestore()
}
class Permission {
  +String name
  +bool hasAccess
  +fromJson()
  +toJson()
}
class Metadata {
  +String? createdBy
  +String? updatedBy
  +Timestamp? createdAt
  +Timestamp? updatedAt
  +fromJson()
  +toJson()
}
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
  +fromFirestore()
  +toFirestore()
  +folder()
}
class Notice {
  +String? id
  +String title
  +String message
  +NoticeType type
  +List~String~ likedBy
  +Metadata? metadata
  +fromFirestore()
  +toFirestore()
  +copyWith()
  +likesCount
}
class TreasuryTransaction {
  +String? id
  +String title
  +TransactionType type
  +double amount
  +DateTime date
  +String? description
  +bool isIncome
  +Metadata? metadata
  +fromFirestore()
  +toFirestore()
}

%% === DATA LAYER ===
class TreasuryRepository {
  <<interface>>
  +getTransactions()
  +getTransactionById()
  +addTransaction()
  +updateTransaction()
  +deleteTransaction()
  +getCurrentBalance()
  +getTransactionSummaryByType()
}
class TreasuryRepositoryFirestore {
  +addTransaction()
  +deleteTransaction()
  +getTransactionById()
  +getTransactions()
  +updateTransaction()
  +getCurrentBalance()
  +getTransactionSummaryByType()
}
class TreasuryService {
  +getTransactions()
  +getTransactionById()
  +addTransaction()
  +updateTransaction()
  +deleteTransaction()
  +getCurrentBalance()
  +getTransactionSummaryByType()
}

%% === UTILS LAYER ===
class Result~T~ {
  +T? data
  +String? error
  +isSuccess
  +isFailure
}

%% === DEPENDENCIES ===
%% UI depends on Domain
MemberTile --> Member
AppbarActionButton ..> VoidCallback
AppChip ..> String
AppElevatedButton ..> VoidCallback
AppTextInput ..> TextEditingController
AppDatePicker ..> TextEditingController
AppDropdown~T~ ..> DropdownItem~T~

%% Domain relationships
User --> Metadata
Member --> Metadata
Member --> RoleType
Member --> MemberStatus
Role --> Permission
Document --> Metadata
Document --> DocumentType
Notice --> Metadata
Notice --> NoticeType
TreasuryTransaction --> Metadata
TreasuryTransaction --> TransactionType

%% Data depends on Domain and Utils
TreasuryRepository <|-- TreasuryRepositoryFirestore
TreasuryRepositoryFirestore --> TreasuryService
TreasuryRepositoryFirestore --> Metadata
TreasuryRepositoryFirestore --> TreasuryTransaction
TreasuryService --> TreasuryTransaction
TreasuryService --> Result~T~

%% UI may use Result~T~ for state/result handling