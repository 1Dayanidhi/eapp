// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'dart:io';
// import 'package:flutter/services.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'application_page.dart';

// Function to check student eligibility
// Future<void> checkEligibility(String studentId) async {
//     final DatabaseReference db = FirebaseDatabase.instance.ref();
//     final DataSnapshot snapshot = await db.child('students/$studentId').get();

//     if (!snapshot.exists) {
//         print("Student not found");
//         return;
//     }

//     final student = snapshot.value as Map;
//     bool isEligible = true;
//     List<String> reasons = [];

//     student.forEach((sem, subjects) {
//         if (sem.startsWith("sem")) {
//             (subjects as Map).forEach((subject, details) {
//                 int marks = (details as Map)['marks'] ?? 0;
//                 int attendance = (details)['attendance'] ?? 0;
//                 String status = (details)['status'] ?? "Pass";

//                 // Condition 1: Marks check
                // if ((subject.contains("NME") || subject.contains("EVS") || subject.contains("Practical") || subject.contains("Lab")) && marks < 35) {
                //     isEligible = false;
                //     reasons.add("$subject: Less than 35 marks");
                // } else if (!subject.contains("NME") && !subject.contains("EVS") && !subject.contains("Practical") && !subject.contains("Lab") && marks < 50) {
                //     isEligible = false;
                //     reasons.add("$subject: Less than 50 marks");
                // }

                // Condition 2: Arrears check
                // if (status == "Fail") {
                //     isEligible = false;
                //     reasons.add("$subject: Failed");
                // }

                // Condition 3: Attendance check
    //             if (subject == "PE" && attendance < 40) {
    //                 isEligible = false;
    //                 reasons.add("$subject: Attendance below 40%");
    //             } else if (subject != "PE" && attendance < 80) {
    //                 isEligible = false;
    //                 reasons.add("$subject: Attendance below 80%");
    //             }
    //         });
    //     }
    // });

    // // Show eligibility result
    // if (isEligible) {
//         print("Student ${student['name']} is eligible to apply.");
//     } else {
//         print("Student ${student['name']} is NOT eligible. Reasons: ${reasons.join(", ")}");
//     }
// }

// Example call (Replace '22csc31' with actual student ID)
// void main() {
//     checkEligibility('22csc31');
// }