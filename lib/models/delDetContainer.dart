class DelDetContainerSubmit{
  final String deliverID; 
  final String status; 
  final String empID;

  DelDetContainerSubmit({this.deliverID,this.status,this.empID});

  factory DelDetContainerSubmit.fromJson(Map<String, dynamic> json) 
  {
    return DelDetContainerSubmit(deliverID: json['deliverID'],status: json['status'],empID: json['empID']);
  }

  Map toMap()
  {
    var map = new Map<String, dynamic>();
    map["deliverID"]  = deliverID; 
     map["status"]    = status; 
    map["empID"]      = empID;
    return map;
  }
}

class DelDetContainerReturn
{
  final int apiReturn;
  final String apiMsg;
  final List<dynamic> items;


  DelDetContainerReturn({this.apiReturn,this.apiMsg,this.items});

  factory DelDetContainerReturn.fromJson(Map<String, dynamic> parsedJson)
  {
    return DelDetContainerReturn(
        apiReturn   : parsedJson['apiReturn'],
        apiMsg      : parsedJson['apiMsg'],
        items        : parsedJson['items'],
    );
  } 
}

