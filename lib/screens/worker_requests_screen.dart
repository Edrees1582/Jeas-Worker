import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jeas_worker/models/custom_user.dart';
import 'package:jeas_worker/resources/auth_methods.dart';
import 'package:jeas_worker/screens/service_details_worker_screen.dart';
import 'package:provider/provider.dart';

class WorkerRequestsScreen extends StatelessWidget {
  final CollectionReference serviceRequests =
      FirebaseFirestore.instance.collection('requests');
  final AuthMethods _auth = AuthMethods();

  WorkerRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Requested Services'),
        actions: <Widget>[
          TextButton.icon(
              onPressed: () async {
                await _auth.logout();
              },
              icon: const Icon(Icons.person),
              label: const Text('logout')),
        ],
      ),
      body: StreamBuilder(
        stream: serviceRequests.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          List<DocumentSnapshot> documents = snapshot.data!.docs;
          List<DocumentSnapshot> filteredDocuments =
              documents.where((document) {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            return (Provider.of<CustomUser?>(context, listen: false)!.uid ==
                        data['workerUID'] &&
                    (data['status'] == 'Accepted' ||
                        data['status'] == 'Completed')) ||
                data['status'] == 'Pending';
          }).toList();

          return filteredDocuments.isEmpty
              ? const Center(
                  child: Text('No requests'),
                )
              : ListView.builder(
                  itemCount: filteredDocuments.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> data =
                        filteredDocuments[index].data() as Map<String, dynamic>;

                    return ListTile(
                      title: Text(data['title']),
                      subtitle: Text(data['description']),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ServiceDetailsWorkerScreen(data: data)),
                        );
                      },
                    );
                  },
                );
          // ListView(
          //   children: snapshot.data!.docs.map((DocumentSnapshot document) {
          //     Map<String, dynamic> data =
          //         document.data() as Map<String, dynamic>;
          //     data['requestId'] = document.id;
          //     if ((Provider.of<CustomUser?>(context, listen: false)!.uid ==
          //                 data['workerUID'] &&
          //             (data['status'] == 'Accepted' ||
          //                 data['status'] == 'Completed')) ||
          //         data['status'] == 'Pending') {}
          //     return ListTile(
          //       title: Text(data['title']),
          //       subtitle: Text(data['description']),
          //       onTap: () {
          //         Navigator.push(
          //           context,
          //           MaterialPageRoute(
          //               builder: (context) =>
          //                   WorkerServiceDetailsScreen(data: data)),
          //         );
          //       },
          //     );
          //   }).toList(),
          // );
        },
      ),
    );
  }
}
