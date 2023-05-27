class LocationSubmit
{
  final String locID;
  final String locCode;
  final String location;

  LocationSubmit({this.locID,this.locCode,this.location});

  factory LocationSubmit.fromJson(Map<String, dynamic> json) 
  {
    return LocationSubmit(locID: json['locID'],locCode: json['locCode'],location: json['location']);
  }

  Map toMap()
  {
    var map = new Map<String, dynamic>();
    map["locID"]      = locID;
    map["locID"]      = locID;
    map["location"]   = location;
    return map;
  }
}

class LocationReturn
{
  final int apiReturn;
  final String apiMsg;
  final List<dynamic> items;


  LocationReturn({this.apiReturn,this.apiMsg,this.items});

  factory LocationReturn.fromJson(Map<String, dynamic> parsedJson)
  {
    return LocationReturn(
        apiReturn   : parsedJson['apiReturn'],
        apiMsg      : parsedJson['apiMsg'],
        items        : parsedJson['items'],
    );
  } 
}

