import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'org_details_page.dart';

class ListPage extends StatefulWidget {
  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  String type = 'caregivers'; // Initialize with default value
  List<Map<String, dynamic>> items = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    type = args != null && args['type'] == 'shelters'
        ? 'shelters'
        : (args != null && args['type'] == 'organisations' ? 'organisations' : 'caregivers');

    print('Loading data for type: $type');

    try {
      if (type == 'organisations') {
        print('Fetching organisations from Supabase...');
        // For now, use dummy data until we debug the database issue
        setState(() {
          items = dummyOrganisations; // Use dummy data for now
          isLoading = false;
        });
        print('Using dummy organisations for now');
        
        // TODO: Uncomment this when database is working
        // final orgRepo = OrganisationRepository(SupabaseService.client);
        // final orgs = await orgRepo.getAllOrganisations().timeout(
        //   Duration(seconds: 10),
        //   onTimeout: () {
        //     print('Timeout fetching organisations');
        //     return <Map<String, dynamic>>[];
        //   },
        // );
        // print('Found ${orgs.length} organisations');
        // setState(() {
        //   items = orgs;
        //   isLoading = false;
        // });
      } else {
        // Use dummy data for caregivers and shelters
        setState(() {
          items = type == 'shelters' ? dummyShelters : dummyCaregivers;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(type == 'shelters'
            ? 'Shelters'
            : (type == 'organisations' ? 'Organisations' : 'Caregivers')),
        // Show profile icon only if logged in is known via Supabase (avoid importing here to keep file lean)
      ),
      body: isLoading
          ? Center(child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                CircularProgressIndicator(),
                SizedBox(height: 12),
                Text('Fetching furry friends...'),
                SizedBox(height: 10),
                Text('🐶🐱', style: TextStyle(fontSize: 24)),
              ],
            ))
          : error != null
              ? Center(child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.sentiment_dissatisfied, size: 40),
                    const SizedBox(height: 8),
                    Text('Error: $error'),
                    const Text('🐶🐱', style: TextStyle(fontSize: 22)),
                  ],
                ))
              : items.isEmpty
                  ? Center(child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.search_off, size: 40),
                        const SizedBox(height: 8),
                        Text('No ${type == 'organisations' ? 'organisations' : type} found'),
                        const Text('🦴😺', style: TextStyle(fontSize: 22)),
                      ],
                    ))
                  : RefreshIndicator(
                      onRefresh: () async {
                        setState(() {
                          isLoading = true;
                        });
                        await Future.delayed(Duration(milliseconds: 300));
                        _loadData();
                      },
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.all(12),
                        itemCount: items.length,
                        itemBuilder: (_, i) {
                          final item = items[i];
                          // Show relevant animal emoji: for organisations by category, for others generic
                          String? animalIcon;
                          if (type == 'organisations') {
                            final category = (item['category'] ?? '').toString().toLowerCase();
                            if (category.contains('dog')) {
                              animalIcon = '🐶';
                            } else if (category.contains('cat')) {
                              animalIcon = '🐱';
                            }
                          } else if (type == 'caregivers') {
                            animalIcon = '🐾';
                          } else if (type == 'shelters') {
                            animalIcon = '🏠';
                          }
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Card(
                              child: ListTile(
                                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                leading: CircleAvatar(
                                  backgroundColor: kPrimary.withOpacity(0.12),
                                  child: animalIcon != null
                                      ? Text(animalIcon, style: const TextStyle(fontSize: 24))
                                      : Icon(type == 'shelters'
                                          ? Icons.home
                                          : (type == 'organisations' ? Icons.apartment : Icons.person)),
                                ),
                                title: Text(item['name'] ?? ''),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      type == 'shelters'
                                          ? '${item['location']} • ${item['capacity']}'
                                          : (type == 'organisations'
                                              ? '${item['category']} • ${item['city']}'
                                              : '${item['skill']} • ${item['location']}'),
                                    ),
                                    if (type == 'organisations' && (item['description']?.isNotEmpty ?? false))
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4.0),
                                        child: Text(
                                          item['description'],
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: type == 'organisations'
                                    ? Icon(Icons.qr_code)
                                    : IconButton(
                                        icon: Icon(Icons.phone),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (_) => AlertDialog(
                                              title: Text('Contact'),
                                              content: Text('Call ${item[type == 'shelters' ? 'contact' : 'phone']} (demo)'),
                                              actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('OK'))],
                                            ),
                                          );
                                        },
                                      ),
                                onTap: () {
                                  if (type == 'organisations') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const OrganisationDetailsPage(),
                                        settings: RouteSettings(arguments: Map<String, String>.from(item)),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
