class ScanSubmit {
  final String deliverID;
  final String barcode;
  final String typeID;
  final String qty;
  final String empID;
  final String remarks;
  ScanSubmit(
      {this.deliverID,
      this.barcode,
      this.typeID,
      this.qty,
      this.empID,
      this.remarks});

  factory ScanSubmit.fromJson(Map<String, dynamic> json) {
    return ScanSubmit(
        deliverID: json['deliverID'],
        barcode: json['barcode'],
        typeID: json['typeID'],
        qty: json['qty'],
        empID: json['empID'],
        remarks: json['remarks']);
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["deliverID"] = deliverID;
    map["barcode"] = barcode;
    map["typeID"] = typeID;
    map["qty"] = qty;
    map["empID"] = empID;
    map["remarks"] = remarks;
    return map;
  }
}

class ScanReturn {
  final int apiReturn;
  final String apiMsg;

  ScanReturn({this.apiReturn, this.apiMsg});

  factory ScanReturn.fromJson(Map<String, dynamic> parsedJson) {
    return ScanReturn(
      apiReturn: parsedJson['apiReturn'],
      apiMsg: parsedJson['apiMsg'],
    );
  }
}
