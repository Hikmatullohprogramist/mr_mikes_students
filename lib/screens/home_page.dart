// ignore_for_file: avoid_unnecessary_containers

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mr_mikes_students/constantas/const.dart';
import 'package:mr_mikes_students/model/students_model.dart';
import 'package:mr_mikes_students/service/students_service.dart';

import '../main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AppService service = AppService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.appColor,
      body: Container(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                    flex: 2,
                    child: Container(
                      color: AppConstants.appColor,
                    )),
                Expanded(
                    flex: 4,
                    child: Container(
                      color: Colors.white,
                    ))
              ],
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Expanded(
                  child: SingleChildScrollView(
                    child: Positioned(
                      top: 70,
                      left: 24,
                      right: 24,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 17),
                          const Text("Mr. Mike's students",
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                              )),
                          const Text(
                            'Ratings',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          buildColumn(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddStudentDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget buildColumn() {
    return StreamBuilder(
      key: UniqueKey(),
      stream: service.getStudents(),
      builder: (ctx, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text("Error: ${snapshot.error}"),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        List<dynamic> students = snapshot.data?.docs ?? [];

        if (students.isEmpty) {
          return const Center(
            child: Text(
              "No students",
              style: TextStyle(fontSize: 22),
            ),
          );
        }

        // Assuming data can be cast to StudentsModel
        students.sort((a, b) {
          double balanceA = a.data().balance;
          double balanceB = b.data().balance;
          return balanceB.compareTo(balanceA);
        });

        return ListView.builder(
          itemCount: students.length,
          shrinkWrap: true,
          primary: false,
          itemBuilder: (ctx, index) {
            StudentsModel data = students[index].data();
            String id = students[index].id;

            String subtitle = "";

            return _buildStudentItem(id, data, subtitle, index);
          },
        );
      },
    );
  }

  Widget _buildStudentItem(
      String id, StudentsModel data, String subTitle, int index) {
    return Slidable(
      key: const ValueKey(0),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        dismissible: DismissiblePane(onDismissed: () {
          service.deleteStudent(id);
        }),
        children: [
          SlidableAction(
            borderRadius: BorderRadius.circular(12),
            onPressed: (v) {
              isMike ? service.deleteStudent(id) : () {};
            },
            backgroundColor: const Color(0xFFFE4A49),
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: Card(
        color: Colors.white,
        elevation: 4,
        child: ListTile(
          title: Text(data.fullName),
          subtitle: Text(subTitle),
          leading: Container(
            height: 34,
            width: 34,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                50,
              ),
            ),
            child: Center(
              child: Text(
                (index + 1).toString(),
              ),
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              isMike
                  ? IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        showDialogStudentBalance(false, context, data, id);
                      },
                    )
                  : SizedBox(),
              Text(
                data.balance.toString(),
                style: const TextStyle(fontSize: 22),
              ),
              isMike
                  ? IconButton(
                      // Plus Button
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        showDialogStudentBalance(true, context, data, id);
                      })
                  : SizedBox(),
            ],
          ),
        ),
      ),
    );
  }

  void showDialogStudentBalance(bool isIncrement, BuildContext ctx,
      StudentsModel data, String studentId) {
    showDialog(
      context: ctx,
      builder: (BuildContext context) {
        // Variable to hold input value
        final TextEditingController controller = TextEditingController();

        // The title of the dialog changes based on whether we're incrementing or decrementing the balance
        String title = isIncrement ? "Add to Balance" : "Remove from Balance";
        String buttonText = isIncrement ? "ADD" : "REMOVE";

        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "Enter amount"),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('CANCEL'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(buttonText),
              onPressed: () {
                double amount = double.tryParse(controller.text) ?? 0;
                double newBalance =
                    isIncrement ? data.balance + amount : data.balance - amount;

                StudentsModel newData = data.copyWith(
                  fullName: data.fullName,
                  balance: newBalance,
                );

                service.updateStudent(newData, studentId);

                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  showAddStudentDialog(BuildContext context) {
    final TextEditingController fullNameController = TextEditingController();
    final TextEditingController balanceController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Student'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                // Full Name field
                TextField(
                  controller: fullNameController,
                  decoration: const InputDecoration(hintText: "Full Name"),
                ),
                // Balance field
                TextField(
                  controller: balanceController,
                  decoration: const InputDecoration(hintText: "Balance"),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('ADD'),
              onPressed: () {
                // Implement your add logic here
                // Example: Adding the student to a list or database
                String fullName = fullNameController.text;
                double balance = double.tryParse(balanceController.text) ??
                    0.0; // Default to 0 if parsing fails
                StudentsModel newStudent = StudentsModel(
                    fullName: fullName,
                    balance: balance,
                    createdAt: Timestamp.now());

                service.addStudent(newStudent);
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }
}
