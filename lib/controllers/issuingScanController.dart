
import 'dart:convert'; 
import 'package:galaxy_warehouse/config/global.dart'; 
import 'package:galaxy_warehouse/models/issuingScan.dart'; 
import 'package:http/http.dart' as http;  

class IssuingScanController
{
 static getIssuingScan(IssuingScanSubmit res) async
  {  
    var body = res.toMap();
    return http.post(apiIssuingScanUrl, body: body).then((http.Response response)
    {
      final int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 400 || json == null)
      {
        print("Error while fetching data");
      }
      return IssuingScanReturn.fromJson(json.decode(response.body));
    });
  }   
}