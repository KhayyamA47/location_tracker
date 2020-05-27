import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext contextP) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: SplashScreen());
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  List<String> coordinates = List();

  initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]); //Lock screen rotation
    _getLocation();
  }

  _getLocation() async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    _locationData = await location.getLocation();

    setState(() {
      String data = 'Latitude : ${_locationData.latitude}     Longitude : ${_locationData.longitude}';
      print(data);
    });
    location.onLocationChanged.listen((LocationData currentLocation) {
      print('Loc $currentLocation');
      setState(() {
        if (coordinates.contains('Lat > ${currentLocation.latitude} --- Long > ${currentLocation.longitude}')) {
          print('SAME');
        } else {
          print('ADDED');
          coordinates.add('Lat > ${currentLocation.latitude} --- Long > ${currentLocation.longitude}');
        }
      });
    });
  }

  _buildRow(int index, String data) {
    return Row(
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.06,
          child: Text(
            index.toString(),
            style: TextStyle(color: Colors.red),
          ),
        ),
        Container(
            width: MediaQuery.of(context).size.width * 0.9,
            child: Container(
              child: Text(data),
            ))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        debugShowCheckedModeBanner: false,
        home: new Scaffold(
            appBar: AppBar(
              title: Text('Location Tracker'),
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.clear_all,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    coordinates.clear();
                  },
                )
              ],
            ),
            body: Column(
              children: [
                Expanded(
                  child: Container(
                    child: ListView.builder(itemCount: coordinates.length, itemBuilder: (context, index) => this._buildRow((index + 1), coordinates[index])),
                  ),
                ),
              ],
            )));
  }
}
