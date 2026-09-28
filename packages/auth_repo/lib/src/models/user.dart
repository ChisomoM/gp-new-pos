// ignore_for_file: public_member_api_docs

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User extends Equatable {
  const User({
    required this.id,
    required this.avatar,
    required this.name,
    required this.accountType,
    required this.email,
    required this.phone,
    required this.isGmailIdUser,
    required this.isAppleIdUser,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  /// Hand-written rather than delegating to the generated [_$UserFromJson]:
  /// that generator reads camelCase keys (`accountType`, `createdAt`, ...),
  /// but every other endpoint in `pos_mobile_app_endpoints.md` returns
  /// snake_case JSON (`account_type`, `merchant_id`, `created_at`, ...), and
  /// the login response's user record's exact field names are undocumented
  /// (`"user": { "...user record..." }`). This reads both casings and falls
  /// back across the common shapes a user's display name is sent under, so
  /// the cashier's name still resolves even if the record uses
  /// `full_name`/`first_name`+`last_name` instead of a flat `name`.
  factory User.fromJson(Map<String, dynamic> json) {
    String? asString(dynamic v) {
      if (v == null) return null;
      final s = v.toString().trim();
      return s.isEmpty ? null : s;
    }
    final firstName = asString(json['first_name'] ?? json['firstName']);
    final lastName = asString(json['last_name'] ?? json['lastName']);
    final combinedName = [
      if (firstName != null) firstName,
      if (lastName != null) lastName,
    ].join(' ');
    final name = asString(json['name']) ??
        asString(json['full_name'] ?? json['fullName']) ??
        (combinedName.isNotEmpty ? combinedName : null) ??
        asString(json['username']) ??
        '';
    return User(
      id: asString(json['id']) ?? '',
      avatar: asString(json['avatar']) ?? '',
      name: name,
      accountType: asString(json['account_type'] ?? json['accountType']) ??
          '',
      email: asString(json['email']) ?? '',
      phone: asString(json['phone'] ?? json['phone_number']) ?? '',
      isGmailIdUser:
          (json['is_gmail_id_user'] ?? json['isGmailIdUser']) as bool? ??
              false,
      isAppleIdUser:
          (json['is_apple_id_user'] ?? json['isAppleIdUser']) as bool? ??
              false,
      createdAt: DateTime.tryParse(
        asString(json['created_at'] ?? json['createdAt']) ?? '',
      ),
      updatedAt: DateTime.tryParse(
        asString(json['updated_at'] ?? json['updatedAt']) ?? '',
      ),
      deletedAt: asString(json['deleted_at'] ?? json['deletedAt']) ?? '',
    );
  }

  factory User.fromDbJson(Map<String, dynamic> json) => _$UserFromDbJson(json);

  final String? id;
  final String? avatar;
  final String? name;
  final String? accountType;
  final String? email;
  final String? phone;
  final bool? isGmailIdUser;
  final bool? isAppleIdUser;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? deletedAt;

  /// Empty user instance
  static const empty = User(
    id: '',
    avatar: '',
    name: '',
    accountType: '',
    email: '',
    phone: '',
    deletedAt: '',
    isGmailIdUser: false,
    isAppleIdUser: false,
    createdAt: null,
    updatedAt: null,
  );

  User copyWith({
    String? id,
    String? avatar,
    String? name,
    String? accountType,
    String? email,
    String? phone,
    bool? isGmailIdUser,
    bool? isAppleIdUser,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? deletedAt,
  }) {
    return User(
      id: id ?? this.id ?? '',
      avatar: avatar ?? this.avatar ?? '',
      name: name ?? this.name ?? '',
      accountType: accountType ?? this.accountType ?? '',
      email: email ?? this.email ?? '',
      phone: phone ?? this.phone ?? '',
      isGmailIdUser: isGmailIdUser ?? this.isGmailIdUser ?? false,
      isAppleIdUser: isAppleIdUser ?? this.isAppleIdUser ?? false,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt ?? '',
    );
  }

  Map<String, dynamic> toJson() => _$UserToJson(this);

  ///installing in db
  Map<String, dynamic> toJsonDb() => _$UserToJsonDb(this);

  @override
  String toString() {
    return '''$id, $avatar, $name, $accountType, $email, $phone, $isGmailIdUser, $isAppleIdUser, $createdAt, $updatedAt, $deletedAt''';
  }

  @override
  List<Object?> get props => [
        id,
        avatar,
        name,
        accountType,
        email,
        phone,
        isGmailIdUser,
        isAppleIdUser,
        createdAt,
        updatedAt,
        deletedAt,
      ];
}

Map<String, dynamic> _$UserToJsonDb(User instance) => <String, dynamic>{
      'id': instance.id,
      'avatar': instance.avatar,
      'name': instance.name,
      'accountType': instance.accountType,
      'email': instance.email,
      'phone': instance.phone,
      'isGmailIdUser': instance.isGmailIdUser ?? false ? 1 : 0,
      'isAppleIdUser': instance.isAppleIdUser ?? false ? 1 : 0,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'deletedAt': instance.deletedAt,
    };

User _$UserFromDbJson(Map<String, dynamic> json) => User(
      id: json['id'] as String? ?? '',
      avatar: json['avatar'] as String? ?? '',
      name: json['name'] as String? ?? '',
      accountType: json['accountType'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      isGmailIdUser: json['isGmailIdUser'] == 1,
      isAppleIdUser: json['isAppleIdUser'] == 1,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      deletedAt: json['deletedAt'] as String? ?? '',
    );
