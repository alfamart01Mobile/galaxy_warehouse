class LoginSubmit{
  final String username;
  final String password;
  LoginSubmit({this.username,this.password});

  factory LoginSubmit.fromJson(Map<String, dynamic> json) 
  {
    return LoginSubmit(username: json['username'],password: json['password']);
  }

  Map toMap()
  {
    var map = new Map<String, dynamic>();
    map["username"] = username;
    map["password"] = password;
    return map;
  }
}

class LoginReturn
{
  final int apiReturn;
  final String apiMsg;
  final List<dynamic> user;


  LoginReturn({this.apiReturn,this.apiMsg,this.user});

  factory LoginReturn.fromJson(Map<String, dynamic> parsedJson)
  {
    return LoginReturn(
        apiReturn   : parsedJson['apiReturn'],
        apiMsg      : parsedJson['apiMsg'],
        user        : parsedJson['user'],
    );
  } 
}

