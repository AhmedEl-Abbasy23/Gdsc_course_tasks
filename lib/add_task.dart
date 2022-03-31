import 'dart:io';
import 'dart:math';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:note_app/widgets.dart';
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({Key? key}) : super(key: key);

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _subtitleController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  CollectionReference _usersRef = FirebaseFirestore.instance.collection('users');
  User? _currentUser = FirebaseAuth.instance.currentUser;
  Reference _storageRef = FirebaseStorage.instance.ref();

  File? _file;
  var _imageName;

  ImagePicker picker = ImagePicker();

  chooseImage(ImageSource source) async {
    var pickedImage = await picker.pickImage(source: source);
    if (pickedImage != null) {
      var rand = Random().nextInt(100000);
      setState(() {
        _file = File(pickedImage.path);
        // to get image-name
        _imageName = "$rand" + basename(pickedImage.path);
      });
    }
  }
  // CRUD
  addTask(BuildContext context) async {
    if (_file == null) {
      return AwesomeDialog(
          context: context,
          body: const Text("Please choose the task image"),
          dialogType: DialogType.ERROR)..show();
    } else {
      if (_formKey.currentState!.validate()) {
        loadingDialog(context, "Adding Task Now ...");
        // upload image -- add Task
        await _storageRef.child(_imageName).putFile(_file!);
        var imgUrl = await _storageRef.child(_imageName).getDownloadURL();
        print('image Url is : $imgUrl ------------');
        await _usersRef
            .doc(_currentUser!.uid)
            .collection('tasks')
            .add({
              'title': _titleController.text,
              'subtitle': _subtitleController.text,
              'imgUrl': imgUrl
            })
            .then((value) {
          Navigator.pushReplacementNamed(context, '/tasks');
              print("Task added");
        })
            .catchError((error) => print("Failed to add task: $error"));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        centerTitle: true,
        title: const Text(
          'Add a new task',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20.0,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Task title:',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20.0,
                  ),
                ),
                const SizedBox(height: 10.0),
                TextFormField(
                  controller: _titleController,
                  validator: (String? value) {
                    if (value!.length > 26) {
                      return "Title must be short";
                    }
                    if (value.length < 2 || value.isEmpty) {
                      return "Title is very short";
                    }
                    return null;
                  },
                  maxLength: 26,
                  cursorColor: const Color(0xFFFE4775),
                  decoration: const InputDecoration(
                    hintText: 'Title',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFFFE4775),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFFFE4775),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFFFE4775),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30.0),
                const Text(
                  'Task subtitle:',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20.0,
                  ),
                ),
                const SizedBox(height: 10.0),
                TextFormField(
                  controller: _subtitleController,
                  validator: (String? value) {
                    if (value!.length > 50) {
                      return "Subtitle must be shorter than 50 letter";
                    }
                    if (value.length < 2 || value.isEmpty) {
                      return "Subtitle is very short";
                    }
                    return null;
                  },
                  maxLength: 50,
                  cursorColor: const Color(0xFFFE4775),
                  decoration: const InputDecoration(
                    hintText: 'Subtitle',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFFFE4775),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFFFE4775),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFFFE4775),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30.0),
                const Text(
                  'Task Image:',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20.0,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Please choose Image Task',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16.0,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                contentPadding: const EdgeInsets.all(15.0),
                                title: const Text('Please choose an image'),
                                content: SizedBox(
                                  height: 120.0,
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            Navigator.pop(context);
                                            await chooseImage(
                                                ImageSource.camera);
                                          },
                                          child: const Text(
                                            'Camera',
                                            style: TextStyle(fontSize: 20.0),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            primary: const Color(0xFFFE4775),
                                          ),
                                        ),
                                        width: double.infinity,
                                        height: 50.0,
                                      ),
                                      const SizedBox(
                                        height: 10.0,
                                      ),
                                      SizedBox(
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            Navigator.pop(context);
                                            await chooseImage(
                                                ImageSource.gallery);
                                          },
                                          child: const Text(
                                            'Gallery',
                                            style: TextStyle(fontSize: 20.0),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            primary: const Color(0xFFFE4775),
                                          ),
                                        ),
                                        width: double.infinity,
                                        height: 50.0,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            });
                      },
                      child: const Text('Choose Image'),
                      style: ElevatedButton.styleFrom(
                        primary: const Color(0xFFFE4775),
                      ),
                    ),
                  ],
                ),
                _file == null
                    ? const SizedBox(height: 200.0)
                    : Center(
                        child:
                            SizedBox(height: 200.0, child: Image.file(_file!))),
                SizedBox(
                  height: 70.0,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await addTask(context);
                    },
                    child: const Text(
                      'Add Task',
                      style: TextStyle(fontSize: 20.0),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: const Color(0xFFFE4775),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
