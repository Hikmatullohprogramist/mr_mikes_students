import 'package:cloud_firestore/cloud_firestore.dart';

class StudentsModel {
  final String fullName;
  final num balance;
  final Timestamp createdAt;

  StudentsModel({
    required this.fullName,
    required this.balance,
    required this.createdAt,
  });

  StudentsModel.fromJson(Map<String, Object?> json)
      : this(
          fullName: json["full_name"] as String,
          balance: json["balance"] as num,
          createdAt: json["created_at"] as Timestamp,
        );

  StudentsModel copyWith({
    String? fullName,
    num? balance,
    Timestamp? createdAt,
  }) {
    return StudentsModel(
      fullName: fullName ?? this.fullName,
      balance: balance ?? this.balance,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, Object?> toJson() {
    return {
      "full_name": this.fullName,
      "balance": this.balance,
      "created_at": this.createdAt
    };
  }
}
