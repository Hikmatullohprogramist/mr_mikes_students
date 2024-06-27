import 'package:cloud_firestore/cloud_firestore.dart';

class StoreModel {
  final String productName;
  final num amount;
  final num price;
  final dynamic img;
  final Timestamp createdAt;

  StoreModel({
    required this.productName,
    required this.amount,
    required this.price,
    required this.img,
    required this.createdAt,
  });

  StoreModel.fromJson(Map<String, Object?> json)
      : this(
          amount: json["amount"] as num,
          productName: json["product_name"] as String,
          price: json["price"] as num,
          img: json["img"] as dynamic,
          createdAt: json["created_at"] as Timestamp,
        );

  StoreModel copyWith({
    String? productName,
    num? amount,
    num? price,
    dynamic img,
    Timestamp? createdAt,
  }) {
    return StoreModel(
      productName: productName ?? this.productName,
      amount: amount ?? this.amount,
      price: price ?? this.price,
      img: img ?? this.img,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, Object?> toJson() {
    return {
      "product_name": productName,
      "amount": amount,
      "price": price,
      "img": img,
      "created_at": createdAt,
    };
  }
}
