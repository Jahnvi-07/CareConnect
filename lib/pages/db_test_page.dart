import 'package:flutter/material.dart';
import '../utils/supabase_service.dart';

class DbTestPage extends StatefulWidget {
  @override
  _DbTestPageState createState() => _DbTestPageState();
}

class _DbTestPageState extends State<DbTestPage> {
  String status = 'Ready to test';
  List<Map<String, dynamic>> orgs = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Database Test')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text(status, style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _testDatabase,
              child: Text('Test Database Connection'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _testOrganisations,
              child: Text('Test Organisations Table'),
            ),
            SizedBox(height: 20),
            if (orgs.isNotEmpty) ...[
              Text('Found ${orgs.length} organisations:', style: TextStyle(fontWeight: FontWeight.bold)),
              Expanded(
                child: ListView.builder(
                  itemCount: orgs.length,
                  itemBuilder: (context, index) {
                    final org = orgs[index];
                    return Card(
                      child: ListTile(
                        title: Text(org['name'] ?? 'Unknown'),
                        subtitle: Text('ID: ${org['id']}'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _testDatabase() async {
    setState(() => status = 'Testing database connection...');
    
    try {
      // Test basic connection
      await SupabaseService.client
          .from('profiles')
          .select('count')
          .limit(1);
      
      setState(() => status = 'Database connection successful!');
    } catch (e) {
      setState(() => status = 'Database error: $e');
    }
  }

  Future<void> _testOrganisations() async {
    setState(() => status = 'Testing organisations table...');
    
    try {
      final response = await SupabaseService.client
          .from('organisations')
          .select('*');
      
      setState(() {
        orgs = List<Map<String, dynamic>>.from(response);
        status = 'Found ${orgs.length} organisations';
      });
    } catch (e) {
      setState(() => status = 'Organisations error: $e');
    }
  }
}
