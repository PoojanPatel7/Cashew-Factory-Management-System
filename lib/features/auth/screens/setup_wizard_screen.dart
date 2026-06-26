import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/confirmation_dialog.dart';
import '../providers/auth_provider.dart';
/// First-time factory setup wizard (3 steps) — theme-aware
class SetupWizardScreen extends StatefulWidget {
  const SetupWizardScreen({super.key});

  @override
  State<SetupWizardScreen> createState() => _SetupWizardScreenState();
}

class _SetupWizardScreenState extends State<SetupWizardScreen> {
  final _pageCtrl = PageController();
  int _currentStep = 0;

  final _serverUrlCtrl = TextEditingController(text: 'http://');
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _factoryNameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _gstinCtrl = TextEditingController();
  final _fssaiCtrl = TextEditingController();

  @override
  void dispose() {
    _pageCtrl.dispose();
    _serverUrlCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _factoryNameCtrl.dispose();
    _addressCtrl.dispose();
    _gstinCtrl.dispose();
    _fssaiCtrl.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 1) {
      if (!_ownerFormKey.currentState!.validate()) return;
      setState(() => _currentStep++);
      _pageCtrl.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOutCubic);
    } else {
      if (!_factoryFormKey.currentState!.validate()) return;
      _completeSetup();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageCtrl.previousPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOutCubic);
    }
  }

  void _completeSetup() {
    ConfirmationDialog.show(
      context,
      title: 'Complete Setup',
      icon: Icons.rocket_launch_rounded,
      fields: [
        ConfirmField(label: 'Owner', value: _nameCtrl.text),
        ConfirmField(label: 'Email', value: _emailCtrl.text),
        ConfirmField(label: 'Factory', value: _factoryNameCtrl.text),
        if (_gstinCtrl.text.isNotEmpty) ConfirmField(label: 'GSTIN', value: _gstinCtrl.text),
        if (_fssaiCtrl.text.isNotEmpty) ConfirmField(label: 'FSSAI', value: _fssaiCtrl.text),
      ],
      confirmLabel: 'Start HM Nuts',
      onConfirm: () async {
        final success = await ProviderScope.containerOf(context, listen: false)
            .read(authProvider.notifier)
            .register(
              _nameCtrl.text,
              _emailCtrl.text,
              _passwordCtrl.text,
              _factoryNameCtrl.text,
            );
        if (success && mounted) {
          context.go('/');
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration failed. Please check your network or try a different email.'), backgroundColor: Colors.red),
          );
        }
      },
    );
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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    if (_currentStep > 0)
                      IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: _prevStep),
                    const Spacer(),
                    TextButton(onPressed: () => context.go('/login'), child: const Text('Cancel')),
                  ],
                ),
              ),
              _buildStepIndicator(cs),
              const SizedBox(height: 24),
              Expanded(
                child: PageView(
                  controller: _pageCtrl,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildOwnerStep(theme),
                    _buildFactoryStep(theme),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity, height: 50,
                  child: ElevatedButton(
                    onPressed: _nextStep,
                    child: Text(_currentStep == 1 ? 'Complete Setup' : 'Continue', style: const TextStyle(fontSize: 16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(ColorScheme cs) {
    const steps = ['Owner', 'Factory'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(2, (i) {
        final isActive = i <= _currentStep;
        return Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: isActive ? cs.primary : cs.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: i < _currentStep
                    ? Icon(Icons.check, size: 16, color: cs.onPrimary)
                    : Text('${i + 1}', style: TextStyle(
                        color: isActive ? cs.onPrimary : cs.onSurface.withValues(alpha: 0.4),
                        fontWeight: FontWeight.w600)),
              ),
            ),
            if (i < 1) ...[
              const SizedBox(width: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 40, height: 2,
                color: i < _currentStep ? cs.primary : cs.surfaceContainerHighest,
              ),
              const SizedBox(width: 4),
            ],
          ],
        );
      }),
    );
  }

  final _ownerFormKey = GlobalKey<FormState>();
  final _factoryFormKey = GlobalKey<FormState>();

  Widget _buildOwnerStep(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: _ownerFormKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Owner Details', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text('Set up the admin account', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 32),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline)),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                if (!v.contains('@')) return 'Invalid email';
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone', prefixIcon: Icon(Icons.phone_outlined)),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _passwordCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password (8+ chars)', prefixIcon: Icon(Icons.lock_outline)),
              validator: (v) => v == null || v.length < 8 ? 'Min 8 chars' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFactoryStep(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: _factoryFormKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Factory Info', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text('Tell us about your factory', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 32),
            TextFormField(
              controller: _factoryNameCtrl,
              decoration: const InputDecoration(labelText: 'Factory Name', prefixIcon: Icon(Icons.factory_outlined)),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _addressCtrl,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Address', prefixIcon: Icon(Icons.location_on_outlined)),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _gstinCtrl,
              decoration: const InputDecoration(labelText: 'GSTIN (Optional)', prefixIcon: Icon(Icons.receipt_long_outlined)),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _fssaiCtrl,
              decoration: const InputDecoration(labelText: 'FSSAI Number (Optional)', prefixIcon: Icon(Icons.verified_outlined)),
            ),
          ],
        ),
      ),
    );
  }
}
