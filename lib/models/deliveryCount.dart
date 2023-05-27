class DeliveryCountSubmit {
  final String deliverID; 

  DeliveryCountSubmit({this.deliverID});

  factory DeliveryCountSubmit.fromJson(Map<String, dynamic> json) {
    return DeliveryCountSubmit(
        deliverID: json['deliverID']);
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["deliverID"] = deliverID; 
    return map;
  }
}

class DeliveryCountReturn {
  final int apiReturn;
  final String apiMsg;
  final List<dynamic> items;

  DeliveryCountReturn({this.apiReturn, this.apiMsg, this.items});

  factory DeliveryCountReturn.fromJson(Map<String, dynamic> parsedJson) {
    return DeliveryCountReturn(
      apiReturn: parsedJson['apiReturn'],
      apiMsg: parsedJson['apiMsg'],
      items: parsedJson['items'],
    );
  }
}
