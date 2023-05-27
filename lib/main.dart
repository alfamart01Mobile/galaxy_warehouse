import 'package:flutter/material.dart';
import 'package:galaxy_warehouse/views/pages/issuing/issuing.dart';
import 'package:galaxy_warehouse/views/pages/login/loginView.dart';
import 'package:galaxy_warehouse/views/pages/warehouse/warehouse.dart';

var proxyHost;
var proxyPort;
main() async {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: "/",
    routes: {
      "/": (BuildContext context) => LoginView(),
      "/warehouse": (BuildContext context) => WarehouseView(),
      "/issuing": (BuildContext context) => IssuingView(),
    },
  ));
}
