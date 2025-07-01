import 'package:flutter_test/flutter_test.dart';
import 'package:lonepeak/domain/models/listing.dart';

void main() {
  group('Listing Model Tests', () {
    test('should create a listing with all required fields', () {
      final listing = Listing(
        title: 'Test Item',
        description: 'A test item for sale',
        category: ListingCategory.forSale,
        price: '€150',
        ownerId: 'user123',
        ownerName: 'John Doe',
        ownerInitials: 'JD',
        createdAt: DateTime.now(),
      );

      expect(listing.title, 'Test Item');
      expect(listing.description, 'A test item for sale');
      expect(listing.category, ListingCategory.forSale);
      expect(listing.price, '€150');
      expect(listing.ownerId, 'user123');
      expect(listing.ownerName, 'John Doe');
      expect(listing.ownerInitials, 'JD');
      expect(listing.imageUrl, isNull);
    });

    test('should handle copyWith correctly', () {
      final original = Listing(
        title: 'Original Title',
        description: 'Original description',
        category: ListingCategory.forSale,
        price: '€100',
        ownerId: 'user1',
        ownerName: 'User One',
        ownerInitials: 'UO',
        createdAt: DateTime.now(),
      );

      final updated = original.copyWith(
        title: 'Updated Title',
        price: '€200',
      );

      expect(updated.title, 'Updated Title');
      expect(updated.price, '€200');
      expect(updated.description, original.description);
      expect(updated.category, original.category);
    });

    test('should convert to/from Firestore correctly', () {
      final listing = Listing(
        id: 'listing123',
        title: 'Test Item',
        description: 'A test item',
        category: ListingCategory.lending,
        price: 'Free',
        ownerId: 'user123',
        ownerName: 'John Doe',
        ownerInitials: 'JD',
        createdAt: DateTime(2024, 1, 1),
        imageUrl: 'https://example.com/image.jpg',
      );

      final firestoreData = listing.toFirestore();

      expect(firestoreData['title'], 'Test Item');
      expect(firestoreData['description'], 'A test item');
      expect(firestoreData['category'], 'lending');
      expect(firestoreData['price'], 'Free');
      expect(firestoreData['ownerId'], 'user123');
      expect(firestoreData['ownerName'], 'John Doe');
      expect(firestoreData['ownerInitials'], 'JD');
      expect(firestoreData['imageUrl'], 'https://example.com/image.jpg');
      expect(firestoreData.containsKey('createdAt'), true);
    });

    test('should handle enum categories correctly', () {
      expect(ListingCategory.forSale.name, 'forSale');
      expect(ListingCategory.lending.name, 'lending');
      expect(ListingCategory.carpool.name, 'carpool');
      expect(ListingCategory.services.name, 'services');

      expect(ListingCategoryExtension.fromName('forsale'), ListingCategory.forSale);
      expect(ListingCategoryExtension.fromName('lending'), ListingCategory.lending);
      expect(ListingCategoryExtension.fromName('carpool'), ListingCategory.carpool);
      expect(ListingCategoryExtension.fromName('services'), ListingCategory.services);
    });

    test('should throw error for invalid category', () {
      expect(
        () => ListingCategoryExtension.fromName('invalid'),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}