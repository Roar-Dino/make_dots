import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:make_dots/GoogleMapsScreen.dart';

class homeScreen extends StatefulWidget {
  const homeScreen({super.key});

  @override
  State<homeScreen> createState() => _homeScreenState();
}

class _homeScreenState extends State<homeScreen> {


  int count = 0;
  void _plusCount(){
    setState(() {
      count ++;
    });
  }
  void _initializeNumber(){
    setState(() {
      count=0;
    });
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text("Make dots"),),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 16.0
              ),
              child: Image.asset('asset/img/dad.jpg'),
            ),
            ElevatedButton(onPressed: (){
              Navigator.of(context).push(MaterialPageRoute(builder: (_)=> GoogleMapScreen()));
            }, child: Text("Go to GoogleMaps")),
            Container(
              decoration: BoxDecoration(
                color: Colors.greenAccent,
              ),
              child: Text(
                "$count 명이 인증",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(onPressed: _plusCount,
                      child: Text("Please make a dot")
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  ElevatedButton(onPressed: _initializeNumber,
                    child: Text("Initialize number"),
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
