

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';
import '../widgets/custom_drawer.dart';
import '../screens/auth_screen.dart';
import '../screens/tasks_screen.dart';
import '../ApiService.dart';
import './EarnBiggerScreen.dart';
import './leaderboard_screen.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  BannerAd? _bannerAd;
  RewardedAd? _rewardedAd;
  int _coins = 0;
  String _referralCode = '';
  List<Map<String, dynamic>> _notifications = [];
  List<Map<String, dynamic>> _leaderboard = [];
  bool _isLoading = true;
  bool _isLoadingAd = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _initializeApp();
    // Set up periodic refresh every 30 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _refreshData();
    });
  }

  Future<void> _initializeApp() async {
    await Future.wait([
      _initializeData(),
      _initGoogleMobileAds(),
    ]);
  }

  Future<void> _initGoogleMobileAds() async {
    await MobileAds.instance.initialize();
    _loadBannerAd();
    _loadRewardedAd();
  }

  Future<void> _refreshData() async {
    try {
      await Future.wait([
        _loadUserData(),
        _loadLeaderboard(),
        _loadNotifications(),
      ]);
    } catch (e) {
      print('Error refreshing data: $e');
    }
  }

  Future<void> _initializeData() async {
    setState(() => _isLoading = true);
    try {
      // First try to load cached data
      await _loadCachedData();
      
      // Then fetch fresh data from server
      await Future.wait([
        _loadUserData(),
        _loadLeaderboard(),
        _loadNotifications(),
      ]);
    } catch (e) {
      print('Error initializing data: $e');
      _handleError(e);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleError(dynamic error) {
    if (error.toString().contains('No token found') || 
        error.toString().contains('Unauthorized')) {
      _redirectToAuth();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${error.toString()}')),
      );
    }
  }

  void _redirectToAuth() {
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _loadUserData() async {
    try {
      final data = await ApiService.getUserProfile();
      if (mounted) {
        setState(() {
          _coins = data['user']['coins'] ?? 0;
          _referralCode = data['user']['referralCode'] ?? '';
        });
      }
      
      // Update cached data
      const storage = FlutterSecureStorage();
      await storage.write(key: 'user_coins', value: _coins.toString());
      await storage.write(key: 'user_referral_code', value: _referralCode);
    } catch (e) {
      print('Error loading user data: $e');
      _handleError(e);
    }
  }

  Future<void> _loadCachedData() async {
    try {
      const storage = FlutterSecureStorage();
      final cachedCoins = await storage.read(key: 'user_coins');
      final cachedReferralCode = await storage.read(key: 'user_referral_code');
      
      if (cachedCoins != null && mounted) {
        setState(() => _coins = int.parse(cachedCoins));
      }
      if (cachedReferralCode != null && mounted) {
        setState(() => _referralCode = cachedReferralCode);
      }
    } catch (e) {
      print('Error loading cached data: $e');
    }
  }

  Future<void> _loadNotifications() async {
    try {
      final notifications = await ApiService.getNotifications();
      if (mounted) {
        setState(() => _notifications = notifications);
      }
    } catch (e) {
      print('Error loading notifications: $e');
      _handleError(e);
    }
  }

  Future<void> _loadLeaderboard() async {
    try {
      final leaderboardData = await ApiService.getLeaderboard();
      if (mounted) {
        setState(() => _leaderboard = leaderboardData);
      }
    } catch (e) {
      print('Error loading leaderboard: $e');
      _handleError(e);
    }
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111',//ca-app-pub-3663556729342401/3606700026
     // ca-app-pub-3940256099942544/6300978111
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() {});
        },
        onAdFailedToLoad: (ad, error) {
          print('Banner ad failed to load: $error');
          ad.dispose();
          if (mounted) setState(() => _bannerAd = null);
        },
      ),
    )..load();
  }

  void _loadRewardedAd() {
    if (_isLoadingAd) return;
    if (mounted) setState(() => _isLoadingAd = true);
    
    RewardedAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/5224354917',
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _rewardedAd = ad;
              _isLoadingAd = false;
            });
          }
        },
        onAdFailedToLoad: (error) {
          print('Failed to load rewarded ad: $error');
          if (mounted) {
            setState(() {
              _rewardedAd = null;
              _isLoadingAd = false;
            });
          }
          Future.delayed(const Duration(minutes: 1), _loadRewardedAd);
        },
      ),
    );
  }

  Future<void> _showRewardedAd() async {
    if (_rewardedAd == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ad not ready yet. Please try again later.')),
      );
      _loadRewardedAd();
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('Failed to show fullscreen content: $error');
        ad.dispose();
        _loadRewardedAd();
      },
    );

    await _rewardedAd!.show(
      onUserEarnedReward: (_, reward) async {
        try {
          final data = await ApiService.claimVideoReward();
          if (mounted) {
            setState(() => _coins = data['coins'] ?? _coins);
          }
          
          if (data['reward'] != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Earned ${data['reward']} coins!')),
            );
          }
          
          // Update cache
          const storage = FlutterSecureStorage();
          await storage.write(key: 'user_coins', value: _coins.toString());
          
          // Refresh data after reward
          _refreshData();
        } catch (error) {
          print('Error updating video watch reward: $error');
          _handleError(error);
        }
      },
    );
  }
  // void _showLeaderboard() {
  //   // Implement leaderboard display logic
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Leaderboard'),
  //       content: SizedBox(
  //         width: double.maxFinite,
  //         child: ListView.builder(
  //           shrinkWrap: true,
  //           itemCount: _leaderboard.length,
  //           itemBuilder: (context, index) {
  //             final user = _leaderboard[index];
  //             return ListTile(
  //               leading: Text('#${index + 1}'),
  //               title: Text(user['username'] ?? 'Unknown'),
  //               trailing: Text('${user['coins'] ?? 0} coins'),
  //             );
  //           },
  //         ),
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.of(context).pop(),
  //           child: const Text('Close'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

    void _showLeaderboard() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LeaderboardScreen()),
    );
  }

  void _showNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notifications'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _notifications.length,
            itemBuilder: (context, index) {
              final notification = _notifications[index];
              return ListTile(
                title: Text(notification['title'] ?? ''),
                subtitle: Text(notification['message'] ?? ''),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _shareApp() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Share your referral code: $_referralCode')),
    );
  }

  void _rateApp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rating feature coming soon!')),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(icon, size: 32, color: Theme.of(context).primaryColor),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  Future<void> _logout() async {
    try {
      const storage = FlutterSecureStorage();
      await storage.deleteAll();
      _redirectToAuth();
    } catch (error) {
      print('Error during logout: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to logout. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? 'Dashboard' : 'Daily Tasks'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Icon(Icons.monetization_on),
                  const SizedBox(width: 4),
                  Text(
                    '$_coins',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: _showNotifications,
          ),
        ],
      ),
      drawer: CustomDrawer(
        coins: _coins,
        referralCode: _referralCode,
        onLogout: _logout,
        onShowLeaderboard: _showLeaderboard,
        onShareApp: _shareApp,
        onRateApp: _rateApp,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          // Dashboard tab
          RefreshIndicator(
            onRefresh: _initializeData,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildMenuItem(
                  icon: Icons.play_circle,
                  title: 'Watch Ads',
                  subtitle: 'Watch ads to earn coins',
                  onTap: _showRewardedAd,
                ),
                _buildMenuItem(
                  icon: Icons.leaderboard,
                  title: 'Leaderboard',
                  subtitle: 'Check your ranking',
                  onTap: _showLeaderboard,
                ),
                _buildMenuItem(
                  icon: Icons.star,
                  title: 'Rate Us',
                  subtitle: 'Rate our app',
                  onTap: _rateApp,
                ),
                _buildMenuItem(
                  icon: Icons.share,
                  title: 'Share App',
                  subtitle: 'Your referral code: $_referralCode',
                  onTap: _shareApp,
                ),
                
                _buildMenuItem(
  icon: Icons.emoji_events,
  title: 'Earn Bigger',
  subtitle: 'Special events and rewards',
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => EarnBiggerScreen(
        currentPoints: _coins,
        currentDownloads: 100000, // Replace with actual download count
      ),
    ),
  ),
),
              ],
            ),
          ),
          // Tasks tab
          TasksScreen(
            referralCode: _referralCode,
            onCoinsUpdated: (newCoins) => setState(() => _coins = newCoins),
          ),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.task),
                label: 'Tasks',
              ),
            ],
          ),
          if (_bannerAd != null)
            SizedBox(
              height: _bannerAd!.size.height.toDouble(),
              width: _bannerAd!.size.width.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _bannerAd?.dispose();
    _rewardedAd?.dispose();
    super.dispose();
  }
}
