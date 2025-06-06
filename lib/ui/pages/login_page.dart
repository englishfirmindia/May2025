import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/auth_provider.dart';
import '../../ui/widgets/custom_text_field.dart';
import '../../ui/widgets/custom_button.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeIn);
    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.2), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95)
        .animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final provider = Provider.of<AuthProvider>(context, listen: false);
    final success = await provider.login(_emailController.text.trim(), _passwordController.text.trim());
    if (success) {
      final user = provider.user!;
      Navigator.pushReplacementNamed(context, user.isAdmin ? '/admin' : '/user');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed. Please try again.')),
      );
    }
  }

  Future<void> _signInWithGoogle() async {
    final provider = Provider.of<AuthProvider>(context, listen: false);
    final success = await provider.signInWithGoogle();
    if (success) {
      final user = provider.user!;
      Navigator.pushReplacementNamed(context, user.isAdmin ? '/admin' : '/user');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Google Sign-In failed. Please try again.')),
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
                                    'Welcome Back!',
                                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                          color: const Color.fromARGB(255, 5, 5, 5),
                                        ),
                                  ),
                                  const SizedBox(height: 30),
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
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
                                      child: const Text(
                                        'Forgot Password?',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  GestureDetector(
                                    onTapDown: (_) => _animationController.reverse(),
                                    onTapUp: (_) {
                                      _animationController.forward();
                                      _login();
                                    },
                                    onTapCancel: () => _animationController.forward(),
                                    child: ScaleTransition(
                                      scale: _scaleAnimation,
                                      child: CustomButton(
                                        text: 'Login',
                                        onPressed: _login,
                                        isLoading: Provider.of<AuthProvider>(context).user == null &&
                                            context.watch<AuthProvider>().user != null,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  GestureDetector(
                                    onTapDown: (_) => _animationController.reverse(),
                                    onTapUp: (_) {
                                      _animationController.forward();
                                      _signInWithGoogle();
                                    },
                                    onTapCancel: () => _animationController.forward(),
                                    child: ScaleTransition(
                                      scale: _scaleAnimation,
                                      child: ElevatedButton.icon(
                                        onPressed: _signInWithGoogle,
                                        icon: Image.asset(
                                          'assets/images/google_logo.png',
                                          height: 24,
                                          width: 24,
                                        ),
                                        label: const Text('Login in with Google'),
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.black,
                                          backgroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            side: const BorderSide(color: Colors.grey),
                                          ),
                                          minimumSize: const Size(double.infinity, 50),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  TextButton(
                                    onPressed: () => Navigator.pushNamed(context, '/signup'),
                                    child: Text(
                                      'Don’t have an account? Sign Up',
                                      style: TextStyle(color: Colors.blue[600]),
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