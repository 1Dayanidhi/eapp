import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  bool isCheckingActive = false;
  DateTime? nominationOpenTime;
  DateTime? nominationCloseTime;
  String? selectedShift;
  String? selectedPost;
  String? selectedUGPG;
  String? isResident;
  List<Map<String, dynamic>> candidateNames = [];

  List<String> getFilteredNominationPosts() {
    if (selectedUGPG == "UG" && isResident == "Yes" && selectedShift == "Shift 1") {
      return [
        'President', 'Secretary', 'Chairpersons for Cultural Activities', 'Chairpersons for Extension Activities',
        'Chairpersons for Games', 'Class 2 Representative', 'Chairperson for Residents', 
        'Assistant Chairperson for Residents', 'Chairperson for Religious Life'
      ];
    } else if (selectedUGPG == "UG" && isResident == "No" && selectedShift == "Shift 1") {
      return [
        'President', 'Secretary', 'Chairpersons for Cultural Activities', 'Chairpersons for Extension Activities',
        'Chairpersons for Games', 'Chairperson for Non-Residents', 'Class 2 Representative'
      ];
    } else if (selectedUGPG == "UG" && isResident == "Yes" && selectedShift == "Shift 2") {
      return [
        'Vice President', 'Treasurer', 'Chairpersons for Cultural Activities', 'Chairpersons for Extension Activities',
        'Chairpersons for Games', 'Chairperson for Residents', 'Assistant Chairperson for Residents', 
        'Class 2 Representative'
      ];
    } else if (selectedUGPG == "UG" && isResident == "No" && selectedShift == "Shift 2") {
      return [
        'Vice President', 'Treasurer', 'Chairpersons for Cultural Activities', 'Chairpersons for Extension Activities',
        'Chairpersons for Games', 'Chairperson for Non-Residents', 'Class 2 Representative'
      ];
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
    /// Fetch nomination open and close time from Firestore
  Future<void> _fetchNominationTime() async {
    try {
      DocumentSnapshot snapshot =
          await _firestore.collection('election_status').doc('current_status').get();

      if (snapshot.exists) {
        Timestamp openTimestamp = snapshot['nomination_start_time'];
        Timestamp closeTimestamp = snapshot['nomination_end_time'];

        setState(() {
          nominationOpenTime = openTimestamp.toDate();
          nominationCloseTime = closeTimestamp.toDate();
        });

        _startCheckingNominationStatus();
      }
    } catch (e) {
      print("Error fetching nomination time: $e");
    }
  }

  /// Start checking nomination status every second within the active period
  void _startCheckingNominationStatus() {
    if (_timer != null) {
      _timer!.cancel();
    }

    _checkNominationStatus();

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _checkNominationStatus();
    });

    setState(() {
      isCheckingActive = true;
    });
  }

  /// Check if the nomination is open based on fetched times
  void _checkNominationStatus() {
    if (nominationOpenTime == null || nominationCloseTime == null) return;

    DateTime now = DateTime.now();
    bool isOpen =
        now.isAfter(nominationOpenTime!) && now.isBefore(nominationCloseTime!);

    if (isOpen != isNominationOpen) {
      setState(() {
        isNominationOpen = isOpen;
      });
    }

    // Stop checking once the nomination period is over
    if (now.isAfter(nominationCloseTime!)) {
      _timer?.cancel();
      setState(() {
        isCheckingActive = false;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  Future<void> fetchCandidatesForPost(String post) async {
  try {
    Query query = _firestore.collection('nomination').where('post', isEqualTo: post);

    // Check if the selected post requires filtering by shift
    List<String> shiftSpecificPosts = [
      'Chairpersons for Cultural Activities',
      'Chairpersons for Extension Activities',
      'Chairpersons for Games',
      'Chairperson for Non-Residents',
      'Class 2 Representative'
    ];

    if (shiftSpecificPosts.contains(post) && selectedShift != null) {
      query = query.where('shift', isEqualTo: selectedShift);
    }

    QuerySnapshot querySnapshot = await query.get();

   List<Map<String, dynamic>> candidates = querySnapshot.docs.map((doc) {
  Map<String, dynamic> data = doc.data() as Map<String, dynamic>; // Convert Firestore data to a Map

  return {
    'name': data.containsKey('name') ? data['name'] : 'N/A',
    'regno': data.containsKey('regno') ? data['regno'] : 'N/A',
    'post': data.containsKey('post') ? data['post'] : 'N/A',
  };
}).toList();


 setState(() {
  candidateNames = candidates;
});

  } catch (e) {
    print("Error fetching candidates: $e");
  }
}


  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      print("Proposer: ${proposerNameController.text}, Reg No: ${proposerRegNoController.text}");
      print("Seconder: ${seconderNameController.text}, Reg No: ${seconderRegNoController.text}");
      print("Resident: $isResident, UG/PG: $selectedUGPG");
      print("Selected Post: $selectedPost");

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
    }
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: Text('Nomination Form')),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: nominationOpenTime == null || nominationCloseTime == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : isNominationOpen
              ? Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: proposerNameController,
                        decoration: InputDecoration(
                            labelText: 'Proposer Name',
                            border: OutlineInputBorder()),
                        validator: (value) =>
                            value!.isEmpty ? 'Enter proposer name' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: proposerRegNoController,
                        decoration: InputDecoration(
                            labelText: 'Proposer Reg No',
                            border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            value!.isEmpty ? 'Enter proposer reg no' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: seconderNameController,
                        decoration: InputDecoration(
                            labelText: 'Seconder Name',
                            border: OutlineInputBorder()),
                        validator: (value) =>
                            value!.isEmpty ? 'Enter seconder name' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: seconderRegNoController,
                        decoration: InputDecoration(
                            labelText: 'Seconder Reg No',
                            border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            value!.isEmpty ? 'Enter seconder reg no' : null,
                      ),
                      const SizedBox(height: 10),

                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                            labelText: 'Select UG or PG',
                            border: OutlineInputBorder()),
                        items: ['UG', 'PG']
                            .map((value) => DropdownMenuItem(
                                value: value, child: Text(value)))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedUGPG = value;
                            selectedShift = null;
                            selectedPost = null; // Reset shift when UG/PG changes
                          });
                        },
                      ),
                      const SizedBox(height: 10),

                      if (selectedUGPG == "UG")
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                              labelText: 'Select Shift',
                              border: OutlineInputBorder()),
                          items: ['Shift 1', 'Shift 2']
                              .map((value) => DropdownMenuItem(
                                  value: value, child: Text(value)))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedShift = value;
                              selectedPost = null;
                            });
                          },
                        ),
                      const SizedBox(height: 10),

                      Text('Are you a resident?', style: TextStyle(fontSize: 16)),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: Text('Yes'),
                              value: 'Yes',
                              groupValue: isResident,
                              onChanged: (value) {
                                setState(() {
                                  isResident = value;
                                  selectedPost = null;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: Text('No'),
                              value: 'No',
                              groupValue: isResident,
                              onChanged: (value) {
                                setState(() {
                                  isResident = value;
                                  selectedPost = null;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                            labelText: 'Select Post',
                            border: OutlineInputBorder()),
                        value: selectedPost,
                        items: getFilteredNominationPosts()
                            .map((post) =>
                                DropdownMenuItem(value: post, child: Text(post)))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedPost = value;
                            fetchCandidatesForPost(value!);
                          });
                        },
                      ),
                      const SizedBox(height: 20),

                      if (candidateNames.isNotEmpty)
                        DropdownButtonFormField<Map<String, dynamic>>(
                          decoration: InputDecoration(
                            labelText: "Select Candidate",
                            border: OutlineInputBorder(),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          ),
                          items: candidateNames
                              .where((candidate) => candidate is Map<String, dynamic>)
                              .map<DropdownMenuItem<Map<String, dynamic>>>(
                                (candidate) => DropdownMenuItem(
                                  value: candidate,
                                  child: Text(
                                      '${candidate['name'] ?? 'Unknown'} - ${candidate['regno'] ?? 'N/A'}'),
                                ),
                              )
                              .toList(),
                          onChanged: (selectedCandidate) {
                            if (selectedCandidate != null) {
                              print("Selected: ${selectedCandidate['name']}");
                            }
                          },
                        ),

                      const SizedBox(height: 20),

                      ElevatedButton(
                        onPressed: _submitForm,
                        child: Text('Submit Nomination'),
                      ),
                    ],
                  ),
                )
              : Center(
                  child: Text(
                    'Nomination period is closed',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
    ),
  );
}

}

