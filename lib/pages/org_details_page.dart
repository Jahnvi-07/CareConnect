import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'chat_page.dart';

class OrganisationDetailsPage extends StatelessWidget {
  const OrganisationDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, String> org = ModalRoute.of(context)!.settings.arguments as Map<String, String>;

    final String name = org['name'] ?? 'Organisation';
    final String category = org['category'] ?? 'NGO';
    final String city = org['city'] ?? '';
    final String address = org['address'] ?? '';
    final String phone = org['phone'] ?? '';
    final String upiId = org['upiId'] ?? '';
    final String payee = org['payee'] ?? name;
    final String suggestedAmount = org['suggestedAmount'] ?? '500';
    final String description = org['description'] ?? '';

    // Fake QR data string (demo): UPI intent style
    final String qrData = 'upi://pay?pa=$upiId&pn=${Uri.encodeComponent(payee)}&am=$suggestedAmount&cu=INR';

    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Builder(builder: (context) {
              String emoji = '🐾';
              final categoryLow = (category.toLowerCase());
              if (categoryLow.contains('dog')) emoji = '🐶';
              if (categoryLow.contains('cat')) emoji = '🐱';
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE4EC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 8),
                    const Expanded(child: Text('Every little support helps a furry friend find a home.')),
                  ],
                ),
              );
            }),
          ),
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: kPrimary.withOpacity(0.12),
                child: const Icon(Icons.home),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('$category • $city', style: TextStyle(color: Colors.grey[700])),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(description),
          const SizedBox(height: 16),
          Row(children: [const Icon(Icons.place, size: 18), const SizedBox(width: 6), Expanded(child: Text(address))]),
          const SizedBox(height: 6),
          Row(children: [const Icon(Icons.phone, size: 18), const SizedBox(width: 6), Text(phone)]),
          const SizedBox(height: 20),

          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadius)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Support via UPI (Demo)', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  // Placeholder box for QR; replaced by qr_flutter if available
                  _QrBox(data: qrData),
                  const SizedBox(height: 12),
                  Text('UPI ID: $upiId'),
                  Text('Payee: $payee'),
                  Text('Suggested: ₹$suggestedAmount'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('I Paid (Demo)'),
                  )
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.chat_bubble_outline),
            label: const Text('Chat with Organisation'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ChatPage(),
                  settings: RouteSettings(arguments: name),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _QrBox extends StatelessWidget {
  final String data;
  const _QrBox({required this.data});

  @override
  Widget build(BuildContext context) {
    // If you later add qr_flutter, you can swap this with QrImage(data: data)
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kPrimary.withOpacity(0.4)),
      ),
      alignment: Alignment.center,
      child: Text('QR (demo)\n${data.substring(0, data.length > 60 ? 60 : data.length)}...', textAlign: TextAlign.center),
    );
  }
}


