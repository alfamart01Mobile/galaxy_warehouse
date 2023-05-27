class DeliveryUpdateSubmit {
  final String deliverID;
  final String shipBy;
  final String cancelBy;
  final String empID;
  final String isComplete;

  DeliveryUpdateSubmit(
      {this.deliverID,
      this.shipBy,
      this.cancelBy,
      this.empID,
      this.isComplete});

  factory DeliveryUpdateSubmit.fromJson(Map<String, dynamic> json) {
    return DeliveryUpdateSubmit(
        deliverID: json['deliverID'],
        shipBy: json['shipBy'],
        cancelBy: json['cancelBy'],
        empID: json['empID'],
        isComplete: json['isComplete']);
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["deliverID"] = deliverID;
    map["shipBy"] = shipBy;
    map["cancelBy"] = cancelBy;
    map["empID"] = empID;
    map["isComplete"] = isComplete;
    return map;
  }
}

class DeliveryUpdateReturn {
  final int apiReturn;
  final String apiMsg;
  final List<dynamic> items;

  DeliveryUpdateReturn({this.apiReturn, this.apiMsg, this.items});

  factory DeliveryUpdateReturn.fromJson(Map<String, dynamic> parsedJson) {
    return DeliveryUpdateReturn(
      apiReturn: parsedJson['apiReturn'],
      apiMsg: parsedJson['apiMsg'],
      items: parsedJson['items'],
    );
  }
}
