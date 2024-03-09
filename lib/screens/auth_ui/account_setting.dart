import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:Recyclo/screens/auth_ui/login.dart';
import 'package:Recyclo/screens/auth_ui/user_profile.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:Recyclo/screens/basic/feedback.dart';
import 'package:Recyclo/screens/auth_ui/about_us.dart';
import 'package:Recyclo/screens/auth_ui/contact.dart';
import 'package:Recyclo/screens/auth_ui/settings.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class AccountSetting extends StatefulWidget {
  const AccountSetting({super.key});

  @override
  State<AccountSetting> createState() => _AccountSettingState();
}

class _AccountSettingState extends State<AccountSetting> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  Map<String, dynamic>? _userData;

  late io.Socket socket;

  @override
  void initState() {
    super.initState();
    _getUserData();
    _initializeSocket();
  }

  Future<void> _getUserData() async {
    User? user = _auth.currentUser;

    if (user != null) {
      DocumentSnapshot<Map<String, dynamic>> snapshot;

      // Check the userType from the 'buyers' collection
      snapshot = await _firestore.collection('buyers').doc(user.uid).get();

      if (snapshot == null || !snapshot.exists) {
        // If not found in 'buyers', check the 'sellers' collection
        snapshot = await _firestore.collection('sellers').doc(user.uid).get();
      }

      setState(() {
        _user = user;
        _userData = snapshot.data();
      });
    }
  }

  void _initializeSocket() {
    // Replace with your server URL
    socket = io.io('http://your-server-url', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    socket.onConnect((data) {
      print('Socket connected: ${socket.id}');
      setState(() {
        _userData?['socketId'] = socket.id;
      });
    });
  }

  //image upload
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    // Replace the image picking logic with setting a default image
    setState(() {
      _image = null; // Set _image to null to indicate no custom image
    });
  }

  //Logout conformation
  void Logout() {
    _showLogoutConfirmationDialog();
  }

  Future<void> _showLogoutConfirmationDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Are You Sure Want to Logout"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog

                // Emit the logout event with the socket ID
                final socketId = _userData?['socketId'];
                if (socketId != null) {
                  if (_userData?['userType'] == 'seller') {
                    socket.emit('seller_logout', socketId);
                  } else if (_userData?['userType'] == 'buyer') {
                    socket.emit('buyer_logout', socketId);
                  }
                }

                await _auth.signOut();
                Fluttertoast.showToast(
              msg: "you are logged out",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Color.fromARGB(255, 8, 149, 128),
              textColor: Colors.white,
            );
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Login()),
                );
              },
              child: Text("Logout"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account Setting')),
      body: _user != null
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            height: 80,
                            width: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              shape: BoxShape.circle,
                            ),
                            child: _image == null
                                ? Image.asset(
                                    'assets/images/person.png', // Replace with your asset path
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _userData?['fullname'] ?? '',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Text(
                            _userData?['phone'] ?? '',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => UserProfile()));
                                },
                                child: Text(
                                  "Profile Setting",
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              InkWell(
                                onTap: () {},
                                child: Icon(
                                  Icons.arrow_right,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SettingScreen(),
                              ),
                            );
                          },
                          child: const Row(children: [
                            Icon(
                              Icons.settings,
                              color: Color.fromARGB(255, 40, 125, 112),
                              size: 30,
                            ),
                            SizedBox(
                              width: 12,
                            ),
                            Text(
                              "Settings",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                          ]),
                        ),
                        const SizedBox(
                          height: 45,
                        ),
                        const Row(children: [
                          Icon(
                            Icons.money,
                            color: Color.fromARGB(255, 40, 125, 112),
                            size: 30,
                          ),
                          SizedBox(
                            width: 12,
                          ),
                          Text(
                            "Rates",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                        ]),
                        const SizedBox(
                          height: 45,
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AboutUsScreen(),
                              ),
                            );
                          },
                          child: const Row(children: [
                            Icon(
                              Icons.info,
                              color: Color.fromARGB(255, 40, 125, 112),
                              size: 30,
                            ),
                            SizedBox(
                              width: 12,
                            ),
                            Text(
                              "About Us",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                          ]),
                        ),
                        const SizedBox(
                          height: 45,
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Contact(),
                              ),
                            );
                          },
                          child: const Row(children: [
                            Icon(
                              Icons.phone,
                              color: Color.fromARGB(255, 40, 125, 112),
                              size: 30,
                            ),
                            SizedBox(
                              width: 12,
                            ),
                            Text(
                              "Contact",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                          ]),
                        ),
                        const SizedBox(
                          height: 45,
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FeedbackPage(
                                    userType: _userData?['userType'] ?? ''),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.feedback,
                                color: Color.fromARGB(255, 40, 125, 112),
                                size: 30,
                              ),
                              SizedBox(
                                width: 12,
                              ),
                              Text(
                                "Feedback",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 45,
                        ),
                        InkWell(
                          onTap: () {
                            
                            Logout();
                          },
                          child: const Row(children: [
                            Icon(
                              Icons.logout,
                              color: Color.fromARGB(255, 40, 125, 112),
                              size: 30,
                            ),
                            SizedBox(
                              width: 12,
                            ),
                            Text(
                              "Logout",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                          ]),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}