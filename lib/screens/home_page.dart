// ignore_for_file: avoid_unnecessary_containers

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mr_mikes_students/constantas/const.dart';
import 'package:mr_mikes_students/model/students_model.dart';
import 'package:mr_mikes_students/service/students_service.dart';

import '../main.dart';
import '../model/points_model.dart';
import 'points_screen/points.dart';

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
                  child: SingleChildScrollView(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 17),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Mr. Mike's students",
                                  style: TextStyle(
                                    fontSize: 24,
                                    color: Colors.white,
                                  )),
                              IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              PointsTableScreen()),
                                    );
                                  },
                                  icon: const Icon(Icons.rule,
                                      color: Colors.white))
                            ],
                          ),
                          const Text(
                            'Ratings',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          searchBox(),
                          const SizedBox(height: 10),
                          buildColumn(),
                        ],
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
        ));
  }

  TextEditingController _searchController = TextEditingController();
  GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();
  String _searchQuery = "";

  Widget searchBox() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        padding: const EdgeInsets.only(left: 12.0, right: 12),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white)),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            labelText: 'Search by name',
            labelStyle: const TextStyle(color: Colors.white),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear, color: Colors.white),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = "";
                });
              },
            ),
          ),
          onChanged: (value) async {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
      ),
    );
  }

  Widget buildColumn() {
    return StreamBuilder(
      key: UniqueKey(),
      stream: service.getStudents(_searchQuery),
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
          num balanceA = a.data().balance;
          num balanceB = b.data().balance;
          return balanceB.compareTo(balanceA);
        });

        return ListView.builder(
          itemCount: students.length,
          shrinkWrap: true,
          primary: false,
          itemBuilder: (ctx, index) {
            StudentsModel data = students[index].data();
            String id = students[index].id;

            return _buildStudentItem(
                id, data, data.studentClass.toString(), index);
          },
        );
      },
    );
  }

  Widget _buildStudentItem(
    String id,
    StudentsModel data,
    String subTitle,
    int index,
  ) {
    return Slidable(
      key: ValueKey(id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        dismissible: isMike
            ? DismissiblePane(onDismissed: () {
                service.deleteStudent(id);
              })
            : null,
        children: [
          isMike
              ? SlidableAction(
                  borderRadius: BorderRadius.circular(12),
                  onPressed: (v) {
                    service.deleteStudent(id);
                  },
                  backgroundColor: const Color(0xFFFE4A49),
                  foregroundColor: Colors.white,
                  icon: Icons.delete,
                  label: 'Delete',
                )
              : const SizedBox(),
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
                        showDialogQuickBalanceUpdate(context, data, id);

                        // showDialogStudentBalance(false, context, data, id);
                      },
                    )
                  : const SizedBox(),
              Text(
                data.balance.toString(),
                style: const TextStyle(fontSize: 22),
              ),
              isMike
                  ? IconButton(
                      // Plus Button
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        showDialogQuickBalanceUpdate(context, data, id);
                        // showDialogStudentBalance(true, context, data, id);
                      })
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }

  String? selectedAction;

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

  void showDialogQuickBalanceUpdate(
      BuildContext ctx, StudentsModel data, String studentId) {
    showDialog(
      context: ctx,
      builder: (BuildContext context) {
        Map<String, int> selectedPointCounts = {};
        num newBalance = data.balance;

        final combinedPointsData = [...AppConstants.pointsGainedData, ...AppConstants.pointsLostData];

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            void updateBalance() {
              newBalance = data.balance;
              selectedPointCounts.forEach((name, count) {
                final actionData = combinedPointsData.firstWhere(
                  (element) => element.name == name,
                );
                newBalance += actionData.points * count;
              });
              setState(() {}); // Update the UI to reflect new balance
            }

            return AlertDialog(
              title: Column(
                children: [
                  Text('Quick Balance Update'),
                  Text(
                    'Balance: $newBalance',
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: combinedPointsData.map((action) {
                        selectedPointCounts[action.name] =
                            selectedPointCounts[action.name] ?? 0;
                        return Card(
                          color: action.type == "loss"
                              ? Colors.redAccent
                              : Colors.greenAccent,
                          child: ListTile(
                            title: Text('${action.name} (${action.points})'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.remove),
                                  onPressed: () {
                                    if (selectedPointCounts[action.name]! > 0) {
                                      selectedPointCounts[action.name] =
                                          selectedPointCounts[action.name]! - 1;
                                      updateBalance();
                                    }
                                  },
                                ),
                                Text(
                                  selectedPointCounts[action.name].toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.add),
                                  onPressed: () {
                                    selectedPointCounts[action.name] =
                                        selectedPointCounts[action.name]! + 1;
                                    updateBalance();
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('CANCEL'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: const Text('UPDATE'),
                  onPressed: () {
                    StudentsModel updatedData = data.copyWith(
                      fullName: data.fullName,
                      balance: newBalance,
                    );

                    // Assuming service.updateStudent is the method to update the student
                    service.updateStudent(updatedData, studentId);

                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }


  showAddStudentDialog(BuildContext context) {
    final TextEditingController fullNameController = TextEditingController();
    final TextEditingController balanceController = TextEditingController();
    final TextEditingController studentClassController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Student'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: fullNameController,
                  decoration: const InputDecoration(hintText: "Full Name"),
                ),
                Visibility(
                  visible: isMike,
                  child: TextField(
                    controller: balanceController,
                    decoration: const InputDecoration(hintText: "Balance"),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                TextField(
                  controller: studentClassController,
                  decoration: const InputDecoration(hintText: "Class"),
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
                String fullName = fullNameController.text;
                double balance = double.tryParse(balanceController.text) ?? 0.0;

                StudentsModel newStudent = StudentsModel(
                    fullName: fullName,
                    balance: balance,
                    createdAt: Timestamp.now(),
                    studentClass: studentClassController.text.trim());

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
