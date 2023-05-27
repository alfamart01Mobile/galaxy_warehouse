class ShippingSubmit {
  final String deliverID;
  final String truckID;
  final String driverID;
  final String empID;

  ShippingSubmit({this.deliverID, this.truckID, this.driverID, this.empID});

  factory ShippingSubmit.fromJson(Map<String, dynamic> json) {
    return ShippingSubmit(
        deliverID: json['deliverID'],
        truckID: json['truckID'],
        driverID: json['driverID'],
        empID: json['empID']);
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["deliverID"] = deliverID;
    map["truckID"] = truckID;
    map["driverID"] = driverID;
    map["empID"] = empID;
    return map;
  }
}

class ShippingReturn {
  final int apiReturn;
  final String apiMsg; 

  ShippingReturn({this.apiReturn,this.apiMsg});

  factory ShippingReturn.fromJson(Map<String, dynamic> parsedJson) {
    return ShippingReturn(
      apiReturn: parsedJson['apiReturn'],
      apiMsg: parsedJson['apiMsg'], 
    );
  }
}
