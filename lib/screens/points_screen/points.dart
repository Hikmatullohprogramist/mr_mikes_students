import 'package:flutter/material.dart';
import 'package:mr_mikes_students/model/points_model.dart';

import '../../constantas/const.dart';

class PointsTableScreen extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Points Table'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            SectionTitle(title: 'What should students do to get points?'),
            ...AppConstants.pointsGainedData.map((data) => PointsCard(data: data)).toList(),
            SectionTitle(title: 'What should students do to lose points?'),
            ...AppConstants.pointsLostData.map((data) => PointsCard(data: data)).toList(),
          ],
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.blueAccent,
        ),
      ),
    );
  }
}

class PointsCard extends StatelessWidget {
  final PointsModel data;

  PointsCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                data.name,
                style: TextStyle(fontSize: 16),
              ),
            ),
            Text(
              data.points.toStringAsFixed(1),
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
