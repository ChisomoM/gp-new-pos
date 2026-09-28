import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:local_data/local_data.dart';
import 'package:net_source/net_source.dart';

import 'package:services_repo/src/firebase_crud.dart';

/// {@template services_repo}
/// Repo for application services
/// {@endtemplate}
class ServicesRepo {
  /// {@macro services_repo}
  ServicesRepo({
    required SharedPrefs prefs,
    // ignore: avoid_unused_constructor_parameters
    required LocalData db,
    required NetSource net,
    FirebaseFirestore? firestore,
  })  : _prefs = prefs,
        _net = net,
        _firebaseCrud = firestore != null
            ? FirebaseCrudService(firestore: firestore)
            : null;

  // Shared preferences keys
  final String _keyId = 'user_id';
  // final String _keyToken = 'token';

  // final String _keyCurrentToken = 'services_token';

  final NetSource _net;
  final SharedPrefs _prefs;
  final FirebaseCrudService? _firebaseCrud;

  final _authController = StreamController<int>.broadcast();

  /// App auth state to indicate when a user session has expired
  Stream<int> get authState async* {
    yield 0;
    yield* _authController.stream;
  }

  /// Firebase CRUD service, if enabled.
  FirebaseCrudService? get firebaseCrud => _firebaseCrud;

  /// Fetches POS transactions (`GET /transactions/list`) — used by both the
  /// Dashboard's "Today's collections" summary (pass [todayOnly]: true) and
  /// the Transaction History screen (pass a [status] filter, no date
  /// range).
  Future<OpStatus> getTransactions({
    String? posDeviceId,
    String? status,
    bool todayOnly = false,
    int page = 1,
    int pageSize = 100,
  }) async {
    try {
      final today = DateTime.now();
      final dateStr = '${today.year.toString().padLeft(4, '0')}-'
          '${today.month.toString().padLeft(2, '0')}-'
          '${today.day.toString().padLeft(2, '0')}';
      final response = await _net.get('transactions/list', null, {
        'page': page,
        'page_size': pageSize,
        'is_from_pos': true,
        if (posDeviceId != null) 'pos_device_id': posDeviceId,
        if (status != null) 'status': status,
        if (todayOnly) 'start_date': dateStr,
        if (todayOnly) 'end_date': dateStr,
      });
      return OpStatus.fromResponse(response);
    } catch (e) {
      return OpStatus.unexpected(e.toString());
    }
  }

  /// Fetches a single transaction (`GET /transactions/get/:id`) for the
  /// Transaction Details screen.
  Future<OpStatus> getTransactionDetails(String id) async {
    try {
      final response = await _net.get('transactions/get/$id');
      return OpStatus.fromResponse(response);
    } catch (e) {
      return OpStatus.unexpected(e.toString());
    }
  }

  /// Looks up the account name behind a mobile money number
  /// (`GET /api/name-lookup/:phone`, session-token route).
  Future<OpStatus> nameLookup(String phone) async {
    try {
      final response = await _net.get('name-lookup/$phone');
      return OpStatus.fromResponse(response);
    } catch (e) {
      return OpStatus.unexpected(e.toString());
    }
  }

  /// Requests a mobile-money collection (`POST /api/mobile-money/collect`,
  /// session-token route). [transactionRef] must be unique per request and
  /// is sent as the `X-Transaction-Ref` header, not the body.
  Future<OpStatus> collect({
    required String phoneNumber,
    required double amount,
    required String transactionRef,
    String? branchId,
    String? posDeviceId,
    String? userId,
  }) async {
    try {
      final response = await _net.post(
        'mobile-money/collect',
        {
          'phone_number': phoneNumber,
          'amount': amount,
          if (branchId != null) 'branch_id': branchId,
          if (posDeviceId != null) 'pos_device_id': posDeviceId,
          if (userId != null) 'user_id': userId,
        },
        {'X-Transaction-Ref': transactionRef},
      );
      return OpStatus.fromResponse(response);
    } catch (e) {
      return OpStatus.unexpected(e.toString());
    }
  }

  /// Polls a collection's outcome
  /// (`GET /api/mobile-money/check-status/:transaction_ref`, session-token
  /// route).
  Future<OpStatus> checkCollectionStatus(String transactionRef) async {
    try {
      final response = await _net.get(
        'mobile-money/check-status/$transactionRef',
      );
      return OpStatus.fromResponse(response);
    } catch (e) {
      return OpStatus.unexpected(e.toString());
    }
  }

  ///getting providers review
  Future<OpStatus> getPlansReviews() async {
    try {
      final id = await _prefs.getString(_keyId);
      final response = await _net.get('plans/reviews/$id');
      if (response.isSuccessful()) {
        log('GOT PLANS VIEWS FROM API: ${response.data}');
        final rawData = response.data;
        log('Response Type: ${rawData.runtimeType}');
      }
      return OpStatus.fromResponse(response);
    } catch (e) {
      return OpStatus.unexpected(e.toString());
    }
  }
}
