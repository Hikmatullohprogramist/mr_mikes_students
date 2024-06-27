import 'package:flutter/material.dart';
import 'package:mr_mikes_students/model/points_model.dart';

class AppConstants {
  static const Color appColor = Color(0xffE84E10);


  static final List<PointsModel> pointsGainedData = [
    PointsModel(name: "Homework (har biri uchun).", points: 5, type: 'gain'),
    PointsModel(name: "Attendance.", points: 2, type: 'gain'),
    PointsModel(name: "Support teacher bilan ishlash.", points: 5, type: 'gain'),
    PointsModel(name: "Vocabulary test (25+).", points: 8, type: 'gain'),
    PointsModel(name: "Achievement Test (75+).", points: 5, type: 'gain'),
    PointsModel(name: "Mid-Course Test (80+).", points: 40, type: 'gain'),
    PointsModel(name: "End-Course Test (80+).", points: 50, type: 'gain'),
  ];

  static final List<PointsModel> pointsLostData = [
    PointsModel(name: "Homework (har biri uchun)", points: -5, type: 'loss'),
    PointsModel(name: "Attendancee", points: -5, type: 'loss'),
    PointsModel(name: "Vocabulary test (25-)", points: -5, type: 'loss'),
    PointsModel(name: "Achievement Test (75-)", points: -5, type: 'loss'),
    PointsModel(name: "Mid-Course Test (70-)", points: -40, type: 'loss'),
    PointsModel(name: "End-Course Test (70-)", points: -50, type: 'loss'),
  ];

}
