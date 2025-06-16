// lib/ui/user_profile/widgets/user_profile_screen_args.dart (Corrected)

// FIX: Import the REAL Estate model from your domain/models directory.
import 'package:lonepeak/domain/models/estate.dart';
import 'package:lonepeak/domain/models/user.dart';

// This class acts as a package to hold all the data the profile screen needs.
// It now correctly uses the single, official 'User' and 'Estate' models.
class UserProfileScreenArgs {
  final User user;
  final Estate estate;

  UserProfileScreenArgs({required this.user, required this.estate});
}

// FIX: The duplicate placeholder 'class Estate' has been completely removed from this file.
