class Permissions {
  static const membersRead = 'members:read';
  static const membersWrite = 'members:write';
  static const membersDelete = 'members:delete';
  static const membersAdmin = 'members:admin';

  static const documentsRead = 'documents:read';
  static const documentsWrite = 'documents:write';
  static const documentsDelete = 'documents:delete';

  static const treasuryRead = 'treasury:read';
  static const treasuryWrite = 'treasury:write';
  static const treasuryReports = 'treasury:reports';

  static const estateRead = 'estate:read';
  static const estateWrite = 'estate:write';
  static const estateAdmin = 'estate:admin';

  static const noticesRead = 'notices:read';
  static const noticesWrite = 'notices:write';
  static const noticesDelete = 'notices:delete';
}

class PermissionGroups {
  static const memberManagement = [
    Permissions.membersRead,
    Permissions.membersWrite,
    Permissions.membersDelete,
  ];

  static const documentManagement = [
    Permissions.documentsRead,
    Permissions.documentsWrite,
    Permissions.documentsDelete,
  ];

  static const treasuryManagement = [
    Permissions.treasuryRead,
    Permissions.treasuryWrite,
    Permissions.treasuryReports,
  ];

  static const fullAccess = [
    ...memberManagement,
    ...documentManagement,
    ...treasuryManagement,
    Permissions.membersAdmin,
    Permissions.estateAdmin,
    Permissions.noticesWrite,
  ];

  static const readOnlyAccess = [
    Permissions.membersRead,
    Permissions.documentsRead,
    Permissions.treasuryRead,
    Permissions.estateRead,
    Permissions.noticesRead,
  ];
}

