import 'package:flutter/material.dart';
import '../utils/session.dart';
import '../utils/supabase_service.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String role = ModalRoute.of(context)!.settings.arguments as String? ?? 'user';
    final isOrg = role == 'org';

    return Scaffold(
      appBar: AppBar(
        title: Text(isOrg ? 'Organization Login' : 'User Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => (v == null || !v.contains('@')) ? 'Enter valid email' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (v) => (v == null || v.length < 4) ? 'Min 4 chars' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: _isLoading ? CircularProgressIndicator() : Text('Login'),
                onPressed: _isLoading ? null : () => _login(isOrg),
              ),
              SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Back'),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _login(bool isOrg) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await SupabaseService.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (response.user != null) {
        // Get user role from profile
        final profileResponse = await SupabaseService.client
            .from('profiles')
            .select('role, name')
            .eq('id', response.user!.id)
            .single();

        final userRole = profileResponse['role'] as String? ?? 'user';
        final userName = profileResponse['name'] as String? ?? '';

        // Set session
        Session.currentRole = userRole;
        Session.currentUserName = userName;

        if (mounted) {
          Navigator.pushReplacementNamed(
            context,
            '/home',
            arguments: userRole,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
