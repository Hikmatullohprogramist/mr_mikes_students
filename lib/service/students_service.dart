// ignore_for_file: constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mr_mikes_students/model/students_model.dart';

import '../model/store_model.dart';

const String STUDENTS_COLLECTION_PREFS = "students";
const String MARKET_COLLECTION_PREFS = "market";
const String STORE_IMAGES_COLLECTION = "store-images";

class AppService {
  final _fireStore = FirebaseFirestore.instance;

  late final CollectionReference _studentsRef;
  late final CollectionReference _storeRef;

  AppService() {
    _studentsRef = _fireStore
        .collection(STUDENTS_COLLECTION_PREFS)
        .withConverter<StudentsModel>(
          fromFirestore: (snapshot, _) =>
              StudentsModel.fromJson(snapshot.data()!),
          toFirestore: (snapshot, _) => snapshot.toJson(),
        );

    _storeRef = _fireStore
        .collection(MARKET_COLLECTION_PREFS)
        .withConverter<StoreModel>(
          fromFirestore: (snapshot, _) => StoreModel.fromJson(snapshot.data()!),
          toFirestore: (snapshot, _) => snapshot.toJson(),
        );
  }

  Stream<QuerySnapshot> getStudents() {
    return _studentsRef.snapshots();
  }

  void addStudent(StudentsModel data) {
    _studentsRef.add(data);
  }

  void updateStudent(StudentsModel data, String id) {
    _studentsRef.doc(id).update(data.toJson());
  }

  void deleteStudent(String id) {
    _studentsRef.doc(id).delete();
  }

  //Store endpoint

  Stream<QuerySnapshot> getStoreItems() {
    return _storeRef.snapshots();
  }

  void addStoreItem(StoreModel data) {
    _storeRef.add(data);
  }

  void updateStoreItem(StoreModel data, String id) {
    _storeRef.doc(id).update(data.toJson());
  }

  void deleteStoreItem(String id) {
    _storeRef.doc(id).delete();
  }
}
