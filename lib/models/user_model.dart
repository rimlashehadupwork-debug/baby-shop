class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role;
  final String accountStatus; // 'active' | 'suspended'
  final bool isCustomVerified;
  final String createdAt;
  final List<Map<String, dynamic>> activityLog;
  final List<dynamic> deliveryAddresses;
  final List<dynamic> paymentMethods;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.role = 'user',
    this.accountStatus = 'active',
    this.isCustomVerified = false,
    this.createdAt = '',
    this.activityLog = const [],
    this.deliveryAddresses = const [],
    this.paymentMethods = const [],
  });

  bool get isSuspended => accountStatus.toLowerCase() == 'suspended';
  bool get isActive => accountStatus.toLowerCase() == 'active';

  /// Factory constructor to create a [UserModel] from a Map/Firestore document.
  factory UserModel.fromMap(Map<String, dynamic> map, {String? uid}) {
    List<Map<String, dynamic>> parsedLog = [];
    if (map['activityLog'] is List) {
      for (final item in map['activityLog'] as List) {
        if (item is Map) {
          parsedLog.add(Map<String, dynamic>.from(item));
        }
      }
    }

    return UserModel(
      uid: uid ?? map['uid'] as String? ?? '',
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      role: map['role'] as String? ?? 'user',
      accountStatus: (map['accountStatus'] ?? map['status'] ?? 'active').toString(),
      isCustomVerified: map['isCustomVerified'] == true || map['emailVerified'] == true,
      createdAt: (map['createdAt'] ?? '').toString(),
      activityLog: parsedLog,
      deliveryAddresses: map['deliveryAddresses'] is List
          ? List<dynamic>.from(map['deliveryAddresses'] as List)
          : [],
      paymentMethods: map['paymentMethods'] is List
          ? List<dynamic>.from(map['paymentMethods'] as List)
          : [],
    );
  }

  /// Converts this [UserModel] instance into a Map representation.
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'accountStatus': accountStatus,
      'isCustomVerified': isCustomVerified,
      'createdAt': createdAt,
      'activityLog': activityLog,
      'deliveryAddresses': deliveryAddresses,
      'paymentMethods': paymentMethods,
    };
  }

  /// Creates a copy of this [UserModel] with updated fields.
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? role,
    String? accountStatus,
    bool? isCustomVerified,
    String? createdAt,
    List<Map<String, dynamic>>? activityLog,
    List<dynamic>? deliveryAddresses,
    List<dynamic>? paymentMethods,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      accountStatus: accountStatus ?? this.accountStatus,
      isCustomVerified: isCustomVerified ?? this.isCustomVerified,
      createdAt: createdAt ?? this.createdAt,
      activityLog: activityLog ?? this.activityLog,
      deliveryAddresses: deliveryAddresses ?? this.deliveryAddresses,
      paymentMethods: paymentMethods ?? this.paymentMethods,
    );
  }
}
