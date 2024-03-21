import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String uid;
  DatabaseService({required this.uid});

  final CollectionReference requestCollection =
      FirebaseFirestore.instance.collection('requests');

  final CollectionReference workerCollection =
      FirebaseFirestore.instance.collection('workers');

  void acceptRequestService(
    String requestId,
  ) async {
    await requestCollection.doc(requestId).update({
      'workerUID': uid,
      'status': 'Accepted',
    });
    await workerCollection.doc(uid).update({
      "requests": FieldValue.arrayUnion([requestId]),
    });
  }

  void completeRequestService(
    String requestId,
  ) async {
    await requestCollection.doc(requestId).update({
      'workerUID': uid,
      'status': 'Completed',
    });
  }

  void cancelRequestService(
    String requestId,
  ) async {
    await requestCollection.doc(requestId).update({
      'workerUID': uid,
      'status': 'Pending',
    });

    DocumentSnapshot documentSnapshot =
        await FirebaseFirestore.instance.collection('workers').doc(uid).get();

    List<dynamic> newArray = List.from(documentSnapshot['requests']);
    newArray.remove(requestId);

    await workerCollection.doc(uid).update({
      "requests": newArray,
    });
  }
}
