

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapScreen extends StatefulWidget {
  const GoogleMapScreen({super.key});

  @override
  State<GoogleMapScreen> createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  GoogleMapController? mapController;
  bool commuteDone = false;
  static final LatLng myPlace = LatLng(36.510884, 127.249420);
  static double okDistance = 200;
  static final Circle withinCircle = Circle(
    circleId: CircleId('circle'),
    center: myPlace,
    fillColor: Colors.blue.withOpacity(0.5),
    radius: okDistance,
    strokeColor: Colors.blue,
    strokeWidth: 1,
  );
  static Circle notWithinCircle = Circle(
    circleId: CircleId('notWithinCircle'),
    center: myPlace,
    strokeWidth: 1,
    strokeColor: Colors.red,
    fillColor: Colors.red.withOpacity(0.5),
    radius: okDistance,
  );
  static Circle checkDoneCircle = Circle(
    circleId: CircleId("checkDoneCircle"),
    center: myPlace,
    strokeColor: Colors.green,
    strokeWidth: 1,
    radius: okDistance,
    fillColor: Colors.green.withOpacity(0.5),
  );
  static final Marker marker = Marker(
    markerId: MarkerId('marker'),
    position: myPlace,
  );
  static final Marker marker2 = Marker(
      markerId: MarkerId('marker2'), position: LatLng(36.509874, 127.246806));
  static final CameraPosition initialCameraPosition =
  CameraPosition(target: myPlace, zoom: 15);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: renderAppBar(),
        body: FutureBuilder(
          future: CheckPermission(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.data == "위치 권한이 허가 되었습니다") {
              return StreamBuilder<Position>(
                  stream: Geolocator.getPositionStream(),
                  builder: (context, snapshot) {
                    bool isWithinRange = false;
                    if(snapshot.hasData){
                      final currentPoint = snapshot.data!;
                      final endPoint = myPlace;
                      final distance = Geolocator.distanceBetween(
                          currentPoint.latitude,
                          currentPoint.longitude,
                          endPoint.latitude,
                          endPoint.longitude);
                      if (distance < okDistance) {
                        isWithinRange = true;
                      }
                    }
                    return Column(
                      children: [
                        _CustomGoogleMap(
                          marKer: marker,
                          marker2: marker2,
                          circle: commuteDone
                              ? checkDoneCircle
                              : isWithinRange
                              ? withinCircle
                              : notWithinCircle,
                          initialPosition: initialCameraPosition,
                          onMapCreated: onMapCreated,
                        ),
                        _CommuteButton(
                          commuteDone: commuteDone,
                          isWithinRange: isWithinRange,
                          onPressed: onCommutePressed,
                        ),
                      ],
                    );
                  });
            }
            return Center(
              child: Text(snapshot.data),
            );
          },
        ));
  }

  onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }


  onCommutePressed() async {
    final result = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("출근 선택"),
            content: Text("출근 하시겠습니까?"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: Text("선택"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: Text("취소"),
              ),
            ],
          );
        });
    if (result) {
      setState(() {
        commuteDone = true;
      });
    }
  }

  Future<String> CheckPermission() async {
    final isLocationEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isLocationEnabled) {
      return '위치 서비스를 활성화 해주세요';
    }
    LocationPermission checkedPermission = await Geolocator.checkPermission();
    if (checkedPermission == LocationPermission.denied) {
      checkedPermission = await Geolocator.requestPermission();
      if (checkedPermission == LocationPermission.denied) {
        return "위치 권한을 허가해줄 것을 요청합니다";
      }
    }
    if (checkedPermission == LocationPermission.deniedForever) {
      return "Settings에서 직접 권한을 허가해주세요";
    }
    return "위치 권한이 허가 되었습니다";
  }

  AppBar renderAppBar() {
    return AppBar(
      actions: [
        IconButton(
          onPressed: () async {
            if (mapController == null) {
              return;
            }

            final location = await Geolocator.getCurrentPosition();

            mapController!.animateCamera(
              CameraUpdate.newLatLng(
                LatLng(
                  location.latitude,
                  location.longitude,
                ),
              ),
            );
          },
          color: Colors.blue,
          icon: Icon(
            Icons.my_location,
          ),
        ),
      ],
      backgroundColor: Colors.white,
      centerTitle: true,
      title: Text(
        "Today",
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.blue,
        ),
      ),
    );
  }
}

class _CustomGoogleMap extends StatelessWidget {
  final Marker marKer;
  final Marker marker2;
  final CameraPosition initialPosition;
  final Circle circle;
  final MapCreatedCallback onMapCreated;

  const _CustomGoogleMap({
    required this.onMapCreated,
    required this.marker2,
    required this.marKer,
    required this.circle,
    required this.initialPosition,
    super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: GoogleMap(
        initialCameraPosition: initialPosition,
        mapType: MapType.normal,
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        circles: Set.from([circle]),
        markers: Set.from([marKer, marker2]),
        onMapCreated: onMapCreated,
      ),
    );
  }
}

class _CommuteButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isWithinRange;
  final bool commuteDone;

  const _CommuteButton({required this.commuteDone,
    required this.onPressed,
    required this.isWithinRange,
    super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isWithinRange)
              Icon(
                Icons.timelapse_outlined,
                size: 50.0,
                color: commuteDone
                    ? Colors.green
                    : isWithinRange
                    ? Colors.blue
                    : Colors.red,
              ),
            SizedBox(
              height: 30.0,
            ),
            if (!commuteDone && isWithinRange)
              ElevatedButton(onPressed: onPressed, child: Text("출근 버튼"))
          ],
        ));
  }
}

