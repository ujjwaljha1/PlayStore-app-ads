

import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  final int coins;
  final String referralCode;
  final VoidCallback onLogout;
  final VoidCallback onShowLeaderboard;
  final VoidCallback onShareApp;
  final VoidCallback onRateApp;

  const CustomDrawer({
    Key? key,
    required this.coins,
    required this.referralCode,
    required this.onLogout,
    required this.onShowLeaderboard,
    required this.onShareApp,
    required this.onRateApp,
  }) : super(key: key);

  void _showSafetyGuidelines(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              height: 6,
              width: 40,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'Safety Guidelines & Privacy Policy',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildGuidelineSection(
                    icon: Icons.security,
                    title: 'Data Protection',
                    items: [
                      'We never request Aadhaar, PAN, or government IDs',
                      'Your personal information is encrypted and secure',
                      'We do not share your data with third parties',
                      'Regular security audits are conducted',
                    ],
                  ),

                  _buildGuidelineSection(
                    icon: Icons.payment,
                    title: 'Payment Safety',
                    items: [
                      'Only use if you have UPI apps (PhonePe, GPay)',
                      'Never share UPI PIN or payment credentials',
                      'All transactions are processed securely',
                      'Report suspicious activities immediately',
                    ],
                  ),

                  _buildGuidelineSection(
                    icon: Icons.verified_user,
                    title: 'Account Security',
                    items: [
                      'Keep your login credentials secure',
                      'Enable two-factor authentication when available',
                      'One account per user only',
                      'Regularly monitor your account activity',
                    ],
                  ),

                  _buildGuidelineSection(
                    icon: Icons.gavel,
                    title: 'Terms of Use',
                    items: [
                      'Follow community guidelines',
                      'No fraudulent activities allowed',
                      'Respect other users privacy',
                      'Violation may lead to account suspension',
                    ],
                  ),

                  _buildGuidelineSection(
                    icon: Icons.privacy_tip,
                    title: 'Privacy Protection',
                    items: [
                      'Minimal data collection policy',
                      'Your data is never sold to third parties',
                      'Clear opt-out options available',
                      'Control over your personal information',
                    ],
                  ),

                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuidelineSection({
    required IconData icon,
    required String title,
    required List<String> items,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontSize: 16)),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  child: Icon(Icons.person, size: 30),
                ),
                const SizedBox(height: 10),
                Text(
                  'Coins: $coins',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                Text(
                  'Code: $referralCode',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.shield),
            title: const Text('Safety Guidelines'),
            subtitle: const Text('Important safety information'),
            onTap: () => _showSafetyGuidelines(context),
          ),
          ListTile(
            leading: const Icon(Icons.leaderboard),
            title: const Text('Leaderboard'),
            onTap: () {
              Navigator.pop(context);
              onShowLeaderboard();
            },
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share App'),
            onTap: () {
              Navigator.pop(context);
              onShareApp();
            },
          ),
          ListTile(
            leading: const Icon(Icons.star),
            title: const Text('Rate Us'),
            onTap: () {
              Navigator.pop(context);
              onRateApp();
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}