import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show WhitelistingTextInputFormatter, rootBundle;
import 'package:google_map_polyutil/google_map_polyutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:heyhubtask/hub_response.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hey Hub Task',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Hey Hub Task'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ///GeoFencing Paths create using bounds of the location
  List<LatLng> _paths = [];

  TextEditingController _latitudeController = TextEditingController();
  TextEditingController _longitudeController = TextEditingController();
  TextEditingController _accuracyController = TextEditingController();
  bool _isLatitudeValid = true;
  bool _isLongitudeValid = true;
  Flushbar flushbar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 32.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                  top: 32.0,
                  bottom: 16.0,
                ),
                child: TextField(
                  controller: _latitudeController,
                  inputFormatters: [
                    WhitelistingTextInputFormatter(RegExp("[0-9.-]")),
                  ],
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Latitude',
                    errorText:
                        !_isLatitudeValid ? 'Please enter latitude' : null,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 16.0,
                ),
                child: TextField(
                  controller: _longitudeController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    WhitelistingTextInputFormatter(RegExp("[0-9.-]")),
                  ],
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Longitude',
                    errorText:
                        !_isLongitudeValid ? 'Please enter longitude' : null,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 16.0,
                ),
                child: TextField(
                  controller: _accuracyController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    WhitelistingTextInputFormatter(RegExp("[0-9.]")),
                  ],
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Accuracy',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        child: RaisedButton(
          onPressed: () async {
            ///Clearing focus from textField and validating text fields for empty value
            ///For now assuming accuracy is optional
            FocusScope.of(context).requestFocus(FocusNode());
            bool isFieldsValidated = true;
            double latitude;
            double longitude;
            double accuracy;
            String latitudeString = _latitudeController.text;
            String longitudeString = _longitudeController.text;
            String accuracyString = _accuracyController.text;

            if (latitudeString.isEmpty) {
              isFieldsValidated = false;
            }

            if (longitudeString.isEmpty) {
              isFieldsValidated = false;
            }

            if (isFieldsValidated) {
              longitude = double.parse(longitudeString);
              latitude = double.parse(latitudeString);
              if (accuracyString.isNotEmpty) {
                accuracy = double.parse(accuracyString);
              } else {
                accuracy = 0;
              }
              bool isWithinArea = await isLocationWithinArea(
                latitude: latitude,
                longitude: longitude,
                accuracy: accuracy,
              );
              if (isWithinArea) {
                _showSnackBar(
                  context: context,
                  message: 'Entered location is within area!',
                  impMessage: false,
                );
              } else {
                _showSnackBar(
                  context: context,
                  message: 'Entered location is not within the area!',
                  impMessage: false,
                );
              }
            } else {
              _showSnackBar(
                context: context,
                message: 'Some fields have been missed!',
                impMessage: true,
              );
            }
          },
          child: Text('Check Location'),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _readAssetFile();
  }

  ///For now it is assumed that the json will come from an asset file named hub.json
  ///In real app scenario, this will come from a REST API
  _readAssetFile() async {
    String json = await rootBundle.loadString('assets/hub.json');
    HubResponse hubResponse = hubResponseFromJson(json);
    Bounds bounds = hubResponse.results.bounds;
    _paths.add(LatLng(bounds.minlat, bounds.minlon));
    _paths.add(LatLng(bounds.maxlat, bounds.maxlon));
    _paths.add(LatLng(bounds.maxlat, bounds.maxlon));
    _paths.add(LatLng(bounds.minlat, bounds.minlon));
  }

  ///Method to check whether the latitude and longitude is within bounds
  Future<bool> isLocationWithinArea(
      {longitude: double, latitude: double, accuracy: double}) async {
    ///Checking if polygon is closed
    ///If polygon is closed then will use isLocationOnEdge
    ///Else will use isLocationOnPath

    bool isClosedPolygon =
        await GoogleMapPolyUtil.isClosedPolygon(poly: _paths);
    bool isLocationWithinArea;
    if (isClosedPolygon) {
      isLocationWithinArea = await GoogleMapPolyUtil.isLocationOnEdge(
        point: LatLng(latitude, longitude),
        polygon: _paths,
        tolerance: accuracy,
      );
    } else {
      isLocationWithinArea = await GoogleMapPolyUtil.isLocationOnPath(
        point: LatLng(latitude, longitude),
        polygon: _paths,
        tolerance: accuracy,
      );
    }

    return isLocationWithinArea;
  }

  /// A method to show snackBar with custom message
  /// impMessage is just used to set long duration in case of long message
  _showSnackBar({context: BuildContext, message: String, impMessage: bool}) {
    flushbar = Flushbar(
      message: message,
      duration: impMessage ? Duration(seconds: 3) : Duration(seconds: 5),
      mainButton: FlatButton(
        onPressed: () {
          flushbar.dismiss();
        },
        child: Text(
          "OK",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    )..show(context);
  }
}
