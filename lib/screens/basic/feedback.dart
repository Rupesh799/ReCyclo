import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackPage extends StatefulWidget {
  final String userType;

  FeedbackPage({required this.userType});

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  TextEditingController feedbackController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to save feedback to the 'feedback' collection
  Future<void> saveFeedback(String feedback) async {
    try {
      await _firestore.collection('feedback').add({
        'feedback': feedback,
        'userType': widget.userType,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Feedback submitted successfully!'),
      ));

      // Optionally, you can navigate to another screen.
      // In this example, we pop the current screen to go back.
      Navigator.of(context).pop();
    } catch (e) {
      print('Error saving feedback: $e');
      // Handle the error here
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feedback',style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),),
      elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 8, 149, 128),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextFormField(
              minLines: 5,
              maxLines: 10,
              keyboardType: TextInputType.multiline,
              controller: feedbackController,
              decoration: InputDecoration(
                hintText: 'Enter your feedback',
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Get the feedback text
                String feedback = feedbackController.text;

                // Save feedback to the 'feedback' collection
                saveFeedback(feedback);
              },
              child: Text('Submit',style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),),
            ),
          ],
        ),
      ),
    );
  }
}

