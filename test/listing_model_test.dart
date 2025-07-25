import 'package:flutter_test/flutter_test.dart';
import 'package:lonepeak/domain/models/listing.dart';

void main() {
  group('Listing Model Tests', () {
    test('should create listing with required fields', () {
      final listing = Listing(
        title: 'Test Item',
        description: 'Test description',
        price: '€100',
        contactInfo: 'test@example.com',
        category: ListingCategory.items,
        ownerId: 'user123',
        ownerName: 'John Doe',
        ownerInitials: 'JD',
        estateId: 'estate123',
      );

      expect(listing.title, 'Test Item');
      expect(listing.description, 'Test description');
      expect(listing.price, '€100');
      expect(listing.contactInfo, 'test@example.com');
      expect(listing.category, ListingCategory.items);
      expect(listing.ownerId, 'user123');
      expect(listing.ownerName, 'John Doe');
      expect(listing.ownerInitials, 'JD');
      expect(listing.estateId, 'estate123');
      expect(listing.isActive, true);
    });

    test('should generate correct initials from owner name', () {
      final listing = Listing(
        title: 'Test',
        description: 'Test',
        price: 'Free',
        contactInfo: 'test',
        category: ListingCategory.items,
        ownerId: 'user',
        ownerName: 'John Doe',
        ownerInitials: '',
        estateId: 'estate',
      );

      expect(listing.ownerInitialsFromName, 'JD');
    });

    test('should generate single initial for single name', () {
      final listing = Listing(
        title: 'Test',
        description: 'Test',
        price: 'Free',
        contactInfo: 'test',
        category: ListingCategory.items,
        ownerId: 'user',
        ownerName: 'John',
        ownerInitials: '',
        estateId: 'estate',
      );

      expect(listing.ownerInitialsFromName, 'J');
    });

    test('should handle empty name for initials', () {
      final listing = Listing(
        title: 'Test',
        description: 'Test',
        price: 'Free',
        contactInfo: 'test',
        category: ListingCategory.items,
        ownerId: 'user',
        ownerName: '',
        ownerInitials: '',
        estateId: 'estate',
      );

      expect(listing.ownerInitialsFromName, '');
    });

    test('should convert to and from firestore correctly', () {
      final listing = Listing(
        title: 'Test Item',
        description: 'Test description',
        price: '€100',
        contactInfo: 'test@example.com',
        category: ListingCategory.services,
        ownerId: 'user123',
        ownerName: 'John Doe',
        ownerInitials: 'JD',
        estateId: 'estate123',
      );

      final firestoreData = listing.toFirestore();
      
      expect(firestoreData['title'], 'Test Item');
      expect(firestoreData['description'], 'Test description');
      expect(firestoreData['price'], '€100');
      expect(firestoreData['contactInfo'], 'test@example.com');
      expect(firestoreData['category'], 'services');
      expect(firestoreData['ownerId'], 'user123');
      expect(firestoreData['ownerName'], 'John Doe');
      expect(firestoreData['ownerInitials'], 'JD');
      expect(firestoreData['estateId'], 'estate123');
      expect(firestoreData['isActive'], true);
    });

    test('should create copy with updated fields', () {
      final listing = Listing(
        title: 'Original Title',
        description: 'Original description',
        price: '€100',
        contactInfo: 'original@example.com',
        category: ListingCategory.items,
        ownerId: 'user123',
        ownerName: 'John Doe',
        ownerInitials: 'JD',
        estateId: 'estate123',
      );

      final updatedListing = listing.copyWith(
        title: 'Updated Title',
        price: '€150',
      );

      expect(updatedListing.title, 'Updated Title');
      expect(updatedListing.price, '€150');
      expect(updatedListing.description, 'Original description');
      expect(updatedListing.contactInfo, 'original@example.com');
    });
  });

  group('ListingCategory Tests', () {
    test('should return correct display names', () {
      expect(ListingCategory.services.displayName, 'Services');
      expect(ListingCategory.items.displayName, 'Items for Sale');
      expect(ListingCategory.housing.displayName, 'Housing');
      expect(ListingCategory.jobs.displayName, 'Jobs');
      expect(ListingCategory.giveaway.displayName, 'Giveaway');
    });
  });
}