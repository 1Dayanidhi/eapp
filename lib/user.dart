import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

void main() {
  runApp(MaterialApp(
    home: NominationForm(),
  ));
}

class NominationForm extends StatefulWidget {
  @override
  _NominationFormState createState() => _NominationFormState();
}

class _NominationFormState extends State<NominationForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController proposerNameController = TextEditingController();
  final TextEditingController proposerRegNoController = TextEditingController();
  final TextEditingController seconderNameController = TextEditingController();
  final TextEditingController seconderRegNoController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Timer? _timer;
  bool isNominationOpen = false;
  DateTime? nominationOpenTime;
  DateTime? nominationCloseTime;
  String? selectedShift;
  String? selectedPost;
  String? selectedUGPG;
  String? isResident;
  List<Map<String, dynamic>> candidateNames = [];

  List<String> getFilteredNominationPosts() {
    if (selectedUGPG == "UG" && isResident == "Yes" && selectedShift == "Shift 1") {
      return ['President', 'Secretary', 'Chairpersons for Cultural Activities', 
              'Chairpersons for Extension Activities', 'Chairpersons for Games', 
              'Class 2 Representative', 'Chairperson for Residents', 
              'Assistant Chairperson for Residents', 'Chairperson for Religious Life'];
    } else if (selectedUGPG == "UG" && isResident == "No" && selectedShift == "Shift 1") {
      return ['President', 'Secretary', 'Chairpersons for Cultural Activities', 
              'Chairpersons for Extension Activities', 'Chairpersons for Games', 
              'Chairperson for Non-Residents', 'Class 2 Representative'];
    } else if (selectedUGPG == "UG" && isResident == "Yes" && selectedShift == "Shift 2") {
      return ['Vice President', 'Treasurer', 'Chairpersons for Cultural Activities', 
              'Chairpersons for Extension Activities', 'Chairpersons for Games', 
              'Chairperson for Residents', 'Assistant Chairperson for Residents', 
              'Class 2 Representative'];
    } else if (selectedUGPG == "UG" && isResident == "No" && selectedShift == "Shift 2") {
      return ['Vice President', 'Treasurer', 'Chairpersons for Cultural Activities', 
              'Chairpersons for Extension Activities', 'Chairpersons for Games', 
              'Chairperson for Non-Residents', 'Class 2 Representative'];
    } else if (selectedUGPG == "PG" && isResident == "Yes") {
      return ['PG Representative', 'Chairperson for Residents', 'Assistant Chairperson for Residents'];
    } else if (selectedUGPG == "PG" && isResident == "No") {
      return ['PG Representative'];
    }
    return [];
  }

  @override
  void initState() {
    super.initState();
    _fetchNominationTime();
  }

  Future<void> _fetchNominationTime() async {
    try {
      DocumentSnapshot snapshot =
          await _firestore.collection('election_status').doc('current_status').get();

      if (snapshot.exists) {
        setState(() {
          nominationOpenTime = (snapshot['nomination_start_time'] as Timestamp).toDate();
          nominationCloseTime = (snapshot['nomination_end_time'] as Timestamp).toDate();
        });
        _startCheckingNominationStatus();
      }
    } catch (e) {
      print("Error fetching nomination time: $e");
    }
  }

  void _startCheckingNominationStatus() {
    _checkNominationStatus();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _checkNominationStatus();
    });
  }

  void _checkNominationStatus() {
    if (nominationOpenTime == null || nominationCloseTime == null) return;

    DateTime now = DateTime.now();
    bool isOpen = now.isAfter(nominationOpenTime!) && now.isBefore(nominationCloseTime!);

    if (isOpen != isNominationOpen) {
      setState(() {
        isNominationOpen = isOpen;
      });
    }

    if (now.isAfter(nominationCloseTime!)) {
      _timer?.cancel();
      _timer = null;
    }
  }

  Future<void> fetchCandidatesForPost(String post) async {
    try {
      Query query = _firestore.collection('nomination').where('post', isEqualTo: post);

      if (selectedShift != null && [
        'Chairpersons for Cultural Activities', 'Chairpersons for Extension Activities',
        'Chairpersons for Games', 'Chairperson for Non-Residents', 'Class 2 Representative'
      ].contains(post)) {
        query = query.where('shift', isEqualTo: selectedShift);
      }

      QuerySnapshot querySnapshot = await query.get();
      List<Map<String, dynamic>> candidates = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {
          'name': data['name'] ?? 'N/A',
          'regno': data['regno'] ?? 'N/A',
          'post': data['post'] ?? 'N/A',
        };
      }).toList();

      setState(() {
        candidateNames = candidates;
      });
    } catch (e) {
      print("Error fetching candidates: $e");
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _firestore.collection('nominations').add({
          'proposer_name': proposerNameController.text,
          'proposer_regno': proposerRegNoController.text,
          'seconder_name': seconderNameController.text,
          'seconder_regno': seconderRegNoController.text,
          'selected_post': selectedPost,
          'ug_pg': selectedUGPG,
          'is_resident': isResident,
          'timestamp': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Nomination Submitted Successfully!')),
        );

        _formKey.currentState!.reset();
        setState(() {
          proposerNameController.clear();
          proposerRegNoController.clear();
          seconderNameController.clear();
          seconderRegNoController.clear();
          selectedPost = null;
          selectedUGPG = null;
          isResident = null;
          selectedShift = null;
          candidateNames = [];
        });
      } catch (e) {
        print("Error submitting nomination: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nomination Form')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: nominationOpenTime == null || nominationCloseTime == null
            ? Center(child: CircularProgressIndicator())
            : isNominationOpen
                ? Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        TextFormField(
                          controller: proposerNameController,
                          decoration: InputDecoration(labelText: 'Proposer Name'),
                          validator: (value) => value!.isEmpty ? 'Enter proposer name' : null,
                        ),
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(labelText: 'Select UG or PG'),
                          items: ['UG', 'PG'].map((value) =>
                              DropdownMenuItem(value: value, child: Text(value))).toList(),
                          onChanged: (value) => setState(() => selectedUGPG = value),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(onPressed: _submitForm, child: Text('Submit Nomination')),
                      ],
                    ),
                  )
                : Center(child: Text('Nomination period is closed', style: TextStyle(fontSize: 18))),
      ),
    );
  }
}