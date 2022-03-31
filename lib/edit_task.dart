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

class EditTaskScreen extends StatefulWidget {
  const EditTaskScreen({Key? key, required this.task}) : super(key: key);
  final task;

  @override
  _EditTaskScreenState createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  CollectionReference _usersRef =
      FirebaseFirestore.instance.collection('users');
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

  var updatedTitle, updatedSubtitle;

  editTask(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // edit task without update image
      if(_file == null) {
        loadingDialog(context, "Updating Task Now ...");
        await _usersRef
          .doc(_currentUser!.uid)
          .collection('tasks')
          .doc(widget.task.id)
          .update({
        'title': updatedTitle,
        'subtitle': updatedSubtitle,
      }).then((value) {
        Navigator.pushReplacementNamed(context, '/tasks');
        print("Task added");
      }).catchError((error) => print("Failed to add task: $error"));
        // upload image -- edit Task
      }else{
        loadingDialog(context, "Updating Task Now ...");
        // delete current image
        await FirebaseStorage.instance.refFromURL(widget.task['imgUrl']).delete();
        // upload new image
        await _storageRef.child(_imageName).putFile(_file!);
          var imgUrl = await _storageRef.child(_imageName).getDownloadURL();
          print('image Url is : $imgUrl ------------');
          await _usersRef
              .doc(_currentUser!.uid)
              .collection('tasks')
              .doc(widget.task.id)
              .update({
            'title': updatedTitle,
            'subtitle': updatedSubtitle,
            'imgUrl': imgUrl,
          }).then((value) {
            Navigator.pushReplacementNamed(context, '/tasks');
            print("Task added");
          }).catchError((error) => print("Failed to add task: $error"));
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
          'Edit task',
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
                  initialValue: widget.task['title'],
                  onSaved: (String? value) {
                    updatedTitle = value!;
                  },
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
                  initialValue: widget.task['subtitle'],
                  onSaved: (String? value) {
                    updatedSubtitle = value!;
                  },
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
                      'Update Image Task',
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
                                title: const Text('Update task image'),
                                content: SizedBox(
                                  height: 120.0,
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            Navigator.pop(context);
                                            await chooseImage(ImageSource.camera);
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
                                            await chooseImage(ImageSource.gallery);
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
                      child: const Text('Update Image'),
                      style: ElevatedButton.styleFrom(
                        primary: const Color(0xFFFE4775),
                      ),
                    ),
                  ],
                ),
                _file == null
                    ? const SizedBox(height: 200.0)
                    : Center(
                        child: SizedBox(height: 200.0, child: Image.file(_file!))),
                SizedBox(
                  height: 70.0,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await editTask(context);
                    },
                    child: const Text(
                      'Edit Task',
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
