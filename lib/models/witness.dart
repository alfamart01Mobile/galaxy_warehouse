class WitnessSubmit {
  final String deliverID;
  final String batchNo; 
  final String empID;

  WitnessSubmit({this.deliverID,this.batchNo, this.empID});

  factory WitnessSubmit.fromJson(Map<String, dynamic> json) {
    return WitnessSubmit(
        deliverID: json['deliverID'],
        batchNo: json['batchNo'], 
        empID: json['empID']);
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["deliverID"] = deliverID;
      map["batchNo"] = batchNo;  
    map["empID"] = empID;
    return map;
  }
}

class WitnessReturn {
  final int apiReturn;
  final String apiMsg;
  final List<dynamic> items;

  WitnessReturn({this.apiReturn, this.apiMsg, this.items});

  factory WitnessReturn.fromJson(Map<String, dynamic> parsedJson) {
    return WitnessReturn(
      apiReturn: parsedJson['apiReturn'],
      apiMsg: parsedJson['apiMsg'],
      items: parsedJson['items'],
    );
  }
}
