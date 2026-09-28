import 'package:net_source/src/models/models.dart';

part 'net_response.g.dart';

/// A data object used to parse network responses from our API
class NetResponse {
  /// {@macro net_response}
  const NetResponse({
    this.message,
    this.data,
    this.status,
    this.success,
  });

  /// The data returned from the network request
  final dynamic data;

  /// A message describing the status of the response
  final String? message;

  /// an int status, 0 for success, 1 for failure (legacy backend convention)
  final int? status;

  /// a bool success flag, as returned by the Geepay gateway/services
  /// (`{"success": true/false, "message", "data"}`)
  final bool? success;

  /// Deserializes the given [JsonMap] into a [NetResponse].
  ///
  /// Some endpoints send `status` as a legacy int (`0`/`1`), some send a
  /// numeric string (`"0"`/`"1"`), and some (e.g. `GET /transactions/list`,
  /// which sends `{"status": "success", ...}` with no `success` boolean at
  /// all) send a word describing the outcome instead. `int.tryParse` only
  /// handles the numeric-string case and silently returns null for a word
  /// like `"success"`, which [isSuccessful] then reads as failure — so
  /// words are mapped to the legacy 0/1 convention here before handing off
  /// to the generated parser.
  static NetResponse fromJson(JsonMap json) {
    final rawStatus = json['status'];
    final normalized = Map<String, dynamic>.from(json);
    if (rawStatus is String) {
      final asInt = int.tryParse(rawStatus);
      if (asInt != null) {
        normalized['status'] = asInt;
      } else {
        const successWords = {'success', 'successful', 'ok', 'completed'};
        const failureWords = {'failed', 'failure', 'error'};
        final word = rawStatus.toLowerCase();
        if (successWords.contains(word)) {
          normalized['status'] = 0;
        } else if (failureWords.contains(word)) {
          normalized['status'] = 1;
        } else {
          normalized['status'] = null;
        }
      }
    }
    return _$NetResponseFromJson(normalized);
  }

  /// Check whether network request was successful.
  ///
  /// Prefers the Geepay `success` bool when present, falling back to the
  /// legacy `status == 0` convention for responses that don't send one.
  bool isSuccessful() {
    return success ?? (status == 0);
  }
}
