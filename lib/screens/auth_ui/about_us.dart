// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';

// class AboutUsScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('About Us',style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//         elevation: 0,
//         flexibleSpace: Container(
//           decoration: BoxDecoration(
//             color: Color.fromARGB(255, 8, 149, 128),
//           ),
//         ),
//         ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // Display Picture
//             Image.asset(
//               'assets/images/welcome.png', // Replace with your image path
//               height: 200,
//               fit: BoxFit.cover,
//             ),
//             SizedBox(height: 20),

//             // "About Us" Text
//             SizedBox(height: 10),
//             Text(
//               'Recyclo is all about making recycling easy and convenient. We use technology to help people recycle more, making our world cleaner and better for everyone.',
//               style: TextStyle(fontSize: 16),
//             ),
//             SizedBox(height: 30),

//             // "Our Purpose" Section
//             Text(
//               'Our Purpose',
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 10),
//             Text(
//               'Our mission is to empower communities to adopt eco-friendly practices for a greener, healthier planet.',
//               style: TextStyle(fontSize: 16),
//             ),
//             SizedBox(height: 30),

//             // "Meet Our Members" Section
//             Text(
//               'Meet Our Members',
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 10),
//             // List of team members
//             ListTile(
//               leading: CircleAvatar(
//                 backgroundImage: AssetImage('assets/images/reeya.jpg'), // Replace with member's profile picture
//               ),
//               title: Text('Riya BC'),
//               subtitle: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text('riyabc.076@kathford.edu.np'),
//                   Text('+977 9815603612'),
//                 ],
//               ),
//             ),
//             ListTile(
//               leading: CircleAvatar(
//                 backgroundImage: AssetImage('assets/images/rupesh.jpg'), // Replace with member's profile picture
//               ),
//               title: Text('Rupesh Khatri'),
//               subtitle: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text('rupeshkhatri.076@kathford.edu.np'),
//                   Text('+977 9816373563'),
//                 ],
//               ),
//             ),
//             ListTile(
//               leading: CircleAvatar(
//                 backgroundImage: AssetImage('assets/images/sneha.jpg'), // Replace with member's profile picture
//               ),
//               title: Text('Sneha Neupane'),
//               subtitle: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text('snehaneupane.076@kathford.edu.np'),
//                   Text('+977 9825365166'),
//                 ],
//               ),
//             ),
//             // Add more ListTile widgets for other members as needed
//           ],
//         ),
//       ),
//     );
//   }
// }

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsScreen extends StatelessWidget {
  _launchEmail(String email) async {
    final Uri _emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
    );

    if (await canLaunch(_emailLaunchUri.toString())) {
      await launch(_emailLaunchUri.toString());
    } else {
      throw 'Could not launch $_emailLaunchUri';
    }
  }

  _launchPhone(String phone) async {
    final Uri _phoneLaunchUri = Uri(
      scheme: 'tel',
      path: phone,
    );

    if (await canLaunch(_phoneLaunchUri.toString())) {
      await launch(_phoneLaunchUri.toString());
    } else {
      throw 'Could not launch $_phoneLaunchUri';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'About Us',
          style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
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
            // Display Picture
            Image.asset(
              'assets/images/welcome.png', // Replace with your image path
              height: 200,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 20),

            // "About Us" Text
            SizedBox(height: 10),
            Text(
              'Recyclo is all about making recycling easy and convenient. We use technology to help people recycle more, making our world cleaner and better for everyone.',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 30),

            // "Our Purpose" Section
            Text(
              'Our Purpose',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Our mission is to empower communities to adopt eco-friendly practices for a greener, healthier planet.',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 30),

            // "Meet Our Members" Section
            Text(
              'Meet Our Members',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            // List of team members
            ListTile(
              leading: CircleAvatar(
                backgroundImage: AssetImage('assets/images/reeya.jpg'), // Replace with member's profile picture
              ),
              title: Text('Riya BC'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                 InkWell(
                  onTap: () => _launchEmail('riyabc.076@kathford.edu.np'),
                  child: Row(
                    children: [
                      Icon(Icons.email, color: Color.fromARGB(255, 8, 149, 128),), // Email icon
                      SizedBox(width: 12),
                      Text(
                        'riyabc.076@kathford.edu.np',
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
                 InkWell(
                  onTap: () => _launchPhone('+9779815603612'),
                  child: Row(
                    children: [
                      Icon(Icons.phone, color: Color.fromARGB(255, 8, 149, 128),), // Phone icon
                      SizedBox(width: 12),
                      Text(
                        '+977 9815603612',
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
                ],
              ),
            ),

            ListTile(
              leading: CircleAvatar(
                backgroundImage: AssetImage('assets/images/rupesh.jpg'), // Replace with member's profile picture
              ),
              title: Text('Rupesh Khatri'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   InkWell(
                  onTap: () => _launchEmail('rupeshkhatri.076@kathford.edu.np'),
                  child: Row(
                    children: [
                      Icon(Icons.email, color: Color.fromARGB(255, 8, 149, 128),), // Email icon
                      SizedBox(width: 12),
                      Text(
                        'rupeshkhatri.076@kathford.edu.np',
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
                 InkWell(
                  onTap: () => _launchPhone('+9779816373563'),
                  child: Row(
                    children: [
                      Icon(Icons.phone, color: Color.fromARGB(255, 8, 149, 128),), // Phone icon
                      SizedBox(width: 12),
                      Text(
                        '+977 9816373563',
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
                ],
              ),
            ),

            ListTile(
              leading: CircleAvatar(
                backgroundImage: AssetImage('assets/images/sneha.jpg'), // Replace with member's profile picture
              ),
              title: Text('Sneha Neupane'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   InkWell(
                  onTap: () => _launchEmail('snehaneupane.076@kathford.edu.np'),
                  child: Row(
                    children: [
                      Icon(Icons.email, color: Color.fromARGB(255, 8, 149, 128),), // Email icon
                      SizedBox(width: 12),
                      Text(
                        'snehaneupane.076@kathford.edu.np',
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
                 InkWell(
                  onTap: () => _launchPhone('+9779825365166'),
                  child: Row(
                    children: [
                      Icon(Icons.phone, color: Color.fromARGB(255, 8, 149, 128),), // Phone icon
                      SizedBox(width: 12),
                      Text(
                        '+977 9825365166',
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
                ],
              ),
            ),
          ],

        ),
      ),
    );
  }
}
