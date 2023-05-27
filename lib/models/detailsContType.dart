class DetailsContTypeSubmit {
  final String deliverID;
  final String empID;
  final String batchNo;

  DetailsContTypeSubmit({this.deliverID, this.empID, this.batchNo});

  factory DetailsContTypeSubmit.fromJson(Map<String, dynamic> json) {
    return DetailsContTypeSubmit(
        deliverID: json['deliverID'],
        empID: json['empID'],
        batchNo: json['batchNo']);
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["deliverID"] = deliverID;
    map["empID"] = empID;
    map["batchNo"] = batchNo;
    return map;
  }
}

class DetailsContTypeReturn {
  final int apiReturn;
  final String apiMsg;
  final List<dynamic> items;

  DetailsContTypeReturn({this.apiReturn, this.apiMsg, this.items});

  factory DetailsContTypeReturn.fromJson(Map<String, dynamic> parsedJson) {
    return DetailsContTypeReturn(
      apiReturn: parsedJson['apiReturn'],
      apiMsg: parsedJson['apiMsg'],
      items: parsedJson['items'],
    );
  }
}
