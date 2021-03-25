import 'package:flutter/material.dart';
import 'dart:async';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:food_scan/styles/customText.dart';
import 'package:food_scan/styles/customBoxDecoration.dart';
import 'package:food_scan/screens/ArticleDetail.dart';
import 'package:food_scan/widgets/drawerHome.dart';
import 'package:connectivity/connectivity.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() {
    return new HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  String result = "";
  bool debug = false;
  bool connected = false;

  initState() {
    super.initState();
    this.verifyConnectivity();
  }

  Future<void> verifyConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      connected = true;
    }
  }

  Future _scanQR() async {
    try {
      String qrResult = await BarcodeScanner.scan();
      setState(() {
        result = qrResult;
        Navigator.push(context,
            new MaterialPageRoute(builder: (BuildContext context) {
          return new Article(
              url: 'https://world.openfoodfacts.org/api/v0/product/' +
                  result +
                  '.json');
        }));
      });
    } on PlatformException catch (ex) {
      if (ex.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          result = "Camera permission was denied";
        });
      } else {
        setState(() {
          result = "Unknown Error $ex";
        });
      }
    } on FormatException {
      setState(() {
        result = "You pressed the back button before scanning anything";
      });
    } catch (ex) {
      setState(() {
        result = "Unknown Error $ex";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Food Scan"),
      ),
      drawer: new DrawerHome(),
      body: new Center(
        child: new ListView(
            //mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.all(20.0),
                children: <Widget>[],
              ),
            ]),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.camera_alt),
        label: Text("Scan"),
        onPressed: _scanQR,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  _launchOpenFoodFacts() async {
    const url = 'https://world.openfoodfacts.org';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
