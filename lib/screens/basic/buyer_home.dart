import 'dart:async';
// import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class BuyerHome extends StatefulWidget {
  const BuyerHome({Key? key});

  @override
  State<BuyerHome> createState() => _BuyerHomeState();
}

class _BuyerHomeState extends State<BuyerHome> {
  geo.Position? currentPositionOfUser;
  final TextEditingController addressController = TextEditingController();

  late GoogleMapController googleMapController;
  late Marker userMarker = Marker(markerId: const MarkerId('currentLocation'));
  Set<Marker> markers = {};
// Marker? sellerMarker;
  late io.Socket socket;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  late User? _user;
  late FirebaseFirestore firestore;
  bool isOnline = false;
  String? buyerSocketId;
  Marker? sellerMarker = Marker(markerId: const MarkerId('sellerLocation'));

  bool hasAcceptedRequest = false;
  late SellerInfo sellerInfo;
  @override
  Future<void> buyer() async {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        _user = user;
      });

      setState(() {
        isOnline = false;
        updateStatus(); // Call the updateStatus method to update the status in the database
      });
    });
    Firebase.initializeApp().then((value) {
      firestore = FirebaseFirestore.instance;
      getCurrentLocationOfUserAndFetchName();
      getCurrentLocation();
    });
  }

  void cancelledRequestRecived() {
    setState(() {
      hasAcceptedRequest = false;
    });
    Fluttertoast.showToast(
      msg: "seller cancelled the request",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Color.fromARGB(255, 8, 149, 128),
      textColor: Colors.white,
    );
  }

  void initState() {
    super.initState();
    //initialization of socket
    socket = io.io('http://192.168.62.25:3000', <String, dynamic>{
      'transport': ['webSocket'],
      'autoConnect': true,
    });

    socket.connect();
    // futerFn().then{}

    buyer().then((value) {
      // Listen for the pickup_request _user.email
      socket.on(_user?.email ?? "", (data) {
        print('Seller request received: $data');

        // Check if the required fields are present in the data
        if (data != null &&
            data.containsKey('sellerInfo') &&
            data['sellerInfo'] is Map<String, dynamic>) {
          Map<String, dynamic> sellerInfo = data['sellerInfo'];

          // Extracting seller details
          String sellerName = sellerInfo['sellerName'];
          String sellerLocationName = sellerInfo['sellerPlaceName'];
          // List sellerWasteType = sellerInfo['sellerWasteType'];
          // Accessing nested location data
          // Map<String, dynamic> sellerLocation = sellerInfo['sellerLocation'];
          // double latitude = sellerLocation['latitude'];
          // double longitude = sellerLocation['longitude'];

          // Show dialog to the user
          showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: Text(
                'New Pickup Request',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              content: Container(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Name: $sellerName',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Location: $sellerLocationName',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),

                   

                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 120, // Set a specific width for the button
                          child: ElevatedButton(
                            onPressed: () {
                              rejectRequest(data);
                              Navigator.pop(context);
                            }, // Add your action or set to null
                            child: Text(
                              'Reject',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent),
                          ),
                        ),
                        Container(
                          width: 120, // Set a specific width for the button
                          child: ElevatedButton(
                            onPressed: () {
                              acceptRequest(data);
                              Navigator.pop(context);
                            }, // Add your action or set to null
                            child: Text(
                              'Accept',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          print('Invalid seller request data');
        }
      });
      socket.on('cancel', (data) => cancelledRequestRecived());
    });
    //socket.on(_user?.email ?? '', (data) =>cancelledRequestRecived());
  }

  Future<void> acceptRequest(Map<String, dynamic> data) async {
    try {
      setState(() {
        hasAcceptedRequest = true;
        sellerInfo = SellerInfo(
          name: data['sellerInfo']['sellerName'],
          locationName: data['sellerInfo']['sellerPlaceName'],
          PhoneNumber: data['sellerInfo']['sellerPhoneNumber'],
        ); // Set the state to indicate acceptance
      });

      if (_user != null) {
        DocumentSnapshot buyerSnapshot =
            await firestore.collection('buyers').doc(_user!.uid).get();

        if (buyerSnapshot.exists) {
          Map<String, dynamic> buyerData =
              buyerSnapshot.data() as Map<String, dynamic>;

          String buyerFullName = buyerData['fullname'] ?? '';
          String buyerPhoneNumber = buyerData['phone'] ?? '';
          String buyerplaceName = buyerData['placeName'] ?? '';
          String buyerEmail = buyerData['email'] ?? '';

          print('name: $buyerFullName');

          socket.emit('accept_request', {
            'message': 'request accepted',
            'buyerInfo': {
              'buyerFullName': buyerFullName,
              'buyerPhoneNumber': buyerPhoneNumber,
              'buyerplaceName': buyerplaceName,
              'buyerEmail': buyerEmail,
            },
          });
          print('Accepting the request. Emitting message to the server...');
        }
      }
    } catch (e) {
      print('Error accepting request: $e');
    }
  }

  void rejectRequest(Map<String, dynamic> data) {
    try {
      socket.emit('reject_request', {'message': 'request rejected'});
      print('Rejecting the request. Emitting message to the server...');
    } catch (e) {
      print('Error rejecting request: $e');
    }
  }

  SellerInfoPanel sellerInfoPanel() {
    return SellerInfoPanel(
      markers: markers,
      googleMapController: googleMapController,
      sellerInfo: sellerInfo,
    );
  }

  @override
  void dispose() {
    socket.disconnect();
    _user = null;
    super.dispose();
  }

  void updateSellerMarker(Map<String, dynamic> data) {
    try {
      GeoPoint? locationData = data['location'];

      if (locationData != null) {
        double sellerLatitude = locationData.latitude;
        double sellerLongitude = locationData.longitude;

        LatLng sellerLatLng = LatLng(sellerLatitude, sellerLongitude);

        setState(() {
          sellerMarker = Marker(
            markerId: const MarkerId('sellerLocation'),
            position: sellerLatLng,
            icon: BitmapDescriptor.defaultMarker,
          );

          if (markers != null) {
            markers.add(sellerMarker!);
          }

          // Move the camera to the seller's location
          googleMapController.moveCamera(
            CameraUpdate.newLatLng(LatLng(sellerLatitude, sellerLongitude)),
          );
        });
      } else {
        print('Location data not found in the pickup request.');
      }
    } catch (e) {
      print('Error updating seller marker: $e');
    }
  }

  void updateStatus() {
    try {
      if (_user != null) {
        // Update the 'status' field in the Firestore collection
        firestore.collection('buyers').doc(_user!.uid).update({
          'status': isOnline ? 'online' : 'offline',
        });

        if (isOnline) {
          // Emit a request to get the buyer's socketId
          socket.emit('buyer_online', {
            'buyerId': _user!.uid,
            'location': {
              'latitude': currentPositionOfUser!.latitude,
              'longitude': currentPositionOfUser!.longitude,
            },
          });

          // Listen for the 'socket_id' event to receive the buyer's socketId
          socket.on('socket_id', (data) {
            setState(() {
              buyerSocketId = data['socketId'];
            });
          });
        }
        // Clear markers when going offline
        // Clear only the seller's marker when going offline
        if (!isOnline && sellerMarker != null) {
          setState(() {
            markers.remove(sellerMarker);
            sellerMarker = null;
          });
        }
      }
    } catch (e) {
      print("Error updating status in database: $e");
    }
  }

  Future<void> getCurrentLocationOfUserAndFetchName() async {
    await getCurrentLocationOfUser(); // Get the current location
    getPlaceName(LatLng(
        currentPositionOfUser!.latitude, currentPositionOfUser!.longitude));
  }

  Future<void> getCurrentLocationOfUser() async {
    geo.Position positionOfUser = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.best);

    currentPositionOfUser = positionOfUser;

    LatLng(currentPositionOfUser!.latitude, currentPositionOfUser!.longitude);
  }

  Future<void> storeLocationInDatabase(LatLng latLng, String placeName) async {
    Map<String, dynamic> geoPoint = {
      'latitude': latLng.latitude,
      'longitude': latLng.longitude,
    };
    try {
      if (_user != null) {
        await firestore.collection('buyers').doc(_user!.uid).set({
          'location': geoPoint,
          'placeName': placeName,
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print("Error storing location in database: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    Future<bool> showExitPopup() async {
      return await showDialog(
            //show confirm dialogue
            //the return value will be from "Yes" or "No" options
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Exit App'),
              content: Text('Do you want to exit an App?'),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  //return false when click on "NO"
                  child: Text('No'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  //return true when click on "Yes"
                  child: Text('Yes'),
                ),
              ],
            ),
          ) ??
          false; //if showDialouge had returned null, then return false
    }

    return WillPopScope(
      onWillPop: showExitPopup, //call function on back button press
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          iconTheme:
              const IconThemeData(color: Color.fromARGB(255, 247, 245, 245)),
          title: const Text(
            "Recyclo",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: const Color.fromARGB(255, 8, 149, 128),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 37, bottom: 10),
              child: LiteRollingSwitch(
                value: isOnline,
                textOn: "Online",
                textOff: "Offline",
                colorOn: Colors.green,
                colorOff: const Color.fromARGB(255, 77, 29, 25),
                iconOn: Icons.network_cell,
                iconOff: Icons.signal_wifi_off_outlined,
                onChanged: (bool value) {
                  setState(() {
                    isOnline = value;
                    updateStatus();
                    // if (isOnline) {
                    //   Future.delayed(Duration(seconds: 10), () {
                    //     getMostRecentPickupRequest();
                    //   });
                    // }
                  });
                },
                onTap: () {},
                onDoubleTap: () {},
                onSwipe: () {},
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context,
                    'history_screen'); // Replace with the actual name of your history screen
              },
              icon: const Icon(
                Icons.notifications,
                color: Colors.white,
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, 'account_screen');
              },
              icon: const Icon(
                Icons.circle,
                color: Colors.white,
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: hasAcceptedRequest
              ? SellerInfoPanel(
                  markers: markers,
                  googleMapController: googleMapController,
                  sellerInfo: sellerInfo)
              : SlidingUpPanel(
                  minHeight: 100,
                  maxHeight: MediaQuery.of(context).size.height - 640,
                  panel: Container(
                    // padding: EdgeInsets.all(10),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
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
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: TextField(
                            controller: addressController,
                            readOnly: true,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.grey),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              suffixIcon: const Icon(Icons.location_on),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  body: GoogleMap(
                    initialCameraPosition: const CameraPosition(
                        target: LatLng(27.672468, 85.337924), zoom: 14),
                    markers: markers,
                    zoomControlsEnabled: false,
                    mapType: MapType.normal,
                    onMapCreated: (GoogleMapController controller) {
                      googleMapController = controller;
                    },
                    onTap: (LatLng latLng) {
                      addOrUpdateMarker(latLng);
                      getPlaceName(latLng, storeLocation: true);
                      // storeLocationInDatabase(latLng); // Store location when tapped
                    },
                  ),
                ),
        ),
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

  Future<void> getPlaceName(LatLng position,
      {bool storeLocation = false}) async {
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
        if (storeLocation) {
          storeLocationInDatabase(position, placeName);
        }

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
          getPlaceName(newPosition, storeLocation: true);
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

class SellerInfo {
  final String name;
  final String locationName;
  final String PhoneNumber;

  SellerInfo({
    required this.name,
    required this.locationName,
    required this.PhoneNumber,
  });
}

class SellerInfoPanel extends StatefulWidget {
  late Set<Marker> markers;
  late GoogleMapController googleMapController;
  late SellerInfo sellerInfo;

  SellerInfoPanel({
    required this.markers,
    required this.googleMapController,
    required this.sellerInfo,
  });

     // Set hasAcceptedRequest to false


  @override
  State<SellerInfoPanel> createState() => _SellerInfoPanelState();
}

 bool hasAcceptedRequest = true; 
  late GoogleMapController googleMapController;

class _SellerInfoPanelState extends State<SellerInfoPanel> {
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
                Navigator.of(context).pop(true); // Yes, cancel
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

// this is for cancelletion of request after request is accepted
  void cancelRequest(BuildContext context) async {
    bool? confirmCancel = await showCancelConfirmationDialog(context);

    if (confirmCancel == true) {

      setState(() {
      hasAcceptedRequest = false; // Set hasAcceptedRequest to false
    });
      Navigator.pop(context);
      
      Fluttertoast.showToast(
        msg: "Your request has been cancelled",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black,
        textColor: Colors.white,
      );
      // Perform cancellation actions here
    }
  }

  void hasCompleted(){

  }

  @override
  Widget build(BuildContext context) {
    return SlidingUpPanel(
      borderRadius: BorderRadius.horizontal(
          left: Radius.circular(10), right: Radius.circular(10)),
      minHeight: 50,
      maxHeight: MediaQuery.of(context).size.height - 400,
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
                'Seller Details',
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
                  'Name: ${widget.sellerInfo.name}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Location: ${widget.sellerInfo.locationName}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                // SizedBox(
                //   height: 10,
                // ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Phone: ${widget.sellerInfo.PhoneNumber}',
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
                    // cancelRequest.call(context);
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
                SizedBox(
                  height: 10,
                ),
                GestureDetector(
                  onTap: () {
                    // Check if onCancelPressed is not null, then call it
                    hasCompleted.call();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.greenAccent),
                    padding: EdgeInsets.all(12),
                    // color: Color.fromARGB(255, 187, 16, 4),
                    alignment: Alignment.center,
                    child: Text(
                      'Completed',
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
        markers: widget.markers,
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
