import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:lonepeak/domain/models/estate.dart';
import 'package:lonepeak/utils/log_printer.dart';
import 'package:lonepeak/utils/result.dart';

final estateServiceProvider = Provider<EstateService>((ref) => EstateService());

class EstateService {
  FirebaseFirestore db = FirebaseFirestore.instance;
  final _log = Logger(printer: PrefixedLogPrinter('EstateService'));

  Future<Result<void>> createEstate(String estateId, Estate estateData) async {
    final docRef = db
        .collection('estates')
        .withConverter(
          fromFirestore: Estate.fromFirestore,
          toFirestore: (Estate estate, options) => estate.toFirestore(),
        )
        .doc(estateId);

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
    return db
        .collection('estates')
        .withConverter(
          fromFirestore: Estate.fromFirestore,
          toFirestore: (Estate estate, options) => estate.toFirestore(),
        )
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
    final docRef = db
        .collection('estates')
        .withConverter(
          fromFirestore: Estate.fromFirestore,
          toFirestore: (Estate estate, options) => estate.toFirestore(),
        )
        .doc(estateId);

    try {
      final snapshot = await docRef.get();
      if (snapshot.exists) {
        return Result.success(snapshot.data());
      } else {
        _log.w('No estate found with ID: $estateId');
        return Result.failure('No estate found with ID: $estateId');
      }
    } catch (e) {
      _log.e('Error fetching estate: $e');
      return Result.failure('Failed to fetch estate');
    }
  }

  Future<Result<void>> updateEstate(String estateId, Estate estateData) async {
    final docRef = db
        .collection('estates')
        .withConverter(
          fromFirestore: Estate.fromFirestore,
          toFirestore: (Estate estate, options) => estate.toFirestore(),
        )
        .doc(estateId);

    try {
      await docRef.update(estateData.toFirestore());
      _log.i('Estate updated successfully with ID: $estateId');
      return Result.success(null);
    } catch (e) {
      _log.e('Error updating estate: $e');
      return Result.failure('Failed to update estate');
    }
  }
}
