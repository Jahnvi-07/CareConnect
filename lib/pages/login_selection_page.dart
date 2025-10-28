import 'package:flutter/material.dart';
import 'package:care_connect/pages/login_type_selection_page.dart';
import 'package:care_connect/pages/signup_selection_page.dart';
import 'package:care_connect/pages/home_page.dart';
import 'package:care_connect/pages/org_details_page.dart';
import 'package:care_connect/utils/constants.dart';
import 'package:care_connect/utils/supabase_service.dart';
import 'package:care_connect/utils/theme_controller.dart';
import 'package:care_connect/utils/session.dart';

class LoginSelectionPage extends StatefulWidget {
  const LoginSelectionPage({super.key});

  @override
  State<LoginSelectionPage> createState() => _LoginSelectionPageState();
}

class _LoginSelectionPageState extends State<LoginSelectionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Care Connect"),
        actions: [
          if (SupabaseService.client.auth.currentUser != null)
            IconButton(
              icon: const Icon(Icons.person_outline),
              onPressed: () => Navigator.pushNamed(context, '/profile'),
            ),
          IconButton(
            icon: const Icon(Icons.brightness_6_outlined),
            onPressed: () => ThemeController.toggle(),
          ),
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => _showSidebar(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Welcome section
          PawBackdrop(
            child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  kPrimary.withOpacity(0.14),
                  kPrimary.withOpacity(0.06),
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                const Text('🐾', style: TextStyle(fontSize: 38)),
                const SizedBox(height: 6),
                const Text(
                  "Welcome to Care Connect",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "Support NGOs, dog rescues & cat shelters making a difference",
                  style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                ),
              ],
            ),
            ),
          ),
          
          // Organizations list
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Featured Organizations",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: dummyOrganisations.length,
                      itemBuilder: (context, index) {
                        final org = dummyOrganisations[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: CircleAvatar(
                              backgroundColor: kPrimary.withOpacity(0.1),
                              child: const Icon(Icons.apartment, color: kPrimary),
                            ),
                            title: Text(
                              org['name'] ?? '',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${org['category']} • ${org['city']}'),
                                const SizedBox(height: 4),
                                Text(
                                  org['description'] ?? '',
                                  style: const TextStyle(fontSize: 12),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const OrganisationDetailsPage(),
                                  settings: RouteSettings(arguments: Map<String, String>.from(org)),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSidebar(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Menu",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            if (SupabaseService.client.auth.currentUser == null) ...[
              _buildMenuOption(
                icon: Icons.login,
                title: "Login",
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginTypeSelectionPage()),
                  );
                },
              ),
              _buildMenuOption(
                icon: Icons.person_add,
                title: "Sign Up",
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SignUpSelectionPage()),
                  );
                },
              ),
            ] else ...[
              _buildMenuOption(
                icon: Icons.logout,
                title: "Logout",
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    await SupabaseService.client.auth.signOut();
                    Session.currentUserName = null;
                    Session.currentRole = 'user';
                    if (mounted) {
                      Navigator.pushNamedAndRemoveUntil(context, '/loginSelect', (route) => false);
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ' + e.toString())));
                    }
                  }
                },
              ),
            ],
            
            if (SupabaseService.client.auth.currentUser != null)
              _buildMenuOption(
                icon: Icons.person,
                title: "Profile",
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/profile');
                },
              ),
            
            _buildMenuOption(
              icon: Icons.history,
              title: "Donation History",
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to donation history
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Donation history coming soon!')),
                );
              },
            ),
            
            _buildMenuOption(
              icon: Icons.info,
              title: "About This App",
              onTap: () {
                Navigator.pop(context);
                _showAboutDialog(context);
              },
            ),
            
            const Spacer(),
            
            // Continue as Guest button (hide when logged in)
            if (SupabaseService.client.auth.currentUser == null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => HomePage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black,
                  ),
                  child: const Text("Continue as Guest"),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: kPrimary),
      title: Text(title),
      onTap: onTap,
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("About Care Connect"),
        content: const Text(
          "Care Connect is a platform that directly connects donors with NGOs and organizations making a difference in the community. "
          "Support causes you care about through direct donations and transparent communication.\n\n"
          "Features:\n"
          "• Browse verified organizations\n"
          "• Direct communication with NGOs\n"
          "• Secure payment processing\n"
          "• Track your donation history",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }
}
