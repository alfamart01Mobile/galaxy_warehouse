class DeliverySubmit{
  final String pickingDate;
  final String locID;
  final String empID;

  DeliverySubmit({this.pickingDate,this.locID,this.empID});

  factory DeliverySubmit.fromJson(Map<String, dynamic> json) 
  {
    return DeliverySubmit(pickingDate: json['pickingDate'],locID: json['locID'],empID: json['empID']);
  }

  Map toMap()
  {
    var map = new Map<String, dynamic>();
    map["pickingDate"] = pickingDate;
    map["locID"]       = locID;
    map["empID"]       = empID;
    return map;
  }
}

class DeliveryReturn
{
  final int apiReturn;
  final String apiMsg;
  final List<dynamic> items;


  DeliveryReturn({this.apiReturn,this.apiMsg,this.items});

  factory DeliveryReturn.fromJson(Map<String, dynamic> parsedJson)
  {
    return DeliveryReturn(
        apiReturn   : parsedJson['apiReturn'],
        apiMsg      : parsedJson['apiMsg'],
        items        : parsedJson['items'],
    );
  } 
}

