import 'package:cloud_firestore/cloud_firestore.dart';

class StudentsModel {
  final String fullName;
  final num balance;
  final Timestamp createdAt;
  final String studentClass;

  StudentsModel({
    required this.fullName,
    required this.balance,
    required this.createdAt,
    required this.studentClass,
  });

  StudentsModel.fromJson(Map<String, Object?> json)
      : this(
          fullName: json["full_name"] as String,
          balance: json["balance"] as num,
          createdAt: json["created_at"] as Timestamp,
          studentClass: (json["student_class"]).toString(),
        );

  StudentsModel copyWith(
      {String? fullName,
      num? balance,
      Timestamp? createdAt,
      String? studentClass}) {
    return StudentsModel(
        fullName: fullName ?? this.fullName,
        balance: balance ?? this.balance,
        createdAt: createdAt ?? this.createdAt,
        studentClass: studentClass ?? this.studentClass);
  }

  Map<String, Object?> toJson() {
    return {
      "full_name": this.fullName,
      "balance": this.balance,
      "created_at": this.createdAt,
      "student_class": this.studentClass
    };
  }
}
