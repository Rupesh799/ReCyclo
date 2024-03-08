import 'package:flutter/material.dart';
import 'package:Recyclo/screens/auth_ui/login.dart';
import 'package:Recyclo/screens/auth_ui/signup.dart';

import '../../constants/routes.dart';
// import 'package:wastehub/constants.dart';

class Welcome extends StatelessWidget {
  const Welcome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:SingleChildScrollView(
        child: Padding(padding: const EdgeInsets.all(20),
          child: Column(children: [
      // const Padding(
      //   padding: EdgeInsets.all(20),
      //   child: Text('ReCyclo',
      //       style: TextStyle(
      //         fontSize: 35,
      //         fontWeight: FontWeight.bold,
      //       )),
      // ),
      Padding(
          padding: const EdgeInsets.only(bottom: 25),
          child: Image.asset("assets/images/Recyclo.png")),
      // ElevatedButton(
      //     onPressed: () {
      //       Routes.instance.push(widget: const Signup(), context: context);
      //     },
      //     child: const Padding(
      //       padding: EdgeInsets.all(12),
      //       child: Text(
      //         "SELLER",
      //         style: TextStyle(
      //           color: (Colors.white),
      //           fontSize: 20,
      //         ),
      //       ),
      //     )),
      SizedBox(
        height: 30,
      ),
      Padding(
          padding: const EdgeInsets.only(top: 16),
          child: ElevatedButton(
          onPressed: () {
            Routes.instance.push(widget: const Login(), context: context);
          },
          child: const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              "LOGIN",
              style: TextStyle(
                color: (Colors.white),
                fontSize: 20,
                
              ),
              
            ),
          ),
          ),

          
          ),
          SizedBox(
            height: 20,
          ),
           Text("DIdn' hae an Account ?"),
          InkWell(
            onTap: (){
              Navigator.push(context,MaterialPageRoute(builder: (context)=>Signup()));
            },
            child: Text("SignUp" , style: TextStyle(color: Colors.green),),
          )
    ],
    ),
    ),
    ),
    );
  }
}
