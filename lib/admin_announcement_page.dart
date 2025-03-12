import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'admin_announcements_list.dart';

class AdminAnnouncementPage extends StatefulWidget {
  const AdminAnnouncementPage({super.key});

  @override
  _AdminAnnouncementPageState createState() => _AdminAnnouncementPageState();
}

class _AdminAnnouncementPageState extends State<AdminAnnouncementPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _deleteExpiredAnnouncements(); // Automatically delete expired announcements
  }

  // Method to delete expired announcements
  Future<void> _deleteExpiredAnnouncements() async {
    final now = DateTime.now();
    final QuerySnapshot expiredAnnouncements = await FirebaseFirestore.instance
        .collection('announcements')
        .where('date', isLessThan: Timestamp.fromDate(now)) // Get past dates
        .get();

    for (var doc in expiredAnnouncements.docs) {
      await FirebaseFirestore.instance.collection('announcements').doc(doc.id).delete();
    }
  }

  // Method to pick a date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Method to add announcement to Firestore
  Future<void> _addAnnouncement() async {
    if (_titleController.text.isNotEmpty &&
        _contentController.text.isNotEmpty &&
        _selectedDate != null) {
      final announcement = {
        'title': _titleController.text,
        'content': _contentController.text,
        'date': Timestamp.fromDate(_selectedDate!), // Store date as Firestore Timestamp
      };

      bool? shouldSave = await _showConfirmationDialog();
      if (shouldSave ?? false) {
        await FirebaseFirestore.instance.collection('announcements').add(announcement);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Announcement Posted')),
        );
        _titleController.clear();
        _contentController.clear();
        setState(() {
          _selectedDate = null;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
    }
  }

  // Method to show confirmation dialog
  Future<bool?> _showConfirmationDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Announcement'),
          content: const Text('Are you sure you want to post this announcement?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Cancel
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Confirm
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Announcements'),
        backgroundColor: const Color(0xFF81D4FA), // Set the color
      ),
      body: SingleChildScrollView( // Wrap the content in a scrollable view
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    _selectedDate == null
                        ? 'Select Date'
                        : 'Date: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _addAnnouncement,
                child: const Text('Post Announcement'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminAnnouncementsListPage()),
                  );
                },
                child: const Text('Announcements Made'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
