
import 'dart:convert'; 
import 'package:galaxy_warehouse/config/global.dart'; 
import 'package:galaxy_warehouse/models/detailsContType.dart'; 
import 'package:http/http.dart' as http;  

class DetailsContTypeController
{
 static getDetailsContType(DetailsContTypeSubmit res) async
  {  
    var body = res.toMap();
    return http.post(apiDetailsContTypeUrl, body: body).then((http.Response response)
    {
      final int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 400 || json == null)
      {
        throw new Exception("Error while fetching data");
      }
      return DetailsContTypeReturn.fromJson(json.decode(response.body));
    });
  }   
}