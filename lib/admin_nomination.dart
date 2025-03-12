import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NominationPage extends StatefulWidget {
  const NominationPage({super.key});

  @override
  _NominationPageState createState() => _NominationPageState();
}

class _NominationPageState extends State<NominationPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, Map<String, dynamic>> _nominations = {}; // Store candidate data
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNominations();
  }

  Future<void> fetchNominations() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection("nominated").get();
      Map<String, Map<String, dynamic>> nominations = {};

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;

        String candidateName = data["candidate_name"] ?? "Unknown";
        String registerNo = data["candidate_regno"] ?? "N/A";
        String post = data["post"] ?? "Unknown";
        String candidateKey = "$candidateName ($registerNo)";

        // Count votes based on proposer & seconder fields
        int proposerVotes = data["proposer"] != null ? 1 : 0;
        int seconderVotes = data["seconder"] != null ? 1 : 0;
        int totalVotes = proposerVotes + seconderVotes;

        // Store candidate data
        if (!nominations.containsKey(candidateKey)) {
          nominations[candidateKey] = {
            "post": post,
            "votes": totalVotes,
          };
        } else {
          nominations[candidateKey]!["votes"] =
              (nominations[candidateKey]!["votes"] ?? 0) + totalVotes;
        }
      }

      setState(() {
        _nominations = nominations;
        _isLoading = false;
      });
    } catch (error) {
      print("Error: $error");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nominations Count"),
        backgroundColor: Colors.blueAccent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _nominations.isEmpty
              ? const Center(
                  child: Text(
                    "Total Nominations: 0",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                )
              : ListView.builder(
                  itemCount: _nominations.length,
                  itemBuilder: (context, index) {
                    String candidate = _nominations.keys.elementAt(index);
                    String post = _nominations[candidate]!["post"];
                    int votes = _nominations[candidate]!["votes"];

                    return Card(
                      margin: const EdgeInsets.all(10),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.person, color: Colors.blue),
                        title: Text(
                          "Candidate: $candidate",
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "Post: $post\nVotes: ${votes > 0 ? votes : "No votes"}",
                          style: const TextStyle(
                              fontSize: 16, color: Colors.black87),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
