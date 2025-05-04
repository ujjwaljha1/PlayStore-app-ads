// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'dart:async';
// import 'dart:convert';
// import 'auth_screen.dart';

// class TasksScreen extends StatefulWidget {
//   final String referralCode;
//   final Function(int)? onCoinsUpdated;

//   const TasksScreen({
//     Key? key,
//     required this.referralCode,
//     this.onCoinsUpdated,
//   }) : super(key: key);

//   @override
//   State<TasksScreen> createState() => _TasksScreenState();
// }

// class _TasksScreenState extends State<TasksScreen> {
//   Map<String, dynamic>? _taskProgress;
//   String _timeUntilReset = '';
//   Timer? _timer;
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadTaskProgress();
//     _startTimer();
//   }

//   void _startTimer() {
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       _updateTimeUntilReset();
//     });
//   }

//   void _updateTimeUntilReset() {
//     if (_taskProgress == null || _taskProgress!['nextResetTime'] == null) return;

//     final nextReset = DateTime.parse(_taskProgress!['nextResetTime']);
//     final now = DateTime.now();
//     final difference = nextReset.difference(now);

//     if (difference.isNegative) {
//       _loadTaskProgress(); // Reload if we've passed reset time
//       return;
//     }

//     final hours = difference.inHours;
//     final minutes = difference.inMinutes % 60;
//     final seconds = difference.inSeconds % 60;

//     setState(() {
//       _timeUntilReset = 
//           '${hours.toString().padLeft(2, '0')}:'
//           '${minutes.toString().padLeft(2, '0')}:'
//           '${seconds.toString().padLeft(2, '0')}';
//     });
//   }

//   void _redirectToAuth() {
//     Navigator.of(context).pushAndRemoveUntil(
//       MaterialPageRoute(builder: (_) => const AuthScreen()),
//       (route) => false,
//     );
//   }

//   Future<void> _loadTaskProgress() async {
//     setState(() => _isLoading = true);
//     try {
//       const storage = FlutterSecureStorage();
//       final token = await storage.read(key: 'token');

//       if (token == null) {
//         _redirectToAuth();
//         return;
//       }

//       final response = await http.get(
//         Uri.parse('https://testing-ads-production.up.railway.app/api/tasks/progress'),
//         headers: {'Authorization': 'Bearer $token'},
//       );

//       if (response.statusCode == 200) {
//         setState(() {
//           _taskProgress = jsonDecode(response.body);
//           _updateTimeUntilReset();
//         });
//       } else if (response.statusCode == 401) {
//         _redirectToAuth();
//       }
//     } catch (error) {
//       print('Error loading task progress: $error');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Failed to load tasks. Please try again.')),
//         );
//       }
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   Future<void> _claimDailyLogin() async {
//     try {
//       const storage = FlutterSecureStorage();
//       final token = await storage.read(key: 'token');

//       if (token == null) {
//         _redirectToAuth();
//         return;
//       }

//       final response = await http.post(
//         Uri.parse('https://testing-ads-production.up.railway.app/api/tasks/daily-login'),
//         headers: {'Authorization': 'Bearer $token'},
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           if (_taskProgress != null && _taskProgress!['progress'] != null) {
//             _taskProgress!['progress']['dailyLoginClaimed'] = true;
//           }
//         });
        
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Claimed 20 coins for daily login!')),
//           );
//         }
        
//         // Refresh parent screen coins
//         widget.onCoinsUpdated?.call(data['coins']);
//       }
//     } catch (error) {
//       print('Error claiming daily login: $error');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Failed to claim reward. Please try again.')),
//         );
//       }
//     }
//   }

//   void _shareApp() {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Share your referral code: ${widget.referralCode}'),
//       ),
//     );
//   }

//   Widget _buildTaskCard({
//     required String title,
//     required String reward,
//     required bool isCompleted,
//     required int progress,
//     int? total,
//     String? subtitle,
//     bool showProgress = true,
//     VoidCallback? onClaim,
//   }) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 16),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 12,
//                     vertical: 6,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.blue.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(
//                     reward,
//                     style: const TextStyle(
//                       color: Colors.blue,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             if (subtitle != null) ...[
//               const SizedBox(height: 8),
//               Text(
//                 subtitle,
//                 style: TextStyle(
//                   color: Colors.grey[600],
//                 ),
//               ),
//             ],
//             if (showProgress && total != null) ...[
//               const SizedBox(height: 16),
//               LinearProgressIndicator(
//                 value: progress / total,
//                 backgroundColor: Colors.grey[200],
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 '$progress / $total',
//                 style: TextStyle(
//                   color: Colors.grey[600],
//                 ),
//               ),
//             ],
//             if (onClaim != null) ...[
//               const SizedBox(height: 16),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: isCompleted ? null : onClaim,
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                   ),
//                   child: Text(
//                     isCompleted ? 'Completed' : 'Claim',
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     final progress = _taskProgress?['progress'] as Map<String, dynamic>? ?? {};

//     return RefreshIndicator(
//       onRefresh: _loadTaskProgress,
//       child: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           Card(
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 children: [
//                   const Text(
//                     'Daily Tasks Reset In:',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     _timeUntilReset,
//                     style: const TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.blue,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//           _buildTaskCard(
//             title: 'Daily Login',
//             reward: '20 Points',
//             isCompleted: progress['dailyLoginClaimed'] == true,
//             progress: progress['dailyLoginClaimed'] == true ? 1 : 0,
//             total: 1,
//             onClaim: _claimDailyLogin,
//           ),
//           _buildTaskCard(
//             title: 'Watch Videos',
//             reward: (progress['videosWatched'] ?? 0) >= 100 ? '1000 Points' :
//                     (progress['videosWatched'] ?? 0) >= 40 ? '400 Points' :
//                     (progress['videosWatched'] ?? 0) >= 20 ? '80 Points' : '0 Points',
//             isCompleted: (progress['videosWatched'] ?? 0) >= 100,
//             progress: progress['videosWatched'] ?? 0,
//             total: 100,
//             subtitle: 'Watch videos to earn rewards:\n'
//                      '• 20 videos: 80 points\n'
//                      '• 40 videos: 400 points\n'
//                      '• 100 videos: 1000 points',
//           ),
//           _buildTaskCard(
//             title: 'Refer Friends',
//             reward: '40 Points per Referral',
//             isCompleted: false,
//             progress: progress['referralsToday'] ?? 0,
//             showProgress: false,
//             subtitle: 'Share your referral code to earn points',
//             onClaim: _shareApp,
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     super.dispose();
//   }
// }


import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';
import 'dart:convert';
import 'auth_screen.dart';

class TasksScreen extends StatefulWidget {
  final String referralCode;
  final Function(int)? onCoinsUpdated;

  const TasksScreen({
    Key? key,
    required this.referralCode,
    this.onCoinsUpdated,
  }) : super(key: key);

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> with TickerProviderStateMixin {
  Map<String, dynamic>? _taskProgress;
  String _timeUntilReset = '';
  Timer? _timer;
  bool _isLoading = true;
  
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  
  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _loadTaskProgress();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTimeUntilReset();
    });
  }

  void _updateTimeUntilReset() {
    if (_taskProgress == null || _taskProgress!['nextResetTime'] == null) return;

    final nextReset = DateTime.parse(_taskProgress!['nextResetTime']);
    final now = DateTime.now();
    final difference = nextReset.difference(now);

    if (difference.isNegative) {
      _loadTaskProgress();
      return;
    }

    setState(() {
      _timeUntilReset = 
          '${difference.inHours.toString().padLeft(2, '0')}:'
          '${(difference.inMinutes % 60).toString().padLeft(2, '0')}:'
          '${(difference.inSeconds % 60).toString().padLeft(2, '0')}';
    });
  }

  Future<void> _loadTaskProgress() async {
    setState(() => _isLoading = true);
    try {
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'token');

      if (token == null) {
        _redirectToAuth();
        return;
      }

      final response = await http.get(
        Uri.parse('https://testing-ads-production.up.railway.app/api/tasks/progress'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _taskProgress = jsonDecode(response.body);
          _updateTimeUntilReset();
          _isLoading = false;
        });
        _fadeController.forward();
        _slideController.forward();
      } else if (response.statusCode == 401) {
        _redirectToAuth();
      }
    } catch (error) {
      print('Error loading task progress: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load tasks. Please try again.')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  void _redirectToAuth() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthScreen()),
      (route) => false,
    );
  }

  Future<void> _claimDailyLogin() async {
    try {
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'token');

      if (token == null) {
        _redirectToAuth();
        return;
      }

      final response = await http.post(
        Uri.parse('https://testing-ads-production.up.railway.app/api/tasks/daily-login'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          if (_taskProgress != null && _taskProgress!['progress'] != null) {
            _taskProgress!['progress']['dailyLoginClaimed'] = true;
          }
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Claimed 20 coins for daily login!'),
              backgroundColor: Colors.green,
            ),
          );
        }
        
        widget.onCoinsUpdated?.call(data['coins']);
      }
    } catch (error) {
      print('Error claiming daily login: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to claim reward. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _shareApp() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.share, color: Colors.white),
            const SizedBox(width: 8),
            Text('Share your referral code: ${widget.referralCode}'),
          ],
        ),
        action: SnackBarAction(
          label: 'Copy',
          onPressed: () {
            // Add clipboard functionality here
          },
        ),
      ),
    );
  }

  Widget _buildTaskCard({
    required String title,
    required String reward,
    required IconData icon,
    required Color iconColor,
    required bool isCompleted,
    required int progress,
    int? total,
    String? subtitle,
    VoidCallback? onClaim,
  }) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.5),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _slideController,
        curve: Curves.easeOutCubic,
      )),
      child: FadeTransition(
        opacity: _fadeController,
        child: Card(
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: isCompleted
                ? LinearGradient(
                    colors: [Colors.green.shade50, Colors.green.shade100],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(icon, color: iconColor, size: 24),
                          const SizedBox(width: 12),
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          reward,
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                  if (total != null) ...[
                    const SizedBox(height: 16),
                    Stack(
                      children: [
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          height: 8,
                          width: MediaQuery.of(context).size.width * (progress / total),
                          decoration: BoxDecoration(
                            color: isCompleted ? Colors.green : Colors.blue,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$progress / $total',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '${((progress / total) * 100).toInt()}%',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (onClaim != null) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isCompleted ? null : onClaim,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: isCompleted ? Colors.green : Colors.blue,
                          disabledBackgroundColor: Colors.grey[300],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isCompleted)
                              const Icon(Icons.check, size: 18)
                            else
                              const Icon(Icons.card_giftcard, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              isCompleted ? 'Completed' : 'Claim',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final progress = _taskProgress?['progress'] as Map<String, dynamic>? ?? {};
    final videosWatched = progress['videosWatched'] ?? 0;

    return RefreshIndicator(
      onRefresh: _loadTaskProgress,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Timer Card
          Card(
            elevation: 8,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.blue.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(
                    Icons.timer,
                    color: Colors.white,
                    size: 40,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Daily Tasks Reset In:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _timeUntilReset,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Daily Login Task
          _buildTaskCard(
            title: 'Daily Login',
            reward: '20 Points',
            icon: Icons.calendar_today,
            iconColor: Colors.purple,
            isCompleted: progress['dailyLoginClaimed'] == true,
            progress: progress['dailyLoginClaimed'] == true ? 1 : 0,
            total: 1,
            onClaim: _claimDailyLogin,
          ),

          // Video Challenges Section
          Container(
            margin: const EdgeInsets.symmetric(vertical: 16),
            child: const Text(
              'Video Challenges',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Beginner Challenge
          _buildTaskCard(
            title: 'Beginner Challenge',
            reward: '80 Points',
            icon: Icons.play_circle_filled,
            iconColor: Colors.green,
            isCompleted: videosWatched >= 20,
            progress: videosWatched > 20 ? 20 : videosWatched,
            total: 20,
            subtitle: 'Watch 20 videos to earn 80 points',
          ),

          // Intermediate Challenge
          _buildTaskCard(
            title: 'Intermediate Challenge',
            reward: '400 Points',
            icon: Icons.play_circle_filled,
            iconColor: Colors.orange,
            isCompleted: videosWatched >= 40,
            progress: videosWatched > 40 ? 40 : videosWatched,
            total: 40,
            subtitle: 'Watch 40 videos to earn 400 points',
          ),

          // Expert Challenge
          _buildTaskCard(
            title: 'Master Challenge',
            reward: '1000 Points',
            icon: Icons.play_circle_filled,
            iconColor: Colors.red,
            isCompleted: videosWatched >= 100,
            progress: videosWatched > 100 ? 100 : videosWatched,
            total: 100,
            subtitle: 'Watch 100 videos to earn 1000 points',
          ),

          // Referral Task
          _buildTaskCard(
            title: 'Refer Friends',
            reward: '40 Points per Referral',
            icon: Icons.people,
            iconColor: Colors.blue,
            isCompleted: false,
            progress: progress['referralsToday'] ?? 0,
            subtitle: 'Share your referral code to earn points',
            onClaim: _shareApp,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }
}
