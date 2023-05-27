class DelDetUpdateStatusSubmit {
  final String deliverID;
  final String ddID;
  final String barcode;
  final String typeID;
  final String qty;
  final String status;
  final String empID;
  final String remarks;
  DelDetUpdateStatusSubmit(
      {this.deliverID,
      this.ddID,
      this.barcode,
      this.typeID,
      this.qty,
      this.status,
      this.empID,
      this.remarks});

  factory DelDetUpdateStatusSubmit.fromJson(Map<String, dynamic> json) {
    return DelDetUpdateStatusSubmit(
        deliverID: json['deliverID'],
        ddID: json['ddID'],
        barcode: json['barcode'],
        typeID: json['typeID'],
        qty: json['qty'],
         status: json['status'],
        empID: json['empID'],
        remarks: json['remarks']);
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["deliverID"] = deliverID;
    map["ddID"] = ddID;
    map["barcode"] = barcode;
    map["typeID"] = typeID;
    map["qty"] = qty;
    map["status"] = status;
    map["empID"] = empID;
    map["remarks"] = remarks;
    return map;
  }
}

class DelDetUpdateStatusReturn {
  final int apiReturn;
  final String apiMsg;

  DelDetUpdateStatusReturn({this.apiReturn, this.apiMsg});

  factory DelDetUpdateStatusReturn.fromJson(Map<String, dynamic> parsedJson) {
    return DelDetUpdateStatusReturn(
      apiReturn: parsedJson['apiReturn'],
      apiMsg: parsedJson['apiMsg'],
    );
  }
}
