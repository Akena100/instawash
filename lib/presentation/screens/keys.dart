import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instawash/core/constants/colors.dart';
import 'package:instawash/forms/key.dart';
// Import the AddDataForm widget

class DisplayDataPage extends StatelessWidget {
  const DisplayDataPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Display'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('keys').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            children: snapshot.data!.docs.map((document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              return Container(
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: AppColors.secondaryColor,
                      borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    title: Text(
                      data['name'],
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      data['id'],
                      style: const TextStyle(color: Colors.white),
                    ),
                  ));
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddDataForm()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
