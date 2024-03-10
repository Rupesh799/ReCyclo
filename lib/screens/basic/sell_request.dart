// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:Recyclo/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:Recyclo/screens/basic/finding_buyer_animation.dart';

class SellRequest extends StatefulWidget {
  const SellRequest({Key? key}) : super(key: key);

  @override
  State<SellRequest> createState() => _SellRequestState();
}

class _SellRequestState extends State<SellRequest> {
  geo.Position? currentPositionOfUser;
  final TextEditingController addressController = TextEditingController();

  late GoogleMapController googleMapController;
  late Marker userMarker = Marker(markerId: const MarkerId('currentLocation'));
  Set<Marker> markers = {};
  PanelController _pc = new PanelController();

  bool isLoading = false;

  List<String> wasteType = ["Plastic", "Paper", "Glass", "e-Waste"];
  List<bool> selectedWaste = [false, false, false, false];

  bool showFindingBuyerAnimation = false;
  int selectedIndex = -1;

  String? buyerName;
  String? buyerPhone;
  String? buyerPlaceName;
  String? placeName;

  LatLng? selectedBuyerLocation;
  double? buyerLat;
  double? buyerLon;

  Map<String, dynamic>? selectedBuyer;

  bool hasBuyerInformation = false;
  late BuyerInfo buyerInfo = BuyerInfo(
    name: '',
    locationName: '',
    PhoneNumber: '',
  );

void noBuyerRecived() {
    setState(() {
      showFindingBuyerAnimation = false;
    });
    Fluttertoast.showToast(
      msg: "No buyer found",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Color.fromARGB(255, 8, 149, 128),
      textColor: Colors.white,
    );
  }


  @override
  void initState() {
    super.initState();

    socket.connect();
    userMarker = Marker(markerId: const MarkerId('currentLocation'));
    getCurrentLocationOfUserAndFetchName();
    getCurrentLocation();

    socket.on('buyer_information', (data) {
      print('buyer information: $data');
      try {
        if (data != null && data['buyerInfo'] != null) {
          hasBuyerInformation = true;
          buyerInfo = BuyerInfo(
            name: data['buyerInfo']['buyerName'] ?? '',
            locationName: data['buyerInfo']['buyerPlaceName'] ?? '',
            PhoneNumber: data['buyerInfo']['buyerPhoneNumber'] ?? '',
          );
          print('Updated buyerInfo: $buyerInfo');
          setState(() {
            showFindingBuyerAnimation = false;
          });
        } else {
          // Handle the case where the received data or required properties are null
          print("Received data or required properties are null");
        }
      } catch (e) {
        print("Error while receiving data: $e");
      }

      // setBuyerInformation(data);
    });

    socket.on('no_buyer',(data) => noBuyerRecived());
  }

// Method to build the sliding panel content for buyer information
  Widget buildBuyerInfoPanel() {
    return BuyerInfoPanel(
      markers: markers,
      googleMapController: googleMapController,
      buyerInfo: buyerInfo,
    );
  }

  Future<void> getCurrentLocationOfUserAndFetchName() async {
    await getCurrentLocationOfUser(); // Get the current location
    getPlaceName(LatLng(
        currentPositionOfUser!.latitude, currentPositionOfUser!.longitude));
  }

  // String _selectedWasteType = 'Plastic';
  String _selectedWasteQuantity = 'Below 1kg';

  List<String> _wasteQuantities = [
    'Below 1kg',
    '1 to 5 kg',
    'Above 5 kg',
  ];

  Future<void> getCurrentLocationOfUser() async {
    geo.Position positionOfUser = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.best);

    currentPositionOfUser = positionOfUser;

    LatLng(currentPositionOfUser!.latitude, currentPositionOfUser!.longitude);
  }

  bool findingBuyer = false;

  Future<void> sendPickupRequest() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        DocumentSnapshot sellerInfo = await FirebaseFirestore.instance
            .collection('sellers')
            .doc(user.uid)
            .get();

        setState(() {
          showFindingBuyerAnimation = true;
        });
        // Check if the seller info exists
        if (sellerInfo.exists) {
          String sellerFullname = sellerInfo['fullname'];
          String sellerPhone = sellerInfo['phone'];
          String sellerEmail = sellerInfo['email'];

          // Construct the pickup request data
          Map<String, dynamic> pickupRequestData = {
            'Name': sellerFullname,
            'Email': sellerEmail,
            'PhoneNumber': sellerPhone,
            'WasteType':
                selectedWaste.map((waste) => waste.toString()).toList(),
            'WasteQuantity': _selectedWasteQuantity,
            'PlaceName': addressController.text,
            'location': {
              'latitude': userMarker.position.latitude,
              'longitude': userMarker.position.longitude,
            },
          };

          // Emit the pickup request data to the server
          socket.emit('pickup_request', pickupRequestData);

          // Collapse the sliding panel after sending the request
          _pc.close();

          // Show a success message or navigate to a confirmation screen
          print('Pickup request sent successfully!');
        }
      } else {
        // Show message "Please select a waste type" at the bottom of the page
        final snackBarError = SnackBar(
          content: Text('Please select a waste type'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBarError);
      }
    } catch (e) {
      print('Error sending pickup request: $e');
      // Handle the error (show an error message, etc.)
    }
  }

  // Method to clear buyer information and reset the panel
  void clearBuyerInformation() {
    setState(() {
      hasBuyerInformation = false;
      buyerName = null;
      buyerPhone = null;
      buyerPlaceName = null;
      selectedBuyerLocation = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: hasBuyerInformation
            ? buildBuyerInfoPanel()
            : SlidingUpPanel(
                borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(10), right: Radius.circular(10)),
                minHeight: 100,
                maxHeight: MediaQuery.of(context).size.height - 300,
                panel: buildSlidingPanelContent(),
                controller: _pc,
                body: Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: const CameraPosition(
                          target: LatLng(27.672468, 85.337924), zoom: 14),
                      markers: markers
                        ..addAll(selectedBuyerLocation != null
                            ? [
                                Marker(
                                    markerId: const MarkerId('selectedBuyer'),
                                    position: selectedBuyerLocation!)
                              ]
                            : []),
                      zoomControlsEnabled: false,
                      mapType: MapType.normal,
                      onMapCreated: (GoogleMapController controller) {
                        googleMapController = controller;
                      },
                      onTap: (LatLng latLng) {
                        addOrUpdateMarker(latLng);
                        getPlaceName(latLng);
                      },
                    ),
                    if (showFindingBuyerAnimation || isLoading)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withOpacity(0.5),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                FindingBuyerAnimation(),
                                SizedBox(height: 16),
                                if (isLoading) CircularProgressIndicator(),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }

// Method to build the sliding panel content with waste type, quantity, and place name
  Widget buildSlidingPanelContent() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              margin: EdgeInsets.only(top: 8),
              height: 5,
              width: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey,
              ),
            ),
          ),
          SizedBox(
            height: 15,
          ),
          TextField(
            controller: addressController,
            readOnly: true,
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              suffixIcon: const Icon(Icons.location_on),
            ),
          ),
          Column(
            children: [
              Text(
                'Waste Type :',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(
                height:
                    12, // Changed from width to height for proper spacing between the text and the list
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: wasteType.length,
                itemBuilder: (BuildContext context, int index) {
                  return CheckboxListTile(
                    title: Text(wasteType[index]),
                    value: selectedIndex ==
                        index, // Check if the current index is the selected one
                    onChanged: (bool? value) {
                      setState(() {
                        if (value != null && value) {
                          // Update the selected index only if the checkbox is checked
                          selectedIndex = index;
                          for (int i = 0; i < selectedWaste.length; i++) {
                            selectedWaste[i] = i ==
                                index; // Update the selectedWaste list accordingly
                          }
                        } else {
                          // Uncheck the checkbox when it is already checked
                          selectedIndex = -1;
                          for (int i = 0; i < selectedWaste.length; i++) {
                            selectedWaste[i] =
                                false; // Reset the selectedWaste list
                          }
                        }
                      });
                    },
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Text(
                'Waste Quantity:',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(
                width: 12,
              ),
              DropdownButton<String>(
                value: _selectedWasteQuantity,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedWasteQuantity = newValue!;
                  });
                },
                items: _wasteQuantities.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              // Check if at least one waste type is selected
              if (selectedWaste.any((waste) => waste)) {
                sendPickupRequest();
              } else {
                // Show message "Please select a waste type" at the bottom of the page
                final snackBarError = SnackBar(
                  content: Text('Please select a waste type'),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBarError);
              }
            },
            child: Text(
              'Send Request',
              style: TextStyle(fontSize: 15, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> getCurrentLocation() async {
    try {
      geo.Position position = await determinePosition();

      setState(() {
        userMarker = Marker(
          markerId: const MarkerId('currentLocation'),
          position: LatLng(position.latitude, position.longitude),
          draggable: true,
          onDragEnd: (newPosition) {
            getPlaceName(newPosition);
          },
        );
        markers.clear();
        markers.add(userMarker);
      });
    } catch (e) {
      print("Error fetching location: $e");
    }
  }

  Future<void> getPlaceName(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, position.longitude,
          localeIdentifier: 'en_US');

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;

        String thoroughfare = place.thoroughfare ?? '';
        String locality = place.locality ?? '';

        String placeName =
            '${thoroughfare.isNotEmpty ? thoroughfare + ', ' : ''}$locality';

        print("Place Name: $placeName");
        // You can show place name in UI or handle it as required
        setState(() {
          addressController.text = placeName;
        });
      }
    } catch (e) {
      print("Error fetching place name: $e");
    }
  }

  void addOrUpdateMarker(LatLng latLng) {
    setState(() {
      markers.remove(userMarker);
      userMarker = Marker(
        markerId: const MarkerId('currentLocation'),
        position: latLng,
        draggable: true,
        onDragEnd: (newPosition) {
          getPlaceName(newPosition);
        },
      );
      markers.add(userMarker);
    });
  }

  Future<geo.Position> determinePosition() async {
    bool serviceEnabled;
    geo.LocationPermission permission;

    serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw 'Location services are disabled';
    }

    permission = await geo.Geolocator.checkPermission();

    if (permission == geo.LocationPermission.denied) {
      permission = await geo.Geolocator.requestPermission();

      if (permission == geo.LocationPermission.denied) {
        throw 'Location permission denied';
      }
    }

    if (permission == geo.LocationPermission.deniedForever) {
      throw 'Location permissions are permanently denied';
    }

    geo.Position position = await geo.Geolocator.getCurrentPosition();

    return position;
  }
}

class BuyerInfo {
  final String name;
  final String locationName;
  final String PhoneNumber;

  BuyerInfo({
    required this.name,
    required this.locationName,
    required this.PhoneNumber,
  });
}

class BuyerInfoPanel extends StatelessWidget {
  late Set<Marker> markers;
  late GoogleMapController googleMapController;
  BuyerInfo buyerInfo;

  BuyerInfoPanel({
    required this.markers,
    required this.googleMapController,
    required this.buyerInfo,
  });

  Future<bool?> showCancelConfirmationDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cancel Request'),
          content: Text('Are you sure you want to cancel the process?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // No, do not cancel
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
                // Yes, cancel
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void cancelRequest(BuildContext context) async {
    bool? confirmCancel = await showCancelConfirmationDialog(context);
    String? cancelledMessage = "Request has been cancelled by seller";

    if (confirmCancel == true) {
      socket.emit('cancel_process', cancelledMessage);
      // Perform cancellation actions here
      Navigator.pop(context);
      Fluttertoast.showToast(
        msg: "Your request has been cancelled",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Color.fromARGB(255, 8, 149, 128),
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlidingUpPanel(
      borderRadius: BorderRadius.horizontal(
          left: Radius.circular(10), right: Radius.circular(10)),
      minHeight: 50,
      maxHeight: MediaQuery.of(context).size.height - 500,
      panel: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.only(top: 8),
                height: 5,
                width: 100,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Center(
              child: Text(
                'Buyer Details',
                style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 8, 149, 128)),
              ),
            ),
            SizedBox(height: 10),
            Column(
              // mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Name: ${buyerInfo.name}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                // SizedBox(
                //   height: 10,
                // ),
                // Text(
                //   'Location: ${buyerInfo.locationName}',
                //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                // ),
                // SizedBox(
                //   height: 10,
                // ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Phone: ${buyerInfo.PhoneNumber}',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    CircleAvatar(
                      // color: Colors.green,
                      radius: 20,
                      backgroundColor: Color.fromARGB(255, 8, 149, 128),
                      child: IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.call,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: () {
                    // Check if onCancelPressed is not null, then call it
                    cancelRequest.call(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.red),
                    padding: EdgeInsets.all(12),
                    // color: Color.fromARGB(255, 187, 16, 4),
                    alignment: Alignment.center,
                    child: Text(
                      'Cancel Request',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ],
            )
            // Add more seller information as needed
          ],
        ),
      ),
      body: GoogleMap(
        // Display GoogleMap as the background
        initialCameraPosition: const CameraPosition(
          target: LatLng(27.672468, 85.337924),
          zoom: 14,
        ),
        markers: markers,
        zoomControlsEnabled: false,
        mapType: MapType.normal,
        onMapCreated: (GoogleMapController controller) {
          googleMapController = controller;
        },
        onTap: (LatLng latLng) {
          // Handle map tap if needed
        },
      ),
    );
  }
}
