
import 'dart:convert'; 
import 'package:galaxy_warehouse/config/global.dart';
import 'package:galaxy_warehouse/models/deliveryCount.dart'; 
import 'package:http/http.dart' as http;  
class DeliveryCountController
{
 static getDeliveryCount(DeliveryCountSubmit res) async
  {  
    var body = res.toMap();
    return http.post(apiDeliveryCountUrl, body: body).then((http.Response response)
    {
      final int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 400 || json == null)
      {
        throw new Exception("Error while fetching data");
      }
 
      return DeliveryCountReturn.fromJson(json.decode(response.body));
    });
  }  
}