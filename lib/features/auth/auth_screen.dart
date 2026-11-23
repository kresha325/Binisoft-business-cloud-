import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text('Auth error: ${snapshot.error}')));
        }
        return snapshot.data == null ? const AuthScreen() : child;
      },
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _register = false;
  bool _busy = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  String _friendlyError(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'Adresa e emailit nuk është e vlefshme.';
      case 'email-already-in-use':
        return 'Ky email është regjistruar tashmë.';
      case 'weak-password':
        return 'Zgjidh një fjalëkalim më të fortë.';
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Emaili ose fjalëkalimi nuk është i saktë.';
      case 'too-many-requests':
        return 'Shumë tentativa. Provo përsëri më vonë.';
      case 'operation-not-allowed':
        return 'Ky lloj regjistrimi nuk është aktivizuar në Firebase.';
      case 'unauthorized-domain':
        return 'Domeni i kësaj faqeje nuk është autorizuar në Firebase.';
      default:
        return 'Autentikimi dështoi (${error.code}).';
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _busy) return;
    setState(() { _busy = true; _error = null; });
    try {
      final email = _email.text.trim();
      final password = _password.text;
      if (_register) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email, password: password,
        );
        await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      } else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email, password: password,
        );
      }
    } on FirebaseAuthException catch (error) {
      if (mounted) setState(() => _error = _friendlyError(error));
    } catch (_) {
      if (mounted) setState(() => _error = 'Ndodhi një gabim. Provo përsëri.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resetPassword() async {
    final email = _email.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Shkruaj emailin për rikthimin e fjalëkalimit.');
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nëse llogaria ekziston, kontrollo emailin.')),
        );
      }
    } on FirebaseAuthException catch (error) {
      if (mounted) setState(() => _error = _friendlyError(error));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.cloud_outlined, size: 54, color: Color(0xFF6557F5)),
                    const SizedBox(height: 20),
                    Text('Binisoft Business Cloud',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    Text(_register ? 'Krijo llogarinë tënde' : 'Hyr në panelin tënd',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(
                        labelText: 'Email', prefixIcon: Icon(Icons.mail_outline),
                        border: OutlineInputBorder()),
                      validator: (value) =>
                        value == null || !value.contains('@') ? 'Shkruaj emailin e vlefshëm' : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _password,
                      obscureText: _obscure,
                      autofillHints: [_register ? AutofillHints.newPassword : AutofillHints.password],
                      decoration: InputDecoration(
                        labelText: 'Fjalëkalimi',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          tooltip: _obscure ? 'Shfaq' : 'Fshih',
                          onPressed: () => setState(() => _obscure = !_obscure),
                          icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                        ),
                      ),
                      validator: (value) =>
                        value == null || value.length < 6 ? 'Minimumi 6 karaktere' : null,
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _busy ? null : _submit,
                      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                      child: _busy
                        ? const SizedBox(height: 20, width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(_register ? 'Regjistrohu' : 'Hyr'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _busy ? null : () => setState(() {
                        _register = !_register;
                        _error = null;
                      }),
                      child: Text(_register ? 'Ke llogari? Hyr' : 'Nuk ke llogari? Regjistrohu'),
                    ),
                    if (!_register)
                      TextButton(onPressed: _busy ? null : _resetPassword,
                        child: const Text('Ke harruar fjalëkalimin?')),
                    const SizedBox(height: 18),
                    const Text('Version pilot • Regjistrimi i biznesit dhe rolet do të shtohen më pas.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
