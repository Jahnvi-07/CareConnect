import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/supabase_service.dart';
import '../utils/session.dart';

class OrgRegistrationPage extends StatefulWidget {
  @override
  _OrgRegistrationPageState createState() => _OrgRegistrationPageState();
}

class _OrgRegistrationPageState extends State<OrgRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _registrationIdController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _registrationIdController.dispose();
    _contactPersonController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register Organization'), backgroundColor: kPrimary),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Organization Name'),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Official Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => (v == null || !v.contains('@')) ? 'Enter valid email' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (v) => (v == null || v.length < 6) ? 'Min 6 characters' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Address'),
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _registrationIdController,
                decoration: InputDecoration(labelText: 'Registration / License ID'),
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _contactPersonController,
                decoration: InputDecoration(labelText: 'Contact Person (Name)'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: _isLoading ? CircularProgressIndicator() : Text('Register Organization'),
                ),
                onPressed: _isLoading ? null : _registerOrg,
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _registerOrg() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // 1. Create organization account in Supabase Auth
      final response = await SupabaseService.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        data: {
          'role': 'org',
          'name': _nameController.text.trim(),
        },
      );

      if (response.user != null) {
        // 2. Create profile record
        await SupabaseService.client.from('profiles').insert({
          'id': response.user!.id,
          'role': 'org',
          'name': _contactPersonController.text.trim().isNotEmpty 
              ? _contactPersonController.text.trim() 
              : _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
        });

        // 3. Create organization record
        await SupabaseService.client.from('organisations').insert({
          'owner_id': response.user!.id,
          'name': _nameController.text.trim(),
          'category': 'NGO', // Default category
          'address': _addressController.text.trim(),
          'phone': _phoneController.text.trim(),
          'upi_id': '${_nameController.text.trim().toLowerCase().replaceAll(' ', '')}@upi',
          'description': 'Organization registered via Care Connect',
        });

        // 4. Set session and navigate
        Session.currentRole = 'org';
        Session.currentUserName = _nameController.text.trim();
        
        if (mounted) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text('Registered Successfully'),
              content: Text('Organization "${_nameController.text.trim()}" registered!'),
              actions: [
                TextButton(
                  onPressed: () { 
                    Navigator.pop(context); 
                    Navigator.pushReplacementNamed(context, '/home', arguments: 'org');
                  }, 
                  child: Text('OK')
                )
              ],
            ),
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
