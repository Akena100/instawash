import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instawash/core/constants/colors.dart';
import 'package:instawash/drawer.dart';
import 'package:instawash/forms/visitor.dart';
import 'package:instawash/presentation/screens/visitor_details.dart';

class VisitorListPage extends StatefulWidget {
  const VisitorListPage({super.key});

  @override
  _VisitorListPageState createState() => _VisitorListPageState();
}

class _VisitorListPageState extends State<VisitorListPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        title: Text('Visitor List', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.secondaryColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      drawer: CustomDrawer(),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Field
            TextField(
              decoration: InputDecoration(
                labelText: 'Search Visitor',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                labelStyle: TextStyle(
                  color: Colors.white,
                ),
                prefixIconColor: Colors.white,
              ),
              onChanged: (query) {
                setState(() {
                  _searchQuery = query.toLowerCase();
                });
              },
            ),
            SizedBox(height: 16),
            // StreamBuilder to display visitor data from Firestore
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('visitors').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No visitors found'));
                  }

                  var visitors = snapshot.data!.docs;

                  return SingleChildScrollView(
                    scrollDirection:
                        Axis.horizontal, // Allow horizontal scrolling
                    child: DataTable(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15)),
                      columns: const <DataColumn>[
                        DataColumn(label: Text('Visitor ID')),
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Visitor Type')),
                        DataColumn(label: Text('Action')),
                      ],
                      rows: visitors.map((visitor) {
                        String visitorID = visitor['visitorID'] ?? '';
                        String firstName = visitor['firstName'] ?? '';
                        String lastName = visitor['lastName'] ?? '';
                        String visitorType = visitor['visitorType'] ?? '';

                        // Filtering based on search query
                        if (!_matchesSearchQuery(
                            visitorID, firstName, lastName, visitorType)) {
                          return DataRow(
                              cells: []); // Do not show this item if it doesn't match the search query
                        }

                        return DataRow(
                          cells: [
                            DataCell(Text(visitorID)),
                            DataCell(Text('$firstName $lastName')),
                            DataCell(Text(visitorType)),
                            DataCell(
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.view_agenda),
                                    onPressed: () {
                                      // Navigate to the details page
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              VisitorDetailPage(
                                            visitorData: visitor.data()
                                                as Map<String, dynamic>,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () {
                                      // Navigate to the details page
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => VisitorForm(
                                            visitorID: visitorID,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      // Navigate to the details page

                                      FirebaseFirestore.instance
                                          .collection('visitor')
                                          .doc(visitorID)
                                          .delete();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content:
                                                  Text('Visitor Deleted')));
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => VisitorForm());
        },
        child: Icon(Icons.add),
      ),
    );
  }

  bool _matchesSearchQuery(
      String visitorID, String firstName, String lastName, String visitorType) {
    return visitorID.toLowerCase().contains(_searchQuery) ||
        firstName.toLowerCase().contains(_searchQuery) ||
        lastName.toLowerCase().contains(_searchQuery) ||
        visitorType.toLowerCase().contains(_searchQuery);
  }
}
