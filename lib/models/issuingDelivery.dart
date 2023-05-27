class IssuingDeliverySubmit {
  final String empID;
  final String isloaded;
  final String controlno;
  final String loc;

  IssuingDeliverySubmit({this.empID, this.isloaded, this.controlno, this.loc});

  factory IssuingDeliverySubmit.fromJson(Map<String, dynamic> json) {
    return IssuingDeliverySubmit(
        empID: json['empID'],
        isloaded: json['isloaded'],
        controlno: json['controlno'],
        loc: json['loc']);
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["empID"] = empID;
    map["isloaded"] = isloaded;
    map["controlno"] = controlno;
    map["loc"] = loc;
    return map;
  }
}

class IssuingDeliveryReturn {
  final int apiReturn;
  final String apiMsg;
  final List<dynamic> items;

  IssuingDeliveryReturn({this.apiReturn, this.apiMsg, this.items});

  factory IssuingDeliveryReturn.fromJson(Map<String, dynamic> parsedJson) {
    return IssuingDeliveryReturn(
      apiReturn: parsedJson['apiReturn'],
      apiMsg: parsedJson['apiMsg'],
      items: parsedJson['items'],
    );
  }
}
