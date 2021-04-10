import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';

class KabeHarita extends StatefulWidget {
  @override
  _KabeHaritaState createState() => _KabeHaritaState();
}

class _KabeHaritaState extends State<KabeHarita> {
  MapController mapController;
  Position p;
  LatLng lt=LatLng(40, 45);
  var points = <LatLng>[
    LatLng(51.5, -0.09),
    LatLng(53.3498, -6.2603),
  ];
  @override
  void initState() {
    super.initState();
    mapController = MapController();
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
                center: lt,
                zoom: 13.0,
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
                      width: 80.0,
                      height: 80.0,
                      point: lt,
                      builder: (ctx){
                        return StreamBuilder(
                            stream: FlutterQiblah.qiblahStream,
                            builder: (_, AsyncSnapshot<QiblahDirection> snapshot) {
                              final qiblahDirection = snapshot.data;
                              return Transform.rotate(
                                angle: (qiblahDirection.direction * (pi / 180) * -1),
                                child: Container(
                                  child: Image.asset("lib/assets/arrow.png")),
                              );
                            });
                      },
                    ),
                  ],
                ),
                PolylineLayerOptions(
                  polylines: [
                    Polyline(
                        points: points,
                        strokeWidth: 4.0,
                        color: Colors.purple),
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
            FloatingActionButton(onPressed: ()async{
              p = await Geolocator.getCurrentPosition();
              lt = LatLng(p.latitude, p.longitude);
              mapController.move(LatLng(p.latitude, p.longitude), 18);
              points.first=LatLng(p.latitude, p.longitude);
              points.last=LatLng( 21.422487, 39.826206);
              setState((){});
            }),
            FloatingActionButton(onPressed: ()async{
              mapController.move(LatLng( 21.422487, 39.826206), 3);
            }),
          ],
        ),
      ),
    );
  }
}
