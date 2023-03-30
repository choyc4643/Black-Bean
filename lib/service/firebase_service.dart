import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../model/problem.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  //web 아닐 때 파이어스토어에 업로드하는 함수, 테스트 필요
  Future<void> _uploadImage(XFile pickedImage, imageName) async {
    // Initialize Firebase if it hasn't been initialized yet
    // final imageName = DateTime.now().millisecondsSinceEpoch.toString();
    final ref = FirebaseStorage.instance.ref().child('images/$imageName');
    UploadTask uploadTask = ref.putFile(File(pickedImage.path));
    final snapshot = await uploadTask.whenComplete(() => null);
    final urlImageUser = await snapshot.ref.getDownloadURL();

    print('firebase_service_dart line 26: Image URL: $urlImageUser');
  }

  //웹에서 파이어스토어에 이미지 업로드 할 때 사용하는 함수
  Future<void> uploadImage_web(XFile pickedFile, imageName) async {
    if (pickedFile != null) {
      final snapshot = await _storage
          .ref()
          .child('images/$imageName')
          .putData(await pickedFile.readAsBytes());
      var imgUrl = await snapshot.ref.getDownloadURL();
      print('firebase_service_dart line 37: Upload complete!  $imgUrl');
    } else {
      print('firebase_service_dart line 38: No image selected.');
    }
  }

  //문제 선택하고 firestore에 올리는 함수
  Future<void> addProblemToDatabase(
    String degree,
    String subject,
    Problem problem,
  ) async {
    try {
      await _firestore
          .collection('degree')
          .doc(degree)
          .collection('subject')
          .doc(subject)
          .collection('problems')
          .doc() // this will create a new document with an automatically generated ID
          .set(problem.toMap());
    } catch (e) {
      print(e);
    }
  }

  //문제 하나 불러오는 함수
  Problem loadProblemFromDatabase(AsyncSnapshot<DocumentSnapshot> snapshot) {
    Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
    var answer = data['answer'];
    var iSection = data['iSection'];
    var mSection = data['mSection'];
    var number = data['number'];
    var problemurl = data['problem'];
    var sSection = data['sSection'];
    var year = data['year'];

    Problem problem = Problem(
        answer: answer,
        iSection: iSection,
        mSection: mSection,
        number: number,
        problem: problemurl,
        sSection: sSection,
        year: year);

    print(problem.toMap());

    return problem;
  }
}
