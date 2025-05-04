import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:confetti/confetti.dart';
import 'dart:math' show pi;  // Add this import for pi constant
class EarnBiggerScreen extends StatefulWidget {
  final int currentPoints;
  final int currentDownloads;

  const EarnBiggerScreen({
    Key? key,
    required this.currentPoints,
    required this.currentDownloads,
  }) : super(key: key);

  @override
  State<EarnBiggerScreen> createState() => _EarnBiggerScreenState();
}

class _EarnBiggerScreenState extends State<EarnBiggerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late ConfettiController _confettiController;
  final List<MilestoneEvent> _milestones = [
    MilestoneEvent(
      downloads: 100000,
      rewardUsers: 25000,
      description: 'First Major Milestone!',
      rewardMultiplier: 0.45,
    ),
    MilestoneEvent(
      downloads: 200000,
      rewardUsers: 50000,
      description: 'Double Success Celebration!',
      rewardMultiplier: 0.50,
    ),
    MilestoneEvent(
      downloads: 500000,
      rewardUsers: 100000,
      description: 'Half Million Special!',
      rewardMultiplier: 0.55,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  Widget _buildMilestoneCard(MilestoneEvent milestone) {
    final potentialReward = (widget.currentPoints * milestone.rewardMultiplier).toStringAsFixed(2);
    final progress = (widget.currentDownloads / milestone.downloads * 100).clamp(0, 100);

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade400,
              Colors.blue.shade800,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(milestone.downloads / 1000).toStringAsFixed(0)}K Downloads',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.info_outline, color: Colors.white),
                  onPressed: () => _showMilestoneDetails(milestone),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              milestone.description,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress / 100,
                minHeight: 15,
                backgroundColor: Colors.white24,
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress >= 100 ? Colors.green : Colors.amber,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Progress: ${progress.toStringAsFixed(1)}%',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Potential Reward:',
                      style: TextStyle(color: Colors.white70),
                    ),
                    Text(
                      '₹$potentialReward',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Winners:',
                      style: TextStyle(color: Colors.white70),
                    ),
                    Text(
                      '${(milestone.rewardUsers / 1000).toStringAsFixed(0)}K Users',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showMilestoneDetails(MilestoneEvent milestone) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${milestone.downloads ~/ 1000}K Downloads Milestone'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'When we reach ${milestone.downloads ~/ 1000}K downloads:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('• ${milestone.rewardUsers} lucky users will be rewarded'),
            Text('• Reward multiplier: ${milestone.rewardMultiplier}x'),
            Text('• Example: 1000 points = ₹${(1000 * milestone.rewardMultiplier).toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            const Text(
              'Selection Criteria:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text('• Active users with minimum 100 points'),
            const Text('• Regular app engagement'),
            const Text('• Valid referral history'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AnimatedTextKit(
          animatedTexts: [
            ColorizeAnimatedText(
              'Earn Bigger',
              textStyle: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              colors: [
                Colors.blue,
                Colors.purple,
                Colors.red,
                Colors.orange,
              ],
            ),
          ],
          repeatForever: true,
        ),
      ),
      body: Stack(
        children: [
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: -pi / 2,
            emissionFrequency: 0.05,
            numberOfParticles: 20,
            maxBlastForce: 100,
            minBlastForce: 80,
            gravity: 0.2,
          ),
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Special Events & Rewards',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Current Downloads: ${widget.currentDownloads}',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ...List.generate(
                        _milestones.length,
                        (index) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildMilestoneCard(_milestones[index]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _confettiController.play(),
        child: const Icon(Icons.celebration),
      ),
    );
  }
}

class MilestoneEvent {
  final int downloads;
  final int rewardUsers;
  final String description;
  final double rewardMultiplier;

  MilestoneEvent({
    required this.downloads,
    required this.rewardUsers,
    required this.description,
    required this.rewardMultiplier,
  });
}