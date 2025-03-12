import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminVotingPage extends StatefulWidget {
  const AdminVotingPage({super.key});

  @override
  _AdminVotingPageState createState() => _AdminVotingPageState();
}

class _AdminVotingPageState extends State<AdminVotingPage> {
  DateTime? nominationStart;
  DateTime? nominationEnd;
  DateTime? votingStart;
  DateTime? votingEnd;

  @override
  void initState() {
    super.initState();
    loadExistingTimes();
  }

  void loadExistingTimes() async {
    final doc = await FirebaseFirestore.instance.collection('election_status').doc('current_status').get();
    if (doc.exists) {
      setState(() {
        nominationStart = (doc['nomination_start_time'] as Timestamp).toDate();
        nominationEnd = (doc['nomination_end_time'] as Timestamp).toDate();
        votingStart = (doc['voting_start_time'] as Timestamp).toDate();
        votingEnd = (doc['voting_end_time'] as Timestamp).toDate();
      });
    }
  }

  void updateElectionTimes() async {
    await FirebaseFirestore.instance.collection('election_status').doc('current_status').set({
      'nomination_start_time': nominationStart,
      'nomination_end_time': nominationEnd,
      'voting_start_time': votingStart,
      'voting_end_time': votingEnd,
      'nomination_open': true,  // Default to true when setting times
      'voting_open': false,
    });
  }

  Future<void> pickDateTime(BuildContext context, Function(DateTime) onConfirm) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        DateTime fullDateTime = DateTime(
          pickedDate.year, pickedDate.month, pickedDate.day,
          pickedTime.hour, pickedTime.minute,
        );
        onConfirm(fullDateTime);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Admin Voting Control")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            buildTimePicker("Nomination Start", nominationStart, (value) => setState(() => nominationStart = value)),
            buildTimePicker("Nomination End", nominationEnd, (value) => setState(() => nominationEnd = value)),
            buildTimePicker("Voting Start", votingStart, (value) => setState(() => votingStart = value)),
            buildTimePicker("Voting End", votingEnd, (value) => setState(() => votingEnd = value)),
            ElevatedButton(onPressed: updateElectionTimes, child: Text("Update Election Times"))
          ],
        ),
      ),
    );
  }

  Widget buildTimePicker(String label, DateTime? value, Function(DateTime) onConfirm) {
    return ListTile(
      title: Text(label),
      subtitle: Text(value != null ? '${value.day}/${value.month}/${value.year} ${value.hour}:${value.minute}' : "Not set"),
      trailing: Icon(Icons.edit),
      onTap: () => pickDateTime(context, onConfirm),
    );
  }
}