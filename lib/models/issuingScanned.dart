class IssuingScannedSubmit {
  final String deliverID;
  final String status;
  final String zone;
  final String empID;

  IssuingScannedSubmit({this.deliverID, this.status, this.zone, this.empID});

  factory IssuingScannedSubmit.fromJson(Map<String, dynamic> json) {
    return IssuingScannedSubmit(
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

class IssuingScannedReturn {
  final int apiReturn;
  final String apiMsg;
  final List<dynamic> items;

  IssuingScannedReturn({this.apiReturn, this.apiMsg, this.items});

  factory IssuingScannedReturn.fromJson(Map<String, dynamic> parsedJson) {
    return IssuingScannedReturn(
      apiReturn: parsedJson['apiReturn'],
      apiMsg: parsedJson['apiMsg'],
      items: parsedJson['items'],
    );
  }
}
