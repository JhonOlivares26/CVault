import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cvault/models/Job.dart';

class JobService {
  final CollectionReference _jobCollection = FirebaseFirestore.instance.collection('jobs');

  Future<void> createJob(Job job) async {
    DocumentReference docRef = _jobCollection.doc();
    job.id = docRef.id; // Asigna el ID generado a tu trabajo
    await docRef.set(job.toJson());
  }

  Stream<List<Job>> getJobs() {
    return _jobCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Job.fromFirestore(doc)).toList();
    });
  }

  Future<void> updateJob(Job job) async {
    await _jobCollection.doc(job.id).update(job.toJson());
  }

  Future<void> deleteJob(Job job) async {
    await _jobCollection.doc(job.id).delete();
  }
}