import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';

class AuthService extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _currentUsername;
  bool _isLoading = true;
  
  // In a real app, this would be a secure database
  // For demo purposes, we'll use SharedPreferences
  final Map<String, UserProfile> _users = {};

  AuthService() {
    _loadAuthState();
  }

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get currentUsername => _currentUsername;
  
  UserProfile? get currentUser => 
      _currentUsername != null ? _users[_currentUsername] : null;
      
  String? get userBio => currentUser?.bio;
  
  DateTime? get userCreatedAt => currentUser?.createdAt;

  Future<void> _loadAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load saved users
      final usersJson = prefs.getString('users');
      if (usersJson != null) {
        final usersMap = json.decode(usersJson) as Map<String, dynamic>;
        usersMap.forEach((key, value) {
          _users[key] = UserProfile.fromJson(value);
        });
      }

      // Create demo account if it doesn't exist
      if (!_users.containsKey('demo')) {
        _users['demo'] = UserProfile(
          username: 'demo',
          email: 'demo@example.com',
          passwordHash: _hashPassword('password'),
          createdAt: DateTime.now(),
          displayName: 'Demo User',
          bio: 'This is a demo account for testing the app',
        );
        await _saveUsers();
      }
      
      // Check if user is logged in
      _currentUsername = prefs.getString('currentUser');
      _isAuthenticated = _currentUsername != null;
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading auth state: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String username, String email, String password) async {
    if (_users.containsKey(username)) {
      return false; // Username already exists
    }

    // Create new user
    final newUser = UserProfile(
      username: username,
      email: email,
      passwordHash: _hashPassword(password),
      createdAt: DateTime.now(),
    );
    
    _users[username] = newUser;
    
    // Save to storage
    await _saveUsers();
    
    // Auto login after registration
    return await login(username, password);
  }

  Future<bool> login(String username, String password) async {
    if (!_users.containsKey(username)) {
      return false; // User doesn't exist
    }

    final user = _users[username]!;
    final passwordHash = _hashPassword(password);
    
    if (user.passwordHash != passwordHash) {
      return false; // Incorrect password
    }

    // Set as current user
    _currentUsername = username;
    _isAuthenticated = true;
    
    // Save current user to storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentUser', username);
    
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _currentUsername = null;
    _isAuthenticated = false;
    
    // Remove current user from storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('currentUser');
    
    notifyListeners();
  }

  Future<void> updateProfile({String? username, String? bio}) async {
    if (_currentUsername == null) return;
    
    // Update user profile
    final currentProfile = _users[_currentUsername]!;
    _users[_currentUsername!] = UserProfile(
      username: currentProfile.username,
      email: currentProfile.email,
      passwordHash: currentProfile.passwordHash,
      createdAt: currentProfile.createdAt,
      displayName: username ?? currentProfile.displayName,
      bio: bio ?? currentProfile.bio,
      profileImageUrl: currentProfile.profileImageUrl,
      preferences: currentProfile.preferences,
    );
    
    // Save to storage
    await _saveUsers();
    
    notifyListeners();
  }

  Future<void> _saveUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final usersMap = {};
      _users.forEach((key, value) {
        usersMap[key] = value.toJson();
      });
      
      await prefs.setString('users', json.encode(usersMap));
    } catch (e) {
      debugPrint('Error saving users: $e');
    }
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}

class UserProfile {
  final String username;
  final String email;
  final String passwordHash;
  final DateTime createdAt;
  final String? displayName;
  final String? bio;
  final String? profileImageUrl;
  final Map<String, dynamic>? preferences;

  UserProfile({
    required this.username,
    required this.email,
    required this.passwordHash,
    required this.createdAt,
    this.displayName,
    this.bio,
    this.profileImageUrl,
    this.preferences,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      username: json['username'],
      email: json['email'],
      passwordHash: json['passwordHash'],
      createdAt: DateTime.parse(json['createdAt']),
      displayName: json['displayName'],
      bio: json['bio'],
      profileImageUrl: json['profileImageUrl'],
      preferences: json['preferences'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'passwordHash': passwordHash,
      'createdAt': createdAt.toIso8601String(),
      'displayName': displayName,
      'bio': bio,
      'profileImageUrl': profileImageUrl,
      'preferences': preferences,
    };
  }
}
