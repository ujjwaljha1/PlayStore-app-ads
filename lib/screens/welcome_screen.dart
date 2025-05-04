// import 'package:flutter/material.dart';
// import 'auth_screen.dart';

// class WelcomeScreen extends StatefulWidget {
//   const WelcomeScreen({Key? key}) : super(key: key);

//   @override
//   State<WelcomeScreen> createState() => _WelcomeScreenState();
// }

// class _WelcomeScreenState extends State<WelcomeScreen> {
//   final PageController _pageController = PageController();
//   int _currentPage = 0;

//   final List<Map<String, dynamic>> _welcomeData = [
//     {
//       'title': 'Welcome to Reward App',
//       'description': 'Earn rewards by watching ads',
//       'icon': Icons.play_circle_outline,
//     },
//     {
//       'title': 'Invite Friends',
//       'description': 'Get bonus coins for referrals',
//       'icon': Icons.people_outline,
//     },
//     {
//       'title': 'Track Progress',
//       'description': 'See your ranking on the leaderboard',
//       'icon': Icons.leaderboard_outlined,
//     },
//   ];

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Stack(
//           children: [
//             PageView.builder(
//               controller: _pageController,
//               onPageChanged: (int page) {
//                 setState(() => _currentPage = page);
//               },
//               itemCount: _welcomeData.length,
//               itemBuilder: (context, index) {
//                 return Padding(
//                   padding: const EdgeInsets.all(40.0),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         _welcomeData[index]['icon'],
//                         size: 100,
//                         color: Theme.of(context).primaryColor,
//                       ),
//                       const SizedBox(height: 50),
//                       Text(
//                         _welcomeData[index]['title']!,
//                         style: const TextStyle(
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                       const SizedBox(height: 20),
//                       Text(
//                         _welcomeData[index]['description']!,
//                         style: const TextStyle(
//                           fontSize: 16,
//                           color: Colors.grey,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//             Positioned(
//               bottom: 50,
//               left: 0,
//               right: 0,
//               child: Column(
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: List.generate(
//                       _welcomeData.length,
//                       (index) => AnimatedContainer(
//                         duration: const Duration(milliseconds: 300),
//                         margin: const EdgeInsets.symmetric(horizontal: 5),
//                         width: _currentPage == index ? 20 : 10,
//                         height: 10,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(5),
//                           color: _currentPage == index
//                               ? Theme.of(context).primaryColor
//                               : Colors.grey.shade300,
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 30),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 40),
//                     child: Row(
//                       children: [
//                         if (_currentPage > 0)
//                           TextButton(
//                             onPressed: () {
//                               _pageController.previousPage(
//                                 duration: const Duration(milliseconds: 300),
//                                 curve: Curves.easeInOut,
//                               );
//                             },
//                             child: const Text('Previous'),
//                           ),
//                         const Spacer(),
//                         ElevatedButton(
//                           onPressed: () {
//                             if (_currentPage < _welcomeData.length - 1) {
//                               _pageController.nextPage(
//                                 duration: const Duration(milliseconds: 300),
//                                 curve: Curves.easeInOut,
//                               );
//                             } else {
//                               Navigator.of(context).pushReplacement(
//                                 MaterialPageRoute(
//                                   builder: (_) => const AuthScreen(),
//                                 ),
//                               );
//                             }
//                           },
//                           style: ElevatedButton.styleFrom(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 30,
//                               vertical: 12,
//                             ),
//                           ),
//                           child: Text(
//                             _currentPage < _welcomeData.length - 1
//                                 ? 'Next'
//                                 : 'Get Started',
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:lottie/lottie.dart';
import 'auth_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _lottieController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> _welcomeData = [
    {
      'title': 'Welcome to Reward App',
      'description': 'Earn rewards by watching ads',
      'lottie': 'assets/reward.json',
    },
    {
      'title': 'Invite Friends',
      'description': 'Get bonus coins for referrals',
      'lottie': 'assets/invite.json',
    },
    {
      'title': 'Track Progress',
      'description': 'See your ranking on the leaderboard',
      'lottie': 'assets/leaderboard.json',
    },
  ];

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_fadeController);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _lottieController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.8),
              Theme.of(context).primaryColor.withOpacity(0.3),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() => _currentPage = page);
                  _fadeController.reset();
                  _fadeController.forward();
                  _lottieController.reset();
                  _lottieController.forward();
                },
                itemCount: _welcomeData.length,
                itemBuilder: (context, index) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 250,
                            width: 250,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.2),
                            ),
                            child: Lottie.asset(
                              _welcomeData[index]['lottie'],
                              controller: _lottieController,
                              onLoaded: (composition) {
                                _lottieController
                                  ..duration = composition.duration
                                  ..forward();
                              },
                            ),
                          ),
                          const SizedBox(height: 50),
                          AnimatedTextKit(
                            animatedTexts: [
                              TypewriterAnimatedText(
                                _welcomeData[index]['title']!,
                                textStyle: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                speed: const Duration(milliseconds: 80),
                              ),
                            ],
                            totalRepeatCount: 1,
                            displayFullTextOnTap: true,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            _welcomeData[index]['description']!,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                bottom: 50,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _welcomeData.length,
                        (index) => TweenAnimationBuilder<double>(
                          tween: Tween(
                            begin: 0.0,
                            end: _currentPage == index ? 1.0 : 0.0,
                          ),
                          duration: const Duration(milliseconds: 300),
                          builder: (context, value, child) {
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              width: 10 + (value * 20),
                              height: 10,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.white.withOpacity(0.5 + (value * 0.5)),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Row(
                        children: [
                          if (_currentPage > 0)
                            TextButton(
                              onPressed: () {
                                _pageController.previousPage(
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                );
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                              ),
                              child: const Text(
                                'Previous',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: () {
                              if (_currentPage < _welcomeData.length - 1) {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                );
                              } else {
                                Navigator.of(context).pushReplacement(
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation, secondaryAnimation) =>
                                        const AuthScreen(),
                                    transitionsBuilder:
                                        (context, animation, secondaryAnimation, child) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      );
                                    },
                                    transitionDuration: const Duration(milliseconds: 800),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Theme.of(context).primaryColor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 5,
                            ),
                            child: Text(
                              _currentPage < _welcomeData.length - 1
                                  ? 'Next'
                                  : 'Get Started',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}