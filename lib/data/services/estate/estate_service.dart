import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:lonepeak/domain/models/estate.dart';
import 'package:lonepeak/utils/log_printer.dart';
import 'package:lonepeak/utils/result.dart';

final estateServiceProvider = Provider<EstateService>((ref) => EstateService());

class EstateService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _log = Logger(printer: PrefixedLogPrinter('EstateService'));

  CollectionReference<Estate> _getEstatesCollection() {
    return _db
        .collection('estates')
        .withConverter(
          fromFirestore: Estate.fromFirestore,
          toFirestore: (Estate estate, options) => estate.toFirestore(),
        );
  }

  Future<Result<void>> createEstate(String estateId, Estate estateData) async {
    final docRef = _getEstatesCollection().doc(estateId);

    try {
      await docRef.set(estateData);
      _log.i('Estate created successfully with ID: $estateId');
      return Result.success(null);
    } catch (e) {
      _log.e('Error creating estate: $e');
      return Result.failure('Failed to create estate');
    }
  }

  Future<Result<String>> createEstateWithAutoId(Estate estateData) {
    return _getEstatesCollection()
        .add(estateData)
        .then((docRef) async {
          _log.i('Estate created successfully with ID: ${docRef.id}');
          return Result.success(docRef.id);
        })
        .catchError((error) {
          _log.e('Error creating estate: $error');
          return Result<String>.failure('Failed to create estate: $error');
        });
  }

  Future<Result<Estate>> getEstate(String estateId) async {
    final docRef = _getEstatesCollection().doc(estateId);

    try {
      final snapshot = await docRef.get();
      if (snapshot.exists) {
        return Result.success(snapshot.data()!);
      } else {
        _log.w('No estate found with ID: $estateId');
        return Result.failure('No estate found with ID: $estateId');
      }
    } catch (e) {
      _log.e('Error fetching estate: $e');
      return Result.failure('Failed to fetch estate');
    }
  }

  Future<Result<List<Estate>>> getPublicEstates() async {
    try {
      final querySnapshot = await _getEstatesCollection().get();

      final estates = querySnapshot.docs.map((doc) => doc.data()).toList();

      return Result.success(estates);
    } catch (e) {
      _log.e('Error fetching public estates: $e');
      return Result.failure('Failed to fetch available estates');
    }
  }

  Future<Result<void>> updateEstate(String estateId, Estate estateData) async {
    final docRef = _getEstatesCollection().doc(estateId);

    try {
      await docRef.update(estateData.toFirestore());
      _log.i('Estate updated successfully with ID: $estateId');
      return Result.success(null);
    } catch (e) {
      _log.e('Error updating estate: $e');
      return Result.failure('Failed to update estate');
    }
  }

  Future<Result<void>> deleteEstate(String estateId) async {
    final docRef = _getEstatesCollection().doc(estateId);

    try {
      await docRef.delete();
      _log.i('Estate deleted successfully with ID: $estateId');
      return Result.success(null);
    } catch (e) {
      _log.e('Error deleting estate: $e');
      return Result.failure('Failed to delete estate');
    }
  }
}
