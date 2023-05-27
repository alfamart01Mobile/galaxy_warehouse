class DelDetUpdateSubmit {
  final String deliverID;
  final String ddID;
  final String barcode;
  final String typeID;
  final String qty;
  final String status;
  final String empID;
  final String remarks;
  DelDetUpdateSubmit(
      {this.deliverID,
      this.ddID,
      this.barcode,
      this.typeID,
      this.qty,
      this.status,
      this.empID,
      this.remarks});

  factory DelDetUpdateSubmit.fromJson(Map<String, dynamic> json) {
    return DelDetUpdateSubmit(
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

class DelDetUpdateReturn {
  final int apiReturn;
  final String apiMsg;

  DelDetUpdateReturn({this.apiReturn, this.apiMsg});

  factory DelDetUpdateReturn.fromJson(Map<String, dynamic> parsedJson) {
    return DelDetUpdateReturn(
      apiReturn: parsedJson['apiReturn'],
      apiMsg: parsedJson['apiMsg'],
    );
  }
}
