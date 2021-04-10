import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:qiblah/haritaPage/kabe_harita.dart';
import 'package:qiblah/kiblePage/kible_pusula.dart';

Position ps;
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedPage = 0;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Color(0xff0c7b93),
        primaryColorLight: Color(0xff00a8cc),
        primaryColorDark: Color(0xff27496d),
        accentColor: Color(0xffecce6d),
      ),
      darkTheme: ThemeData.dark().copyWith(accentColor: Color(0xffecce6d)),
      home: Scaffold(
        body:Stack(children: [
          Offstage(
            offstage: _selectedPage != 0,
            child: KiblePusula(),
          ),
          Offstage(
            offstage: _selectedPage != 1,
            child: KabeHarita(),
          ),
        ]),
        bottomNavigationBar: BottomNavigationBar(
          unselectedItemColor: Color(0xFF515979),
          selectedItemColor: Colors.white.withOpacity(0.85),
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.location_on),
              label: "Kıble",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              label: "Harita",
            ),
          ],
          currentIndex: _selectedPage,
          onTap: _onTapped,
        ),
      ),
    );
  }
  void _onTapped(int index) {
    setState(() {
      _selectedPage = index;
    });
  }
}