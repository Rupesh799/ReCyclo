import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

class BuyerInformationBox extends StatelessWidget {
  final String? buyerName;
  final String? buyerPhone;
  final String? buyerPlaceName;
  final Function(BuildContext)? onCancelPressed;

  const BuyerInformationBox({
    Key? key,
    this.buyerName,
    this.buyerPhone,
    this.buyerPlaceName,
    this.onCancelPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        padding: EdgeInsets.all(16),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '$buyerName has been chosen as your buyer',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 22, 109, 25),
              ),
            ),
            SizedBox(height: 10),
            buildInfoRow(
              icon: Icons.phone,
              text: 'Call the buyer: $buyerPhone',
              color: Color.fromARGB(255, 22, 109, 25),
              onTap: () => _launchPhoneDialer(buyerPhone),
            ),
            SizedBox(height: 10),
            buildInfoRow(
              icon: Icons.location_on,
              text: '$buyerPlaceName',
              color: Color.fromARGB(255, 22, 109, 25),
            ),
            SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                // Check if onCancelPressed is not null, then call it
                onCancelPressed?.call(context);
              },
              child: Container(
                padding: EdgeInsets.all(12),
                color: Color.fromARGB(255, 187, 16, 4),
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
        ),
      ),
    );
  }
}

Widget buildInfoRow({
  required IconData icon,
  required String text,
  required Color color, // Add the 'color' parameter
  VoidCallback? onTap,
}) {
  return Row(
    children: [
      Icon(
        icon,
        color: color,
      ),
      SizedBox(width: 8),
      Expanded(
        child: InkWell(
          onTap: onTap,
          child: Text(
            text,
            style: TextStyle(
              fontSize: 20,
              color: Color.fromARGB(255, 22, 109, 25),
            ),
          ),
        ),
      ),
    ],
  );
}

Future<void> _launchPhoneDialer(String? phoneNumber) async {
  if (phoneNumber != null && await canLaunch('tel:$phoneNumber')) {
    // ignore: deprecated_member_use
    await launch('tel:$phoneNumber');
  } else {
    print('Could not launch phone dialer.');
  }
}

void onCancelPressed(BuildContext context) {
  // Unselect the buyer and navigate back to the sell request page
  Navigator.pop(
      context); // This will close the current screen and return to the previous one
  // Show a popup message (you can use a package like 'fluttertoast' or 'flushbar' for this)
  // Example using 'fluttertoast':
  Fluttertoast.showToast(
    msg: "Your request has been cancelled",
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    backgroundColor: Colors.black,
    textColor: Colors.white,
  );
}
