import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flower_app/shared/data_from_firestore.dart';
import 'package:flower_app/shared/snackbar.dart';
import 'package:flower_app/shared/user_img.dart';
import 'package:intl/intl.dart';
import 'package:flower_app/shared/colors.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' show basename;

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? imgName;
  File? imgPath;
  final credential = FirebaseAuth.instance.currentUser;
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  uploadImage() async {
    final pickedImg =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    try {
      if (pickedImg != null) {
        setState(() {
          imgPath = File(pickedImg.path);
          imgName = basename(pickedImg.path);
          int random = Random().nextInt(9999999);
          imgName = "$random$imgName";
        });
      } else {
        if (!mounted) return;
        showSnackBar(context, "NO img selected");
      }
    } catch (e) {
      if (!mounted) return;
      showSnackBar(context, "Error => $e");
    }
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton.icon(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!mounted) return;
              Navigator.pop(context);
            },
            label: const Text(
              "logout",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
          )
        ],
        backgroundColor: appbarGreen,
        title: const Text("Profile Page"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(22.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                      color: Colors.grey, shape: BoxShape.circle),
                  child: Stack(children: [
                    CircleAvatar(
                      radius: 71,
                      child: imgPath == null
                          ? const ImgUser()
                          : ClipOval(
                              child: Image.file(
                              imgPath!,
                              width: 145,
                              height: 145,
                              fit: BoxFit.cover,
                            )),
                    ),
                    Positioned(
                      bottom: -10,
                      left: 103,
                      child: IconButton(
                          onPressed: () async {
                            await uploadImage();
                            if (imgPath != null) {
                              final storageRef =
                                  FirebaseStorage.instance.ref(imgName);
                              await storageRef.putFile(imgPath!);
                              String url = await storageRef.getDownloadURL();
                              users
                                  .doc(credential!.uid)
                                  .update({"imgLink": url});
                            }
                          },
                          icon: const Icon(
                            Icons.add_a_photo,
                            color: Color.fromARGB(255, 95, 95, 95),
                          )),
                    )
                  ]),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Center(
                  child: Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                    color: pTNgreen, borderRadius: BorderRadius.circular(11)),
                child: const Text(
                  "Sign In Info",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                  ),
                ),
              )),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 22,
                  ),
                  Text(
                    "Email: ${credential!.email}",
                    style: const TextStyle(
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                    "Created date: ${DateFormat("MMMM d, y").format(credential!.metadata.creationTime!)}",
                    style: const TextStyle(
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                    "Last Signed In: ${DateFormat("MMMM d, y").format(credential!.metadata.lastSignInTime!)}",
                    style: const TextStyle(
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 22,
              ),
              Center(
                child: TextButton(
                    onPressed: () {
                      credential!.delete();

                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Delete Account",
                      style: TextStyle(fontSize: 18),
                    )),
              ),
              const SizedBox(
                height: 22,
              ),
              Center(
                  child: Container(
                      padding: const EdgeInsets.all(11),
                      decoration: BoxDecoration(
                          color: pTNgreen,
                          borderRadius: BorderRadius.circular(11)),
                      child: const Text(
                        "Your Info",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ))),
              GetDataFromFirestore(
                documentId: credential!.uid,
              )
            ],
          ),
        ),
      ),
    );
  }
}
