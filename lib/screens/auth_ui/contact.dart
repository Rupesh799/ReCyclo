import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Contact extends StatelessWidget {
  _launchEmail() async {
    const email = 'mailto:recyclo@gmail.com';
    try {
      // ignore: deprecated_member_use
      if (await canLaunch(email)) {
        // ignore: deprecated_member_use
        await launch(email);
      } else {
        throw 'Could not launch $email';
      }
    } catch (e) {
      print('Error launching email: $e');
    }
  }

  _launchPhone() async {
    const phone = 'tel:+9779800123456';
    // ignore: deprecated_member_use
    if (await canLaunch(phone)) {
      // ignore: deprecated_member_use
      await launch(phone);
    } else {
      throw 'Could not launch $phone';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Contact Us',
          style: TextStyle(
              fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 8, 149, 128),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: _launchEmail,
              child: Row(
                children: [
                  Icon(
                    Icons.email,
                    color: Color.fromARGB(255, 8, 149, 128),
                  ), // Email icon
                  SizedBox(width: 12),
                  Text(
                    'recyclo@gmail.com',
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            InkWell(
              onTap: _launchPhone,
              child: Row(
                children: [
                  Icon(
                    Icons.phone,
                    color: Color.fromARGB(255, 8, 149, 128),
                  ), // Phone icon
                  SizedBox(width: 12),
                  Text(
                    '+977 9800123456',
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text(
              'If you have any query about ReCyclo, feel free to contact us...',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
