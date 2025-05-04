// import 'package:flutter/material.dart';
// import '../ApiService.dart';

// class LeaderboardScreen extends StatefulWidget {
//   @override
//   _LeaderboardScreenState createState() => _LeaderboardScreenState();
// }

// class _LeaderboardScreenState extends State<LeaderboardScreen> {
//   List<Map<String, dynamic>> _leaderboard = [];
//   String _userReferralCode = '';
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadLeaderboard();
//     _getUserReferralCode();
//   }

//   Future<void> _loadLeaderboard() async {
//     try {
//       final leaderboardData = await ApiService.getLeaderboard();
//       if (mounted) {
//         setState(() {
//           _leaderboard = leaderboardData;
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       print('Error loading leaderboard: $e');
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   Future<void> _getUserReferralCode() async {
//     try {
//       final userProfile = await ApiService.getUserProfile();
//       if (mounted) {
//         setState(() {
//           _userReferralCode = userProfile['user']['referralCode'] ?? '';
//         });
//       }
//     } catch (e) {
//       print('Error getting user referral code: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Leaderboard'),
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Text(
//                     'Your Referral Code: $_userReferralCode',
//                     style: Theme.of(context).textTheme.bodyMedium,
//                   ),
//                 ),
//                 Expanded(
//                   child: ListView.builder(
//                     itemCount: _leaderboard.length,
//                     itemBuilder: (context, index) {
//                       final user = _leaderboard[index];
//                       return ListTile(
//                         leading: Text('#${index + 1}'),
//                         title: Text(user['referralCode'] ?? 'Unknown'),
//                         trailing: Text('${user['coins'] ?? 0} coins'),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import '../ApiService.dart';

// class LeaderboardScreen extends StatefulWidget {
//   @override
//   _LeaderboardScreenState createState() => _LeaderboardScreenState();
// }

// class _LeaderboardScreenState extends State<LeaderboardScreen> {
//   List<Map<String, dynamic>> _leaderboard = [];
//   String _userReferralCode = '';
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadLeaderboard();
//     _getUserReferralCode();
//   }

//   Future<void> _loadLeaderboard() async {
//     try {
//       final leaderboardData = await ApiService.getLeaderboard();
//       if (mounted) {
//         setState(() {
//           _leaderboard = leaderboardData;
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       print('Error loading leaderboard: $e');
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   Future<void> _getUserReferralCode() async {
//     try {
//       final userProfile = await ApiService.getUserProfile();
//       if (mounted) {
//         setState(() {
//           _userReferralCode = userProfile['user']['referralCode'] ?? '';
//         });
//       }
//     } catch (e) {
//       print('Error getting user referral code: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Leaderboard'),
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Text(
//                     'Your Referral Code: $_userReferralCode',
//                     style: Theme.of(context).textTheme.bodyMedium,
//                   ),
//                 ),
//                 Expanded(
//                   child: ListView.separated(
//                     padding: const EdgeInsets.all(16.0),
//                     itemCount: _leaderboard.length,
//                     separatorBuilder: (context, index) => const Divider(),
//                     itemBuilder: (context, index) {
//                       final user = _leaderboard[index];
//                       final position = index + 1;
//                       return ListTile(
//                         leading: CircleAvatar(
//                           child: Text('$position'),
//                         ),
//                         title: Text(user['referralCode'] ?? 'Unknown'),
//                         subtitle: Text('${user['coins'] ?? 0} coins'),
//                         trailing: position == 1
//                             ? const Icon(Icons.local_fire_department, color: Colors.orange)
//                             : null,
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//     );
//   }
// }

// // Notes for user safety:
// // 1. We do not send any emails to users regarding the leaderboard or any events. All communication is done through direct in-app notifications.
// // 2. If a user wins an event, they will be notified directly within the app, and their referral code and reward information will be updated accordingly.
// // 3. We do not share user data or referral codes with any third parties. All information is kept secure and used solely for the purposes of the app's features and functionality.
// // 4. Users should be cautious of any external communications or requests related to the leaderboard or events, as they may be fraudulent. Please contact our support team if you have any concerns.

import 'package:flutter/material.dart';
import '../ApiService.dart';

class LeaderboardScreen extends StatefulWidget {
  @override
  _LeaderboardScreenState createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<Map<String, dynamic>> _leaderboard = [];
  String _userReferralCode = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
    _getUserReferralCode();
  }

  Future<void> _loadLeaderboard() async {
    try {
      final leaderboardData = await ApiService.getLeaderboard();
      if (mounted) {
        setState(() {
          _leaderboard = leaderboardData;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading leaderboard: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _getUserReferralCode() async {
    try {
      final userProfile = await ApiService.getUserProfile();
      if (mounted) {
        setState(() {
          _userReferralCode = userProfile['user']['referralCode'] ?? '';
        });
      }
    } catch (e) {
      print('Error getting user referral code: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Your Referral Code: $_userReferralCode',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _leaderboard.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final user = _leaderboard[index];
                      final position = index + 1;
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text('$position'),
                        ),
                        title: Text(user['referralCode'] ?? 'Unknown'),
                        subtitle: Text('${user['coins'] ?? 0} coins'),
                        trailing: position == 1
                            ? const Icon(Icons.local_fire_department, color: Colors.orange)
                            : null,
                      );
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Note: We do not send any emails regarding the leaderboard or events. All communication is done through direct in-app notifications.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
    );
  }
}