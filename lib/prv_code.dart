import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
 
  runApp( MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark(),
    home: const  HomePage()
  ));
}
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return Myapp();

            // if (user?.emailVerified ?? false) {
            //   return const Text("Done");
            // } else {
            //   // Navigator.of(context).push(MaterialPageRoute(
            //   //     builder: (context) => const VerifyEmailView()));
            //   return const VerifyEmailView();
            // }

            default:
              return const CircularProgressIndicator();
          }
        });
  }
}
class Myapp extends StatefulWidget {
  const Myapp({super.key});

  @override
  State<Myapp> createState() => _MyappState();
}

class _MyappState extends State<Myapp> {
  bool On=false;
  final dbR= FirebaseDatabase.instance.ref();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("IOT UI"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            On?Icon(
              Icons.lightbulb,
              size: 100,
              color: Colors.amber,
            ):Icon(
              Icons.lightbulb_outline,
              size: 100,
      
            ),
            ElevatedButton(
              style:TextButton.styleFrom(backgroundColor: On?Colors.green:Colors.white10),
              onPressed: (){
                dbR.child("LIGHT").set({"SWITCH":!On});
                setState(() {
                  On=!On;
                });
              }, 
              child: On?Text("ON"):Text("OFF")
              )
          ],
        ),
      )
    );
  }
}