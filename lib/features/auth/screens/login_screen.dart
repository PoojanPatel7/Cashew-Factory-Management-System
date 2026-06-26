import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

/// Login screen with premium glassmorphism design — theme-aware
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isSignUp = false;
  final _nameCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();

  late AnimationController _animCtrl;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeIn = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    _pinCtrl.dispose();
    super.dispose();
  }

  void _handleGoogleLogin() async {
    final success = await ref.read(authProvider.notifier).signInWithGoogle();

    if (!success && mounted) {
      final error = ref.read(authProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Login failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleEmailLogin() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_isSignUp) {
      if (_pinCtrl.text != '5252') {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid Developer PIN'), backgroundColor: Colors.red));
         return;
      }
      final success = await ref.read(authProvider.notifier).register(
        _nameCtrl.text.trim(),
        _emailCtrl.text.trim(),
        _passwordCtrl.text,
        '',
      );
      if (!success && mounted) {
        final error = ref.read(authProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error ?? 'Sign up failed'), backgroundColor: Colors.red));
      }
    } else {
      final success = await ref.read(authProvider.notifier).login(
        _emailCtrl.text.trim(),
        _passwordCtrl.text,
      );
      if (!success && mounted) {
        final error = ref.read(authProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error ?? 'Login failed'), backgroundColor: Colors.red));
      }
    }
  }
  
  void _handleForgotPassword() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid email address first')));
      return;
    }
    final success = await ref.read(authProvider.notifier).resetPassword(email);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success ? 'Password reset link sent!' : (ref.read(authProvider).error ?? 'Failed to send link')),
        backgroundColor: success ? Colors.green : Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final authState = ref.watch(authProvider);

    ref.listen(authProvider, (previous, next) {
      if (next.isAuthenticated) {
        if (next.role == null) {
          if (previous?.role != null || previous?.isAuthenticated == false || previous == null) {
            _showPinDialog();
          }
        } else {
          context.go('/home');
        }
      }
    });

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.scaffoldBackgroundColor, cs.surface],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: FadeTransition(
                opacity: _fadeIn,
                child: SlideTransition(
                  position: _slideUp,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLogo(cs),
                        const SizedBox(height: 40),
                        _buildLoginCard(theme, cs, authState.isLoading),
                      ],
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

  Widget _buildLogo(ColorScheme cs) {
    return Column(
      children: [
        Container(
          width: 80, height: 80,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: cs.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 4))],
          ),
          child: Image.asset('assets/images/logo.png', fit: BoxFit.cover),
        ),
        const SizedBox(height: 16),
        Text('HM Nuts',
          style: TextStyle(color: cs.primary, fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: 1)),
        Text('Factory Management System',
          style: TextStyle(color: cs.onSurface.withValues(alpha: 0.5), fontSize: 13, letterSpacing: 0.5)),
      ],
    );
  }

  Widget _buildLoginCard(ThemeData theme, ColorScheme cs, bool isLoading) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outline, width: 0.5),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(_isSignUp ? 'Create Account' : 'Welcome Back',
              style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700), textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(_isSignUp ? 'Sign up to create a factory' : 'Sign in to manage your factory',
              style: TextStyle(color: cs.onSurface.withValues(alpha: 0.5)), textAlign: TextAlign.center),
            const SizedBox(height: 32),

            SizedBox(
              height: 50,
              child: OutlinedButton(
                onPressed: isLoading ? null : _handleGoogleLogin,
                style: OutlinedButton.styleFrom(
                  backgroundColor: cs.surface,
                  side: BorderSide(color: cs.outline.withValues(alpha: 0.5)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: EdgeInsets.zero,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/google_logo.png', height: 24, width: 24),
                    const SizedBox(width: 12),
                    Text('Sign in with Google', 
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface)),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: Divider(color: cs.outline.withValues(alpha: 0.5))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('OR', style: TextStyle(color: cs.onSurface.withValues(alpha: 0.5), fontSize: 12, fontWeight: FontWeight.w600)),
                ),
                Expanded(child: Divider(color: cs.outline.withValues(alpha: 0.5))),
              ],
            ),
            const SizedBox(height: 24),


            if (_isSignUp) ...[
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Full Name', 
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Please enter your name';
                  return null;
                },
              ),
              const SizedBox(height: 16),
            ],
            TextFormField(
              controller: _emailCtrl,

              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email', 
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Please enter your email';
                if (!v.contains('@')) return 'Enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _passwordCtrl,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Please enter your password';
                if (v.length < 6) return 'Password must be 6+ characters';
                return null;
              },
            ),
            const SizedBox(height: 16),

            if (_isSignUp) ...[
              TextFormField(
                controller: _pinCtrl,
                obscureText: true,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Developer PIN', 
                  prefixIcon: const Icon(Icons.security),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required for Sign Up';
                  return null;
                },
              ),
              const SizedBox(height: 16),
            ],

            Row(
              children: [
                SizedBox(
                  height: 24, width: 24,
                  child: Checkbox(
                    value: _rememberMe,
                    onChanged: (v) => setState(() => _rememberMe = v ?? false),
                    activeColor: cs.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text('Remember me', style: TextStyle(color: cs.onSurface.withValues(alpha: 0.7), fontSize: 13))),
                TextButton(
                  onPressed: _handleForgotPassword, 
                  child: const Text('Forgot Password?', style: TextStyle(fontSize: 13))
                ),
              ],
            ),
            const SizedBox(height: 24),


            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                setState(() {
                  _isSignUp = !_isSignUp;
                  _formKey.currentState?.reset();
                });
              },
              child: Text(_isSignUp ? 'Already have an account? Sign In' : 'No account? Create one (Requires PIN)'),
            ),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : _handleEmailLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: isLoading
                    ? SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: cs.onPrimary))
                    : Text(_isSignUp ? 'Sign Up' : 'Sign In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPinDialog() {
    final pinCtrl = TextEditingController();
    bool isLoading = false;
    bool obscurePin = true;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Setup Owner Access'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Enter the setup PIN to assign the OWNER role to this account.'),
                  const SizedBox(height: 16),
                  TextField(
                    controller: pinCtrl,
                    obscureText: obscurePin,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'PIN',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      suffixIcon: IconButton(
                        icon: Icon(obscurePin ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setStateDialog(() => obscurePin = !obscurePin),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () {
                    ref.read(authProvider.notifier).logout();
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isLoading ? null : () async {
                    setStateDialog(() => isLoading = true);
                    final success = await ref.read(authProvider.notifier).verifyOwnerPin(pinCtrl.text.trim());
                    if (success && mounted) {
                      Navigator.pop(context); // close dialog
                      // Will auto navigate to /home via ref.listen
                    } else if (mounted) {
                      setStateDialog(() => isLoading = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(ref.read(authProvider).error ?? 'Invalid PIN'), backgroundColor: Colors.red),
                      );
                    }
                  },
                  child: isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Submit'),
                ),
              ],
            );
          }
        );
      }
    );
  }
}
