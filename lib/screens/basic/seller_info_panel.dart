// import 'package:flutter/material.dart';
// import 'package:Recyclo/screens/basic/buyer_home.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:sliding_up_panel/sliding_up_panel.dart';

// class SellerInfoPanel extends StatelessWidget {
//   late Set<Marker> markers;
//   late GoogleMapController googleMapController;
//    late SellerInfo sellerInfo;

//   SellerInfoPanel({
//     required this.markers,
//     required this.googleMapController,
//     required this.sellerInfo,
//   });

//    Future<bool?> showCancelConfirmationDialog(BuildContext context) async {
//     return showDialog<bool>(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Cancel Request'),
//           content: Text('Are you sure you want to cancel the process?'),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(false); // No, do not cancel
//               },
//               child: Text('No'),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(true); // Yes, cancel
//               },
//               child: Text('Yes'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void cancelRequest(BuildContext context) async {
//   bool? confirmCancel = await showCancelConfirmationDialog(context);

//   if (confirmCancel == true) {
//     // Perform cancellation actions here

    
//   }
// }


//   @override
//   Widget build(BuildContext context) {
//     return SlidingUpPanel(
//       borderRadius: BorderRadius.horizontal(left: Radius.circular(10),right: Radius.circular(10)),
//       minHeight:50,
//       maxHeight: MediaQuery.of(context).size.height - 500,
//        panel: Container(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//              Center(
//                           child: Container(
//                             padding: EdgeInsets.all(10),
//                             margin: EdgeInsets.only(top: 8),
//                             height: 5,
//                             width: 100,
//                             decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(10),
//                                 color: Colors.grey),
//                           ),
//                         ),
//                         SizedBox(
//                           height: 20,
//                         ),
//             Center(
//               child: Text(
//                 'Seller Details',
//                 style: TextStyle(
//                   fontSize: 25,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.green
//                 ),
//               ),
//             ),
//             SizedBox(height: 10),
//             Column(
//               // mainAxisAlignment: MainAxisAlignment.start,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text('Name: ${sellerInfo.name}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
//                 SizedBox(height: 10,),
//                 Text('Location: ${sellerInfo.locationName}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
//                 SizedBox(height: 10,),

//                 Text('Phone: ${sellerInfo.PhoneNumber}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
//                 SizedBox(height: 20,),

//                 ElevatedButton(onPressed: (){
//                    cancelRequest(context);
//                 }, child: Text("Cancel Request",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
//                 style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),)

//               ],
//             )
//             // Add more seller information as needed
//           ],
//         ),
//       ),
//       body: GoogleMap(
//         // Display GoogleMap as the background
//         initialCameraPosition: const CameraPosition(
//           target: LatLng(27.672468, 85.337924),
//           zoom: 14,
//         ),
//         markers: markers,
//         zoomControlsEnabled: false,
//         mapType: MapType.normal,
//         onMapCreated: (GoogleMapController controller) {
//           googleMapController = controller;
//         },
//         onTap: (LatLng latLng) {
//           // Handle map tap if needed
//         },
//       ),
//     );
//   }
// }
