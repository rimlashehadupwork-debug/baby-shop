class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role;
  final List<dynamic> deliveryAddresses;
  final List<dynamic> paymentMethods;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.role = 'user',
    this.deliveryAddresses = const [],
    this.paymentMethods = const [],
  });

  /// Factory constructor to create a [UserModel] from a Map/Firestore document.
  factory UserModel.fromMap(Map<String, dynamic> map, {String? uid}) {
    return UserModel(
      uid: uid ?? map['uid'] as String? ?? '',
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      role: map['role'] as String? ?? 'user',
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
    List<dynamic>? deliveryAddresses,
    List<dynamic>? paymentMethods,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      deliveryAddresses: deliveryAddresses ?? this.deliveryAddresses,
      paymentMethods: paymentMethods ?? this.paymentMethods,
    );
  }
}
