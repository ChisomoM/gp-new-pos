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
  /// Some endpoints send `status` as a legacy int (`0`/`1`) while others
  /// (e.g. auth failures like `{"status": "failed"}`) send it as a string,
  /// so it's normalized to an int before handing off to the generated
  /// parser to avoid a type-cast crash.
  static NetResponse fromJson(JsonMap json) {
    final rawStatus = json['status'];
    final normalized = Map<String, dynamic>.from(json);
    if (rawStatus is String) {
      normalized['status'] = int.tryParse(rawStatus);
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
