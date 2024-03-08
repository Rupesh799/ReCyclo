// import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:Recyclo/authentication/auth_service.dart';
import 'package:Recyclo/screens/auth_ui/login.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class Signup extends StatefulWidget {
  // const Signup({super.key});
  final Function? toggleView;
  const Signup({super.key, this.toggleView});

  @override
  State<Signup> createState() => _SignupState();
}

enum UserType { Seller, Buyer }

class _SignupState extends State<Signup> {
  bool isShowPassword = true;

  final AuthService _auth = AuthService();
  UserType selectedUserType = UserType.Seller;

  //wastetype
  List<String> wasteType = ["Plastic", "Paper", "Glass", "e-Waste"];
  List<bool> selectedWaste = [false, false, false, false];

// waste quantity
  List<String> wasteQty = [
    'Below 1kg',
    '1 to 5 kg',
    'Above 5 kg',
  ];
  List<bool> selectedQty = [false, false, false];
  String initialSelectedQty = "Below 1kg";

// User Authentication
  String fullName = "", email = "", phone = "", password = "";

  TextEditingController namecontroller = new TextEditingController();
  TextEditingController emailcontroller = new TextEditingController();
  TextEditingController phonecontroller = new TextEditingController();
  TextEditingController passwordcontroller = new TextEditingController();
  // TextEditingController wasteTypecontroller = new TextEditingController();
  List<TextEditingController> wasteTypecontroller = [];
  // TextEditingController wasteQtycontroller = new TextEditingController();
  List<TextEditingController> wasteQtycontroller = [];
  final _formKey = GlobalKey<FormState>();
  // final _wasteFormKey = GlobalKey<FormState>();

  bool validateWasteFields() {
    if (!selectedWaste.contains(true)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            "Please select at least one waste type",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Color.fromARGB(255, 8, 149, 128)));
      return false;
    }

    // ignore: unnecessary_null_comparison
    if (initialSelectedQty == null || initialSelectedQty.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            "Please select waste quantity",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Color.fromARGB(255, 8, 149, 128)));
      return false;
    }
    return true;
  }

  // defining the socket
  late io.Socket socket;

  @override
  void initState() {
    super.initState();

    //initialize socket.io client
    socket = io.io('http://192.168.143.25:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoconnect': false,
    });

    socket.connect();
  }

  register() async {
    if (password != null &&
        namecontroller.text != "" &&
        emailcontroller.text != "" &&
        phonecontroller.text != "") {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);

        // Emit 'register_seller' event to the Socket.IO server
        socket.emit('register_seller',{
          'fullname': fullName,
          'email': email,
          'phone': phone,
          'password': password,
        });

        await FirebaseFirestore.instance
            .collection('sellers')
            .doc(userCredential.user?.uid)
            .set({
          'fullname': fullName,
          'email': email,
          'phone': phone,
          'password': password,
          'userType': selectedUserType == UserType.Seller ? 'Seller' : 'Buyer',
          // Add other fields as needed
        });

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              "Registered Succesfully!",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: Color.fromARGB(255, 8, 149, 128)));

        // ignore: use_build_context_synchronously
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Login()));
      } on FirebaseAuthException catch (e) {
        if (e.code == "weak-password") {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Password is too weeak"),
              backgroundColor: Color.fromARGB(255, 8, 149, 128)));
        } else if (e.code == "email-already-in-use") {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Email is already used"),
              backgroundColor: Color.fromARGB(255, 8, 149, 128)));
        }
      }
    }
  }

//buyer
  register1() async {
    if (password != null &&
            namecontroller.text != "" &&
            emailcontroller.text != "" &&
            phonecontroller.text != "" &&
            validateWasteFields()
        // ignore: unrelated_type_equality_checks
        ) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);

        // Emit 'register_buyer' event to the Socket.IO server
        // socket.emit(
        //   'register_buyer',
        //   {
        //     'fullname': fullName,
        //     'email': email,
        //     'phone': phone,
        //     'password': password,
        //     'selectedWaste': selectedWaste,
        //     'initialSelectedQty': initialSelectedQty,
        //   },
        // );

        // socket.on('register_buyer_callback', (data) {
        //   print('Socket ID received: ${data['socketId']}');
        // });

        await FirebaseFirestore.instance
            .collection('buyers')
            .doc(userCredential.user?.uid)
            .set({
          'fullname': fullName,
          'email': email,
          'phone': phone,
          'password': password,
          'userType': selectedUserType == UserType.Buyer ? 'Buyer' : 'Seller',
          'WasteType': selectedWaste,
          'WasteQuantity': initialSelectedQty,
          // Add other fields as needed
        });

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              "Registered Succesfully!",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: Color.fromARGB(255, 8, 149, 128)));

        // ignore: use_build_context_synchronously
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Login()));
      } on FirebaseAuthException catch (e) {
        if (e.code == "weak-password") {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Password is too weeak"),
              backgroundColor: Color.fromARGB(255, 8, 149, 128)));
        } else if (e.code == "email-already-in-use") {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Email is already used"),
              backgroundColor: Color.fromARGB(255, 8, 149, 128)));
        }
      }
    }
  }

  //toggle button
  List<String> get btns => ["Seller", "Buyer"];
  // int counter =0;

  // Function to render the form fields based on the selected user type
  Widget renderFormFields(UserType userType) {
    switch (userType) {
      case UserType.Seller:
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextFormField(
                  controller: namecontroller,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                      hintText: "FullName",
                      prefixIcon: Icon(
                        Icons.person,
                        color: Color.fromARGB(255, 8, 149, 128),
                      ))),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  controller: emailcontroller,
                  validator: (value) {
                    if (value != null) {
                      if (value.contains('@') && value.endsWith('.com')) {
                        return null;
                      }
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                      hintText: "Email",
                      prefixIcon: Icon(
                        Icons.mail,
                        color: Color.fromARGB(255, 8, 149, 128),
                      ))),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextFormField(
                  controller: phonecontroller,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      hintText: "Phone Number",
                      prefixIcon: Icon(
                        Icons.call,
                        color: Color.fromARGB(255, 8, 149, 128),
                      ))),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextFormField(
                  controller: passwordcontroller,
                  obscureText: isShowPassword,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'This field is required';
                    }
                    if (value.trim().length < 8) {
                      return 'Password must be at least 8 characters in length';
                    }
                    // Return null if the entered password is valid
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: "Create Password",
                    prefixIcon: const Icon(
                      Icons.lock,
                      color: Color.fromARGB(255, 8, 149, 128),
                    ),
                    suffixIcon: TextButton(
                      onPressed: () {
                        setState(() {
                          isShowPassword = !isShowPassword;
                        });
                      },
                      child: const Icon(
                        Icons.visibility,
                        color: Color.fromARGB(255, 8, 149, 128),
                      ),
                    ),
                  )),
            ),
            ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      fullName = namecontroller.text;
                      email = emailcontroller.text;
                      phone = phonecontroller.text;
                      password = passwordcontroller.text;
                    });
                  }
                  register();
                },
                child: const Text(
                  "SignUp",
                  style: TextStyle(color: Colors.white),
                )),
          ],
        );
      case UserType.Buyer:
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextFormField(
                  controller: namecontroller,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                      hintText: "FullName",
                      prefixIcon: Icon(
                        Icons.person,
                        color: Color.fromARGB(255, 8, 149, 128),
                      ))),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  controller: emailcontroller,
                  validator: (value) {
                    if (value != null) {
                      if (value.contains('@') && value.endsWith('.com')) {
                        return null;
                      }
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                      hintText: "Email",
                      prefixIcon: Icon(
                        Icons.mail,
                        color: Color.fromARGB(255, 8, 149, 128),
                      ))),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextFormField(
                  controller: phonecontroller,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      hintText: "Phone Number",
                      prefixIcon: Icon(
                        Icons.call,
                        color: Color.fromARGB(255, 8, 149, 128),
                      ))),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextFormField(
                  controller: passwordcontroller,
                  obscureText: isShowPassword,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'This field is required';
                    }
                    if (value.trim().length < 8) {
                      return 'Password must be at least 8 characters in length';
                    }
                    // Return null if the entered password is valid
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: "Create Password",
                    prefixIcon: const Icon(
                      Icons.lock,
                      color: Color.fromARGB(255, 8, 149, 128),
                    ),
                    suffixIcon: TextButton(
                      onPressed: () {
                        setState(() {
                          isShowPassword = !isShowPassword;
                        });
                      },
                      child: const Icon(
                        Icons.visibility,
                        color: Color.fromARGB(255, 8, 149, 128),
                      ),
                    ),
                  )),
            ),
            SizedBox(
              height: 12,
            ),
            Text("Select Waste Type"),
            ListView.builder(
              shrinkWrap: true,
              itemCount: wasteType.length,
              itemBuilder: (context, index) {
                return CheckboxListTile(
                    title: Text(wasteType[index]),
                    value: selectedWaste[index],
                    onChanged: (value) {
                      setState(() {
                        selectedWaste[index] = value!;
                      });
                    });
              },
            ),
            SizedBox(
              height: 12,
            ),
            Text("Choose Waste Quantity"),
            TextFormField(
              decoration: InputDecoration(labelText: "Select"),
            ),
            DropdownButtonFormField<String>(
              value: initialSelectedQty,
              onChanged: (newValue) {
                setState(() {
                  initialSelectedQty = newValue!;
                });
              },
              items: wasteQty.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select an item';
                }
                return null;
              },
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      fullName = namecontroller.text;
                      email = emailcontroller.text;
                      phone = phonecontroller.text;
                      password = passwordcontroller.text;
                    });
                    List<String> selectedItems = [];
                    for (int i = 0; i < wasteType.length; i++) {
                      if (selectedWaste[i]) {
                        selectedItems.add(wasteType[i]);
                      }
                    }
                  }
                  register1();
                },
                child: const Text(
                  "SignUp",
                  style: TextStyle(color: Colors.white),
                )),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(children: [
                const SizedBox(
                  height: 20,
                ),
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                      child: Text('Create an Account',
                          style: TextStyle(
                            fontSize: 35,
                            fontWeight: FontWeight.bold,
                          ))),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Radio(
                      value: UserType.Seller,
                      groupValue: selectedUserType,
                      onChanged: (value) {
                        setState(() {
                          selectedUserType = value as UserType;
                        });
                      },
                    ),
                    const Text('Seller'),
                    Radio(
                      value: UserType.Buyer,
                      groupValue: selectedUserType,
                      onChanged: (value) {
                        setState(() {
                          selectedUserType = value as UserType;
                        });
                      },
                    ),
                    const Text('Buyer'),
                  ],
                ),
                renderFormFields(selectedUserType),

                const SizedBox(
                  height: 20,
                ),
                const Text("Already Have an Account?"),

                // TextButton(onPressed: (){}, child: const Text("Create an Account."))
                InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, 'login_screen');
                  },
                  child: const Text(
                    "Login",
                    style: TextStyle(color: Colors.blue, fontSize: 12),
                  ),
                )
              ]),
            )),
      ),
    );
  }
}
