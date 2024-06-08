import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cvault/models/Job.dart';

class JobService {
  final CollectionReference _jobsCollection = FirebaseFirestore.instance.collection('jobs');

  Future<void> createJob(Job job) async {
    DocumentReference docRef = _jobsCollection.doc();
    job.id = docRef.id; // Asigna el ID generado a tu trabajo
    await docRef.set(job.toJson());
  }

  Future<List<Job>> getJobs() async {
    QuerySnapshot snapshot = await _jobsCollection.get();
    return snapshot.docs.map((doc) => Job.fromFirestore(doc)).toList();
  }

  Future<void> updateJob(Job job) async {
    await _jobsCollection.doc(job.id).update(job.toJson());
  }

  Future<void> deleteJob(Job job) async {
    await _jobsCollection.doc(job.id).delete();
  }
}