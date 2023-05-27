import 'dart:async';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:galaxy_warehouse/config/global.dart';
import 'package:galaxy_warehouse/config/session.dart' as session;
import 'package:galaxy_warehouse/controllers/loginController.dart';
import 'package:galaxy_warehouse/libraries/MyHttpRequest.dart';
import 'package:galaxy_warehouse/libraries/loading.dart';
import 'package:galaxy_warehouse/models/login.dart';
import 'package:galaxy_warehouse/views/pages/issuing/checkIssuing.dart';
import 'package:galaxy_warehouse/views/pages/issuing/issuing.dart';
import 'package:galaxy_warehouse/views/pages/warehouse/checkWarehouse.dart';
import 'package:galaxy_warehouse/views/pages/warehouse/warehouse.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

class LoginView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Delivery Scanner',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: LoginPage(title: appName),
    );
  }
}

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Loading pr;
  final bool _isValidUser = false;
  bool _isPasswordVisible;
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _spServerUrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    this._usernameController.text = '';
    this._passwordController.text = '';
    _isPasswordVisible = true;
    _getAppSettings();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return WillPopScope(
      onWillPop: () => _appExitConfirm(),
      child: Scaffold(
        body: Builder(builder: (BuildContext context) {
          return Center(
              child: Container(
            padding: new EdgeInsets.all(20.0),
            child: Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(120, 0, 120, 20),
                      child: Image.asset(
                        'assets/img/app-icon.png',
                      ),
                    ),
                    new TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(labelText: 'username'),
                      keyboardType: TextInputType.text,
                      readOnly: false,
                      maxLines: 1,
                    ),
                    new TextFormField(
                      controller: _passwordController,
                      obscureText: _isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            }),
                      ),
                      keyboardType: TextInputType.text,
                      readOnly: false,
                      maxLines: 1,
                    ),
                    new SizedBox(
                      height: 10.0,
                    ),
                    new ButtonBar(
                      alignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new RaisedButton(
                          onPressed: _appExitConfirm,
                          child: Text("    Cancel    "),
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(30.0)),
                          color: Colors.redAccent,
                        ),
                        new RaisedButton(
                            onPressed: _isValidUser
                                ? null
                                : () async {
                                    if (_usernameController.text ==
                                            adminUserName &&
                                        _passwordController.text ==
                                            adminPassword) {
                                      _appSettings();
                                    } else {
                                      await userLogin(context);
                                    }
                                  },
                            child: Text("     Login     "),
                            shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(30.0)),
                            color: Colors.red),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        '$appServer - $appVersionName',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  ],
                )),
          ));
        }),
      ),
    );
  }

  Future<bool> userLogin(context) async {
    pr = new Loading(context);
    pr.load().show();
    MyHttpRequest request = new MyHttpRequest(context: context);
    bool validateConnection = await request.validateConnection();
    if (!validateConnection) {
      pr.load().hide();
      return false;
    }
    LoginSubmit res = new LoginSubmit(
        username: _usernameController.text, password: _passwordController.text);
    LoginReturn res2 = await LoginController.getUser(res);

    if (res2.apiReturn >= 0) {
      setState(() {
        session.userEmployeeID = res2.user[0]['employeeID'];
        session.userFullName = res2.user[0]['fullName'];
        session.userLocationID = res2.user[0]['locationID'];
        session.userLocationCode = res2.user[0]['locationCode'];
        session.userLocation = res2.user[0]['locationName'];
        session.userDepartmentID = res2.user[0]['departmentID'];
        session.userDepartment = res2.user[0]['department'];
        session.userType = res2.user[0]['userType'];
        session.userIsScanning = res2.user[0]['isScanning'];
      });

      Navigator.of(context).push(new PageRouteBuilder(
          pageBuilder: (BuildContext context, _, __) {
        if (session.userIsScanning == 1) {
          return session.userType == 1
              ? new WarehouseView()
              : new IssuingView();
        } else {
          return session.userType == 1
              ? new CheckWarehouseView()
              : new CheckIssuingView();
        }
      }, transitionsBuilder:
              (_, Animation<double> animation, __, Widget child) {
        return new FadeTransition(opacity: animation, child: child);
      }));
      pr.load().hide();
      return true;
    } else {
      Flushbar(
        title: "Login Failed!",
        message: res2.apiMsg,
        icon: Icon(
          Icons.warning,
          size: 28,
          color: Colors.white,
        ),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 3),
      ).show(context);
      pr.load().hide();
      return false;
    }
  }

  Future<bool> _appExitConfirm() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Are you sure?'),
        content: Text('Do you want to close an App'),
        actions: <Widget>[
          FlatButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('No'),
          ),
          FlatButton(
            onPressed: () => SystemChannels.platform
                .invokeMethod('SystemNavigator.pop', true),
            /*Navigator.of(context).pop(true)*/
            child: Text('Yes'),
          ),
        ],
      ),
    );
  }

  Future<bool> _appSettings() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('App Settings'),
        content: FittedBox(
          child: Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: <Widget>[
                  new TextFormField(
                    style: TextStyle(fontSize: 12),
                    controller: _spServerUrl,
                    decoration: const InputDecoration(labelText: 'API Url'),
                    keyboardType: TextInputType.url,
                    readOnly: false,
                    maxLines: 2,
                  ),
                ],
              )),
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('No'),
          ),
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop(false);
              _updateAppSettings();
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  Future getApiAppSettings() async {
    try {
      var response = await Dio().post(
        appSettingsUrl,
        onSendProgress: (int sent, int total) {
          print("$sent $total");
        },
      );
      setState(() {
        print("app setting : ${response.data}");
        apiSignatureFolder = response.data['signatureUrl'];
        if (appVersion != response.data['warehouseVersion']) {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.WARNING,
            animType: AnimType.BOTTOMSLIDE,
            title: 'New Update Available',
            desc:
                'This application current version is $appVersion and need update to version ${response.data['warehouseVersion']}',
            dismissOnTouchOutside: false,
            dismissOnBackKeyPress: false,
            btnOkText: "Ok",
            btnOkColor: Colors.orangeAccent,
            btnOkOnPress: () {
              SystemChannels.platform.invokeMethod('SystemNavigator.pop', true);
            },
          )..show();
        }
      });
      if (apiSignatureFolder == '') {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.ERROR,
          animType: AnimType.BOTTOMSLIDE,
          title: 'Problem found!',
          desc: 'Application setting not found!. Please restart this app. ',
          dismissOnTouchOutside: false,
          btnOkText: "Close",
          btnOkColor: Colors.red,
          btnOkOnPress: () {
            SystemChannels.platform.invokeMethod('SystemNavigator.pop', true);
          },
        )..show();
      }
    } catch (e) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.ERROR,
        animType: AnimType.BOTTOMSLIDE,
        title: 'Error found!',
        desc:
            'System encounter error durring request to get application settings!. Please report to system administrator!. ',
        dismissOnTouchOutside: true,
        btnCancelOnPress: () {
          if (appServer == 'Production') {
            SystemChannels.platform.invokeMethod('SystemNavigator.pop', true);
          }
        },
      )..show();
    }
  }

  Future<void> _getAppSettings() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _spServerUrl.text = prefs.getString("spServerUrl") ?? '';
      setState(() {
        if (_spServerUrl.text == '') {
          _spServerUrl.text = apiUrl;
        } else {
          apiUrl = _spServerUrl.text;
        }

        setValuesApi();
      });
    } catch (e) {
      setState(() {
        apiUrl = _spServerUrl.text;
        setValuesApi();
      });
    }
  }

  void setValuesApi() {
    setState(() {
      apiLoginUrl = '$apiUrl/login';
      apiDeliveryUrl = '$apiUrl/delivery';
      apiZoneUrl = '$apiUrl/delivery_details';
      apiDetailsZoneUrl = '$apiUrl/details_zone';
      apiUpdateContUrl = '$apiUrl/update_cont';
      apiDDZoneUrl = '$apiUrl/dd_zone';
      apiLocationUrl = '$apiUrl/location';
      apiScanZoneUrl = '$apiUrl/delivery_details_zone';
      apiWarehouseScanUlr = '$apiUrl/update_cont';
      apiZoneBarcodeUrl = '$apiUrl/d_barcode';

      apiZoneContainerUrl = '$apiUrl/dd_cont_zone';
      apiContainerUrl = '$apiUrl/dd_cont';
      apiIssuingDeliveryUrl = '$apiUrl/d_loaded';
      apiIssuingScanUrl = '$apiUrl/update_status';
      apiTruckUrl = '$apiUrl/truck';
      apiDriverUrl = '$apiUrl/driver';
      apiShippingUrl = '$apiUrl/insert_da';
      apiShippingUpdateUrl = '$apiUrl/update_da';
      apiDeliveryUpdateUrl = '$apiUrl/update_deliver';
      apiIssuingScannedUrl = '$apiUrl/d_barcode';
      apiDetailsContTypeUrl = '$apiUrl/dd_contype';
      apiBatchUrl = '$apiUrl/d_batches';
      apiUploadUrl = '$apiUrl/upload_sign';
      apiWitnessUrl = '$apiUrl/d_witness';
      apiWitnessUpdateUrl = '$apiUrl/update_witness';
      apiDelDetContainerUrl = '$apiUrl/dd_cont_check';
      apiDelDetUpdaterUrl = '$apiUrl/update_dd_wh_cont';
      apiDelDetUpdateStatusUrl = '$apiUrl/update_dd_status';
      apiUpdateDelShipUrl = '$apiUrl/update_del_ship';
      apiDeliveryCountUrl = '$apiUrl/d_count';
      apiDOSContent = '$apiUrl/dos_content';
      appSettingsUrl = '$apiUrl/app_settings_warehouse';
    });
    getApiAppSettings();
  }

  Future<void> _updateAppSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setString('spServerUrl', _spServerUrl.text);
      apiUrl = _spServerUrl.text;

      setValuesApi();
    });
  }
}
