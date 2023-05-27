class User
{
  final int employeeID;
  final String employeeNo;
  final String fullName;
  final int locationID;
  final String locationCode;
  final String locationName;
  final int userType; 

  User({this.employeeID,this.employeeNo,this.fullName,this.locationID,this.locationCode,this.locationName,this.userType});

  factory User.fromJson(Map<String, dynamic> parsedJson)
  {
    return User(
      employeeID    :   parsedJson['employeeID'],
      employeeNo    :   parsedJson['employeeNo'],
      fullName      :   parsedJson['fullName'],
      locationID    :   parsedJson['locationID'],
      locationCode  :   parsedJson['locationCode'],
      locationName  :   parsedJson['locationName'],
      userType      :   parsedJson['userType']);
  }
}