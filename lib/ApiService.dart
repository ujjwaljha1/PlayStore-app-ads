

// import 'package:http/http.dart' as http;
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'dart:convert';

// class ApiService {
//   static const String baseUrl = 'https://testing-ads-production.up.railway.app';
//   static const storage = FlutterSecureStorage();

//   static Future<String?> getToken() async {
//     return await storage.read(key: 'token');
//   }

//   static void _handleError(http.Response response) {
//     if (response.statusCode == 401) {
//       throw Exception('Unauthorized access');
//     } else if (response.statusCode == 404) {
//       throw Exception('Resource not found');
//     } else if (response.statusCode >= 500) {
//       throw Exception('Server error occurred');
//     } else {
//       try {
//         final errorData = jsonDecode(response.body);
//         throw Exception(errorData['message'] ?? 'Unknown error occurred');
//       } catch (e) {
//         throw Exception('Failed with status code: ${response.statusCode}');
//       }
//     }
//   }

//   static Future<Map<String, dynamic>> getUserProfile() async {
//     final token = await getToken();
//     if (token == null) throw Exception('No token found');

//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/api/user/profile'),
//         headers: {'Authorization': 'Bearer $token'},
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         await storage.write(key: 'user_data', value: response.body);
//         return data;
//       } else {
//         final cached = await storage.read(key: 'user_data');
//         if (cached != null) {
//           return jsonDecode(cached);
//         }
//         _handleError(response);
//         return {};
//       }
//     } catch (e) {
//       final cached = await storage.read(key: 'user_data');
//       if (cached != null) {
//         return jsonDecode(cached);
//       }
//       rethrow;
//     }
//   }

//   static Future<List<Map<String, dynamic>>> getNotifications() async {
//     final token = await getToken();
//     if (token == null) throw Exception('No token found');

//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/api/notifications'),
//         headers: {'Authorization': 'Bearer $token'},
//       );

//       if (response.statusCode == 200) {
//         final data = response.body;
//         await storage.write(key: 'notifications_data', value: data);
//         List<dynamic> notificationsData = jsonDecode(data);
//         return notificationsData.map((item) => Map<String, dynamic>.from(item)).toList();
//       } else {
//         _handleError(response);
//         return [];
//       }
//     } catch (e) {
//       rethrow;
//     }
//   }

//   static Future<Map<String, dynamic>> claimVideoReward() async {
//     final token = await getToken();
//     if (token == null) throw Exception('No token found');

//     try {
//       // First update the video watch count
//       final watchResponse = await http.post(
//         Uri.parse('$baseUrl/api/tasks/watch-video'),
//         headers: {'Authorization': 'Bearer $token'},
//       );

//       if (watchResponse.statusCode == 200) {
//         final data = jsonDecode(watchResponse.body);
//         return {
//           'coins': data['coins'],
//           'reward': data['reward'],
//           'videosWatched': data['videosWatched']
//         };
//       } else {
//         _handleError(watchResponse);
//         return {};
//       }
//     } catch (e) {
//       rethrow;
//     }
//   }

//   static Future<List<Map<String, dynamic>>> getLeaderboard() async {
//     try {
//       final response = await http.get(Uri.parse('$baseUrl/api/leaderboard'));

//       if (response.statusCode == 200) {
//         List<dynamic> leaderboardData = jsonDecode(response.body);
//         return leaderboardData.map((item) => Map<String, dynamic>.from(item)).toList();
//       } else {
//         _handleError(response);
//         return [];
//       }
//     } catch (e) {
//       rethrow;
//     }
//   }
// }

import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'https://testing-ads-production.up.railway.app';
  static const storage = FlutterSecureStorage();

  static Future<String?> getToken() async {
    return await storage.read(key: 'token');
  }

  static void _handleError(http.Response response) {
    if (response.statusCode == 401) {
      throw Exception('Unauthorized access');
    } else if (response.statusCode == 404) {
      throw Exception('Resource not found');
    } else if (response.statusCode >= 500) {
      throw Exception('Server error occurred');
    } else {
      try {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? errorData['error'] ?? 'Unknown error occurred');
      } catch (e) {
        throw Exception('Failed with status code: ${response.statusCode}');
      }
    }
  }

  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
    required String username,
    String? referralCode,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.trim(),
          'password': password,
          'name': name.trim(),
          'username': username.trim(),
          if (referralCode?.isNotEmpty ?? false) 'referralCode': referralCode!.trim(),
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        await storage.write(key: 'token', value: data['token']);
        await storage.write(key: 'user_data', value: jsonEncode(data['user']));
        return data;
      } else {
        _handleError(response);
        return {};
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.trim(),
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await storage.write(key: 'token', value: data['token']);
        await storage.write(key: 'user_data', value: jsonEncode(data['user']));
        return data;
      } else {
        _handleError(response);
        return {};
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> logout() async {
    await storage.delete(key: 'token');
    await storage.delete(key: 'user_data');
    await storage.deleteAll(); // Clean up all stored data
  }

  static Future<Map<String, dynamic>> getUserProfile() async {
    final token = await getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/user/profile'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await storage.write(key: 'user_data', value: response.body);
        return data;
      } else {
        final cached = await storage.read(key: 'user_data');
        if (cached != null) {
          return jsonDecode(cached);
        }
        _handleError(response);
        return {};
      }
    } catch (e) {
      final cached = await storage.read(key: 'user_data');
      if (cached != null) {
        return jsonDecode(cached);
      }
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getNotifications() async {
    final token = await getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/notifications'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = response.body;
        await storage.write(key: 'notifications_data', value: data);
        List<dynamic> notificationsData = jsonDecode(data);
        return notificationsData.map((item) => Map<String, dynamic>.from(item)).toList();
      } else {
        _handleError(response);
        return [];
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> claimVideoReward() async {
    final token = await getToken();
    if (token == null) throw Exception('No token found');

    try {
      final watchResponse = await http.post(
        Uri.parse('$baseUrl/api/tasks/watch-video'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (watchResponse.statusCode == 200) {
        final data = jsonDecode(watchResponse.body);
        return {
          'coins': data['coins'],
          'reward': data['reward'],
          'videosWatched': data['videosWatched']
        };
      } else {
        _handleError(watchResponse);
        return {};
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getLeaderboard() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/leaderboard'));

      if (response.statusCode == 200) {
        List<dynamic> leaderboardData = jsonDecode(response.body);
        return leaderboardData.map((item) => Map<String, dynamic>.from(item)).toList();
      } else {
        _handleError(response);
        return [];
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getTaskProgress() async {
    final token = await getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/tasks/progress'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        _handleError(response);
        return {};
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? username,
    String? email,
    String? currentPassword,
    String? newPassword,
  }) async {
    final token = await getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/user/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          if (name != null) 'name': name.trim(),
          if (username != null) 'username': username.trim(),
          if (email != null) 'email': email.trim(),
          if (currentPassword != null) 'currentPassword': currentPassword,
          if (newPassword != null) 'newPassword': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await storage.write(key: 'user_data', value: jsonEncode(data));
        return data;
      } else {
        _handleError(response);
        return {};
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<bool> markNotificationAsRead(String notificationId) async {
    final token = await getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/notifications/$notificationId/read'),
        headers: {'Authorization': 'Bearer $token'},
      );

      return response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getReferralStats() async {
    final token = await getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/user/referrals'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        _handleError(response);
        return {};
      }
    } catch (e) {
      rethrow;
    }
  }
}