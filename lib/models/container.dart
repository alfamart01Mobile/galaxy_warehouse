class ContainerSubmit{
  final String deliverID; 
  final String empID;

  ContainerSubmit({this.deliverID,this.empID});

  factory ContainerSubmit.fromJson(Map<String, dynamic> json) 
  {
    return ContainerSubmit(deliverID: json['deliverID'],empID: json['empID']);
  }

  Map toMap()
  {
    var map = new Map<String, dynamic>();
    map["deliverID"] = deliverID; 
    map["empID"]       = empID;
    return map;
  }
}

class ContainerReturn
{
  final int apiReturn;
  final String apiMsg;
  final List<dynamic> items;


  ContainerReturn({this.apiReturn,this.apiMsg,this.items});

  factory ContainerReturn.fromJson(Map<String, dynamic> parsedJson)
  {
    return ContainerReturn(
        apiReturn   : parsedJson['apiReturn'],
        apiMsg      : parsedJson['apiMsg'],
        items        : parsedJson['items'],
    );
  } 
}

