class ZoneSubmit{
  final String deliverID; 
  final String empID;

  ZoneSubmit({this.deliverID,this.empID});

  factory ZoneSubmit.fromJson(Map<String, dynamic> json) 
  {
    return ZoneSubmit(deliverID: json['deliverID'],empID: json['empID']);
  }

  Map toMap()
  {
    var map = new Map<String, dynamic>();
    map["deliverID"] = deliverID; 
    map["empID"]       = empID;
    return map;
  }
}

class ZoneReturn
{
  final int apiReturn;
  final String apiMsg;
  final List<dynamic> items;


  ZoneReturn({this.apiReturn,this.apiMsg,this.items});

  factory ZoneReturn.fromJson(Map<String, dynamic> parsedJson)
  {
    return ZoneReturn(
        apiReturn   : parsedJson['apiReturn'],
        apiMsg      : parsedJson['apiMsg'],
        items        : parsedJson['items'],
    );
  } 
}

