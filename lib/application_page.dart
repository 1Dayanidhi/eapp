import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MaterialApp(home: ApplicationForm()));
}

class ApplicationForm extends StatefulWidget {
  const ApplicationForm({super.key});

  @override
  ApplicationFormState createState() => ApplicationFormState();
}

class ApplicationFormState extends State<ApplicationForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _vision1Controller = TextEditingController();
  final _vision2Controller = TextEditingController();
  String? selectedShift;
  String? selectedPost;
  String? residentStatus;
  String? attendance;
  String? arrear;
  String? above50Percent;
  int currentStep = 0;
  bool isUg = false;
  bool isPg = false;
  bool isFirstYear = false;
  bool isSecondYear = false;
  bool isShift1 = false;
  bool isShift2 = false;

  final List<String> generalPosts = [
    'President', 'Vice President', 'Secretary', 'Treasurer',
    'Chairpersons for Cultural Activities', 'Chairpersons for Extension Activities','Chairpersons for Games', 
    'Chairperson for Non-Residents','Class 2 Representative','PG Representative',
  ];
  final List<String> residentPosts = [
    'Chairperson for Residents', 'Assistant Chairperson for Residents',
    'Chairperson for Religious Life', 
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (docSnapshot.exists) {
        var data = docSnapshot.data() as Map<String, dynamic>;
        setState(() {
          _nameController.text = data['username'] ?? '';
          _studentIdController.text = data['regno'] ?? '';
          _emailController.text = data['email'] ?? '';
          _phoneController.text = data['phone'] ?? '';
        });
      }
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Application Submitted Successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Application Form', style: TextStyle(fontSize: 20)),
        backgroundColor: const Color(0xFF81D4FA),
      ),
      body: Stepper(
        currentStep: currentStep,
        onStepContinue: () {
          if (currentStep < 3) {
            setState(() {
              currentStep++;
            });
          } else {
            _submitForm();
          }
        },
        onStepCancel: () {
          setState(() {
            if (currentStep > 0) {
              currentStep--;
            }
          });
        },
        controlsBuilder: (context, details) {
          return Row(
            children: [
              if (currentStep != 0)
                ElevatedButton(
                  onPressed: details.onStepCancel,
                  child: const Text('Back'),
                ),
              const SizedBox(width: 10),
              if (currentStep < 3)
                ElevatedButton(
                  onPressed: details.onStepContinue,
                  child: const Text('Next'),
                ),
              const SizedBox(width: 10),
              if (currentStep == 3)
                ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Submit'),
                ),
            ],
          );
        },
        steps: [
          Step(
            title: const Text('Personal Info'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextFormField(controller: _studentIdController, decoration: const InputDecoration(labelText: 'Student ID', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email ID', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextFormField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Are you a resident?', border: OutlineInputBorder()),
                  items: ['Yes', 'No'].map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
                  onChanged: (value) => setState(() => residentStatus = value),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Shift', border: OutlineInputBorder()),
                  items: ['Shift 1', 'Shift 2'].map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
                  onChanged: (value) => setState(() => selectedShift = value),
                ),
                const SizedBox(height: 10),
                Column(
  children: [
    Row(
      children: [
        Checkbox(
          value: isUg,
          onChanged: (value) => setState(() {
            isUg = value!;
            isPg = false;
          }),
        ),
        const Text('UG'),
        Checkbox(
          value: isPg,
          onChanged: (value) => setState(() {
            isPg = value!;
            isUg = false;
            isFirstYear = false; // Reset year selection
            isSecondYear = false;
          }),
        ),
        const Text('PG'),
      ],
    ),
    const SizedBox(height: 10),
    if (isUg) // Show both year options only if UG is selected
      Row(
        children: [
          Checkbox(
            value: isFirstYear,
            onChanged: (value) => setState(() {
              isFirstYear = value!;
              isSecondYear = !value;
            }),
          ),
          const Text('1st Year'),
          Checkbox(
            value: isSecondYear,
            onChanged: (value) => setState(() {
              isSecondYear = value!;
              isFirstYear = !value;
            }),
          ),
          const Text('2nd Year'),
        ],
      ),
    if (isPg) // Show only the 1st year option if PG is selected
      Row(
        children: [
          Checkbox(
            value: isFirstYear,
            onChanged: (value) => setState(() {
              isFirstYear = value!;
            }),
          ),
          const Text('1st Year'),
        ],
      ),
  ],
),

                const SizedBox(height: 10),
              ],
            ),
          ),
          Step(
            title: const Text('Post & Details'),
            content:  Column(
              children: [
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
  decoration: const InputDecoration(
    labelText: 'Post Applying For',
    border: OutlineInputBorder(),
  ),
  items: (
    isFirstYear && isUg
      ? (residentStatus == "No"
          ? ['Class 2 Representative']
          : ['Class 2 Representative', 'Assistant Chairperson for Residents'])
      : isFirstYear && isPg
          ? ['PG Representative']
          : isSecondYear && isUg
              ? (residentStatus == "Yes"
                  ? [
                      'President',
                      'Vice President',
                      'Secretary',
                      'Treasurer',
                      'Chairpersons for Cultural Activities',
                      'Chairpersons for Extension Activities',
                      'Chairpersons for Games',
                      'Chairperson for Residents',
                      'Chairperson for Religious Life'
                    ]
                  : [
                      'President',
                      'Vice President',
                      'Secretary',
                      'Treasurer',
                      'Chairpersons for Cultural Activities',
                      'Chairpersons for Extension Activities',
                      'Chairpersons for Games',
                      'Chairperson for Non-Residents'
                    ])
              : []
  )
      .map<DropdownMenuItem<String>>((position) => DropdownMenuItem<String>(
            value: position,
            child: Text(position),
          ))
      .toList(),
  onChanged: (value) => setState(() => selectedPost = value),
),


            const SizedBox(height: 10),
            ],
            ),
          ),
          Step(
            title: const Text('Vision'),
            content: Column(
              children: [
                const SizedBox(height: 10),
                TextFormField(controller: _vision1Controller, decoration: const InputDecoration(labelText: 'Vision Statement 1', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextFormField(controller: _vision2Controller, decoration: const InputDecoration(labelText: 'Vision Statement 2', border: OutlineInputBorder())),
                const SizedBox(height: 10),
              ],
            ),
          ),
          Step(
            title: const Text('Arrear & Attendance'),
            content: Column(
              children: [
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Do you have any arrears?', border: OutlineInputBorder()),
                  items: ['Yes', 'No'].map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
                  onChanged: (value) => setState(() => arrear = value),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Do you have above 50% in all subjects?', border: OutlineInputBorder()),
                  items: ['Yes', 'No'].map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
                  onChanged: (value) => setState(() => above50Percent = value),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Do you have 50% attendance in all subjects?', border: OutlineInputBorder()),
                  items: ['Yes', 'No'].map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
                  onChanged: (value) => setState(() => attendance = value),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
