

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:lottie/lottie.dart';
import 'dashboard_screen.dart';
import '../ApiService.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _referralController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _usernameController.dispose();
    _referralController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      Map<String, dynamic> response;
      
      if (_isLogin) {
        response = await ApiService.login(
          email: _emailController.text,
          password: _passwordController.text,
        );
      } else {
        response = await ApiService.register(
          email: _emailController.text,
          password: _passwordController.text,
          name: _nameController.text,
          username: _usernameController.text,
          referralCode: _referralController.text,
        );
      }

      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const DashboardScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red.withOpacity(0.8),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(10),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? _obscurePassword : false,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    color: Theme.of(context).primaryColor,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          labelStyle: TextStyle(color: Theme.of(context).primaryColor),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.8),
              Theme.of(context).primaryColor.withOpacity(0.4),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            height: 200,
                            child: Lottie.asset(
                              _isLogin ? 'assets/login.json' : 'assets/register.json',
                              repeat: true,
                            ),
                          ),
                          const SizedBox(height: 20),
                          AnimatedTextKit(
                            animatedTexts: [
                              TypewriterAnimatedText(
                                _isLogin ? 'Welcome Back!' : 'Join Our Community!',
                                textStyle: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                speed: const Duration(milliseconds: 100),
                              ),
                            ],
                            totalRepeatCount: 1,
                            displayFullTextOnTap: true,
                          ),
                          const SizedBox(height: 30),
                          if (!_isLogin) ...[
                            _buildInputField(
                              controller: _nameController,
                              label: 'Full Name',
                              icon: Icons.person,
                              validator: (value) {
                                if (value?.isEmpty ?? true) return 'Please enter your name';
                                return null;
                              },
                            ),
                            _buildInputField(
                              controller: _usernameController,
                              label: 'Username',
                              icon: Icons.alternate_email,
                              validator: (value) {
                                if (value?.isEmpty ?? true) return 'Please enter username';
                                if (value!.length < 3) {
                                  return 'Username must be at least 3 characters';
                                }
                                if (value.contains(' ')) {
                                  return 'Username cannot contain spaces';
                                }
                                return null;
                              },
                            ),
                          ],
                          _buildInputField(
                            controller: _emailController,
                            label: 'Email',
                            icon: Icons.email,
                            validator: (value) {
                              if (value?.isEmpty ?? true) return 'Please enter email';
                              if (!value!.contains('@')) return 'Please enter a valid email';
                              return null;
                            },
                          ),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            child: _buildInputField(
                              controller: _passwordController,
                              label: 'Password',
                              icon: Icons.lock,
                              isPassword: true,
                              validator: (value) {
                                if (value?.isEmpty ?? true) return 'Please enter password';
                                if (!_isLogin && value!.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                          ),
                          if (!_isLogin) ...[
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              child: _buildInputField(
                                controller: _referralController,
                                label: 'Referral Code (Optional)',
                                icon: Icons.card_giftcard,
                              ),
                            ),
                          ],
                          const SizedBox(height: 30),
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 500),
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: value,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Theme.of(context).primaryColor,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    elevation: 5,
                                  ),
                                  child: _isLoading
                                      ? SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Theme.of(context).primaryColor,
                                          ),
                                        )
                                      : Text(
                                          _isLogin ? 'LOGIN' : 'SIGN UP',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          TextButton(
                            onPressed: () {
                              setState(() => _isLogin = !_isLogin);
                              _animationController.reset();
                              _animationController.forward();
                            },
                            child: Text(
                              _isLogin
                                  ? 'Don\'t have an account? Sign Up'
                                  : 'Already have an account? Login',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}