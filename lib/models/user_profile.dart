import 'package:flutter/material.dart';

enum UserRole {
  student,
  mentor,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.student:
        return 'Student';
      case UserRole.mentor:
        return 'Mentor';
    }
  }

  String get description {
    switch (this) {
      case UserRole.student:
        return 'Track moods, journal with AI insights, meditate, and connect with peers.';
      case UserRole.mentor:
        return 'Create support groups, share resources, and guide students on their wellness journey.';
    }
  }

  IconData get icon {
    switch (this) {
      case UserRole.student:
        return Icons.school_rounded;
      case UserRole.mentor:
        return Icons.volunteer_activism_rounded;
    }
  }
}

class UserProfile {
  final String uid;
  final String displayName;
  final String email;
  final String avatarUrl;
  final String school;
  final UserRole role;
  final DateTime createdAt;
  final DateTime? lastActiveAt;
  final bool isOnline;
  final List<String> joinedGroups;
  final Map<String, dynamic> preferences;

  UserProfile({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.avatarUrl,
    required this.school,
    required this.role,
    required this.createdAt,
    this.lastActiveAt,
    this.isOnline = false,
    this.joinedGroups = const [],
    this.preferences = const {},
  });

  UserProfile copyWith({
    String? uid,
    String? displayName,
    String? email,
    String? avatarUrl,
    String? school,
    UserRole? role,
    DateTime? createdAt,
    DateTime? lastActiveAt,
    bool? isOnline,
    List<String>? joinedGroups,
    Map<String, dynamic>? preferences,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      school: school ?? this.school,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      isOnline: isOnline ?? this.isOnline,
      joinedGroups: joinedGroups ?? this.joinedGroups,
      preferences: preferences ?? this.preferences,
    );
  }

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'displayName': displayName,
        'email': email,
        'avatarUrl': avatarUrl,
        'school': school,
        'role': role.name,
        'createdAt': createdAt.toIso8601String(),
        'lastActiveAt': lastActiveAt?.toIso8601String(),
        'isOnline': isOnline,
        'joinedGroups': joinedGroups,
        'preferences': preferences,
      };

  factory UserProfile.fromMap(Map<String, dynamic> map) => UserProfile(
        uid: map['uid'] as String,
        displayName: map['displayName'] as String,
        email: map['email'] as String,
        avatarUrl: map['avatarUrl'] as String,
        school: map['school'] as String,
        role: UserRole.values.firstWhere(
          (e) => e.name == map['role'],
          orElse: () => UserRole.student,
        ),
        createdAt: DateTime.parse(map['createdAt'] as String),
        lastActiveAt: map['lastActiveAt'] != null 
            ? DateTime.parse(map['lastActiveAt'] as String) 
            : null,
        isOnline: map['isOnline'] as bool? ?? false,
        joinedGroups: List<String>.from(map['joinedGroups'] ?? []),
        preferences: Map<String, dynamic>.from(map['preferences'] ?? {}),
      );
}



