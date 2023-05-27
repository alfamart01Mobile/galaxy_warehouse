class TruckSubmit{
  final String truckID; 
  final String truckNo;

  TruckSubmit({this.truckID,this.truckNo});

  factory TruckSubmit.fromJson(Map<String, dynamic> json) 
  {
    return TruckSubmit(truckID: json['truckID'],truckNo: json['truckNo']);
  }

  Map toMap()
  {
    var map = new Map<String, dynamic>();
    map["truckID"] = truckID; 
    map["truckNo"]       = truckNo;
    return map;
  }
}

class TruckReturn
{
  final int apiReturn;
  final String apiMsg;
  final List<dynamic> items;


  TruckReturn({this.apiReturn,this.apiMsg,this.items});

  factory TruckReturn.fromJson(Map<String, dynamic> parsedJson)
  {
    return TruckReturn(
        apiReturn   : parsedJson['apiReturn'],
        apiMsg      : parsedJson['apiMsg'],
        items        : parsedJson['items'],
    );
  } 
}

