import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instawash/models/user_model.dart';
import 'package:instawash/presentation/screens/signupuser.dart';
import 'package:instawash/presentation/screens/userdetails.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController searchController = TextEditingController();
  List<UserModel> users = [];
  bool isLoading = false;
  DocumentSnapshot? lastDocument;
  bool hasMore = true;
  final int limit = 10;
  final ScrollController _scrollController = ScrollController();
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    fetchUsers();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        fetchUsers();
      }
    });
  }

  Future<void> fetchUsers() async {
    if (isLoading || !hasMore) return;

    setState(() => isLoading = true);

    Query query =
        _firestore.collection('users').orderBy('fullName').limit(limit);

    if (searchQuery.isNotEmpty) {
      query = _firestore
          .collection('users')
          .where('searchKeywords', arrayContains: searchQuery.toLowerCase())
          .limit(limit);
    }

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument!);
    }

    QuerySnapshot querySnapshot = await query.get();
    List<DocumentSnapshot> newDocs = querySnapshot.docs;

    if (newDocs.isNotEmpty) {
      lastDocument = newDocs.last;
      users.addAll(newDocs.map((doc) => UserModel.fromSnapshot(doc)).toList());
    } else {
      hasMore = false;
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User List'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search by ID, Name, Role',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                  users.clear();
                  lastDocument = null;
                  hasMore = true;
                });
                fetchUsers();
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: users.length + (isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == users.length) {
                  return Center(child: CircularProgressIndicator());
                }

                UserModel user = users[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey[300],
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: user.imageUrl,
                          fit: BoxFit.cover,
                          width: 100,
                          height: 100,
                          placeholder: (context, url) => Center(
                            child: CupertinoActivityIndicator(),
                          ),
                          errorWidget: (context, url, error) => Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    title: Text(user.fullName),
                    subtitle: Text(user.role),
                    trailing: Icon(Icons.arrow_forward),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserDetailsPage(user: user),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => SignUpScreen2()),
        child: Icon(Icons.add),
      ),
    );
  }
}
