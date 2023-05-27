class BatchSubmit{
  final String deliverID; 
  final String empID;

  BatchSubmit({this.deliverID,this.empID});

  factory BatchSubmit.fromJson(Map<String, dynamic> json) 
  {
    return BatchSubmit(deliverID: json['deliverID'],empID: json['empID']);
  }

  Map toMap()
  {
    var map = new Map<String, dynamic>();
    map["deliverID"] = deliverID; 
    map["empID"]       = empID;
    return map;
  }
}

class BatchReturn
{
  final int apiReturn;
  final String apiMsg;
  final List<dynamic> items;


  BatchReturn({this.apiReturn,this.apiMsg,this.items});

  factory BatchReturn.fromJson(Map<String, dynamic> parsedJson)
  {
    return BatchReturn(
        apiReturn   : parsedJson['apiReturn'],
        apiMsg      : parsedJson['apiMsg'],
        items        : parsedJson['items'],
    );
  } 
}

