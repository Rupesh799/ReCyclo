import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: getUserType(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError || snapshot.data == null) {
          return Scaffold(
            body: Center(
              child: Text("Error fetching user type"),
            ),
          );
        } else {
          String userType = snapshot.data!;

          return Scaffold(
            appBar: AppBar(
              title: Text("Change Profile Information"),
            ),
            body: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: userType == 'buyer'
                    ? buildBuyerButtons(context)
                    : (userType == 'seller' ? buildSellerButtons(context) : []),
              ),
            ),
          );
        }
      },
    );
  }

  List<Widget> buildBuyerButtons(BuildContext context) {
    return [
      buildButton(context, "FullName"),
      SizedBox(height: 16),
      buildButton(context, "Email"),
      SizedBox(height: 16),
      buildButton(context, "Phone"),
      SizedBox(height: 16),
      buildButton(context, "Password"),
      SizedBox(height: 16),
      buildButton(context, "WasteType"),
      SizedBox(height: 16),
      buildButton(context, "WasteQuantity"),
    ];
  }

  List<Widget> buildSellerButtons(BuildContext context) {
    return [
      buildButton(context, "FullName"),
      SizedBox(height: 16),
      buildButton(context, "Email"),
      SizedBox(height: 16),
      buildButton(context, "Phone"),
      SizedBox(height: 16),
      buildButton(context, "Password"),
    ];
  }

  Widget buildButton(BuildContext context, String label) {
    return ElevatedButton(
      onPressed: () {
        if (label.toLowerCase() == "wastetype") {
          _showWasteTypeDialog(context);
        } else {
          _showInputDialog(context, label.toLowerCase());
        }
      },
      child: Text(label),
    );
  }

  Future<void> _showInputDialog(BuildContext context, String inputType) async {
    // ... (unchanged code for the dialog)
  }

  Future<void> _showWasteTypeDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return WasteTypeDialog();
      },
    );
  }

  Future<String> getUserType() async {
    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId != null) {
        DocumentSnapshot<Map<String, dynamic>> buyerSnapshot =
            await FirebaseFirestore.instance
                .collection('buyers')
                .doc(userId)
                .get();

        if (buyerSnapshot.exists) {
          return 'buyer';
        }

        DocumentSnapshot<Map<String, dynamic>> sellerSnapshot =
            await FirebaseFirestore.instance
                .collection('sellers')
                .doc(userId)
                .get();

        if (sellerSnapshot.exists) {
          return 'seller';
        }
      }

      return '';
    } catch (e) {
      print("Error fetching user type: $e");
      return '';
    }
  }
}

class WasteTypeDialog extends StatefulWidget {
  @override
  _WasteTypeDialogState createState() => _WasteTypeDialogState();
}

class _WasteTypeDialogState extends State<WasteTypeDialog> {
  List<String> selectedWasteTypes = [];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Select Waste Types"),
      content: Column(
        children: [
          buildCheckbox("Plastic"),
          buildCheckbox("Paper"),
          buildCheckbox("Glass"),
          buildCheckbox("e-Waste"),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("Cancel"),
        ),
        TextButton(
          onPressed: () async {
            // Handle the selected waste types
            print("Selected Waste Types: $selectedWasteTypes");

            // Update the user's information in the Firestore database
            await updateWasteTypesInDatabase(selectedWasteTypes);

            Navigator.pop(context);
          },
          child: Text("Save"),
        ),
      ],
    );
  }

  Widget buildCheckbox(String label) {
    return Row(
      children: [
        Checkbox(
          value: selectedWasteTypes.contains(label),
          onChanged: (bool? value) {
            setState(() {
              if (value != null) {
                if (value) {
                  selectedWasteTypes.add(label);
                } else {
                  selectedWasteTypes.remove(label);
                }
              }
            });
          },
        ),
        Text(label),
      ],
    );
  }

  Future<void> updateWasteTypesInDatabase(
      List<String> selectedWasteTypes) async {
    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId != null) {
        // Fetch the user type from Firebase
        String userType = await getUserType();

        // Fetch the existing waste types to maintain unselected types
        List<bool> allWasteTypes = await getAllWasteTypes();

        // Update only the selected waste types in the list
        for (int i = 0; i < allWasteTypes.length; i++) {
          allWasteTypes[i] = selectedWasteTypes.contains(wasteTypeOptions[i]);
        }

        // Update the information in the appropriate collection based on user type
        await updateUserInfoInDatabase(
          allWasteTypes,
          userId: userId,
          userType: userType,
          inputType: "WasteType",
        );
      }
    } catch (e) {
      print("Error updating WasteTypes in the database: $e");
    }
  }

  Future<List<bool>> getAllWasteTypes() async {
    // Assuming wasteTypeOptions is a list containing all possible waste types
    List<bool> allWasteTypes = List.filled(wasteTypeOptions.length, false);

    // ... (you may fetch the existing values from the database here)

    return allWasteTypes;
  }

  final List<String> wasteTypeOptions = [
    "Plastic",
    "Paper",
    "Glass",
    "e-Waste"
  ];

// Update the updateUserInfoInDatabase function to handle List<bool>
  Future<void> updateUserInfoInDatabase(List<bool> newValues,
      {required String userId,
      required String userType,
      required String inputType}) async {
    try {
      String collectionName = (userType == "seller") ? "sellers" : "buyers";

      // Update other information in Firestore with merge
      await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(userId)
          .set({inputType: newValues}, SetOptions(merge: true));

      print("$inputType updated successfully: $newValues");
    } catch (e) {
      print("Error updating $inputType: $e");
    }
  }

  Future<String> getUserType() async {
    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId != null) {
        DocumentSnapshot<Map<String, dynamic>> buyerSnapshot =
            await FirebaseFirestore.instance
                .collection('buyers')
                .doc(userId)
                .get();

        if (buyerSnapshot.exists) {
          return 'buyer';
        }

        DocumentSnapshot<Map<String, dynamic>> sellerSnapshot =
            await FirebaseFirestore.instance
                .collection('sellers')
                .doc(userId)
                .get();

        if (sellerSnapshot.exists) {
          return 'seller';
        }
      }

      return '';
    } catch (e) {
      print("Error fetching user type: $e");
      return '';
    }
  }
}
