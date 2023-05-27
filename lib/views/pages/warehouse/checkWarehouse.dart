import 'package:barcode_scan/barcode_scan.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/services.dart';
import 'package:galaxy_warehouse/config/global.dart';
import 'package:galaxy_warehouse/controllers/completeController.dart';
import 'package:galaxy_warehouse/controllers/delDetContainerController.dart';
import 'package:galaxy_warehouse/controllers/delDetUpdateController.dart';
import 'package:galaxy_warehouse/controllers/deliverUpdateController.dart';
import 'package:galaxy_warehouse/controllers/scanController.dart';
import 'package:galaxy_warehouse/controllers/scanZoneController.dart';
import 'package:galaxy_warehouse/controllers/zoneController.dart';
import 'package:galaxy_warehouse/controllers/zoneBarcodeController.dart';
import 'package:galaxy_warehouse/libraries/AudioPlay.dart';
import 'package:galaxy_warehouse/libraries/MyHttpRequest.dart';
import 'package:galaxy_warehouse/libraries/loading.dart';
import 'package:galaxy_warehouse/models/Complete.dart';
import 'package:galaxy_warehouse/models/Delivery.dart';
import 'package:galaxy_warehouse/models/Zone.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:galaxy_warehouse/models/container.dart';
import 'package:galaxy_warehouse/models/delDetContainer.dart';
import 'package:galaxy_warehouse/models/delDetUpdate.dart';
import 'package:galaxy_warehouse/models/location.dart';
import 'package:galaxy_warehouse/models/scan.dart';
import 'package:galaxy_warehouse/models/scanZone.dart';
import 'package:galaxy_warehouse/models/zoneBarcode.dart';
import 'package:galaxy_warehouse/views/pages/issuing/checkIssuing.dart';
import 'package:galaxy_warehouse/views/pages/issuing/issuing.dart';
import 'package:galaxy_warehouse/views/pages/login/loginView.dart';
import 'package:galaxy_warehouse/views/pages/warehouse/warehouse.dart';
import 'package:group_radio_button/group_radio_button.dart';
import 'package:intl/intl.dart';
import 'package:galaxy_warehouse/config/session.dart' as session;
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:vibration/vibration.dart';
import 'package:dio/dio.dart';

class CheckWarehouseView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Delivery Scanner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CheckWarehousePage(),
    );
  }
}

const _kPages = <String, IconData>{
  'search': Icons.search,
  'detail': Icons.info,
  'container': Icons.dashboard,
};

class CheckWarehousePage extends StatefulWidget {
  const CheckWarehousePage({Key key}) : super(key: key);

  @override
  CheckWarehousePageState createState() => CheckWarehousePageState();
}

class CheckWarehousePageState extends State<CheckWarehousePage>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _wcScaffoldKey = GlobalKey<ScaffoldState>();
  AudioPlay scanPlayer = new AudioPlay();
  AudioPlay errorScanPlayer = new AudioPlay();
  String mp3Uri;

  Loading pr;
  final pageTitle = TextEditingController();

  // static ConvexAppBarState appBarKey = new  ConvexAppBarState();

  TabStyle _tabStyle = TabStyle.reactCircle;
  static TabController tabController;
  TabController _defController;

  ZoneReturn _zoneReturn;
  ScanZoneReturn _scanZoneReturn;
  DelDetUpdateReturn _delDetUpdateReturn;
  DeliveryReturn _deliveryReturn;
  LocationReturn _locationReturn;
  List<DropdownMenuItem> _locationList = [];
  DelDetContainerReturn _delDetContainerReturn;
  List<dynamic> dosContents = [];

  ZoneBarcodeReturn _zoneBarcodeReturn;
  List httpSearchZoneBarcodeLIst = [];
  CompleteReturn _completeReturn;
  final _wSearchFormKey = GlobalKey<FormState>();
  final _cwScanningFormKey = GlobalKey<FormState>();
  final _wSearchDate = TextEditingController();

  int _searchLocationID;
  final _searchZone = TextEditingController();
  final _searchBarcode = TextEditingController();

  final _selectedDeliverID = TextEditingController();
  final _selectedLocationCode = TextEditingController();
  final _selectedLocation = TextEditingController();
  final _selectedLocationID = TextEditingController();
  final _selectedDate = TextEditingController();
  final _selectedControlNo = TextEditingController();
  final _selectedTotalContainer = TextEditingController();
  final _selectedScannedQty = TextEditingController();
  final _selectedTotalReqQty = TextEditingController();
  final _selectedZone = TextEditingController();

  final _scanningBarcode = TextEditingController();
  final _scanningDeliverDetailID = TextEditingController();
  final _scanningQty = TextEditingController();
  final _scanningZone = TextEditingController();
  final _scanningTypeID = TextEditingController();
  final _scanningRemarks = TextEditingController();

  List<dynamic> _isChecked = [];
  bool _isUpdating = false;
  bool _isContinueScanning = false;
  bool _isDisableQty = false;
  DateTime _currentDate = DateTime.now();
  bool _isCompleteWarehouse = false;
  bool hasUnchecked = false;

  var focusNode = FocusNode();
  @override
  void initState() {
    super.initState();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    pageTitle.text = "SEARCH DATE & LOCATION";
    httpGetLocation();
    tabController = new TabController(
      vsync: this,
      length: _kPages.length,
    );

    _scanningBarcode.addListener(() {
      setState(() {
        if (_scanningBarcode.text.length > 2) {
          bool isDos = _scanningBarcode.text.toUpperCase().contains("DOS");
          if (isDos ||
              _scanningBarcode.text == 'ALLOCATION' ||
              _scanningBarcode.text == 'FAS' ||
              _scanningBarcode.text == 'PROMO' ||
              _scanningBarcode.text == 'SABA') {
            _isDisableQty = false;
            _scanningQty.text = "";
            _scanningTypeID.text = "2";
          } else {
            _scanningTypeID.text = "1";
            _isDisableQty = true;
            _scanningQty.text = "1";
          }
        } else {
          _scanningTypeID.text = "1";
        }
      });
    });

    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        _scanningQty.selection = TextSelection(
            baseOffset: 0, extentOffset: _scanningQty.text.length);
      }
    });

    tabController.addListener(() {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
      setState(() {
        if (_isUpdating == false) {
          this._scanningBarcode.text = "";
          this._scanningZone.text = "";
          this._scanningQty.text = "";
          this._scanningTypeID.text = "";
          this._scanningRemarks.text = "";
          _isContinueScanning = true;
        } else {
          _isContinueScanning = false;
        }
        switch (tabController.index) {
          case 0:
            {
              pageTitle.text = "SEARCH DATE & LOCATION";
            }
            break;
          case 1:
            {
              pageTitle.text = "DELIVERY DETAILS";

              if (_selectedDeliverID.text != "") {}
            }
            break;
          case 2:
            {
              pageTitle.text = "CONTAINER LIST";
              if (_selectedDeliverID.text != "") {
                httpGetDelDetContainer();
              }
            }
            break;
          case 3:
            {
              pageTitle.text = "SCANNED BARCODE LIST";
              if (_selectedDeliverID.text != "") {
                httpGetZoneBarcode();
                httpSearchZoneBarcode(_selectedZone.text);
              }
            }
            break;
          case 4:
            {
              pageTitle.text = "SCANNING FORM";
              if (_selectedDeliverID.text != "" && _isUpdating == false) {
                _scan(context);
              }

              if (_isCompleteWarehouse == true) {
                SystemChannels.textInput.invokeMethod('TextInput.hide');
              }
            }
            break;
        }
        print("Current Page is >>>>>> ${pageTitle.text}");
      });
      if (tabController.index != 3 && tabController.index != 4) {
        _selectedZone.text = "";
      }
      if (_selectedDeliverID.text == "" && tabController.index != 0) {
        GlobalDialog(
                context: context,
                title: "No Record",
                message: "Please search delivery first!",
                dismiss: 60)
            .showErrorDialog();
      }
    });

    scanPlayer.load(soundsPath + scanAudioFile, scanAudioFile);
    errorScanPlayer.load(soundsPath + scanErrorAudioFile, scanErrorAudioFile);
  }

  @override
  Widget build(BuildContext context) {
    final drawerHeader = UserAccountsDrawerHeader(
      decoration: BoxDecoration(
        color: Colors.blueAccent,
      ),
      currentAccountPicture: Icon(
        Icons.verified_user,
        color: Colors.white,
        size: 50.0,
      ),
      accountName: session.userEmployeeID == 0
          ? Text("")
          : Text(
              '${session.userLocationCode} - ${session.userLocation}',
              style: TextStyle(fontSize: 12, color: Colors.white),
            ),
      accountEmail: session.userEmployeeID == 0
          ? Text("")
          : Text(
              session.userFullName,
              style: TextStyle(fontSize: 12, color: Colors.white),
            ),
    );

    final drawerItems = ListView(
      children: <Widget>[
        Container(height: 150, child: drawerHeader),
        ListTile(
            leading: Icon(
              Icons.done_all,
              color: Colors.blueAccent,
            ),
            title: Text(
              'Warehouse Checking',
              style: TextStyle(
                  color: Colors.blueAccent, fontWeight: FontWeight.bold),
            ),
            onTap: () async {
              Navigator.of(context).pop();
            }),
        ListTile(
            title: Text(
              'Logout',
              style: TextStyle(color: Colors.blueAccent),
            ),
            leading: Icon(Icons.exit_to_app, color: Colors.blueAccent),
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
      length: 5,
      initialIndex: 0,
      child: Scaffold(
        key: _wcScaffoldKey,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.blueAccent,
          title: Text(
            _selectedDate.text == "" || _selectedLocationID.text == ""
                ? "No deliver found!"
                : "${_selectedLocation.text} - ${_selectedDate.text}",
            style: new TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                pageTitle.text,
                style: new TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(),
            Expanded(
              child: TabBarView(
                physics: NeverScrollableScrollPhysics(),
                controller: tabController,
                children: [tabSearch(), tabDetail(), tabZone()],
              ),
            ),
          ],
        ),
        bottomNavigationBar: ConvexAppBar(
          initialActiveIndex: 0,
          controller: tabController,
          backgroundColor: Colors.blue,
          style: TabStyle.reactCircle,
          items: <TabItem>[
            for (final entry in _kPages.entries)
              TabItem(icon: entry.value, title: entry.key),
          ],
          onTap: (int i) {
            setState(() {
              _isUpdating = false;
              _selectedZone.text = "";
              if (i == 1) {
                httpGetDelivery();
              }
            });
          },
        ),
        drawer: Drawer(
          child: drawerItems,
        ),
      ),
    );
  }

  Future getDOSContent(e) async {
    print("deliverDetailID" + _scanningDeliverDetailID.text);
    print("API SIGNATURE : $apiSignatureFolder");
    FormData formData = FormData.fromMap({
      "deliverDetailID": _scanningDeliverDetailID.text,
      "userEmpID": session.userEmployeeID,
    });

    var response = await Dio().post(
      apiDOSContent,
      data: formData,
      onSendProgress: (int sent, int total) {
        print("$sent $total");
      },
    ); 
    setState(() {
      dosContents = response.data['items'];
    });
    if (_scanningBarcode.text .contains(new RegExp('dos', caseSensitive: false))) 
    {  
      _containerFormDialog(_delDetContainerReturn.items.indexOf(e),dosContents);
    } 
  }

  Future _scan(context) async {
    if (_isCompleteWarehouse == true) {
      return false;
    }

    if (_scanningBarcode.text
            .contains(new RegExp('dos', caseSensitive: false)) ||
        _scanningBarcode.text == 'ALLOCATION' ||
        _scanningBarcode.text == 'FAS' ||
        _scanningBarcode.text == 'PROMO' ||
        _scanningBarcode.text == 'SABA') {
      _isDisableQty = false;
      _scanningQty.text = "";
      _scanningTypeID.text = "2";
      FocusScope.of(context).requestFocus(focusNode);
    }
  }

  Future selectDate(BuildContext context) async {
    final DateTime pickedDate = await showDatePicker(
        context: context,
        initialDate: _currentDate,
        firstDate: DateTime(2020),
        lastDate: new DateTime(
            _currentDate.year, _currentDate.month + 1, _currentDate.day));
    if (pickedDate != null && pickedDate != _currentDate)
      setState(() {
        _currentDate = pickedDate;
        _wSearchDate.text = _currentDate.toString().substring(0, 10);
      });
  }

  void httpSearchZoneBarcode(String query) {
    ZoneBarcodeReturn dummySearchList = ZoneBarcodeReturn();
    dummySearchList = _zoneBarcodeReturn;
    if (query.isNotEmpty) {
      List dummyListData = [];
      dummySearchList.items.forEach((item) {
        if (item['zone'].contains(query.toUpperCase())) {
          dummyListData.add(item);
        }
      });
      setState(() {
        httpSearchZoneBarcodeLIst.clear();
        httpSearchZoneBarcodeLIst.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        httpSearchZoneBarcodeLIst.clear();
        httpSearchZoneBarcodeLIst.addAll(_zoneBarcodeReturn.items);
      });
    }
  }

  Future<bool> _containerFormDialog(containerIndex,_dosContents) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: ConstrainedBox(
                    constraints: new BoxConstraints(
                      minHeight: 300,
                      maxHeight: MediaQuery.of(context).size.height - 50,
                    ),
                    child: AbsorbPointer(
                      absorbing: _isCompleteWarehouse,
                      child: Form(
                        key: _cwScanningFormKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            TextFormField(
                              controller: _scanningBarcode,
                              keyboardType: TextInputType.text,
                              readOnly: true,
                              autofocus: false,
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
                              keyboardType: TextInputType.number,
                              focusNode: focusNode,
                              autofocus: !_isCompleteWarehouse,
                              readOnly: false,
                              inputFormatters: <TextInputFormatter>[
                                WhitelistingTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(4),
                              ],
                              decoration:
                                  InputDecoration(labelText: 'Quantity'),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Quantity is required!. ';
                                }
                                return null;
                              },
                            ),
                            Row(
                              children: <Widget>[
                                RadioButton(
                                  description: _scanningBarcode.text ==
                                              'ALLOCATION' ||
                                          _scanningBarcode.text == 'FAS' ||
                                          _scanningBarcode.text == 'PROMO' ||
                                          _scanningBarcode.text == 'SABA'
                                      ? "Crates"
                                      : "Container",
                                  value: "1",
                                  groupValue: _scanningTypeID.text,
                                  onChanged: (value) => setState(
                                    () => _scanningTypeID.text = value,
                                  ),
                                  textPosition: RadioButtonTextPosition.right,
                                ),
                                RadioButton(
                                  description: "Box",
                                  value: "2",
                                  groupValue: _scanningTypeID.text,
                                  onChanged: (value) => setState(
                                    () => _scanningTypeID.text = value,
                                  ),
                                  textPosition: RadioButtonTextPosition.right,
                                ),
                              ],
                            ),
                            TextFormField(
                              controller: _scanningRemarks,
                              keyboardType: TextInputType.text,
                              autofocus: !_isCompleteWarehouse,
                              maxLines: 2,
                              readOnly: false,
                              inputFormatters: <TextInputFormatter>[
                                LengthLimitingTextInputFormatter(300),
                              ],
                              onTap: () {},
                              decoration: InputDecoration(labelText: 'Remarks'),
                            ),
                            _scanningBarcode.text.toUpperCase().contains("DOS")
                                ? Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 10, 0, 10),
                                    child: Column(
                                      children: [
                                        Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text("Content : ",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold))),
                                        Align(
                                            alignment: Alignment.topLeft,
                                            child: dosContents.length == 0
                                                ? Center(
                                                    child: Text(
                                                        "No Record found!"),
                                                  )
                                                : _dosContentTable(_dosContents))
                                      ],
                                    ),
                                  )
                                : Text("")
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: Text('Close'),
              ),
              FlatButton(
                onPressed: _isCompleteWarehouse == true
                    ? null
                    : () {
                        if (_cwScanningFormKey.currentState.validate()) {
                          Navigator.of(context).pop(true);
                          httpSaveScan(
                              _wcScaffoldKey.currentContext, containerIndex);
                        }
                      },
                child: Text('Save'),
              ),
            ],
          );
        });
  }

  Widget tabSearch() {
    return Container(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            Container(
              width: double.maxFinite,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Form(
                    key: _wSearchFormKey,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                          child: TextFormField(
                            controller: _wSearchDate,
                            keyboardType: TextInputType.text,
                            readOnly: true,
                            inputFormatters: <TextInputFormatter>[
                              WhitelistingTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            onTap: () => selectDate(context),
                            decoration: InputDecoration(labelText: 'Date'),
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Date is required!. ';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text("Location"),
                  _locationReturn == null
                      ? Text(
                          "Loading..",
                          style: TextStyle(color: Colors.blueAccent),
                        )
                      : SearchableDropdown(
                          items: _locationReturn.items.map((i) {
                            return (DropdownMenuItem(
                              child: Text(
                                  "${i['locationCode']} - ${i['location']}"),
                              value: i['locationID'],
                            ));
                          }).toList(),
                          value: _searchLocationID,
                          isExpanded: true,
                          hint: new Text('Location'),
                          searchHint: new Text(
                            'Location',
                            style: new TextStyle(fontSize: 20),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchLocationID = value;
                              print("SEARCH VALUE IS >>>> $value");
                            });
                          },
                          searchFn: (String keyword, items) {
                            return searchFN(keyword, items);
                          },
                        ),
                ],
              ),
            ),
            new SizedBox(
              height: 10.0,
            ),
            new ButtonBar(
              alignment: MainAxisAlignment.center,
              children: <Widget>[
                new RaisedButton(
                  onPressed:
                      _searchLocationID == null || _wSearchDate.text == ""
                          ? null
                          : () async {
                              httpGetDelivery();
                            },
                  child: Text("Search to Proceed"),
                  color: Colors.blue,
                ),
              ],
            ),
          ],
        ),
      ),
    );
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

  Widget tabDetail() {
    return Container(
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                new Flexible(
                  child: TextFormField(
                    controller: _selectedControlNo,
                    keyboardType: TextInputType.text,
                    readOnly: true,
                    decoration: InputDecoration(labelText: 'Control No.'),
                  ),
                ),
                SizedBox(width: 10),
                new Flexible(
                  child: TextFormField(
                    controller: _selectedLocation,
                    keyboardType: TextInputType.text,
                    readOnly: true,
                    decoration: InputDecoration(labelText: 'Location'),
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                new Flexible(
                  child: TextFormField(
                    controller: _selectedDate,
                    keyboardType: TextInputType.text,
                    readOnly: true,
                    decoration: InputDecoration(labelText: 'Date'),
                  ),
                ),
                SizedBox(width: 10),
                new Flexible(
                  child: TextFormField(
                    controller: _selectedTotalContainer,
                    keyboardType: TextInputType.text,
                    readOnly: true,
                    decoration: InputDecoration(labelText: 'Total Container'),
                  ),
                ),
                SizedBox(width: 10),
                new Flexible(
                  child: TextFormField(
                    controller: _selectedScannedQty,
                    keyboardType: TextInputType.text,
                    readOnly: true,
                    decoration: InputDecoration(labelText: 'Total Scanned.'),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: new CircularPercentIndicator(
                header: new Text(
                  "Scanning Percentage",
                  style: new TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.bold),
                ),
                radius: 150.0,
                lineWidth: 18.0,
                percent: _selectedDeliverID.text == ''
                    ? 0
                    : (double.parse(_selectedTotalReqQty.text == ""
                                    ? 0
                                    : _selectedTotalReqQty.text) >
                                double.parse(_selectedTotalContainer.text)) ==
                            true
                        ? 1
                        : (double.parse(_selectedTotalReqQty.text == ""
                                ? 0
                                : _selectedTotalReqQty.text) /
                            double.parse(_selectedTotalContainer.text)),
                center: new Text(
                    "${_selectedDeliverID.text == '' || _selectedTotalReqQty.text == '' ? 0.0 : ((double.parse(_selectedTotalReqQty.text) / double.parse(_selectedTotalContainer.text)) * 100).toInt()}%"),
                progressColor: Colors.green,
                backgroundColor: Colors.grey,
                footer: new Text(
                    "${_selectedTotalReqQty.text} out of ${_selectedTotalContainer.text}"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget tabZone() {
    return Container(
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
              child: Row(
                children: <Widget>[
                  // Flexible(
                  //   child: TextField(
                  //     decoration: InputDecoration(
                  //         labelText: "Search Barcode",
                  //         hintText: "Search Barcode",
                  //         prefixIcon: Icon(Icons.search),
                  //         contentPadding:
                  //             const EdgeInsets.symmetric(vertical: 1.0),
                  //         border: OutlineInputBorder(
                  //             borderRadius:
                  //                 BorderRadius.all(Radius.circular(25.0)))),
                  //     onChanged: (value) {},
                  //   ),
                  // ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Text(
                          "${_selectedTotalContainer.text}",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text("Total Container"),
                      ],
                    ),
                    SizedBox(
                      width: 50,
                    ),
                    Column(
                      children: <Widget>[
                        Text(
                          "${_selectedScannedQty.text}",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text("Total Scanned."),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            _delDetContainerReturn == null
                ? Text('No record found!')
                : RefreshIndicator(
                    onRefresh: () async {
                      if (_selectedDeliverID.text.toString() != "") {
                        httpGetDelDetContainer();
                      }
                    },
                    child: SizedBox(
                      height: (MediaQuery.of(context).size.height - 340),
                      child: ListView(children: <Widget>[
                        _containerTable(),
                      ]),
                    )),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: RaisedButton(
                onPressed: (_selectedDeliverID.text == '' ||
                            _selectedTotalReqQty.text == '' ||
                            ((double.parse(_selectedTotalReqQty.text) /
                                            double.parse(
                                                _selectedTotalContainer.text)) *
                                        100)
                                    .toInt() <
                                90 ||
                            _isCompleteWarehouse == true) ||
                        (hasUnchecked == true)
                    ? null
                    : () {
                        _confirmSetComplete();
                      },
                child: Text(
                  "Set as Complete",
                  style: TextStyle(color: Colors.white70),
                ),
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _confirmSetComplete() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Are you sure?'),
        content:
            Text('Do you want to set as complete for scanning this delivery?'),
        actions: <Widget>[
          FlatButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('No'),
          ),
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop(true);
              httpSetAsComplete();
            },
            child: Text('Yes'),
          ),
        ],
      ),
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
    rows.addAll(_delDetContainerReturn.items);
    rows.add({
      "container": "",
      "zone": "",
      "scannedQty": "",
      "loadedQty": "",
      "unloadedQty": "",
      "offloadedQty": ""
    });
    return DataTable(
      showCheckboxColumn: true,
      columnSpacing: 6,
      columns: [
        DataColumn(label: Text('')),
        DataColumn(label: Text('Container')),
        DataColumn(label: Text('Zone')),
        DataColumn(label: Text('Type')),
        DataColumn(label: Text('WH')),
        DataColumn(label: Text('LD')),
        DataColumn(label: Text('UL')),
        DataColumn(label: Text('OL')),
      ],
      rows: _delDetContainerReturn.items.map((e) {
        count++;
        //if (count < rows.length) {
        whTotal += e["scannedQty"];
        ldTotal += e["loadedQty"];
        ulTotal += e["unloadedQty"];
        olTotal += e["offloadedQty"];
        return DataRow(
          cells: <DataCell>[
            DataCell(
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                child: Container(
                  width: 20,
                  child: Align(
                    alignment: Alignment.center,
                    child: Checkbox(
                      value: e["isChecked"] == 1 ? true : false,
                      onChanged: (bool value) {
                        setState(() {
                          if (e["zones"] == '') {
                            _scanningBarcode.text = "${e["container"]}";
                          } else {
                            _scanningBarcode.text =
                                "${e["container"]}-${_selectedLocationCode.text}";
                          }
                          _scanningDeliverDetailID.text =
                              "${e["deliverDetail_ID"]}";
                          _scanningTypeID.text =
                              e['containerType_ID'].toString();
                          _scanningRemarks.text =
                              "${e["remWH"] == null ? '' : e["remWH"]}";

                          if ((_scanningBarcode.text.contains(new RegExp('dos',
                                      caseSensitive: false)) ||
                                  e["zones"] == '') &&
                              e["isChecked"] != 1) {
                            if (e["isChecked"] == 1) {
                              _scanningQty.text = "0";
                            } else {
                              _scanningQty.text =
                                  "${e["scannedQty"] == 0 ? '' : e["scannedQty"]}";
                            }
                             if (_scanningBarcode.text .contains(new RegExp('dos', caseSensitive: false))) { 
                              getDOSContent(e);
                            }
                            else
                            {
                              _containerFormDialog(_delDetContainerReturn.items.indexOf(e),dosContents);
                            }
                          } else {
                            if (e["isChecked"] == 1) {
                              _scanningQty.text = "0";
                            } else {
                              _scanningQty.text = "1";
                            }
                            httpSaveScan(context,
                                _delDetContainerReturn.items.indexOf(e));
                          }
                        });
                      },
                      checkColor: Colors.white,
                      activeColor: Colors.green,
                    ),
                  ),
                ),
              ),
            ),
            DataCell(
                Text(
                  "${e["container"]}",
                  style: new TextStyle(
                      color: Colors.blueAccent, fontWeight: FontWeight.bold),
                ), onTap: () {
              if (e["container"] == 'ALLOCATION' ||
                  e["container"] == 'FAS' ||
                  e["container"] == 'PROMO' ||
                  e["container"] == 'SABA') {
                _scanningBarcode.text = "${e["container"]}";
              } else {
                _scanningBarcode.text =
                    "${e["container"]}-${_selectedLocationCode.text}";
              }
              this._scanningDeliverDetailID.text = "${e["deliverDetail_ID"]}";
              this._scanningQty.text = e["scannedQty"].toString();
              this._scanningTypeID.text = e["containerType_ID"].toString();
              _scanningRemarks.text = "${e["remWH"] == null ? '' : e["remWH"]}";
              if (_scanningBarcode.text
                      .contains(new RegExp('dos', caseSensitive: false)) ||
                  _scanningBarcode.text == 'ALLOCATION' ||
                  _scanningBarcode.text == 'FAS' ||
                  _scanningBarcode.text == 'PROMO' ||
                  _scanningBarcode.text == 'SABA') {
                _scanningQty.text =
                    "${e["scannedQty"] == 0 ? '' : e["scannedQty"]}";
              } else {
                _scanningQty.text = "1";
              }
              if (_scanningBarcode.text .contains(new RegExp('dos', caseSensitive: false))) { 
                getDOSContent(e);
              }
              else
              {
                _containerFormDialog(_delDetContainerReturn.items.indexOf(e),dosContents);
              }
            }),
            DataCell(Text("${e["zones"]}")),
            DataCell(Center(
                child: Container(
              color:
                  e["containerType_ID"] == 1 ? Colors.cyan : Colors.pinkAccent,
              child: Text(" ${e["contType"]} ",
                  style: TextStyle(color: Colors.white)),
            ))),
            DataCell(Center(child: Text("${e["scannedQty"]}"))),
            DataCell(Center(child: Text("${e["loadedQty"]}"))),
            DataCell(Center(child: Text("${e["unloadedQty"]}"))),
            DataCell(Center(child: Text("${e["offloadedQty"]}"))),
          ],
        );
      }).toList(),
    );
  }

   Widget _dosContentTable(_dosContents) {
    return DataTable(
      columnSpacing: 10,
      columns: [
        DataColumn(label: Text('Qty')),
        DataColumn(label: Text('Description')),
      ],
      rows: _dosContents.map<DataRow>((e) {
        //if (count < rows.length) {
        return DataRow(
          cells: <DataCell>[
            DataCell(Text("${e["pluQty"]}")),
            DataCell(Text("${e["pluDesc"]}"))
          ],
        );
      }).toList(),
    );
  }
  Future httpSetAsComplete() async {
    pr = new Loading(context);
    pr.load().show();
    MyHttpRequest request = new MyHttpRequest(context: context);
    bool validateConnection = await request.validateConnection();
    if (!validateConnection) {
      pr.load().hide();
      return null;
    }

    CompleteSubmit res = new CompleteSubmit(
        deliverID: _selectedDeliverID.text,
        scannedBy: session.userEmployeeID.toString(),
        cancelBy: "0",
        empID: session.userEmployeeID.toString());
    CompleteReturn res2 = await CompleteController.getComplete(res);

    setState(() {
      _completeReturn = res2;
      if (_completeReturn != null) {
        if (_completeReturn.apiReturn >= 0) {
          _isCompleteWarehouse = true;
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

  Future httpSaveScan(context, recordIndex) async {
    MyHttpRequest request = new MyHttpRequest(context: context);
    bool validateConnection = await request.validateConnection();
    if (!validateConnection) {
      return null;
    }
    DelDetUpdateSubmit res = new DelDetUpdateSubmit(
        deliverID: _selectedDeliverID.text,
        ddID: _scanningDeliverDetailID.text,
        barcode: _scanningBarcode.text,
        typeID: _scanningTypeID.text,
        qty: _scanningQty.text,
        status: '0',
        empID: session.userEmployeeID.toString(),
        remarks: _scanningRemarks.text);
    DelDetUpdateReturn res2 = await DelDetUpdateController.getDelDetUpdate(res);
    _delDetUpdateReturn = res2;
    if (res2 != null) {
      print("getting scanning result from server>>>>>>${res2.apiMsg}");
      if (res2.apiReturn >= 0) {
        httpGetDelDetContainer();
        httpGetDeliveryRefresh();
        return true;
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
        return false;
      }
    }
  }

  Future httpGetDelDetContainer() async {
    pr = new Loading(context);
    pr.load().show();
    MyHttpRequest request = new MyHttpRequest(context: context);
    bool validateConnection = await request.validateConnection();
    if (!validateConnection) {
      pr.load().hide();
      return null;
    }
    print("deliverID: ${_selectedDeliverID.text}");
    DelDetContainerSubmit res = new DelDetContainerSubmit(
        deliverID: _selectedDeliverID.text,
        status: '0',
        empID: session.userEmployeeID.toString());
    DelDetContainerReturn res2 =
        await DelDetContainerController.getDelDetContainer(res);
    print("loading container from server >>>>> ${res2.apiMsg} ");
    setState(() {
      _delDetContainerReturn = res2;
      if (_delDetContainerReturn != null) {
        hasUnchecked = false;
        if (_delDetContainerReturn.items[0]["isChecked"] != 1 &&
            _delDetContainerReturn.items[0]['detailType_ID'] == 1) {
          hasUnchecked = true;
        }
      }
    });
    pr.load().hide();
  }

  Future httpGetDelivery() async {
    pr = new Loading(context);
    pr.load().show();
    MyHttpRequest request = new MyHttpRequest(context: context);
    bool validateConnection = await request.validateConnection();
    if (!validateConnection) {
      pr.load().hide();
      return null;
    }

    DeliverySubmit res = new DeliverySubmit(
        pickingDate: _wSearchDate.text,
        locID: _searchLocationID.toString(),
        empID: session.userEmployeeID.toString());

    DeliveryReturn res2 = await ZoneController.getDelivery(res);

    setState(() {
      _deliveryReturn = res2;
      _selectedControlNo.text = "";
      _selectedLocationCode.text = "";
      _selectedLocation.text = "";
      _selectedLocationID.text = "";
      _selectedDate.text = "";
      _selectedTotalContainer.text = "0";
      _selectedScannedQty.text = "0";
      _selectedTotalReqQty.text = "0";
      _isCompleteWarehouse = false;
      _zoneReturn = null;
      if (_deliveryReturn != null) {
        if (_deliveryReturn.items.length > 0) {
          _selectedDeliverID.text = _deliveryReturn.items[0]['deliverID'];
          _selectedControlNo.text = _deliveryReturn.items[0]['controlNo'];
          _selectedLocationCode.text =
              "${_deliveryReturn.items[0]['locationCode']}";
          _selectedLocation.text =
              "${_deliveryReturn.items[0]['locationCode']} - ${_deliveryReturn.items[0]['location']}";
          _selectedLocationID.text =
              _deliveryReturn.items[0]['locationID'].toString();
          _selectedDate.text = _deliveryReturn.items[0]['pickDate'];
          _selectedTotalContainer.text =
              _deliveryReturn.items[0]['totalContainer'].toString();
          _selectedScannedQty.text =
              _deliveryReturn.items[0]['totalScannedQty'].toString();
          _selectedTotalReqQty.text =
              _deliveryReturn.items[0]['totalReqQty'].toString();
          _isCompleteWarehouse =
              _deliveryReturn.items[0]['scannedDate'] != null ? true : false;
          pr.load().hide(); 
          httpGetZone(); 
        }
        else {
          Flushbar(
            title: "Error!",
            message: "No delivery found!.",
            icon: Icon(
              Icons.warning,
              size: 28,
              color: Colors.white,
            ),
            backgroundColor: Colors.orangeAccent,
            duration: Duration(seconds: 1),
          ).show(context);
        }
      }
      else
      {
         Flushbar(
            title: "Error!",
            message: "No delivery found!.",
            icon: Icon(
              Icons.warning,
              size: 28,
              color: Colors.white,
            ),
            backgroundColor: Colors.orangeAccent,
            duration: Duration(seconds: 1),
          ).show(context);
      }
    });
    pr.load().hide();
  }

  Future httpGetDeliveryRefresh() async {
    MyHttpRequest request = new MyHttpRequest(context: context);
    bool validateConnection = await request.validateConnection();
    if (!validateConnection) {
      return null;
    }
    DeliverySubmit res = new DeliverySubmit(
        pickingDate: _wSearchDate.text,
        locID: _searchLocationID.toString(),
        empID: session.userEmployeeID.toString());

    DeliveryReturn res2 = await ZoneController.getDelivery(res);
    setState(() {
      _deliveryReturn = res2;
      if (_deliveryReturn != null) {
        if (_deliveryReturn.items.length > 0) {
          _selectedTotalContainer.text =
              _deliveryReturn.items[0]['totalContainer'].toString();
          _selectedScannedQty.text =
              _deliveryReturn.items[0]['totalScannedQty'].toString();
          _selectedTotalReqQty.text =
              _deliveryReturn.items[0]['totalReqQty'].toString();
        }
      }
    });
  }

  Future httpGetZone() async {
    MyHttpRequest request = new MyHttpRequest(context: context);
    bool validateConnection = await request.validateConnection();
    if (!validateConnection) {
      return null;
    }

    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String dateNow = formatter.format(now);
    try
    {
      
    ZoneSubmit res = new ZoneSubmit(
        deliverID: _selectedDeliverID.text.toString(),
        empID: session.userEmployeeID.toString());
    ZoneReturn res2 = await ZoneController.getZone(res);

    setState(() {
      _zoneReturn = res2;
    });
         tabController.animateTo(1, duration: Duration(milliseconds: 1));
    }
    catch(e)
    {
      Flushbar(
            title: "Error!",
            message: "durring getting zone!.",
            icon: Icon(
              Icons.warning,
              size: 28,
              color: Colors.white,
            ),
            backgroundColor: Colors.orangeAccent,
            duration: Duration(seconds: 1),
          ).show(context);
    }
  }

  Future httpGetZoneBarcode() async {
    MyHttpRequest request = new MyHttpRequest(context: context);
    bool validateConnection = await request.validateConnection();
    if (!validateConnection) {
      return null;
    }
    print("deliverID:${_selectedDeliverID.text.toString()}," +
        "status: 0," +
        "zone:," +
        "empID: ${session.userEmployeeID.toString()}");
    ZoneBarcodeSubmit res = new ZoneBarcodeSubmit(
        deliverID: _selectedDeliverID.text.toString(),
        status: "0",
        zone: "",
        empID: session.userEmployeeID.toString());
    ZoneBarcodeReturn res2 = await ZoneBarcodeController.getZoneBarcode(res);
    setState(() {
      _zoneBarcodeReturn = res2;
      httpSearchZoneBarcode(_selectedZone.text);
    });
  }

  Future httpGetLocation() async {
    MyHttpRequest request = new MyHttpRequest(context: context);
    bool validateConnection = await request.validateConnection();
    if (!validateConnection) {
      return null;
    }

    LocationSubmit res =
        new LocationSubmit(locID: '0', locCode: '', location: '');
    LocationReturn res2 = await ZoneController.getLocation(res);
    print("loading location from server >>>>> ${res2.apiMsg} ");
    setState(() {
      _locationReturn = res2;
    });
  }

  Future httpScanZone() async {
    pr = new Loading(context);
    pr.load().show();
    MyHttpRequest request = new MyHttpRequest(context: context);
    bool validateConnection = await request.validateConnection();
    if (!validateConnection) {
      pr.load().hide();
      return null;
    }
    setState(() {
      this._scanningZone.text = "";
    });
    print("pickingDate: ${_selectedDate.text}" +
        "locID: ${_selectedLocationID.text}," +
        "barcode: ${_scanningBarcode.text}," +
        "empID: ${session.userEmployeeID.toString()}");
    ScanZoneSubmit res = new ScanZoneSubmit(
        pickingDate: _selectedDate.text,
        locID: _selectedLocationID.text,
        barcode: _scanningBarcode.text,
        empID: session.userEmployeeID.toString());
    ScanZoneReturn res2 = await ScanZoneController.getScanZone(res);
    setState(() {
      _scanZoneReturn = res2;
      bool isFailed = true;
      String failedMsg = 'Failed to get zone!';
      if (res2 != null) {
        failedMsg = res2.apiMsg;
        if (res2.apiReturn >= 0) {
          isFailed = false;
          print(
              "getting scanned zone from server>>>>>>${res2.items[0]['Zones']}");
          setState(() {
            this._scanningZone.text = res2.items[0]['Zones'];
            this._scanningRemarks.text = res2.items[0]['Remarks'];
          });
          pr.load().hide();
          return true;
        }
        pr.load().hide();
        _scanningBarcode.text = "";
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
          duration: Duration(seconds: 3),
        ).show(context);
        return false;
      }

      if (isFailed) {
        Flushbar(
          title: "Failed!",
          message: failedMsg,
          icon: Icon(
            Icons.warning,
            size: 28,
            color: Colors.white,
          ),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 1),
        ).show(context);
      }
      pr.load().hide();
      return false;
    });
    pr.load().hide();
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
