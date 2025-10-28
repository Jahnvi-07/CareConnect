import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/constants.dart';
import '../utils/supabase_service.dart';
import '../utils/session.dart' as app_session;
import '../utils/theme_controller.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _loading = true;
  String? _name;
  String? _email;
  String? _error;
  List<Map<String, dynamic>> _donations = [];
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final user = SupabaseService.client.auth.currentUser;
      if (user == null) {
        setState(() {
          _error = 'Not logged in';
          _loading = false;
        });
        return;
      }

      _email = user.email;

      final profile = await SupabaseService.client
          .from('profiles')
          .select('name')
          .eq('id', user.id)
          .maybeSingle();

      _name = (profile != null ? profile['name'] as String? : null) ?? 'User';

      final donationRows = await SupabaseService.client
          .from('chats')
          .select('id, last_message_at, organisations(name)')
          .eq('user_id', user.id)
          .eq('is_payment_confirmed', true)
          .order('last_message_at', ascending: false);

      _donations = List<Map<String, dynamic>>.from(donationRows);

      setState(() {
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _logout() async {
    try {
      await SupabaseService.client.auth.signOut();
      app_session.Session.currentUserName = null;
      app_session.Session.currentRole = 'user';
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/loginSelect', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ' + e.toString())));
      }
    }
  }

  Future<void> _changeName() async {
    final user = SupabaseService.client.auth.currentUser;
    if (user == null) return;
    _nameCtrl.text = _name ?? '';
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Change Name'),
        content: TextField(
          controller: _nameCtrl,
          decoration: const InputDecoration(labelText: 'Name'),
          textInputAction: TextInputAction.done,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              try {
                final newName = _nameCtrl.text.trim();
                if (newName.isEmpty) return;
                await SupabaseService.client.from('profiles').update({'name': newName}).eq('id', user.id);
                if (mounted) {
                  Navigator.pop(context);
                  setState(() => _name = newName);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name updated')));
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ' + e.toString())));
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _changeEmail() async {
    final user = SupabaseService.client.auth.currentUser;
    if (user == null) return;
    _emailCtrl.text = _email ?? '';
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Change Email'),
        content: TextField(
          controller: _emailCtrl,
          decoration: const InputDecoration(labelText: 'Email'),
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              try {
                final newEmail = _emailCtrl.text.trim();
                if (!newEmail.contains('@')) return;
                await SupabaseService.client.auth.updateUser(UserAttributes(email: newEmail));
                if (mounted) {
                  Navigator.pop(context);
                  setState(() => _email = newEmail);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email update requested. Check inbox for verification.')));
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ' + e.toString())));
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _changePassword() async {
    _passwordCtrl.text = '';
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Change Password'),
        content: TextField(
          controller: _passwordCtrl,
          decoration: const InputDecoration(labelText: 'New Password'),
          obscureText: true,
          textInputAction: TextInputAction.done,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              try {
                final newPwd = _passwordCtrl.text;
                if (newPwd.length < 6) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password must be at least 6 characters')));
                  }
                  return;
                }
                await SupabaseService.client.auth.updateUser(UserAttributes(password: newPwd));
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password updated')));
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ' + e.toString())));
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Profile'),
        actions: [
          IconButton(onPressed: () => ThemeController.toggle(), icon: const Icon(Icons.brightness_6_outlined)),
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: ' + _error!))
              : RefreshIndicator(
                  onRefresh: _fetchData,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Card(
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.badge_outlined),
                              title: const Text('Change Name'),
                              onTap: _changeName,
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(Icons.mail_outline),
                              title: const Text('Change Email'),
                              onTap: _changeEmail,
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(Icons.lock_outline),
                              title: const Text('Change Password'),
                              onTap: _changePassword,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: kPrimary.withOpacity(0.12),
                            child: const Icon(Icons.person, color: Colors.black54),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_name ?? 'User', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                                if (_email != null)
                                  Text(_email!, style: TextStyle(color: Colors.grey[700])),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Donation History', style: TextStyle(fontWeight: FontWeight.w700)),
                              const SizedBox(height: 8),
                              if (_donations.isEmpty)
                                Text('No confirmed donations yet.', style: TextStyle(color: Colors.grey[700]))
                              else
                                ..._donations.map((d) {
                                  final org = d['organisations'] as Map<String, dynamic>?;
                                  final orgName = org != null ? (org['name'] as String? ?? 'Organisation') : 'Organisation';
                                  final when = d['last_message_at'] as String?;
                                  return ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    leading: CircleAvatar(
                                      backgroundColor: kPrimary.withOpacity(0.12),
                                      child: const Icon(Icons.volunteer_activism, color: Colors.black54),
                                    ),
                                    title: Text(orgName),
                                    subtitle: when != null ? Text(DateTime.tryParse(when)?.toLocal().toString() ?? when) : null,
                                  );
                                }),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}


