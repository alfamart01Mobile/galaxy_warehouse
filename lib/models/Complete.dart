class CompleteSubmit {
  final String deliverID;
  final String scannedBy;
  final String cancelBy;
  final String empID;

  CompleteSubmit(
      {this.deliverID, this.scannedBy, this.cancelBy, this.empID});

  factory CompleteSubmit.fromJson(Map<String, dynamic> json) {
    return CompleteSubmit(
        deliverID: json['deliverID'],
        scannedBy: json['scannedBy'],
        cancelBy: json['cancelBy'],
        empID: json['empID']);
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["deliverID"] = deliverID;
    map["scannedBy"] = scannedBy;
    map["cancelBy"] = cancelBy;
    map["empID"] = empID;
    return map;
  }
}

class CompleteReturn {
  final int apiReturn;
  final String apiMsg;
  final List<dynamic> items;

  CompleteReturn({this.apiReturn, this.apiMsg, this.items});

  factory CompleteReturn.fromJson(Map<String, dynamic> parsedJson) {
    return CompleteReturn(
      apiReturn: parsedJson['apiReturn'],
      apiMsg: parsedJson['apiMsg'],
      items: parsedJson['items'],
    );
  }
}
