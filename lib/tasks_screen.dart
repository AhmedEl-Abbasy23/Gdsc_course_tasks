import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:note_app/edit_task.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({Key? key}) : super(key: key);

  @override
  _TasksScreenState createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  CollectionReference _users = FirebaseFirestore.instance.collection('users');
  Reference _storageRef = FirebaseStorage.instance.ref();
  User? _currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        // appBar: AppBar(title: Text('Welcome ${widget.username}'),),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 50.0),
            const Padding(
              padding: EdgeInsets.only(left: 20.0),
              child: Text(
                'Tasks',
                style: TextStyle(
                  fontSize: 35.0,
                ),
              ),
            ),
            Container(
              margin:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              height: 500.0,
              child: StreamBuilder(
                  stream: _users.doc(_currentUser!.uid).collection('tasks').snapshots(),
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot?> snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (BuildContext context, int index) {
                          var data = snapshot.data!.docs[index];
                          return Dismissible(
                            onDismissed: (direction) async {
                              await _users
                                  .doc(_currentUser!.uid)
                                  .collection('tasks')
                                  .doc(data.id)
                                  .delete()
                                  .then((value) async {
                                print('-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-');
                                print(
                                    '${snapshot.data!.docs[index]['title']} : is deleted');
                                print('-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-');
                                await FirebaseStorage.instance
                                    .refFromURL(
                                        snapshot.data!.docs[index]['imgUrl'])
                                    .delete();
                              }).catchError((error) {
                                print(error.toString());
                              });
                            },
                            key: UniqueKey(),
                            child: Container(
                              color: const Color(0xFFD4D4D4),
                              margin: const EdgeInsets.symmetric(vertical: 5.0),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 5.0,
                                  horizontal: 10.0,
                                ),
                                leading: Image.network(data['imgUrl']),
                                title: Text(
                                  data['title'],
                                  style: const TextStyle(fontSize: 20.0),
                                ),
                                subtitle: Text(
                                  data['subtitle'],
                                  style: const TextStyle(fontSize: 20.0),
                                ),
                                trailing: IconButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => EditTaskScreen(
                                               task: data),
                                      ));
                                    },
                                    icon: const Icon(Icons.edit)),
                                onTap: () {},
                              ),
                            ),
                          );
                        },
                      );
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  }),
            ),
            const SizedBox(height: 50.0),
            // add task button
            Expanded(
              child: Align(
                alignment: Alignment.bottomRight,
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, '/addTask');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20.0, horizontal: 35.0),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFE4775),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10.0),
                      ),
                    ),
                    child: SvgPicture.asset(
                      'assets/images/plus.svg',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
