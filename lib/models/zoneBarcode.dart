class ZoneBarcodeSubmit {
  final String deliverID;
  final String status;
  final String zone;
  final String empID;

  ZoneBarcodeSubmit({this.deliverID, this.status, this.zone, this.empID});

  factory ZoneBarcodeSubmit.fromJson(Map<String, dynamic> json) {
    return ZoneBarcodeSubmit(
        deliverID: json['deliverID'],
        status: json['status'],
        zone: json['zone'],
        empID: json['empID']);
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["deliverID"] = deliverID;
    map["status"] = status;
    map["zone"] = zone;
    map["empID"] = empID;
    return map;
  }
}

class ZoneBarcodeReturn
{
  final int apiReturn;
  final String apiMsg;
  final List<dynamic> items;


  ZoneBarcodeReturn({this.apiReturn,this.apiMsg,this.items});

  factory ZoneBarcodeReturn.fromJson(Map<String, dynamic> parsedJson)
  {
    return ZoneBarcodeReturn(
        apiReturn   : parsedJson['apiReturn'],
        apiMsg      : parsedJson['apiMsg'],
        items       : parsedJson['items'],
    );
  } 
}
