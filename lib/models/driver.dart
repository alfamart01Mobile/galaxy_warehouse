class DriverSubmit{
  final String driverID; 
  final String driverName;

  DriverSubmit({this.driverID,this.driverName});

  factory DriverSubmit.fromJson(Map<String, dynamic> json) 
  {
    return DriverSubmit(driverID: json['driverID'],driverName: json['driverName']);
  }

  Map toMap()
  {
    var map = new Map<String, dynamic>();
    map["driverID"] = driverID; 
    map["driverName"]       = driverName;
    return map;
  }
}

class DriverReturn
{
  final int apiReturn;
  final String apiMsg;
  final List<dynamic> items;


  DriverReturn({this.apiReturn,this.apiMsg,this.items});

  factory DriverReturn.fromJson(Map<String, dynamic> parsedJson)
  {
    return DriverReturn(
        apiReturn   : parsedJson['apiReturn'],
        apiMsg      : parsedJson['apiMsg'],
        items        : parsedJson['items'],
    );
  } 
}

