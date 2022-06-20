import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'voituretracer.dart';
import 'open.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  //1 statelesswidget   la page ne peut pas etre changer
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Connect Flutter with Express',
      theme: ThemeData(
        primarySwatch: Colors.cyan,
      ),
      home: const SplashScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  //2 statefulwidget    la page peut etre changer de contenue a chaque fois
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // 3 page accueil
  VoitureTracer voitureTracerService = VoitureTracer();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //scaffold
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Container(
          child: FutureBuilder<List>(
            future: voitureTracerService
                .getAllVoitureTracer(), //select des voiturestracer
            builder: (context, snapshot) {
              //snapshot = future
              print(snapshot.data);
              if (snapshot.hasData) {
                return ListView.builder(
                  //listview
                  itemCount: snapshot.data?.length,
                  itemBuilder: (context, i) {
                    return Card(
                      shadowColor: Colors.blue,
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24)),
                      child: Column(
                        children: [
                          Ink.image(
                            image: const NetworkImage(
                                'https://annuelauto.ca/wp-content/uploads/2021/10/electriccarapp-1.png'),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MyMap(
                                          snapshot.data![i]['numTracer'])),
                                );
                              },
                            ),
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                          Text(
                            snapshot.data![i]['marque'],
                            style: TextStyle(fontSize: 30.0),
                          ),
                          TextButton(
                            style: ButtonStyle(
                              foregroundColor:
                                  MaterialStateProperty.all<Color>(Colors.blue),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        MyMap(snapshot.data![i]['numTracer'])),
                              );
                            },
                            child: const Text(
                              'Position',
                              style:
                                  TextStyle(fontSize: 20.0, color: Colors.cyan),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                );
              } else {
                return const Center(
                  child: Text('No Data Found'),
                );
              }
            },
          ),
        ));
  }
}

class MyMap extends StatefulWidget {
  //page de la map
  final String id;
  late double lan;
  late double lat;

  MyMap(this.id, {Key? key}) : super(key: key); // select by id = num tracer

  @override
  _MyMapState createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {
  // la classe qui donne la position
  late GoogleMapController mapController;
  Location _location = Location();
  final Set<Marker> markers = new Set();
  Random random = new Random();
  late String id = widget.id;
  late double lan = 100;
  late double lat = 40;

  Future<double> getLocationLat(String id) async {
    //getter de latitude
    String baseUrl = "http://vehiculetracker.herokuapp.com/cord/$id";
    try {
      var response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        return jsonDecode(
            response.body)["latitude"]; //decode de json et prendre latitude
      } else {
        return Future.error("Server Error");
      }
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<double> getLocationLan(String id) async {
    //getter de langitude
    String baseUrl = "http://vehiculetracker.herokuapp.com/cord/$id";
    print("object");
    try {
      var response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        print("heelo");
        return jsonDecode(
            response.body)["longitude"]; //decode de json et prendre longitude
      } else {
        return Future.error("Server Error");
      }
    } catch (e) {
      return Future.error(e);
    }
  }

  void controlePos(String id) async {
    lan = await getLocationLan(
        id); //affectation des methodes getters de latitude et longitude au variables lat et lan
    lat = await getLocationLat(id);
  }

  void _onMapCreated(GoogleMapController controller) {
    //changement sur la map
    mapController = controller;
    setState(() {
      markers;
    });
    _location.onLocationChanged.listen((l) async {
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(lat, lan), zoom: 10),
        ),
      );

      setState(() {
        //methode qui ajoure marker
        markers.add(Marker(
          //add first marker
          markerId: MarkerId('$l.latitude!'),
          position: LatLng(lat, lan), //position of marker
          infoWindow: InfoWindow(
            //popup info
            title: 'My Custom Title ',
            snippet: '$lat, $lan',
          ),
          icon: BitmapDescriptor.defaultMarker, //Icon for Marker
        ));
      });

      controlePos(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //app bar de retour vers page acceuil
        title: Text("Retour à la liste"),
        backgroundColor: Colors.cyan,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      MyHomePage(title: 'Liste des voitures')),
            );
          },
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            GoogleMap(
                initialCameraPosition: CameraPosition(target: LatLng(lat, lan)),
                mapType: MapType.normal,
                onMapCreated: _onMapCreated,
                myLocationEnabled: true,
                markers: markers),
          ],
        ),
      ),
    );
  }
}
