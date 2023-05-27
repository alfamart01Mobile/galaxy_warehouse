import 'package:galaxy_warehouse/controllers/deliveryController.dart';
import 'package:galaxy_warehouse/libraries/MyHttpRequest.dart';
import 'package:galaxy_warehouse/models/Delivery.dart';  
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:galaxy_warehouse/views/pages/login/loginView.dart'; 
import 'package:intl/intl.dart'; 
import 'package:galaxy_warehouse/config/session.dart' as session;

class DeliveryPage extends StatefulWidget 
{
  @override
  _DeliveryPageState createState() => _DeliveryPageState();
}

class _DeliveryPageState extends State
{

  DeliveryReturn _deliveryList;
  @override
  void initState()
  {
    super.initState();
    _assignDeliveryList();
  }


  @override
  Widget build(BuildContext context) {
    final drawerHeader = UserAccountsDrawerHeader(
      accountName: Text('[${session.userLocationCode}] ${session.userLocation}'),
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
                Navigator.push(context, MaterialPageRoute( builder: (context) => LoginView()));
            })
      ],
    );


    return new Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text("Warehouse: Delivery List"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
            },
          ), 
        ],
      ),
      body: Builder(builder: (BuildContext context) {
        return Container(
          color: Colors.white30,
          child: _deliveryList==null ? Center(child: CircularProgressIndicator()): Padding(
            padding: const EdgeInsets.all(8.0),
            child: RefreshIndicator(
              onRefresh:() async
              {
                 _assignDeliveryList();
              },
              child: ListView.builder(
                itemCount: _deliveryList.items.length,
                itemBuilder: (context, index) {
                  return Card( //
                    color: _deliveryList.items[index]['totalScannedQty']  >= _deliveryList.items[index]['totalContainer']?
                    Colors.green:Colors.white,//                        <-- Card widget
                    child: InkWell(
                      onTap: () 
                      {
                         
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
                              new TextSpan(text: 'Store : ', style: new TextStyle(fontWeight: FontWeight.bold)),
                              new TextSpan(text: '[${_deliveryList.items[index]['locationCode']}] ${_deliveryList.items[index]['location']}'),
                              new TextSpan(text: '\nControlNo : ', style: new TextStyle( fontWeight: FontWeight.bold)),
                              new TextSpan(text: _deliveryList .items[index]['controlNo']),
                              new TextSpan(text: '\nTotal Container : ', style: new TextStyle( fontWeight: FontWeight.bold)),
                              new TextSpan(text: _deliveryList .items[index]['totalContainer'].toString()),
                              new TextSpan(text: '  Total Scanned : ', style: new TextStyle( fontWeight: FontWeight.bold)),
                              new TextSpan( text: _deliveryList.items[index]['totalScannedQty'].toString()),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      }),
      drawer: Drawer(
        child: drawerItems,
      ));
  }

  void _assignDeliveryList() async
  {
     MyHttpRequest request = new MyHttpRequest(context: context);
    bool validateConnection =await request.validateConnection();
    if(!validateConnection)
    { 
      return null;
    }

    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String dateNow = formatter.format(now);

    DeliverySubmit res = new DeliverySubmit(pickingDate:'2021-01-10',locID: '375',empID: session.userEmployeeID.toString()); 
      DeliveryReturn res2 = await DeliveryController.getDelivery(res); 
    setState(()
    {
      _deliveryList  = res2; 
    });
  }
   
}


