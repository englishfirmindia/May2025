import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/auth_provider.dart';
import '../../ui/widgets/custom_text_field.dart';
import '../../ui/widgets/custom_button.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _passwordStrength = '';

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeIn);
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95)
        .animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    _animationController.forward();

    // Listen for password changes to update strength
    _passwordController.addListener(_updatePasswordStrength);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _updatePasswordStrength() {
    final password = _passwordController.text;
    if (password.isEmpty) {
      setState(() => _passwordStrength = '');
      return;
    }

    int score = 0;
    if (password.length >= 8) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;
    if (password.contains(RegExp(r'[A-Za-z]'))) score++;

    setState(() {
      if (score <= 2) {
        _passwordStrength = 'Weak';
      } else if (score == 3) {
        _passwordStrength = 'Medium';
      } else {
        _passwordStrength = 'Strong';
      }
    });
  }

  Future<void> _signup() async {
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match.')),
      );
      return;
    }

    final provider = Provider.of<AuthProvider>(context, listen: false);
    final success = await provider.signup(
      _nameController.text.trim(),
      _emailController.text.trim(),
      password,
    );
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signup successful! Redirecting to login...')),
      );
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signup failed. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Image.asset(
                            'assets/images/logo.jpeg',
                            width: 140,
                            height: 140,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SlideTransition(
                          position: _slideAnimation,
                          child: Card(
                            elevation: 4.0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                            color: Colors.white.withOpacity(0.9),
                            shadowColor: Colors.blue[200]!.withOpacity(0.3),
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Create an Account',
                                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                          color: const Color.fromARGB(255, 5, 5, 5),
                                        ),
                                  ),
                                  const SizedBox(height: 30),
                                  CustomTextField(
                                    controller: _nameController,
                                    labelText: 'Full Name',
                                    prefixIcon: Icons.person,
                                  ),
                                  const SizedBox(height: 16),
                                  CustomTextField(
                                    controller: _emailController,
                                    labelText: 'Email',
                                    prefixIcon: Icons.email,
                                  ),
                                  const SizedBox(height: 16),
                                  CustomTextField(
                                    controller: _passwordController,
                                    labelText: 'Password',
                                    prefixIcon: Icons.lock,
                                    obscureText: _obscurePassword,
                                    onToggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
                                  ),
                                  if (_passwordStrength.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Password Strength: $_passwordStrength',
                                          style: TextStyle(
                                            color: _passwordStrength == 'Weak'
                                                ? Colors.red
                                                : _passwordStrength == 'Medium'
                                                    ? Colors.orange
                                                    : Colors.green[700],
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  const SizedBox(height: 16),
                                  CustomTextField(
                                    controller: _confirmPasswordController,
                                    labelText: 'Confirm Password',
                                    prefixIcon: Icons.lock,
                                    obscureText: _obscureConfirmPassword,
                                    onToggleObscure: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                                  ),
                                  const SizedBox(height: 24),
                                  GestureDetector(
                                    onTapDown: (_) => _animationController.reverse(),
                                    onTapUp: (_) {
                                      _animationController.forward();
                                      _signup();
                                    },
                                    onTapCancel: () => _animationController.forward(),
                                    child: ScaleTransition(
                                      scale: _scaleAnimation,
                                      child: CustomButton(text: 'Sign Up', onPressed: _signup),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  TextButton(
                                    onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                                    child: Text(
                                      'Already have an account? Login',
                                      style: TextStyle(color: Color.fromARGB(255, 0, 2, 0)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: () async {
                    await launchUrl(Uri.parse('https://englishfirm.com/privacy-policy/'));
                  },
                  child: Text(
                    'Privacy Policy',
                    style: TextStyle(
                      color: Colors.blue[600],
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}