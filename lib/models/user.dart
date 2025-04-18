enum UserRole {
  user,
  admin,
}

class AppUser {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final DateTime createdAt;
  final List<String> fcmTokens;
  
  AppUser({
    required this.id,
    required this.name,
    required this.email, 
    required this.role,
    required this.createdAt,
    this.fcmTokens = const [],
  });
  
  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role.toString().split('.').last,
      'createdAt': createdAt,
      'fcmTokens': fcmTokens,
    };
  }
  
  // Create from Firestore document
  factory AppUser.fromMap(String id, Map<String, dynamic> map) {
    return AppUser(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] == 'admin' ? UserRole.admin : UserRole.user,
      createdAt: (map['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
      fcmTokens: List<String>.from(map['fcmTokens'] ?? []),
    );
  }
  
  // Check if user is admin
  bool get isAdmin => role == UserRole.admin;
  
  // Create a copy with updated fields
  AppUser copyWith({
    String? name,
    String? email,
    UserRole? role,
    DateTime? createdAt,
    List<String>? fcmTokens,
  }) {
    return AppUser(
      id: this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      fcmTokens: fcmTokens ?? this.fcmTokens,
    );
  }
}