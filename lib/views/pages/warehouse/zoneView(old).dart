import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:galaxy_warehouse/controllers/zoneController.dart';
import 'package:galaxy_warehouse/libraries/MyHttpRequest.dart';
import 'package:galaxy_warehouse/models/Delivery.dart';
import 'package:galaxy_warehouse/models/Zone.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:galaxy_warehouse/models/location.dart';
import 'package:galaxy_warehouse/views/pages/login/loginView.dart';
import 'package:intl/intl.dart';
import 'package:galaxy_warehouse/config/session.dart' as session;

class ZonePage extends StatefulWidget {
  @override
  _ZonePageState createState() => _ZonePageState();
}

class _ZonePageState extends State {
  ZoneReturn _zoneList;
  DeliveryReturn _deliveryList;
  LocationReturn _locationList;
  int _selectedIndexLocation;
  final _searchFormKey = GlobalKey<FormState>();
  final _searchDate = TextEditingController();
  final _searchLocation = TextEditingController();
  
  final _selectedDeliverID = TextEditingController();
  final _selectedLocation = TextEditingController();
  final _selectedDate = TextEditingController();
  final _selectedControlNo = TextEditingController();
  final _selectedTotalContainer = TextEditingController();
  final _selectedRemarks = TextEditingController();

   final _scanningQty = TextEditingController();
    final _scanningBarcode = TextEditingController();
    final _scanningTypeID = TextEditingController();

  DateTime _currentDate = DateTime.now();
  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  @override
  Widget build(BuildContext context) {
    final drawerHeader = UserAccountsDrawerHeader(
      accountName:
          Text('[${session.userLocationCode}] ${session.userLocation}'),
      accountEmail: Text(session.userFullName),
      currentAccountPicture: CircleAvatar(
        child: FlutterLogo(size: 42.0),
        backgroundColor: Colors.white,
      ),
    );

    final drawerItems = ListView(
      children: <Widget>[
        drawerHeader,
        ListTile(
            title: Text('Logout'),
            onTap: () async {
              session.destroySession();
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => LoginView()));
            })
      ],
    );

    return new Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: Text("Warehouse: Zone List"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                _searchDialog(context);
              },
            ),
          ],
        ),
        body: Builder(builder: (BuildContext context) {
          return Container(
            color: Colors.white30,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(children: <Widget>[
                    new Flexible(child: TextFormField(
                      controller: _selectedControlNo,
                      keyboardType: TextInputType.text,
                      readOnly: true,
                      decoration: InputDecoration(labelText: 'Control No.'),
                    ),),
                     SizedBox(width: 10),
                    new Flexible(child: TextFormField(
                      controller: _selectedLocation,
                      keyboardType: TextInputType.text,
                      readOnly: true,
                      decoration: InputDecoration(labelText: 'Location'),
                    ),),
                    ],
                  ), 
                  Row(children: <Widget>[ 
                  new Flexible(child: TextFormField(
                      controller: _selectedDate,
                      keyboardType: TextInputType.text,
                      readOnly: true,
                      decoration: InputDecoration(labelText: 'Date'),
                    ),),
                     SizedBox(width: 10),
                    new Flexible(child: TextFormField(
                      controller: _selectedTotalContainer,
                      keyboardType: TextInputType.text,
                      readOnly: true,
                      decoration: InputDecoration(labelText: 'Total Container'),
                    ),),
                  ],),  
                        new SizedBox(
                          height: 10.0,
                        ),
                        new ButtonBar(
                          alignment: MainAxisAlignment.center,
                          children: <Widget>[ 
                            new RaisedButton(
                              onPressed: ()  async{
                                _scan(context);
                              },
                              child: Text("Scan"),
                              color: Colors.red,
                            ), 
                            new RaisedButton(
                              onPressed :(() async {
                                 
                              }),
                              child: Text("Receive"),
                              color: Colors.red,
                            ), 
                          ],
                        ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                    child: Text(
                      'Zones',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                    ),
                  ),
                  _zoneList == null
                      ? Text('No record found!')
                      : RefreshIndicator(
                          onRefresh: () async {
                            _assignZoneList(_selectedDeliverID.text);
                          },
                          child: SizedBox(
                            height:
                                (MediaQuery.of(context).size.height / 2) - 80,
                            child: ListView(children: <Widget>[
                              DataTable(
                                columns: [
                                  DataColumn(label: Text('Zone')),
                                  DataColumn(label: Text('Qty')),
                                  DataColumn(label: Text('Container')),
                                  DataColumn(label: Text('Box')), 
                                ],
                                rows: _zoneList.items
                                    .map((e) => DataRow(
                                          cells: <DataCell>[
                                            DataCell(Text("${e["zone"]}",style: new TextStyle(color: Colors.redAccent,fontWeight: FontWeight.bold),),
                                            onTap: (){
                                              _zoneContentDialog(context);
                                            }), 
                                            DataCell(Text("${e["totalQty"]}")),
                                            DataCell(Text("${e["container"]}")),
                                            DataCell(Text("${e["box"]}")), 
                                          ],
                                        ))
                                    .toList(),
                              ),
                            ]),
                          )),
                ],
              ),
            ),
          );
        }),
        drawer: Drawer(
          child: drawerItems,
        ));
  }

  Future _scan(context) async 
  {
    this._scanningBarcode.text='';
    try {
      String barcode = await BarcodeScanner.scan();
      setState(() 
      {
        this._scanningBarcode.text= barcode; 
      });
    } on PlatformException catch (e) 
    {
      print(e);
    }
  }
  Future<void> _selectDate(BuildContext context) async {
    final DateTime pickedDate = await showDatePicker(
        context: context,
        initialDate: _currentDate,
        firstDate: DateTime(2020),
        lastDate: DateTime(2030));
    if (pickedDate != null && pickedDate != _currentDate)
      setState(() {
        _currentDate = pickedDate;
        _searchDate.text = _currentDate.toString().substring(0, 10);
      });
  }

  void _getDelivery() async {
    MyHttpRequest request = new MyHttpRequest(context: context);
    bool validateConnection = await request.validateConnection();
    if (!validateConnection) {
      return null;
    }

    print(
        "pickingDate: ${_searchDate.text},locID:${_locationList.items[_selectedIndexLocation]['locationID']}");

    DeliverySubmit res = new DeliverySubmit(
        pickingDate: _searchDate.text,
        locID: _locationList.items[_selectedIndexLocation]['locationID']
            .toString(),
        empID: session.userEmployeeID.toString());
    DeliveryReturn res2 = await ZoneController.getDelivery(res);
    print("loading delivery list from server >>>>>");
    setState(() {
      _deliveryList = res2;
      _selectedControlNo.text = "";
      _selectedLocation.text = "";
      _selectedDate.text = "";
       _selectedTotalContainer.text = ""; 
      _zoneList = null;
      if (_deliveryList != null) {
        print(
            "loading delivery list from server >>>>> ${_deliveryList.apiMsg}");
        if (_deliveryList.items.length > 0) {
          _assignZoneList(_deliveryList.items[0]['deliverID']);
          _selectedDeliverID.text = _deliveryList.items[0]['deliverID'];
          _selectedControlNo.text = _deliveryList.items[0]['controlNo'];
          _selectedLocation.text =
              "[${_deliveryList.items[0]['locationCode']}] ${_deliveryList.items[0]['location']}";
          _selectedDate.text = _deliveryList.items[0]['pickDate'];
          _selectedTotalContainer.text = _deliveryList.items[0]['totalContainer'].toString();
        }
      }
    });
  }

  void _assignZoneList(id) async {
    MyHttpRequest request = new MyHttpRequest(context: context);
    bool validateConnection = await request.validateConnection();
    if (!validateConnection) {
      return null;
    }

    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String dateNow = formatter.format(now);

    ZoneSubmit res = new ZoneSubmit(
        deliverID: id.toString(), empID: session.userEmployeeID.toString());
    ZoneReturn res2 = await ZoneController.getZone(res);
    print("loading zone list from server >>>>> ${res2.apiMsg}");
    setState(() {
      _zoneList = res2;
    });
  }

  void _getLocation() async {
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
      _locationList = res2;
    });
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
                      key: _searchFormKey,
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            controller: _searchDate,
                            keyboardType: TextInputType.text,
                            readOnly: true,
                            inputFormatters: <TextInputFormatter>[
                              WhitelistingTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            onTap: () => _selectDate(context),
                            decoration: InputDecoration(labelText: 'Date'),
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Date is required!. ';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Text("Location",
                      style: new TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.bold)),
                  SizedBox(
                    height: (MediaQuery.of(context).size.height / 3),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _locationList.items.length,
                      itemBuilder: (context, index) {
                        return Card(
                          color: _selectedIndexLocation == index
                              ? Colors.green
                              : Colors
                                  .white, //                        <-- Card widget
                          child: InkWell(
                            onTap: () {
                              int i;
                              if (_selectedIndexLocation == null) {
                                i = index;
                              } else if (_selectedIndexLocation == index) {
                                i = null;
                              } else {
                                i = index;
                              }
                              setState(() {
                                _selectedIndexLocation = i;
                                print(
                                    "selected >>>>>$index ${_selectedIndexLocation}");
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: new RichText(
                                text: new TextSpan(
                                  style: new TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.black,
                                  ),
                                  children: <TextSpan>[
                                    new TextSpan(
                                        text: 'Store : ',
                                        style: new TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    new TextSpan(
                                        text:
                                            '[${_locationList.items[index]['locationCode']}] ${_locationList.items[index]['location']}'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              new FlatButton(
                child: new Text("Ok"),
                onPressed: () {
                  if(_searchFormKey.currentState.validate()) { 
                    _getDelivery();
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

    void _zoneContentDialog(context2) {
    showDialog(
      context: context2,
      builder: (BuildContext context) {
        // return object of type Dialog
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            scrollable: true,
            title: new Text("Item Lists"),
            content: Container(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Form(
                      key: _searchFormKey,
                      child: Column(
                        children: <Widget>[
                          TextFormField( 
                            keyboardType: TextInputType.text,
                            readOnly: true,
                            inputFormatters: <TextInputFormatter>[
                              WhitelistingTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            onTap: () => _selectDate(context),
                            decoration: InputDecoration(labelText: 'Add New Item'),
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Date is required!. ';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                 ],
              ),
            ),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              new FlatButton(
                child: new Text("Ok"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
      },
    );
  }
}

class SearchDialog extends StatefulWidget {
  @override
  _SearchDialogState createState() => new _SearchDialogState();
}

class _SearchDialogState extends State<SearchDialog> {
  Color _c = Colors.redAccent;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Container(
        color: _c,
        height: 20.0,
        width: 20.0,
      ),
      actions: <Widget>[
        FlatButton(
            child: Text('Switch'),
            onPressed: () => setState(() {
                  _c == Colors.redAccent
                      ? _c = Colors.blueAccent
                      : _c = Colors.redAccent;
                }))
      ],
    );
  }
}
