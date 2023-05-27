
import 'dart:convert'; 
import 'package:galaxy_warehouse/config/global.dart';
import 'package:galaxy_warehouse/models/delDetUpdate.dart'; 
import 'package:http/http.dart' as http;  
class DelDetUpdateController
{
 static getDelDetUpdate(DelDetUpdateSubmit res) async
  {  
    var body = res.toMap();
    return http.post(apiDelDetUpdaterUrl, body: body).then((http.Response response)
    {
      final int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 400 || json == null)
      {
        throw new Exception("Error while fetching data");
      }
      return DelDetUpdateReturn.fromJson(json.decode(response.body));
    });
  }  
}