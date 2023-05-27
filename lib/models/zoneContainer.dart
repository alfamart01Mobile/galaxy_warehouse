class ZoneContainerSubmit{
  final String deliverID; 
  final String empID;

  ZoneContainerSubmit({this.deliverID,this.empID});

  factory ZoneContainerSubmit.fromJson(Map<String, dynamic> json) 
  {
    return ZoneContainerSubmit(deliverID: json['deliverID'],empID: json['empID']);
  }

  Map toMap()
  {
    var map = new Map<String, dynamic>();
    map["deliverID"] = deliverID; 
    map["empID"]       = empID;
    return map;
  }
}

class ZoneContainerReturn
{
  final int apiReturn;
  final String apiMsg;
  final List<dynamic> items;


  ZoneContainerReturn({this.apiReturn,this.apiMsg,this.items});

  factory ZoneContainerReturn.fromJson(Map<String, dynamic> parsedJson)
  {
    return ZoneContainerReturn(
        apiReturn   : parsedJson['apiReturn'],
        apiMsg      : parsedJson['apiMsg'],
        items        : parsedJson['items'],
    );
  } 
}

