class UpdateDelShipSubmit{
  final String deliverID; 
  final String batchNo;
  final String empID;

  UpdateDelShipSubmit({this.deliverID,this.batchNo,this.empID});

  factory UpdateDelShipSubmit.fromJson(Map<String, dynamic> json) 
  {
    return UpdateDelShipSubmit(deliverID: json['deliverID'],batchNo: json['batchNo'],empID: json['empID']);
  }

  Map toMap()
  {
    var map = new Map<String, dynamic>();
    map["deliverID"] = deliverID;
    map["batchNo"] = batchNo; 
    map["empID"]       = empID;
    return map;
  }
}

class UpdateDelShipReturn
{
  final int apiReturn;
  final String apiMsg; 


  UpdateDelShipReturn({this.apiReturn,this.apiMsg});

  factory UpdateDelShipReturn.fromJson(Map<String, dynamic> parsedJson)
  {
    return UpdateDelShipReturn(
        apiReturn   : parsedJson['apiReturn'],
        apiMsg      : parsedJson['apiMsg'], 
    );
  } 
}

