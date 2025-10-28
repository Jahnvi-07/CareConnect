import 'package:supabase_flutter/supabase_flutter.dart';

class OrganisationRepository {
  final SupabaseClient client;
  OrganisationRepository(this.client);

  Future<List<Map<String, dynamic>>> getAllOrganisations() async {
    try {
      // First try a simple query without the join
      final response = await client
          .from('organisations')
          .select('*')
          .order('created_at', ascending: false);
      
      return response.map((org) {
        return {
          'id': org['id'],
          'name': org['name'],
          'category': org['category'] ?? 'NGO',
          'city': org['city'] ?? 'Unknown',
          'address': org['address'] ?? '',
          'phone': org['phone'] ?? '',
          'upiId': org['upi_id'] ?? '',
          'payee': org['name'],
          'suggestedAmount': '500', // Default amount
          'description': org['description'] ?? 'Organization registered via Care Connect',
          'owner_name': org['name'], // Use org name as fallback
        };
      }).toList();
    } catch (e) {
      print('Error fetching organisations: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getOrganisationById(String id) async {
    try {
      final response = await client
          .from('organisations')
          .select('*, profiles!organisations_owner_id_fkey(name)')
          .eq('id', id)
          .single();
      
      return {
        'id': response['id'],
        'name': response['name'],
        'category': response['category'] ?? 'NGO',
        'city': response['city'] ?? 'Unknown',
        'address': response['address'] ?? '',
        'phone': response['phone'] ?? '',
        'upiId': response['upi_id'] ?? '',
        'payee': response['name'],
        'suggestedAmount': '500',
        'description': response['description'] ?? 'Organization registered via Care Connect',
        'owner_name': response['profiles']?['name'] ?? response['name'],
      };
    } catch (e) {
      return null;
    }
  }
}
