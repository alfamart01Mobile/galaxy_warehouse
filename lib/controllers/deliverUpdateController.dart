
import 'dart:convert'; 
import 'package:galaxy_warehouse/config/global.dart'; 
import 'package:galaxy_warehouse/models/deliveryUpdate.dart'; 
import 'package:http/http.dart' as http;  

class DeliveryUpdateController
{
 static getDeliveryUpdate(DeliveryUpdateSubmit res) async
  {  
    var body = res.toMap();
    return http.post(apiDeliveryUpdateUrl, body: body).then((http.Response response)
    {
      final int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 400 || json == null)
      {
        throw new Exception("Error while fetching data");
      }
      return DeliveryUpdateReturn.fromJson(json.decode(response.body));
    });
  }   
}