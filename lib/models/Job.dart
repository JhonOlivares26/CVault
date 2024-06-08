import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Job with ChangeNotifier {
  String id;
  String title;
  String description;
  String location;
  String modality;
  String salary;
  String companyId;
  String companyName;
  List<String> applicants;

  Job({required this.id, required this.title, required this.description, required this.location, required this.modality, required this.salary, required this.companyId, required this.companyName, required this.applicants});

  factory Job.fromFirestore(DocumentSnapshot jobDoc) {
    Map<String, dynamic> jobData = jobDoc.data() as Map<String, dynamic>;
    return Job(
      id: jobDoc.id,
      title: jobData['title'],
      description: jobData['description'],
      location: jobData['location'],
      modality: jobData['modality'],
      salary: jobData['salary'],
      companyId: jobData['companyId'],
      companyName: jobData['companyName'],
      applicants: List<String>.from(jobData['applicants']),
    );
  }

  factory Job.fromMap(Map<String, dynamic> jobData) {
  return Job(
    id: jobData['id'] ?? '',
    title: jobData['title'] ?? '',
    description: jobData['description'] ?? '',
    location: jobData['location'] ?? '',
    modality: jobData['modality'] ?? '',
    salary: jobData['salary'] ?? '',
    companyId: jobData['companyId'] ?? '',
    companyName: jobData['companyName'] ?? '',
    applicants: jobData['applicants'] != null ? List<String>.from(jobData['applicants']) : [],
  );
}

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'modality': modality,
      'salary': salary,
      'companyId': companyId,
      'companyName': companyName,
      'applicants': applicants,
    };
  }
}

Future<void> createJob(Job job) async {
  CollectionReference jobs = FirebaseFirestore.instance.collection('jobs');
  await jobs.add(job.toJson());
}