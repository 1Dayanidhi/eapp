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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Timer? _timer;
  bool isNominationOpen = false;
  DateTime? nominationOpenTime;
  DateTime? nominationCloseTime;
  String? selectedPost;
  List<Map<String, dynamic>> candidateNames = [];

  @override
  void initState() {
    super.initState();
    _fetchNominationTime();
  }

  /// Fetch nomination open and close times from Firestore
  Future<void> _fetchNominationTime() async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('election_status').doc('current_status').get();

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

  /// Start checking nomination status
  void _startCheckingNominationStatus() {
    if (_timer != null) {
      _timer!.cancel();
    }

    _checkNominationStatus();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _checkNominationStatus();
    });
  }

  /// Check if nominations are open
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
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Fetch candidates for the selected post along with vote count
  Future<void> fetchCandidatesForPost(String post) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('nomination')
          .where('post', isEqualTo: post)
          .get();

      List<Map<String, dynamic>> candidates = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id, // Store document ID for updating votes
          'name': data['name'] ?? 'N/A',
          'regno': data['regno'] ?? 'N/A',
          'post': data['post'] ?? 'N/A',
          'vote_count': data['vote_count'] ?? 0,
        };
      }).toList();

      setState(() {
        candidateNames = candidates;
      });
    } catch (e) {
      print("Error fetching candidates: $e");
    }
  }

  /// Update vote count for a candidate
  Future<void> updateVoteCount(String candidateId) async {
    try {
      DocumentReference docRef = _firestore.collection('nomination').doc(candidateId);
      await docRef.update({"vote_count": FieldValue.increment(1)});
      print("Vote added successfully!");

      // Refresh the vote count
      fetchCandidatesForPost(selectedPost!);
    } catch (e) {
      print("Error updating votes: $e");
    }
  }

  /// Submit nomination form
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      print("Selected Post: $selectedPost");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nomination Submitted Successfully!')),
      );

      _formKey.currentState!.reset();
      setState(() {
        selectedPost = null;
        candidateNames = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nomination & Voting')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: nominationOpenTime == null || nominationCloseTime == null
            ? Center(child: CircularProgressIndicator())
            : isNominationOpen
                ? Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                              labelText: 'Select Post', border: OutlineInputBorder()),
                          value: selectedPost,
                          items: ['President', 'Secretary', 'Treasurer']
                              .map((post) => DropdownMenuItem(value: post, child: Text(post)))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedPost = value;
                              fetchCandidatesForPost(value!);
                            });
                          },
                        ),
                        const SizedBox(height: 20),

                        // Show candidates and vote counts
                        if (candidateNames.isNotEmpty)
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: candidateNames.length,
                            itemBuilder: (context, index) {
                              var candidate = candidateNames[index];
                              return Card(
                                child: ListTile(
                                  title: Text('${candidate['name']} - ${candidate['regno']}'),
                                  subtitle: Text('Votes: ${candidate['vote_count']}'),
                                  trailing: ElevatedButton(
                                    onPressed: () {
                                      updateVoteCount(candidate['id']);
                                    },
                                    child: Text('Vote'),
                                  ),
                                ),
                              );
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