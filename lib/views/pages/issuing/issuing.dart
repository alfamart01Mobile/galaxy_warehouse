 
import 'dart:typed_data';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:dio/dio.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:galaxy_warehouse/config/global.dart';
import 'package:galaxy_warehouse/controllers/deliverUpdateController.dart';
import 'package:galaxy_warehouse/controllers/driverController.dart';
import 'package:galaxy_warehouse/controllers/issuingScanController.dart';
import 'package:galaxy_warehouse/controllers/containerController.dart';
import 'package:galaxy_warehouse/controllers/batchController.dart';
import 'package:galaxy_warehouse/controllers/issuingScannedController.dart';
import 'package:galaxy_warehouse/controllers/shippingController.dart';
import 'package:galaxy_warehouse/controllers/truckController.dart';
import 'package:galaxy_warehouse/controllers/witnessController.dart';
import 'package:galaxy_warehouse/controllers/witnessUpdateController.dart'; 
import 'package:galaxy_warehouse/libraries/AudioPlay.dart';
import 'package:galaxy_warehouse/libraries/MyHttpRequest.dart';
import 'package:galaxy_warehouse/libraries/loading.dart';
import 'package:galaxy_warehouse/models/batch.dart';
import 'package:galaxy_warehouse/models/issuingScan.dart';
import 'package:galaxy_warehouse/models/container.dart';
import 'package:galaxy_warehouse/models/deliveryUpdate.dart';
import 'package:galaxy_warehouse/models/driver.dart';
import 'package:galaxy_warehouse/models/issuingScanned.dart';
import 'package:galaxy_warehouse/models/location.dart';
import 'package:galaxy_warehouse/models/shipping.dart';
import 'package:galaxy_warehouse/models/shippingUpdate.dart';
import 'package:galaxy_warehouse/models/truck.dart';
import 'package:galaxy_warehouse/models/witness.dart';
import 'package:galaxy_warehouse/models/witnessUpdate.dart';
import 'package:galaxy_warehouse/models/zoneContainer.dart';
import 'package:galaxy_warehouse/views/pages/issuing/checkIssuing.dart';
import 'package:galaxy_warehouse/views/pages/login/loginView.dart';
import 'package:galaxy_warehouse/config/session.dart' as session;
import 'package:galaxy_warehouse/views/pages/warehouse/checkWarehouse.dart';
import 'package:galaxy_warehouse/views/pages/warehouse/warehouse.dart';
import 'package:group_radio_button/group_radio_button.dart';
import 'package:hand_signature/signature.dart'; 
import 'package:galaxy_warehouse/models/issuingDelivery.dart';
import 'package:galaxy_warehouse/controllers/issuingDeliveryController.dart';
import 'package:galaxy_warehouse/models/detailsContType.dart';
import 'package:galaxy_warehouse/controllers/detailsContTypeController.dart';
import 'package:galaxy_warehouse/models/dropDown.dart';
import 'package:vibration/vibration.dart';

class IssuingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Delivery Scanner',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: IssuingPage(),
    );
  }
}

const _kPages = <String, IconData>{
  'search': Icons.search,
  'detail': Icons.info,
  'loading': Icons.check_circle,
  'offloading': Icons.remove_circle,
  'confirm': Icons.done_all,
};

class IssuingPage extends StatefulWidget {
  const IssuingPage({Key key}) : super(key: key);

  @override
  IssuingPageState createState() => IssuingPageState();
}

class IssuingPageState extends State<IssuingPage>
    with TickerProviderStateMixin {
  AudioPlay scanPlayer = new AudioPlay();
  AudioPlay errorScanPlayer = new AudioPlay();
  String mp3Uri;
  Loading pr;
  bool get scrollTest => false;
  final pageTitle = TextEditingController();
  final navBarTitle = TextEditingController();

  // static final GlobalKey<ConvexAppBarState> appBarKeyIssuing =  new GlobalKey<ConvexAppBarState>();

  TabStyle _tabStyle = TabStyle.reactCircle;
  static TabController tabController;

  LocationReturn _locationReturn;
  IssuingDeliveryReturn _issuingDeliveryReturn;
  ZoneContainerReturn _zoneContainerReturn;
  ContainerReturn _containerReturn;
  DetailsContTypeReturn _detailsContTypeReturn;
  IssuingScanReturn _issuingScanReturn;
  TruckReturn _truckReturn;
  DriverReturn _driverReturn;
  ShippingReturn _shippingReturn;
  ShippingUpdateReturn _shippingUpdateReturn;
  DeliveryUpdateReturn _deliveryUpdateReturn;
  IssuingScannedReturn _issuingScannedReturn;
  WitnessReturn _witnessReturn;
  WitnessUpdateReturn _witnessUpdateReturn;
  BatchReturn _batchReturn;
  List<DropdownMenuItem> _locationList = [];
  List<DropdownMenuItem> _truckList2 = [];
  List<DropdownMenuItem> _driverList2 = [];
  List<DropdownMenuItem> _batchList2 = [];

  List<DropDown> _batchList = [];
  List<DropDown> _truckList = [];
  List<DropDown> _driverList = [];
  final _issuingSearchFormKey = GlobalKey<FormState>();
  final _confirmationFormKey = GlobalKey<FormState>();
  final _searchDate = TextEditingController();
  final _searchControlNo = TextEditingController();
  final _searchLocation = TextEditingController();
  final _searchIsLoaded = TextEditingController();
  final _searchLocationID = TextEditingController();

  final _scanningFormKey = GlobalKey<FormState>();
  final _searchZone = TextEditingController();
  final _searchBarcode = TextEditingController();
  final _selectedDeliverID = TextEditingController();
  final _selectedLocation = TextEditingController();
  final _selectedDONo = TextEditingController();
  final _selectedLocationID = TextEditingController();
  DateTime _selectedDate;
  final _selectedControlNo = TextEditingController();
  final _selectedTotalContainer = TextEditingController();
  final _selectedTotalScanned = TextEditingController();

  final _selectedZone = TextEditingController();

  final _scanningBarcode = TextEditingController();
  final _scanningQty = TextEditingController();
  final _scanningZone = TextEditingController();
  final _scanningStatus = TextEditingController();

  var _batchIndex = null;
  var _truckIndex = null;
  var _driverIndex = null;

  final _selectedTruck = TextEditingController();
  final _selectedDriver = TextEditingController();
  final _selectedBatchNo = TextEditingController();

  bool _isUpdating = false;
  bool _isContinueScanning = false;
  bool _isDisableQty = false;
  bool _isAllowedToShip = false;
  bool _isShip = false;

  bool _withWitness = false;
  final witness = TextEditingController();
  DefaultCacheManager manager = new DefaultCacheManager();

  ValueNotifier<ByteData> signatureResult = ValueNotifier<ByteData>(null);
  HandSignatureControl control = new HandSignatureControl(
    threshold: 5.0,
    smoothRatio: 0.65,
    velocityRange: 2.0,
  );

  ValueNotifier<String> svg = ValueNotifier<String>(null);

  ValueNotifier<ByteData> rawImage = ValueNotifier<ByteData>(null);

  @override
  void initState() {
    super.initState();
    httpGetIssuingDelivery();
    navBarTitle.text = "SEARCH DELIVERY!";
    _selectedDeliverID.text = "";
    _searchLocationID.text = "";
    _scanningStatus.text = "1";
    _selectedBatchNo.text = "1";

    pageTitle.text = "SEARCH DELIVERY!";
    tabController = new TabController(
      vsync: this,
      length: _kPages.length,
    );
    tabController.addListener(() {
      setState(() {
        if (_isUpdating == false) {
          this._scanningBarcode.text = "";
          this._scanningZone.text = "";
          this._scanningQty.text = "";
          this._scanningStatus.text = "";
          _isContinueScanning = true;
        } else {
          _isContinueScanning = false;
        }
        switch (tabController.index) {
          case 0:
            {
              pageTitle.text = "SEARCH DELIVERY";
            }
            break;
          case 1:
            {
              pageTitle.text = "DELIVERY DETAILS";
              if (_selectedDeliverID.text != "") {
                httpGetContainer();
              }
            }
            break;
          case 2:
            {
              _scanningStatus.text = "1";
              pageTitle.text = "LOADED LIST";
              if (_selectedDeliverID.text != "") {
                httpGetIssuingScanned(1);
              }
            }
            break;
          case 3:
            {
              _scanningStatus.text = "3";
              pageTitle.text = "OFFLOADED LIST";
              if (_selectedDeliverID.text != "") {
                httpGetIssuingScanned(3);
              }
            }
            break;
          case 4:
            {
              pageTitle.text = "DRIVER CONFIRMATION";
              if (_selectedDeliverID.text != "") {
                imageCache.clear();
                rawImage.value = null;
                _isAllowedToShip = false;
                _isShip = false;
                _withWitness = false;
                witness.text = "";
                _truckIndex = null;
                _driverIndex = null;
                _batchIndex = null;

                httpGetTruck();
                httpGetDriver();
                httpGetBatch();
                setState(() {
                  control.clear();
                });
              }
            }
            break;
          case 5:
            {
              pageTitle.text = "SCANNING FORM";
              if (_isUpdating == false && _selectedDeliverID.text != "") {
                _scan(context);
              }
            }
            break;
        }
        print("Current Page is >>>>>> ${pageTitle.text}");
      });

      if (_selectedDeliverID.text == "" && tabController.index != 0) {
        GlobalDialog(
                context: context,
                title: "No Record",
                message: "Please search delivery first!",
                dismiss: 60)
            .showErrorDialog();
      }
    });

    _scanningBarcode.addListener(() {
      setState(() {
        if (_scanningBarcode.text.length > 3) {
          bool isDos = _scanningBarcode.text.toUpperCase().contains("DOS");
          if (isDos) {
            _isDisableQty = false;
            _scanningQty.text = "";
          } else {
            _isDisableQty = true;
            _scanningQty.text = "1";
          }
        }
      });
    });

    scanPlayer.load(soundsPath + scanAudioFile, scanAudioFile);
    errorScanPlayer.load(soundsPath + scanErrorAudioFile, scanErrorAudioFile);
  }

  void refreshConfirmation() {
    httpGetBatch();
    httpGetDetailsContType();
  }

  @override
  Widget build(BuildContext context) {
    final drawerHeader = UserAccountsDrawerHeader(
      accountName: session.userEmployeeID == 0
          ? Text("")
          : Text('${session.userLocationCode} - ${session.userLocation}'),
      accountEmail:
          session.userEmployeeID == 0 ? Text("") : Text(session.userFullName),
      currentAccountPicture: CircleAvatar(
        child: FlutterLogo(size: 42.0),
        backgroundColor: Colors.white,
      ),
    );
    final drawerItems = ListView(
      children: <Widget>[
        drawerHeader, 
        ListTile(
                title: Text(
                  'Issuing Scanning', 
              style: TextStyle(color: Colors.redAccent),
                ),
                leading: Icon(Icons.camera),
                onTap: () async {
                  // Navigator.push(context,  MaterialPageRoute(builder: (context) => CheckIssuingView()));
                  Navigator.of(context).pop();
                  Navigator.of(context).push(new PageRouteBuilder(
                      pageBuilder: (BuildContext context, _, __) {
                    return new CheckIssuingView();
                  }, transitionsBuilder:
                          (_, Animation<double> animation, __, Widget child) {
                    return new FadeTransition(opacity: animation, child: child);
                  }));
                }), 
        ListTile(
            title: Text('Logout'),
            leading: Icon(Icons.exit_to_app),
            onTap: () async {
              session.destroySession();
              Navigator.of(context).pop();
              Navigator.of(context).push(new PageRouteBuilder(
                  pageBuilder: (BuildContext context, _, __) {
                return new LoginView();
              }, transitionsBuilder:
                      (_, Animation<double> animation, __, Widget child) {
                return new FadeTransition(opacity: animation, child: child);
              }));
            }),
      ],
    );

    return DefaultTabController(
      length: _kPages.length,
      initialIndex: 0,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: Text(
            _selectedDeliverID.text == ""
                ? "SEARCH DELIVERY"
                : "${_selectedLocation.text} : ${_selectedDONo.text}",
            style: TextStyle(fontSize: 16),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
              child: Row(
                children: <Widget>[
                  Text(
                    pageTitle.text,
                    style: new TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent),
                  ),
                  tabController.index != 0
                      ? Text("")
                      : Expanded(
                          child: Align(
                            alignment: Alignment.topRight,
                            child: InkWell(
                              splashColor: Colors.red,
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(30, 0, 30, 0),
                                child: Icon(
                                  Icons.search,
                                  color: Colors.redAccent,
                                ),
                              ),
                              onTap: () {
                                _searchDialog(context);
                              },
                            ),
                          ),
                        )
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    color: Color.fromRGBO(247, 245, 237, 1),
                    border: Border.all(
                      color: Colors.white24,
                    )),
                child: TabBarView(
                  physics: NeverScrollableScrollPhysics(),
                  controller: tabController,
                  children: [
                    _issuingDeliveryReturn == null
                        ? Center(child: Text('Loading..'))
                        : Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: SingleChildScrollView(
                                child: Container(
                                    decoration: contentDecoration(),
                                    child: displayDeliverTab()))),
                    _containerReturn == null
                        ? Center(child: Text('No record found!'))
                        : Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: SingleChildScrollView(
                                child: Container(
                                    decoration: contentDecoration(),
                                    child: displayDetailsTab())),
                          ),
                    Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: SizedBox(
                          child: Column(
                            children: <Widget>[
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height - 270,
                                child: SingleChildScrollView(
                                    child: Container(
                                        decoration: contentDecoration(),
                                        child: _issuingScannedReturn == null
                                            ? Center(
                                                child: Text('No record found!'))
                                            : displayScannedTab(1))),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  RaisedButton(
                                    onPressed: () {
                                      _scan(context);
                                    },
                                    child: Text(
                                      "Scan for Loading",
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                    color: Colors.green,
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  RaisedButton(
                                    onPressed: () {
                                      _scanningFormDialog(this.context);
                                    },
                                    child: Text(
                                      "Manual Loading",
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                    color: Colors.green,
                                  ),
                                ],
                              )
                            ],
                          ),
                        )),
                    Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: SizedBox(
                          child: Column(
                            children: <Widget>[
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height - 270,
                                child: SingleChildScrollView(
                                    child: Container(
                                        decoration: contentDecoration(),
                                        child: _issuingScannedReturn == null
                                            ? Center(
                                                child: Text('No record found!'))
                                            : displayScannedTab(3))),
                              ),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    RaisedButton(
                                      onPressed: () {
                                        _scan(context);
                                      },
                                      child: Text(
                                        "Scan For Unloading",
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                      color: Colors.orangeAccent,
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    RaisedButton(
                                      onPressed: () {
                                        _scanningFormDialog(this.context);
                                      },
                                      child: Text(
                                        "Manual Unloading",
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                      color: Colors.orangeAccent,
                                    ),
                                  ])
                            ],
                          ),
                        )),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SingleChildScrollView(
                          child: Column(
                        children: <Widget>[
                          _batchList.length == 0
                              ? Text("")
                              : Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 10, 0, 10),
                                  child: DropdownSearch<DropDown>(
                                    items: _batchList,
                                    itemAsString: (DropDown u) => u.name,
                                    selectedItem: _batchIndex == null
                                        ? null
                                        : _batchList[_batchIndex],
                                    maxHeight: 300,
                                    label: "Batch No.",
                                    onChanged: (e) {
                                      setState(() {
                                        print(e.name);
                                        int c = 0;
                                        _batchList.forEach((element) {
                                          if (e.id == element.id) {
                                            _batchIndex = c;
                                          }
                                          c++;
                                        });
                                        _selectedBatchNo.text = e.id;
                                      });
                                      httpGetDetailsContType();
                                      setTruckAndDriverVal(e.id);
                                      httpGetWitness();
                                    },
                                    showSearchBox: true,
                                  ),
                                ),
                          Container(
                              decoration: contentDecoration(),
                              child: displayConfirmationTab())
                        ],
                      )),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: ConvexAppBar(
          initialActiveIndex: 0,
          controller: tabController,
          backgroundColor: Colors.red,
          style: TabStyle.reactCircle,
          items: <TabItem>[
            for (final entry in _kPages.entries)
              TabItem(icon: entry.value, title: entry.key),
          ],
          onTap: (int i) {
            setState(() {
              _isUpdating = false;
            });
          },
        ),
        drawer: Drawer(
          child: drawerItems,
        ),
      ),
    );
  }

  BoxDecoration contentDecoration() {
    return BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.grey,
        ));
  }

  Widget displayDeliverTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        DataTable(
          columns: [
            DataColumn(label: Text('Control No.')), 
            DataColumn(label: Text('Total')),
            DataColumn(label: Text('Location')),
          ],
          rows: _issuingDeliveryReturn.items
              .map((e) => DataRow(
                    cells: <DataCell>[
                      DataCell(
                          Text(
                            "${e["controlNo"]}",
                            style: new TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold),
                          ), onTap: () {
                        setState(() {
                          _selectedDeliverID.text = e["deliverID"];
                          _selectedDONo.text = "${e["controlNo"]}";
                          _selectedLocation.text =
                              "${e['locationCode']} - ${e['location']}";
                        });
                        print(">>>>>>>> selected deliverID: ${e['deliverID']}");
                        tabController.animateTo(1,
                            duration: Duration(milliseconds: 1));
                      }),
                      DataCell(Text("${e["totalContainer"]}")),
                      DataCell(Text("${e["locationCode"]} - ${e["location"]}")),
                    ],
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget displayDetailsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _containerTable(),
      ],
    );
  }

  Widget _containerTable() {
    var count = 0;
    int allTotal = 0;
    int whTotal = 0;
    int ldTotal = 0;
    int ulTotal = 0;
    int olTotal = 0;

    List rows = [];
    rows.addAll(_containerReturn.items);
    rows.add({
      "container": "",
      "zone": "",
      "TotalQty": "",
      "scannedQty": "",
      "loadedQty": "",
      "unloadedQty": "",
      "offloadedQty": ""
    });
    return DataTable(
      columnSpacing: 6,
      columns: [
        DataColumn(label: Text('Container')),
        DataColumn(label: Text('Zone')),
        DataColumn(label: Text('Total')),
        DataColumn(label: Text('WH')),
        DataColumn(label: Text('LD')),
        DataColumn(label: Text('UL')),
        DataColumn(label: Text('OL')),
      ],
      rows: rows.map((e) {
        count++;
        if (count < rows.length) {
          allTotal += e["totalQty"];
          whTotal += e["scannedQty"];
          ldTotal += e["loadedQty"];
          ulTotal += e["unloadedQty"];
          olTotal += e["offloadedQty"];
          return DataRow(
            cells: <DataCell>[
              DataCell(Text("${e["container"]}")),
              DataCell(Text("${e["zones"]}")),
              DataCell(Center(child: Text("${e["totalQty"]}"))),
              DataCell(Center(child: Text("${e["scannedQty"]}"))),
              DataCell(Center(child: Text("${e["loadedQty"]}"))),
              DataCell(Center(child: Text("${e["unloadedQty"]}"))),
              DataCell(Center(child: Text("${e["offloadedQty"]}"))),
            ],
          );
        }
        return DataRow(
          cells: <DataCell>[
            DataCell(Text("")),
            DataCell(Text(
              "TOTAL",
              style: TextStyle(fontWeight: FontWeight.bold),
            )),
            DataCell(Center(
                child: Text("$allTotal",
                    style: TextStyle(fontWeight: FontWeight.bold)))),
            DataCell(Center(
                child: Text("$whTotal",
                    style: TextStyle(fontWeight: FontWeight.bold)))),
            DataCell(Center(
                child: Text("$ldTotal",
                    style: TextStyle(fontWeight: FontWeight.bold)))),
            DataCell(Center(
                child: Text("$ulTotal",
                    style: TextStyle(fontWeight: FontWeight.bold)))),
            DataCell(Center(
                child: Text("$olTotal",
                    style: TextStyle(fontWeight: FontWeight.bold)))),
          ],
        );
      }).toList(),
    );
  }

  Widget _detailsContTypeTable() {
    var count = 0;
    int ldcQty = 0;
    int ldbQty = 0;

    List rows = [];
    rows.addAll(_detailsContTypeReturn.items);
    rows.add({
      "barcode": "",
      "LDCQty": "",
      "LDBQty": "",
    });
    return DataTable(
      columns: [
        DataColumn(label: Text('Barcode')),
        DataColumn(label: Center(child: Text('Container'))),
        DataColumn(label: Center(child: Text('Box'))),
      ],
      rows: rows.map((e) {
        count++;
        if (count < rows.length) {
          ldcQty += e["LDCQty"];
          ldbQty += e["LDBQty"];
          return DataRow(
            cells: <DataCell>[
              DataCell(Text("${e["Barcode"]}")),
              DataCell(Center(child: Text("${e["LDCQty"]}"))),
              DataCell(Center(child: Text("${e["LDBQty"]}"))),
            ],
          );
        }
        return DataRow(
          cells: <DataCell>[
            DataCell(Text(
              "TOTAL",
              style: TextStyle(fontWeight: FontWeight.bold),
            )),
            DataCell(Center(
                child: Text("$ldcQty",
                    style: TextStyle(fontWeight: FontWeight.bold)))),
            DataCell(Center(
                child: Text("$ldbQty",
                    style: TextStyle(fontWeight: FontWeight.bold)))),
          ],
        );
      }).toList(),
    );
  }

  Widget displayScannedTab(int status) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        DataTable(
          columnSpacing: 6,
          columns: [
            DataColumn(label: Text('Barcode')),
            DataColumn(label: Text('Zone')),
            DataColumn(label: Text('Qty')),
            DataColumn(label: Text('Type')),
          ],
          rows: _issuingScannedReturn.items
              .map((e) => DataRow(
                    cells: <DataCell>[
                      DataCell(
                          e["barcode"].toUpperCase().contains("DOS") == false
                              ? Text("${e["barcode"]}")
                              : Text(
                                  "${e["barcode"]}",
                                  style: new TextStyle(
                                      color: Colors.redAccent,
                                      fontWeight: FontWeight.bold),
                                ), onTap: () {
                        setState(() {
                          _scanningBarcode.text = e["barcode"];
                          _scanningStatus.text = status.toString();
                          _scanningQty.text = e["qty"].toString();
                          _isUpdating = true;
                        });
                        print(">>>>>>>> selected deliverID: ${e['deliverID']}");
                        _scanningFormDialog(context);
                      }),
                      DataCell(Text("${e["zone"]}")),
                      DataCell(Text("${e["qty"]}")),
                      DataCell(Text("${e["containerType"]}"))
                    ],
                  ))
              .toList(),
        ),
      ],
    );
  }

  bool setTruckAndDriverVal(batch) {
    imageCache.clear();
    rawImage.value = null;
    if (_batchReturn != null && batch != "") {
      if (_batchReturn.items.length > 0) {
        setState(() {
          _selectedTruck.text = "";
          _selectedDriver.text = "";
          _driverIndex = null;
          _truckIndex = null;
        });
        for (int c = 0; c < _batchReturn.items.length; c++) {
          if (int.parse(batch) == _batchReturn.items[c]['batchNo']) {
            setState(() {
              _selectedTruck.text = _batchReturn.items[c]['truckID'].toString();
              int indx = 0;
              _driverList.forEach((element) {
                print(
                    ">> ${_driverReturn.items[c]['Driver_ID'].toString()} ----- ${element.id}");
                if (_driverReturn.items[c]['Driver_ID'].toString() ==
                    element.id) {
                  _driverIndex = indx;
                  _selectedDriver.text =
                      _driverReturn.items[c]['Driver_ID'].toString();
                }
                indx++;
              });

              int indx2 = 0;
              _truckList.forEach((element) {
                print(
                    ">> ${_truckReturn.items[c]['truckID'].toString()} ----- ${element.id}");
                if (_truckReturn.items[c]['truckID'].toString() == element.id) {
                  _truckIndex = indx2;
                  _selectedTruck.text =
                      _truckReturn.items[c]['truckID'].toString();
                }
                indx2++;
              });

              httpGetWitness();
              return true;
            });
          }
        }
        return false;
      }
    }
    return false;
  }

  Widget displayConfirmationTab() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
            child: Text(
              "Assigned Driver & Truck",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          _tdForm(),
          const Divider(),
          _isAllowedToShip == false
              ? Text("")
              : Container(
                  child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                      child: Text(
                        "Delivery Summary",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    _detailsContTypeReturn == null
                        ? Text("No Record")
                        : _detailsContTypeTable(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: <Widget>[
                              Checkbox(
                                value: this._withWitness,
                                onChanged: _isShip == true
                                    ? null
                                    : (bool value) {
                                        setState(() {
                                          witness.text = "";
                                          this._withWitness = value;
                                        });
                                      },
                              ),
                              Text(
                                "With Witness Signature",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          )),
                    ),

                    Visibility(
                        visible: _withWitness,
                        child: Column(
                          children: <Widget>[
                            TextFormField(
                              autofocus: false,
                              controller: witness,
                              keyboardType: TextInputType.text,
                              readOnly: _isShip,
                              decoration: InputDecoration(labelText: 'Witness'),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              height: 70,
                              color: Colors.white,
                              child: Center(
                                  child: InkWell(
                                onTap: _isShip == true
                                    ? null
                                    : () {
                                        _signFormDialog(context);
                                      },
                                child: Image.network(
                                  '$apiSignatureFolder${_selectedDeliverID.text}/${_selectedDeliverID.text}-${_selectedBatchNo.text}.png',
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildImageView();
                                  },
                                ),
                              )),
                            ),
                          ],
                        )),
                    // signatureResult == null ? Text("No img"):Image.memory(signatureResult.buffer.asUint8List()),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Flexible(
                              child: SizedBox(
                            width: double.infinity,
                            child: RaisedButton(
                              onPressed: _isShip == true
                                  ? null
                                  : () async {
                                      httpUpdateDelivery();
                                    },
                              color: Colors.green,
                              child: Text('Click here to Ship',
                                  style: TextStyle(color: Colors.white70)),
                            ),
                          )),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 120,
                    )
                  ],
                )),
        ],
      ),
    );
  }

  Widget _tdForm() {
    return Form(
      key: _confirmationFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _truckList.length == 0
              ? Text("")
              : DropdownSearch<DropDown>(
                  items: _truckList,
                  itemAsString: (DropDown u) => u.name,
                  selectedItem:
                      _truckIndex == null ? null : _truckList[_truckIndex],
                  maxHeight: 300,
                  label: "Truck.",
                  onChanged: (e) {
                    setState(() {
                      print(e.name);
                      int c = 0;
                      _truckList.forEach((element) {
                        if (e.id == element.id) {
                          _truckIndex = c;
                        }
                        c++;
                      });
                      _selectedTruck.text = e.id;
                    });
                  },
                  showSearchBox: true,
                ),
          SizedBox(
            height: 20,
          ),
          _driverList.length == 0
              ? Text("")
              : DropdownSearch<DropDown>(
                  items: _driverList,
                  itemAsString: (DropDown u) => u.name,
                  selectedItem:
                      _driverIndex == null ? null : _driverList[_driverIndex],
                  maxHeight: 300,
                  label: "Driver.",
                  onChanged: (e) {
                    setState(() {
                      print(e.name);
                      int c = 0;
                      _driverList.forEach((element) {
                        if (e.id == element.id) {
                          _driverIndex = c;
                        }
                        c++;
                      });
                      _selectedDriver.text = e.id;
                    });
                  },
                  showSearchBox: true,
                ),
          RaisedButton(
            onPressed: _selectedDriver.text == "" || _selectedTruck.text == ""
                ? null
                : () {
                    httpSaveAssignedTD();
                  },
            color: Colors.green,
            child: Center(
              child: Text('Save Assigned Driver & Truck',
                  style: TextStyle(color: Colors.white70)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildImageView() {
    return Container(
      width: MediaQuery.of(context).size.width - 20,
      height: 96.0,
      decoration: BoxDecoration(
        border: Border.all(),
        color: Colors.white30,
      ),
      child: ValueListenableBuilder<ByteData>(
        valueListenable: rawImage,
        builder: (context, data, child) {
          if (data == null) {
            return Container(
              color: Colors.white,
              child: Center(
                  child: InkWell(
                onTap: () {
                  _signFormDialog(context);
                },
                child: Text('For witness signature, click here!.'),
              )),
            );
          } else {
            return InkWell(
              onTap: () {
                _signFormDialog(context);
              },
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Image.memory(data.buffer.asUint8List()),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _scanningForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Form(
          key: _scanningFormKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _scanningBarcode,
                keyboardType: TextInputType.text,
                readOnly: false,
                inputFormatters: <TextInputFormatter>[
                  LengthLimitingTextInputFormatter(20),
                ],
                onTap: () {},
                decoration: InputDecoration(labelText: 'Barcode'),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Barcode is required!. ';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _scanningQty,
                keyboardType: TextInputType.text,
                readOnly: _isDisableQty,
                inputFormatters: <TextInputFormatter>[
                  WhitelistingTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(5),
                ],
                onTap: () {},
                decoration: InputDecoration(labelText: 'Qty'),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Qty is required!. ';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  _signFormDialog(contx) {
    showGeneralDialog(
        context: contx,
        barrierDismissible: true,
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
        barrierColor: Colors.black45,
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (BuildContext context, Animation animation,
            Animation secondaryAnimation) {
          return Center(
            child: Container(
              width: MediaQuery.of(contx).size.width - 10,
              height: MediaQuery.of(contx).size.height / 1.7,
              padding: EdgeInsets.all(20),
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text("Witness Signature",
                        style: TextStyle(
                          fontSize: 14,
                        )),
                  ),
                  Center(
                    child: AspectRatio(
                      aspectRatio: 1.6,
                      child: Stack(
                        children: <Widget>[
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.black,
                                border: Border.all(
                                  color: Theme.of(contx).accentColor,
                                )),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Container(
                                constraints: BoxConstraints.expand(),
                                color: Colors.white,
                                child: HandSignaturePainterView(
                                  control: control,
                                  type: SignatureDrawType.shape,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          RaisedButton(
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                            child: Text(
                              "Close",
                              style: TextStyle(color: Colors.white),
                            ),
                            color: Colors.redAccent,
                          ),
                          SizedBox(width: 2),
                          RaisedButton(
                            onPressed: () {
                              control.clear();
                            },
                            child: Text(
                              "Clear",
                              style: TextStyle(color: Colors.white),
                            ),
                            color: Colors.orange,
                          ),
                          SizedBox(width: 2),
                          RaisedButton(
                            onPressed: () async {
                              rawImage.value = await control.toImage(
                                color: Colors.blueAccent,
                              );
                              setState(() {
                                signatureResult = rawImage;
                              });
                              Navigator.of(context).pop(false);
                              httpUploadSignature();
                            },
                            child: Text(
                              "Save",
                              style: TextStyle(color: Colors.white),
                            ),
                            color: Colors.green,
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  searchFN(String keyword, items) {
    List<int> ret = List<int>();
    if (keyword != null && items != null && keyword.isNotEmpty) {
      keyword.split(" ").forEach((k) {
        int i = 0;
        items.forEach((item) {
          if (k.isNotEmpty &&
              (item.child.data
                  .toString()
                  .toLowerCase()
                  .contains(k.toLowerCase()))) {
            ret.add(i);
          }
          i++;
        });
      });
    }
    if (keyword.isEmpty) {
      ret = Iterable<int>.generate(items.length).toList();
    }
    return (ret);
  }

  Future httpUploadSignature() async {
    FormData formData = FormData.fromMap({
      "deliverID": _selectedDeliverID.text,
      "batch": _selectedBatchNo.text,
      "signature": MultipartFile.fromBytes(rawImage.value.buffer.asUint8List(),
          filename: "${_selectedDeliverID.text}-${_selectedBatchNo.text}.png")
    });

    var response = await Dio().post(
      apiUploadUrl,
      data: formData,
      onSendProgress: (int sent, int total) {
        print("$sent $total");
      },
    );
    print(response.statusCode);
    print("Upload response >>>>> ${response.toString()}");
  }

  Future<bool> _logout(_context) {
    print("BACK>>>>>>>>>");
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Are you sure?'),
        content: Text('You want to logout?'),
        actions: <Widget>[
          FlatButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('No'),
          ),
          FlatButton(
            onPressed: () {
              session.destroySession();
              Navigator.of(context).pop();
              Navigator.of(context).push(new PageRouteBuilder(
                  pageBuilder: (BuildContext context, _, __) {
                return new LoginView();
              }, transitionsBuilder:
                      (_, Animation<double> animation, __, Widget child) {
                return new FadeTransition(opacity: animation, child: child);
              }));
            },
            /*Navigator.of(context).pop(true)*/
            child: Text('Yes'),
          ),
        ],
      ),
    );
  }

  Future<bool> _scanningFormDialog(_context) {
    return showDialog(
      context: _context,
      builder: (context) => AlertDialog(
        title: Text(_scanningStatus.text == "1"
            ? "LOADING DELIVERY FORM"
            : "OFFLOADING DELIVERY FORM"),
        content: _scanningForm(),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              if (_scanningFormKey.currentState.validate()) {
                setState(() {
                  _isContinueScanning = true;
                });
                Navigator.of(context).pop(false);
                httpSaveScan(_context);
              }
            },
            child: Text('SAVE'),
          ),
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            /*Navigator.of(context).pop(true)*/
            child: Text('CLOSE'),
          ),
        ],
      ),
    );
  }

  void _searchDialog(context2) {
    showDialog(
      context: context2,
      builder: (BuildContext context) {
        // return object of type Dialog
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: new Text("Search Delivery"),
            content: Container(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Form(
                      key: _issuingSearchFormKey,
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            controller: _searchControlNo,
                            keyboardType: TextInputType.text,
                            readOnly: false,
                            inputFormatters: <TextInputFormatter>[
                              LengthLimitingTextInputFormatter(20),
                            ],
                            onTap: () {},
                            decoration:
                                InputDecoration(labelText: 'Control No'),
                          ),
                          TextFormField(
                            controller: _searchLocation,
                            keyboardType: TextInputType.text,
                            readOnly: false,
                            inputFormatters: <TextInputFormatter>[
                              LengthLimitingTextInputFormatter(20),
                            ],
                            onTap: () {},
                            decoration: InputDecoration(labelText: 'Location'),
                          ),
                          // SearchableDropdown(
                          //   items: _locationList,
                          //   value: _searchLocationID.text,
                          //   isExpanded: true,
                          //   hint: new Text('Location'),
                          //   searchHint: new Text(
                          //     'Location',
                          //     style: new TextStyle(fontSize: 20),
                          //   ),
                          //   onChanged: (value) {
                          //     setState(() {
                          //       _searchLocationID.text = value;
                          //       print("SEARCH VALUE IS >>>> $value");
                          //     });
                          //   },
                          // ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                            child: Align(
                                alignment: Alignment.topLeft,
                                child: Text("Loaded?",
                                    style: new TextStyle(fontSize: 12))),
                          ),
                          Row(
                            children: <Widget>[
                              RadioButton(
                                description: "Yes",
                                value: "1",
                                groupValue: _searchIsLoaded.text,
                                onChanged: (value) => setState(
                                  () => _searchIsLoaded.text = value,
                                ),
                                textPosition: RadioButtonTextPosition.right,
                              ),
                              RadioButton(
                                description: "No",
                                value: "0",
                                groupValue: _searchIsLoaded.text,
                                onChanged: (value) => setState(
                                  () => _searchIsLoaded.text = value,
                                ),
                                textPosition: RadioButtonTextPosition.right,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text(
                  "SEARCH",
                  style: new TextStyle(color: Colors.redAccent),
                ),
                onPressed: () {
                  httpGetIssuingDelivery();
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                child: new Text("CLOSE",
                    style: new TextStyle(color: Colors.redAccent)),
                onPressed: () {
                  if (_issuingSearchFormKey.currentState.validate()) {
                    Navigator.of(context).pop();
                  }
                  // _scan(context2);
                },
              ),
            ],
          );
        });
      },
    );
  }

  Future httpGetIssuingDelivery() async {
    MyHttpRequest request = new MyHttpRequest(context: context);
    bool validateConnection = await request.validateConnection();
    if (!validateConnection) {
      return null;
    }
    print("empID: ${session.userEmployeeID.toString()}," +
        "isloaded: ${_searchIsLoaded.text}," +
        "controlno: ${_searchControlNo.text}," +
        "loc: ${_searchLocationID.text}");
    IssuingDeliverySubmit res = new IssuingDeliverySubmit(
        empID: session.userEmployeeID.toString(),
        isloaded: _searchIsLoaded.text,
        controlno: _searchControlNo.text,
        loc: _searchLocation.text);
    IssuingDeliveryReturn res2 =
        await IssuingDeliveryController.getIssuingDelivery(res);
    print("loading issuing delivery from server >>>>> ${res2.apiMsg} ");
    setState(() {
      _issuingDeliveryReturn = res2;
      if (_issuingDeliveryReturn != null) {
        print("*********** HTTP GET >>DELIVERY<< RESULT *************");
        print("Items: \n${_issuingDeliveryReturn.items}");
      }
    });
  }

  Future httpGetIssuingScanned(int status) async {
    pr = new Loading(context);
    pr.load().show();
    MyHttpRequest request = new MyHttpRequest(context: context);
    bool validateConnection = await request.validateConnection();
    if (!validateConnection) {
      pr.load().hide();
      return null;
    }
    print('deliverID: ${_selectedDeliverID.text},' +
        'status: ${status.toString()},' +
        'zone: "",' +
        'empID: ${session.userEmployeeID.toString()}');
    IssuingScannedSubmit res = new IssuingScannedSubmit(
        deliverID: _selectedDeliverID.text,
        status: status.toString(),
        zone: "",
        empID: session.userEmployeeID.toString());
    IssuingScannedReturn res2 =
        await IssuingScannedController.getIssuingScanned(res);
    setState(() {
      _issuingScannedReturn = res2;
      if (_issuingScannedReturn != null) {
        print("*********** HTTP GET >>ISSUING SCANNED<< RESULT *************");
        print("Items: \n${_issuingScannedReturn.items}");
      }
      pr.load().hide();
    });
  }

  Future httpGetContainer() async {
    pr = new Loading(context);
    pr.load().show();
    MyHttpRequest request = new MyHttpRequest(context: context);
    bool validateConnection = await request.validateConnection();
    if (!validateConnection) {
      pr.load().hide();
      return null;
    }

    ContainerSubmit res = new ContainerSubmit(
        deliverID: _selectedDeliverID.text,
        empID: session.userEmployeeID.toString());
    ContainerReturn res2 = await ContainerController.getContainer(res);
    print("loading container from server >>>>> ${res2.apiMsg} ");
    setState(() {
      _containerReturn = res2;
      if (_containerReturn != null) {
        print(
            "*********** HTTP GET >>CONTAINER DETAILS<< RESULT *************");
        print("Items: \n${_containerReturn.items}");
      }
    });
    pr.load().hide();
  }

  Future httpGetBatch() async {
    MyHttpRequest request = new MyHttpRequest(context: context);
    bool validateConnection = await request.validateConnection();
    if (!validateConnection) {
      return null;
    }
    BatchSubmit res = new BatchSubmit(
        deliverID: _selectedDeliverID.text,
        empID: session.userEmployeeID.toString());
    BatchReturn res2 = await BatchController.getBatch(res);
    setState(() {
      _batchReturn = res2;
      print(_batchList2.length);
      _batchList.clear();
      _batchList2.clear();
      int count = 0;
      int maxBatchNo = 0;
      for (int c = 0; c < _batchReturn.items.length; c++) {
        _batchList.add(DropDown(
            id: _batchReturn.items[c]['batchNo'].toString(),
            name: "Batch #${_batchReturn.items[c]['batchNo']}"));
        print(_batchList[0].name);
        _batchList2.add(new DropdownMenuItem(
            child: new Text("Batch #${_batchReturn.items[c]['batchNo']}"),
            value: _batchReturn.items[c]['batchNo'].toString()));
        count++;
        if (maxBatchNo < _batchReturn.items[c]['batchNo']) {
          maxBatchNo = _batchReturn.items[c]['batchNo'] + 1;
        }
      }
      if (count == 0) {
        _batchList.add(new DropDown(id: "1", name: "Batch #1"));

        _batchList2.add(new DropdownMenuItem(
            child: new Text("Batch #1 (new)"), value: "1"));
        _selectedBatchNo.text = "1";
        _batchIndex = 0;
      } else {
        _batchList2.add(new DropdownMenuItem(
            child: new Text("Batch #$maxBatchNo (new)"), value: "$maxBatchNo"));
        _selectedBatchNo.text = "$maxBatchNo";
        _batchList.add(
            new DropDown(id: "$maxBatchNo", name: "Batch #$maxBatchNo (new)"));
        _batchIndex = count;
      }
      setTruckAndDriverVal(_selectedBatchNo.text);
      httpGetWitness();
    });
  }

  Future httpUpdateDelivery() async {
    pr = new Loading(context);
    pr.load().show();
    MyHttpRequest request = new MyHttpRequest(context: context);
    bool validateConnection = await request.validateConnection();
    if (!validateConnection) {
      pr.load().hide();
      return null;
    }

    print(" deliverID: ${_selectedDeliverID.text}," +
        "shipBy: ${session.userEmployeeID.toString()}," +
        "cancelBy: 0," +
        "empID: ${session.userEmployeeID.toString()}");
    DeliveryUpdateSubmit res = new DeliveryUpdateSubmit(
        deliverID: _selectedDeliverID.text,
        shipBy: session.userEmployeeID.toString(),
        cancelBy: "0",
        empID: session.userEmployeeID.toString());
    DeliveryUpdateReturn res2 =
        await DeliveryUpdateController.getDeliveryUpdate(res);

    _isShip = false;
    setState(() {
      _deliveryUpdateReturn = res2;
      if (_deliveryUpdateReturn != null) {
        if (_deliveryUpdateReturn.apiReturn >= 0) {
          _isShip = true;
          httpUpdateWitness();
          Flushbar(
            title: "Successfully!",
            message: res2.apiMsg,
            icon: Icon(
              Icons.warning,
              size: 28,
              color: Colors.white,
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ).show(context);
        } else {
          Flushbar(
            title: "Failed!",
            message: res2.apiMsg,
            icon: Icon(
              Icons.warning,
              size: 28,
              color: Colors.white,
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 1),
          ).show(context);
        }
      }
    });
    pr.load().hide();
  }

  Future httpGetTruck() async {
    MyHttpRequest request = new MyHttpRequest(context: context);
    bool validateConnection = await request.validateConnection();
    if (!validateConnection) {
      return null;
    }
    TruckSubmit res = new TruckSubmit(truckID: "0", truckNo: "");
    TruckReturn res2 = await TruckController.getTruck(res);
    setState(() {
      _truckReturn = res2;
      _truckList.clear();
      for (int c = 0; c < _truckReturn.items.length; c++) {
        _truckList.add(DropDown(
            id: _truckReturn.items[c]['truckID'].toString(),
            name: "${_truckReturn.items[c]['truckNo']}"));
      }
    });
  }

  Future httpSaveAssignedTD() async {
    pr = new Loading(context);
    pr.load().show();
    MyHttpRequest request = new MyHttpRequest(context: context);
    bool validateConnection = await request.validateConnection();
    if (!validateConnection) {
      pr.load().hide();
      return null;
    }
    print(
        "deliverID: ${_selectedDeliverID.text},truckID:  ${_selectedTruck.text},driverID:  ${_selectedDriver.text},empID:  ${session.userEmployeeID.toString()}");
    ShippingSubmit res = new ShippingSubmit(
        deliverID: _selectedDeliverID.text,
        truckID: _selectedTruck.text,
        driverID: _selectedDriver.text,
        empID: session.userEmployeeID.toString());
    ShippingReturn res2 = await ShippingController.getShipping(res);
    setState(() {
      _shippingReturn = res2;
      if (_shippingReturn != null) {
        if (_shippingReturn.apiReturn >= 0) {
          httpGetDetailsContType();
          Flushbar(
            title: "Successfully!",
            message: res2.apiMsg,
            icon: Icon(
              Icons.warning,
              size: 28,
              color: Colors.white,
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ).show(context);
        } else {
          Flushbar(
            title: "Failed!",
            message: res2.apiMsg,
            icon: Icon(
              Icons.warning,
              size: 28,
              color: Colors.white,
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 1),
          ).show(context);
        }
      }
    });
    pr.load().hide();
  }

  Future httpGetDriver() async {
    MyHttpRequest request = new MyHttpRequest(context: context);
    bool validateConnection = await request.validateConnection();
    if (!validateConnection) {
      return null;
    }
    DriverSubmit res = new DriverSubmit(driverID: "0", driverName: "");
    DriverReturn res2 = await DriverController.getDriver(res);
    setState(() {
      _driverReturn = res2;
      _driverList.clear();
      for (int c = 0; c < _driverReturn.items.length; c++) {
        _driverList.add(DropDown(
            id: _driverReturn.items[c]['Driver_ID'].toString(),
            name: "${_driverReturn.items[c]['DriverName']}"));
      }
    });
  }

  Future httpGetDetailsContType() async {
    MyHttpRequest request = new MyHttpRequest(context: context);
    bool validateConnection = await request.validateConnection();
    if (!validateConnection) {
      return null;
    }

    DetailsContTypeSubmit res = new DetailsContTypeSubmit(
        deliverID: _selectedDeliverID.text,
        empID: session.userEmployeeID.toString(),
        batchNo: _selectedBatchNo.text);
    DetailsContTypeReturn res2 =
        await DetailsContTypeController.getDetailsContType(res);
    print("loading container from server >>>>> ${res2.apiMsg} ");
    setState(() {
      _detailsContTypeReturn = res2;
      if (_detailsContTypeReturn != null) {
        if (_detailsContTypeReturn.items.length > 0) {
          _isAllowedToShip = true;
        } else {
          _isAllowedToShip = false;
        }
      }
    });
  }

  Future httpGetWitness() async {
    MyHttpRequest request = new MyHttpRequest(context: context);
    bool validateConnection = await request.validateConnection();
    if (!validateConnection) {
      return null;
    }

    WitnessSubmit res = new WitnessSubmit(
        deliverID: _selectedDeliverID.text,
        empID: session.userEmployeeID.toString(),
        batchNo: _selectedBatchNo.text);
    WitnessReturn res2 = await WitnessController.getWitness(res);
    print(" deliverID: ${_selectedDeliverID.text}" +
        "empID: ${session.userEmployeeID.toString()}" +
        "batchNo: ${_selectedBatchNo.text}");
    print("loading witness from server >>>>> ${res2.apiMsg} ");
    setState(() {
      _witnessReturn = res2;
      if (_witnessReturn != null) {
        if (_witnessReturn.items.length > 0) {
          _withWitness =
              _witnessReturn.items[0]['isNoWitness'] == 1 ? false : true;
          witness.text = _witnessReturn.items[0]['Witness'];
          print("witness ${_witnessReturn.items[0]['Witness']}");
        }
      }
    });
  }

  Future httpUpdateWitness() async {
    MyHttpRequest request = new MyHttpRequest(context: context);
    bool validateConnection = await request.validateConnection();
    if (!validateConnection) {
      return null;
    }
    print("deliverID: ${_selectedDeliverID.text}" +
        "empID: ${session.userEmployeeID.toString()}" +
        "isNoWitness: ${_withWitness == true ? "0" : "1"}" +
        "witness: ${witness.text}" +
        "batchNo: ${_selectedBatchNo.text}");
    WitnessUpdateSubmit res = new WitnessUpdateSubmit(
        deliverID: _selectedDeliverID.text,
        empID: session.userEmployeeID.toString(),
        isNoWitness: _withWitness == true ? "0" : "1",
        witness: witness.text,
        batchNo: _selectedBatchNo.text);
    WitnessUpdateReturn res2 =
        await WitnessUpdateController.getWitnessUpdate(res);
    print("loading container from server >>>>> ${res2.apiMsg} ");
    setState(() {
      _witnessUpdateReturn = res2;
      if (_witnessUpdateReturn != null) {
        if (_witnessUpdateReturn.apiReturn > 0) {
          print(_witnessUpdateReturn);
        }
      }
    });
  }

  Future httpSaveScan(context) async {
    pr = new Loading(context);
    pr.load().show();
    MyHttpRequest request = new MyHttpRequest(context: context);
    bool validateConnection = await request.validateConnection();
    if (!validateConnection) {
      pr.load().hide();
      return false;
    }

    IssuingScanSubmit res = new IssuingScanSubmit(
        deliverID: _selectedDeliverID.text,
        barcode: _scanningBarcode.text,
        status: _scanningStatus.text,
        qty: _scanningQty.text,
        empID: session.userEmployeeID.toString());

    IssuingScanReturn res2 = await IssuingScanController.getIssuingScan(res);

    _issuingScanReturn = res2;
    if (res2 != null) { 
      if (res2.apiReturn >= 0) {
        httpGetIssuingScanned(int.parse(_scanningStatus.text));
        setState(() {
          this._scanningBarcode.text = "";
          this._scanningZone.text = "";
          this._scanningQty.text = "";
        });
        _responseEffect(1);
        Flushbar(
          title: "Successfully!",
          message: res2.apiMsg,
          icon: Icon(
            Icons.warning,
            size: 28,
            color: Colors.white,
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ).show(context);
        await Future.delayed(Duration(seconds: 1));
        if (_isContinueScanning && _isUpdating == false) {
          _scan(context);
        }
        setState(() {
          _isUpdating = false;
        });
        pr.load().hide();
        return true;
      } else {
        _responseEffect(0);
        Flushbar(
          title: "Failed!",
          message: res2.apiMsg,
          icon: Icon(
            Icons.warning,
            size: 28,
            color: Colors.white,
          ),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 1),
        ).show(context);
        Future.delayed(Duration(seconds: 1), () {
          _scanningFormDialog(context);
        });
        pr.load().hide();
        return false;
      }
    }
    pr.load().hide();
  }

  Future _scan(context) async {
    this._scanningBarcode.text = '';
    try {
      String barcode = await BarcodeScanner.scan();
      if (barcode != null) {
        setState(() {
          this._scanningBarcode.text = barcode;
          bool isDos = _scanningBarcode.text.toUpperCase().contains("DOS");
          if (isDos) {
            _scanningFormDialog(context);
          } else {
            httpSaveScan(context);
          }
        });
      }
    } on PlatformException catch (e) {
      print(e);
    }
  }

  void _responseEffect(int type) async {
    if (type == 0) {
      errorScanPlayer.play();
    } else {
      scanPlayer.play();
    }
    await Vibration.vibrate();
  }
}
