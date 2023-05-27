class ScanZoneSubmit{
  final String pickingDate;
  final String locID;
  final String barcode;
  final String empID;

  ScanZoneSubmit({this.pickingDate,this.locID,this.barcode,this.empID});

  factory ScanZoneSubmit.fromJson(Map<String, dynamic> json) 
  {
    return ScanZoneSubmit(pickingDate: json['pickingDate'],locID: json['locID'],barcode: json['barcode'],empID: json['empID']);
  }

  Map toMap()
  {
    var map = new Map<String, dynamic>();
    map["pickingDate"] = pickingDate;
    map["locID"]       = locID;
    map["barcode"]       = barcode;
    map["empID"]       = empID;
    return map;
  }
}

class ScanZoneReturn
{
  final int apiReturn;
  final String apiMsg;
  final List<dynamic> items;


  ScanZoneReturn({this.apiReturn,this.apiMsg,this.items});

  factory ScanZoneReturn.fromJson(Map<String, dynamic> parsedJson)
  {
    return ScanZoneReturn(
        apiReturn   : parsedJson['apiReturn'],
        apiMsg      : parsedJson['apiMsg'],
        items        : parsedJson['items'],
    );
  } 
}

