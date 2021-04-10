import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';
import 'package:qiblah/kiblePage/loading.dart';

class KabeHarita extends StatefulWidget {
  @override
  _KabeHaritaState createState() => _KabeHaritaState();
}

class _KabeHaritaState extends State<KabeHarita> {

  final _locationStreamController = StreamController<LocationStatus>.broadcast();

  get stream => _locationStreamController.stream;
  MapController mapController;
  Position currentLocation;
  LatLng currentLocationLatlng;
  bool findKabe=false;
  var kabeMarkers = <LatLng>[
    LatLng(0, 0),
    LatLng(0, 0),
  ];
  @override
  void initState() {
    super.initState();
    mapController = MapController();
    _checkLocationStatus();
  }
  @override
  void dispose() {
    super.dispose();
    _locationStreamController.close();
    FlutterQiblah().dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Stack(children: <Widget>[
          Align(
            alignment: Alignment.center,
            child: FlutterMap(
              options: MapOptions(
                center: currentLocationLatlng,
                zoom: 3.0,
              ),
              mapController:mapController ,
              layers:  <LayerOptions>[
                TileLayerOptions(
                    urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: ['a', 'b', 'c']
                ),
                MarkerLayerOptions(
                  markers: [
                    Marker(
                      width: 30.0,
                      height: 30.0,
                      point: currentLocationLatlng,
                      builder: (ctx){
                        if(findKabe){
                          return StreamBuilder(
                              stream: FlutterQiblah.qiblahStream,
                              builder: (_, AsyncSnapshot<QiblahDirection> snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting)
                                  return Container();
                                final qiblahDirection = snapshot.data;
                                return Transform.rotate(
                                  angle: (qiblahDirection.direction * (pi / 180) * -1),
                                  child: Container(child: Image.asset("lib/assets/arrow.png")),
                                );
                              });
                        }else{
                          return Container();
                        }
                      },
                    ),
                    Marker(
                      width: 30.0,
                      height: 30.0,
                      point: LatLng( 21.422487, 39.826206),
                      builder: (ctx){
                        return SvgPicture.asset("assets/kabe.svg");
                      },
                    )
                  ],
                ),
                PolylineLayerOptions(
                  polylines: [
                    Polyline(
                        points: kabeMarkers,
                        strokeWidth: 4.0,
                        color: Colors.green),
                  ],
                ),
              ],
            ),
          ),
        ]),
      ),
      floatingActionButton: Container(
        height: 150,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            StreamBuilder(
                stream: stream,
              builder: (context, AsyncSnapshot<LocationStatus> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return LoadingIndicator();
                }
                if (snapshot.data.enabled == true) {
                  switch (snapshot.data.status) {
                    case LocationPermission.always:
                    case LocationPermission.whileInUse:
                    return FloatingActionButton(
                        child: Icon(Icons.gps_fixed,color: Colors.white,),
                        backgroundColor: Colors.blue,
                        onPressed: ()async{
                          await _checkLocationStatus();
                          currentLocation = await Geolocator.getCurrentPosition();
                          currentLocationLatlng = LatLng(37.910000, 40.240002);
                          mapController.move(LatLng(currentLocationLatlng.latitude, currentLocationLatlng.longitude), 18);
                          kabeMarkers.first=LatLng(currentLocationLatlng.latitude, currentLocationLatlng.longitude);
                          kabeMarkers.last=LatLng( 21.422487, 39.826206);
                          findKabe=true;
                          setState((){});
                        });
                    case LocationPermission.denied:
                      return FloatingActionButton(
                        child: Icon(Icons.location_disabled_sharp,color: Colors.white,),
                        backgroundColor: Colors.blue,
                        onPressed: _checkLocationStatus,
                      );
                    case LocationPermission.deniedForever:
                      return FloatingActionButton(
                        child: Icon(Icons.location_disabled_sharp,color: Colors.white,),
                        backgroundColor: Colors.blue,
                        onPressed: _checkLocationStatus,
                      );
                    default:
                      return Container();
                  }
                }
                else {
                  return FloatingActionButton(
                    child: Icon(Icons.location_off_outlined,color: Colors.white,),
                    backgroundColor: Colors.blue,
                    onPressed: _checkLocationStatus,
                  );
                }
              }
            ),
            FloatingActionButton(
                child: Icon(Icons.gps_fixed,color: Colors.white,),
                backgroundColor: Colors.blue,
                onPressed: ()async{
              mapController.move(LatLng( 21.422487, 39.826206), 3);
            }),
          ],
        ),
      ),
    );
  }
  Future<void> _checkLocationStatus() async {
    final locationStatus = await FlutterQiblah.checkLocationStatus();
    if (locationStatus.enabled && locationStatus.status == LocationPermission.denied) {
      await FlutterQiblah.requestPermissions();
      final s = await FlutterQiblah.checkLocationStatus();
      _locationStreamController.sink.add(s);
    } else
      _locationStreamController.sink.add(locationStatus);
  }
}
