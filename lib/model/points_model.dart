class PointsModel {
  final String name;
  final double points;
  final String type;

  PointsModel({
    required this.name,
    required this.points,
    required this.type,
  });

  factory PointsModel.fromMap(Map<String, String> map) {
    return PointsModel(
      name: map['Name']!,
      points: double.parse(map['# of points']!),
      type: map['type']!,
    );
  }

  Map<String, String> toMap() {
    return {
      'Name': name,
      '# of points': points.toString(),
      'type': type,
    };
  }
}