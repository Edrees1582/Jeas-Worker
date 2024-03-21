// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jeas_worker/models/custom_user.dart';
import 'package:jeas_worker/resources/database.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ServiceDetailsWorkerScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference workers =
      FirebaseFirestore.instance.collection('workers');
  final CollectionReference requests =
      FirebaseFirestore.instance.collection('requests');

  ServiceDetailsWorkerScreen({super.key, required this.data});

  @override
  _ServiceDetailsWorkerScreenState createState() =>
      _ServiceDetailsWorkerScreenState();
}

class _ServiceDetailsWorkerScreenState
    extends State<ServiceDetailsWorkerScreen> {
  String status = "";

  @override
  void initState() {
    super.initState();
    status = widget.data['status'];
  }

  Future<Map<String, dynamic>> getRequesterInfo(String requesterUid) async {
    DocumentSnapshot doc = await widget.users.doc(requesterUid).get();
    return doc.data() as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getWorkerInfo(String workerUid) async {
    DocumentSnapshot doc = await widget.workers.doc(workerUid).get();
    return doc.data() as Map<String, dynamic>;
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    Uri url = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.data['title']),
      ),
      body: StreamBuilder(
        stream: widget.requests.doc(widget.data['uid']).snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
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

          Map<String, dynamic> data = widget.data;

          if (!snapshot.hasData || snapshot.data!.data() == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pop(context);
            });
          } else {
            data = snapshot.data!.data() as Map<String, dynamic>;
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Title: ${data['title']}'),
                Text('Description: ${data['description']}'),
                Text('Location: ${data['location']}'),
                Text('Service Type: ${data['serviceType']}'),
                Text('Service Category: ${data['serviceCategory']}'),
                Text('Status: ${data['status']}'),
                if (data['status'] == 'Accepted' &&
                    Provider.of<CustomUser?>(context, listen: false)!.uid ==
                        data['workerUID'])
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          DatabaseService(
                                  uid: Provider.of<CustomUser?>(context,
                                          listen: false)!
                                      .uid)
                              .completeRequestService(widget.data['uid']);
                        },
                        child: const Text('Complete Service'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          DatabaseService(
                                  uid: Provider.of<CustomUser?>(context,
                                          listen: false)!
                                      .uid)
                              .cancelRequestService(widget.data['uid']);
                        },
                        child: const Text('Cancel Service'),
                      ),
                    ],
                  ),
                if (data['status'] == 'Pending')
                  ElevatedButton(
                    onPressed: () {
                      DatabaseService(
                              uid: Provider.of<CustomUser?>(context,
                                      listen: false)!
                                  .uid)
                          .acceptRequestService(widget.data['uid']);
                    },
                    child: const Text('Accept Request'),
                  ),
                FutureBuilder(
                  future: getRequesterInfo(data['requesterUID']),
                  builder:
                      (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      Map<String, dynamic>? requesterData = snapshot.data;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Requester Name: ${requesterData?['name']}'),
                          Text(
                              'Requester Phone Number: ${requesterData?['phoneNumber']}'),
                          ElevatedButton(
                            onPressed: () {
                              _makePhoneCall(requesterData?['phoneNumber']);
                            },
                            child: const Text('Call Requester'),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
