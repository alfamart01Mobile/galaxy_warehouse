class IssuingScanSubmit {
  final String deliverID;
  final String barcode;
  final String qty;
  final String status;
  final String empID;

  IssuingScanSubmit(
      {this.deliverID, this.barcode, this.qty, this.status, this.empID});

  factory IssuingScanSubmit.fromJson(Map<String, dynamic> json) {
    return IssuingScanSubmit(
        deliverID: json['deliverID'],
        barcode: json['barcode'],
        qty: json['qty'],
        status: json['status'],
        empID: json['empID']);
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["deliverID"] = deliverID;
    map["barcode"] = barcode;
    map["qty"] = qty;
    map["status"] = status;
    map["empID"] = empID;
    return map;
  }
}

class IssuingScanReturn {
  final int apiReturn;
  final String apiMsg;

  IssuingScanReturn({this.apiReturn, this.apiMsg});

  factory IssuingScanReturn.fromJson(Map<String, dynamic> parsedJson) {
    return IssuingScanReturn(
      apiReturn: parsedJson['apiReturn'],
      apiMsg: parsedJson['apiMsg'],
    );
  }
}
