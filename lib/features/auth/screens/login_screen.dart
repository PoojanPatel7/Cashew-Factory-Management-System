import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Login screen with premium glassmorphism design — theme-aware
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _rememberMe = false;

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
    super.dispose();
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    // TODO: Replace with real API call
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);

    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

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
                        _buildLoginCard(theme, cs),
                        const SizedBox(height: 20),
                        TextButton.icon(
                          onPressed: () => context.go('/setup'),
                          icon: const Icon(Icons.add_business_rounded, size: 18),
                          label: const Text('First time? Set up your factory'),
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
    );
  }

  Widget _buildLogo(ColorScheme cs) {
    return Column(
      children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [cs.primary, cs.secondary]),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: cs.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 4))],
          ),
          child: Icon(Icons.spa_rounded, color: cs.onPrimary, size: 40),
        ),
        const SizedBox(height: 16),
        Text('CashewPro',
          style: TextStyle(color: cs.primary, fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: 1)),
        Text('Factory Management System',
          style: TextStyle(color: cs.onSurface.withValues(alpha: 0.5), fontSize: 13, letterSpacing: 0.5)),
      ],
    );
  }

  Widget _buildLoginCard(ThemeData theme, ColorScheme cs) {
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
            Text('Welcome Back',
              style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('Sign in to manage your factory',
              style: TextStyle(color: cs.onSurface.withValues(alpha: 0.5))),
            const SizedBox(height: 28),

            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
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
            const SizedBox(height: 12),

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
                TextButton(onPressed: () {}, child: const Text('Forgot Password?', style: TextStyle(fontSize: 13))),
              ],
            ),
            const SizedBox(height: 24),

            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                child: _isLoading
                    ? SizedBox(width: 22, height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: cs.onPrimary))
                    : const Text('Sign In', style: TextStyle(fontSize: 16)),
              ),
            ),

            const SizedBox(height: 16),

            // Demo login hint
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: cs.primary, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('Demo: Use any email & 6+ char password',
                      style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.6))),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
