class ShippingUpdateSubmit {
  final String deliverID;
  final String batch;
  final String truckID;
  final String driverID;
  final String empID;

  ShippingUpdateSubmit({this.deliverID,this.batch, this.truckID, this.driverID, this.empID});

  factory ShippingUpdateSubmit.fromJson(Map<String, dynamic> json) {
    return ShippingUpdateSubmit(
        deliverID: json['deliverID'],
        batch: json['batch'],
        truckID: json['truckID'],
        driverID: json['driverID'],
        empID: json['empID']);
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["deliverID"] = deliverID;
      map["batch"] = batch;
    map["truckID"] = truckID;
    map["driverID"] = driverID;
    map["empID"] = empID;
    return map;
  }
}

class ShippingUpdateReturn {
  final int apiReturn;
  final String apiMsg;
  final List<dynamic> items;

  ShippingUpdateReturn({this.apiReturn, this.apiMsg, this.items});

  factory ShippingUpdateReturn.fromJson(Map<String, dynamic> parsedJson) {
    return ShippingUpdateReturn(
      apiReturn: parsedJson['apiReturn'],
      apiMsg: parsedJson['apiMsg'],
      items: parsedJson['items'],
    );
  }
}
