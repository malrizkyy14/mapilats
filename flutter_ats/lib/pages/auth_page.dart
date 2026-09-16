
import 'package:flutter/material.dart';

import '../services/api_client.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key, required this.onAuthenticated});
  final void Function(String token, String name, String email) onAuthenticated;
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLogin = true;
  bool loading = false;

  Future<void> submit() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.length < 6 ||
        (!isLogin && nameController.text.trim().isEmpty)) {
      _message(
        isLogin
            ? 'Email dan password minimal 6 karakter wajib diisi.'
            : 'Nama, email, dan password minimal 6 karakter wajib diisi.',
      );
      return;
    }
    setState(() => loading = true);
    try {
      final api = ApiClient();
      if (isLogin) {
        final result = await api.login(
          emailController.text.trim(),
          passwordController.text,
        );
        final data = Map<String, dynamic>.from(result['data']);
        widget.onAuthenticated(
          data['token'].toString(),
          Map<String, dynamic>.from(data['user'])['name'].toString(),
          Map<String, dynamic>.from(data['user'])['email'].toString(),
        );
      } else {
        await api.register(
          nameController.text.trim(),
          emailController.text.trim(),
          passwordController.text,
        );
        if (mounted) {
          _message('Registrasi berhasil. Silakan login.');
          setState(() => isLogin = true);
        }
      }
    } catch (error) {
      _message(error is ApiException ? error.message : 'Terjadi kesalahan.');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: const Color(0xffded1c6)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xff3a2921).withValues(alpha: 0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Center(
                      child: Text(
                        'M',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    isLogin ? 'Login to Malrizky App' : 'Register to Malrizky App',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isLogin
                        ? 'Log in to manage your articles.'
                        : 'Create an account to manage the malrizky blog.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: const Color(0xff66564d),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (!isLogin) ...[
                    TextField(
                      controller: nameController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Nama lengkap',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.alternate_email_rounded),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    onSubmitted: (_) => submit(),
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock_outline_rounded),
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: loading ? null : submit,
                      child: loading
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              isLogin ? 'Masuk' : 'Daftar',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Center(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xff6f4632),
                      ),
                      onPressed: loading
                          ? null
                          : () => setState(() => isLogin = !isLogin),
                      child: Text(
                        isLogin ? 'Belum punya akun? Daftar' : 'Sudah punya akun? Masuk',
                        style: const TextStyle(fontWeight: FontWeight.w600),
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
  );
}
