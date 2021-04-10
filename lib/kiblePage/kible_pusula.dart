import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mapbox_geocoding/mapbox_geocoding.dart';
import 'package:mapbox_geocoding/model/reverse_geocoding.dart';
import 'package:qiblah/kiblePage/loading.dart';

class KiblePusula extends StatefulWidget {
  @override
  _KiblePusulaState createState() => _KiblePusulaState();
}

class _KiblePusulaState extends State<KiblePusula> {
  final _locationStreamController = StreamController<LocationStatus>.broadcast();

  get stream => _locationStreamController.stream;

  @override
  void initState() {
    _checkLocationStatus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(image: DecorationImage(image: AssetImage("assets/kabe.jpg"))),
      child: new BackdropFilter(
        filter: new ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: new BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF43A3DA).withOpacity(0.2), Color(0xFF8ED7DA).withOpacity(0.2)]),
          ),
          child: StreamBuilder(
            stream: stream,
            builder: (context, AsyncSnapshot<LocationStatus> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return LoadingIndicator();
              }
              if (snapshot.data.enabled == true) {
                switch (snapshot.data.status) {
                  case LocationPermission.always:
                  case LocationPermission.whileInUse:
                    return QiblahCompassWidget();
                  case LocationPermission.denied:
                    return LocationErrorWidget(
                      error: "Location service permission denied",
                      callback: _checkLocationStatus,
                    );
                  case LocationPermission.deniedForever:
                    return LocationErrorWidget(
                      error: "Location service Denied Forever !",
                      callback: _checkLocationStatus,
                    );
                  default:
                    return Container();
                }
              }
              else {
                return LocationErrorWidget(
                  error: "Please enable Location service",
                  callback: _checkLocationStatus,
                );
              }
            },
          ),
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

  @override
  void dispose() {
    super.dispose();
    _locationStreamController.close();
    FlutterQiblah().dispose();
  }
}

class QiblahCompassWidget extends StatefulWidget {

// From coordinates
  @override
  _QiblahCompassWidgetState createState() => _QiblahCompassWidgetState();
}

class _QiblahCompassWidgetState extends State<QiblahCompassWidget> {
  MapboxGeocoding geocoding = MapboxGeocoding('pk.eyJ1IjoidGVhcnNmdXJ5IiwiYSI6ImNra2t3ZWtlajJiYWsycXF0cTV3NjdxOHoifQ.NDJ302t__eUEkJtq8vGh1A');
  String konum ="";
  @override
  void initState() {
    getCity();
    super.initState();
  }

  getCity( ) async {
   var currentLocation = await Geolocator.getCurrentPosition();
    try {
      ReverseGeocoding reverseModel = await geocoding.reverseModel(currentLocation.latitude,
          currentLocation.longitude);
      print(reverseModel.features[0].placeName);
      setState(() {
        konum= reverseModel.features[0].placeName;
      });
    } catch (Excepetion) {
      konum="Konum Bulunamadı";
      return 'Reverse Geocoding Error';
    }
  }
  final _compassSvg = SvgPicture.asset(
    'assets/pusula.svg',
    fit: BoxFit.contain,
    color: Colors.white,
    height: 400,
    alignment: Alignment.center,
  );

  final _needleSvg = SvgPicture.asset(
    'assets/igne.svg',
    height: 280,
    width: 40,
    alignment: Alignment.center,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      width: 100,
      child: StreamBuilder(
        stream: FlutterQiblah.qiblahStream,
        builder: (_, AsyncSnapshot<QiblahDirection> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingIndicator();
          }
          final qiblahDirection = snapshot.data;
          return Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Transform.rotate(
                angle: (qiblahDirection.direction * (pi / 180) * -1),
                child: _compassSvg,
              ),
              Transform.rotate(
                angle: (qiblahDirection.qiblah * (pi / 180) * -1),
                child: Container(
                    height: 450,
                    alignment: Alignment.topCenter,
                    child: SvgPicture.asset("assets/kabe.svg",width: 35,height: 40,)),
              ),
              _needleSvg,
              Positioned(
                bottom: 58,
                child: Text("${qiblahDirection.offset.toStringAsFixed(3)}°"),
              ),Positioned(
                bottom: 38,
                child: Text(konum),
              )
            ],
          );
        },
      ),
    );
  }
}
