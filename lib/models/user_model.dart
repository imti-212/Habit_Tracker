class UserModel {
  final String id;
  final String displayName;
  final String email;
  final String? gender;
  final DateTime? dateOfBirth;
  final double? height;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.displayName,
    required this.email,
    this.gender,
    this.dateOfBirth,
    this.height,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      displayName: map['displayName'] ?? '',
      email: map['email'] ?? '',
      gender: map['gender'],
      dateOfBirth: map['dateOfBirth'] != null 
          ? DateTime.parse(map['dateOfBirth']) 
          : null,
      height: map['height']?.toDouble(),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'email': email,
      'gender': gender,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'height': height,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? displayName,
    String? email,
    String? gender,
    DateTime? dateOfBirth,
    double? height,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      height: height ?? this.height,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
