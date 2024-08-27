import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  
  final List<String> tasks = <String>['Study for exam'];
  final List<bool> checkboxes = List.generate(8, (index)=>false);

  TextEditingController nameController = TextEditingController();

  bool isChecked = false;

  void addItemToList() async {
    final String taskName = nameController.text;

    await db.collection('tasks').add({
      'name': taskName,
      'completed': false,
      'timestamp':FieldValue.serverTimestamp(),
    });

    setState(() {
    tasks.insert(0, taskName);
    });
}
  
  

  void removeItems(int index) async {
    //get the tasks to be removed
    String taskToBeRemoved = tasks[index];

    //remove the task from firestore
    QuerySnapshot querySnapshot = await db
        .collection('tasks')
        .where('name', isEqualTo: taskToBeRemoved)
        .get();

      if(querySnapshot.size > 0){
        DocumentSnapshot documentSnapshot = querySnapshot.docs[0];
        await documentSnapshot.reference.delete();
      }

      setState(() {
        tasks.removeAt(index);
        checkboxes.removeAt(index);
    });
  }

    @override
    Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              height: 80, 
              child: Image.asset('assets/rdplogo.png'),
            ),
            const Text(
              'Daily Planner', 
                style: TextStyle(
                fontFamily: 'Caveat', 
                fontSize: 32,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        height: 400,
          child: Column(
            children: [
              TableCalendar(
                calendarFormat: CalendarFormat.month,
                headerVisible: true,
                focusedDay: DateTime.now(),
                firstDay: DateTime(2023),
                lastDay: DateTime(2025),
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: tasks.length,
                itemBuilder: (BuildContext context, int index) {
                  return SingleChildScrollView(
                    child: Container(
                      decoration: BoxDecoration(
                        color: checkboxes[index]
                            ? Colors.green.withOpacity(0.7)
                            : Colors.blue.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            !checkboxes[index]
                            ? Icons.manage_history
                            : Icons.playlist_add_check_circle,
                          ),
                          SizedBox(width: 18),
                          Text('${tasks[index]}',
                            style: checkboxes[index]? TextStyle(
                              decoration: TextDecoration.lineThrough,
                              fontSize: 20,
                              color: Colors.black.withOpacity(0.5),
                            )
                          : TextStyle(
                              fontSize: 20,
                          ),
                          ),
                          Row(
                            children: [
                              Checkbox(
                                value: checkboxes[index], 
                                onChanged: (newValue) {
                                  setState(() {
                                    checkboxes[index] = newValue!;
                                  });

                                  //To-Do updateTaskCompletionStatus()

                                }),
                            const IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: null,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
                },
              )
            ],
          ),
      ),
    );
    
    }
  }