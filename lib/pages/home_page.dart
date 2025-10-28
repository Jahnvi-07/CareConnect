import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/session.dart';
import '../utils/theme_controller.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String role = ModalRoute.of(context)!.settings.arguments as String? ?? 'user';
    final isOrg = role == 'org';

    final isLoggedIn = Session.currentUserName != null && Session.currentUserName!.isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        title: Text('Care Connect'),
        actions: [
          if (isLoggedIn)
            IconButton(onPressed: () => Navigator.pushNamed(context, '/profile'), icon: Icon(Icons.person_outline)),
          IconButton(
            onPressed: () => ThemeController.toggle(),
            icon: const Icon(Icons.brightness_6_outlined),
          ),
          IconButton(onPressed: () => Navigator.pushNamed(context, '/loginSelect'), icon: Icon(Icons.logout)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Pet of the Day ---
            _PetOfTheDay(),
            SizedBox(height: 16),
            Text('Hello, ${Session.currentUserName ?? (isOrg ? 'Organization' : 'User')}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            SizedBox(height: 6),
            Text('What would you like to do?', style: TextStyle(color: Colors.grey[700])),
            SizedBox(height: 16),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                Chip(label: Text('🐶 Adopt a Dog!')),
                Chip(label: Text('🐱 Cat Companions')),
                Chip(label: Text('🦴 Donate Pet Food')),
                Chip(label: Text('😺 Foster Kittens')),
                Chip(label: Text('🐾 Therapy Pets')),
              ],
            ),
            SizedBox(height: 12),
            _ActionCard(
              icon: Icons.volunteer_activism_outlined,
              title: 'Find Caregivers',
              subtitle: 'Skilled caregivers available by city and skill',
              onTap: () => Navigator.pushNamed(context, '/list', arguments: {'type': 'caregivers'}),
            ),
            SizedBox(height: 12),
            _ActionCard(
              icon: Icons.home_outlined,
              title: 'Find Shelters',
              subtitle: 'Locate nearby shelters with availability',
              onTap: () => Navigator.pushNamed(context, '/list', arguments: {'type': 'shelters'}),
            ),
            SizedBox(height: 12),
            _ActionCard(
              icon: Icons.apartment_outlined,
              title: 'Browse Organisations',
              subtitle: 'Discover NGOs and support their work',
              onTap: () => Navigator.pushNamed(context, '/list', arguments: {'type': 'organisations'}),
            ),
            SizedBox(height: 18),
            if (isOrg)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Organization Dashboard (demo)', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text('You can add caregivers, view requests, and manage availability.'),
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

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(kRadius),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: kPrimary.withOpacity(0.1),
                child: Icon(icon, color: kPrimary),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontWeight: FontWeight.w700)),
                    SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(color: Colors.grey[700])),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// Pet of the Day Widget
class _PetOfTheDay extends StatelessWidget {
  static final _pets = [
    {'emoji': '🐶', 'name': 'Buddy', 'desc': 'Looking for a forever home!'},
    {'emoji': '🐱', 'name': 'Mittens', 'desc': 'Sweet cat who loves naps.'},
    {'emoji': '🐕', 'name': 'Rex', 'desc': 'Loyal friend and good boy.'},
    {'emoji': '🐈', 'name': 'Luna', 'desc': 'Elegant and gentle.'},
    {'emoji': '🐾', 'name': 'Shadow', 'desc': 'Mysterious but caring!'},
  ];
  _PetOfTheDay();

  @override
  Widget build(BuildContext context) {
    final pet = _pets[DateTime.now().day % _pets.length];
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.9),
      child: ListTile(
        leading: Text(pet['emoji']!, style: const TextStyle(fontSize: 36)),
        title: Text('${pet['name']} — Pet of the Day!', style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(pet['desc']!),
        trailing: const Icon(Icons.favorite, color: Colors.pinkAccent),
      ),
    );
  }
}
