import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/domain/models/service.dart';
import 'package:lonepeak/utils/result.dart';

final marketplaceServiceProvider = Provider<MarketplaceService>(
  (ref) => MarketplaceService(FirebaseFirestore.instance),
);

class MarketplaceService {
  final FirebaseFirestore _db;
  late final CollectionReference<Service> _servicesCollection;

  MarketplaceService(this._db) {
    _servicesCollection = _db
        .collection('services')
        .withConverter<Service>(
          fromFirestore: (snapshot, _) => Service.fromFirestore(snapshot),
          toFirestore: (service, _) => service.toFirestore(),
        );
  }

  Future<Result<void>> addService(Service service) async {
    try {
      await _servicesCollection.doc().set(service);
      return Result.success(null);
    } catch (e) {
      return Result.failure('Failed to add service.');
    }
  }

  Future<Result<List<Service>>> getServices({
    required String estateId,
    String? category,
  }) async {
    try {
      Query<Service> query = _servicesCollection.where(
        'estateId',
        isEqualTo: estateId,
      );

      if (category != null && category != 'All') {
        query = query.where('category', isEqualTo: category);
      }

      final snapshot = await query.orderBy('createdAt', descending: true).get();
      final services = snapshot.docs.map((doc) => doc.data()).toList();
      return Result.success(services);
    } catch (e) {
      return Result.failure('Failed to fetch services.');
    }
  }
}
