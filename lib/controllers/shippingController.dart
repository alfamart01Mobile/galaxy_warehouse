
import 'dart:convert'; 
import 'package:galaxy_warehouse/config/global.dart'; 
import 'package:galaxy_warehouse/models/shipping.dart'; 
import 'package:http/http.dart' as http;  

class ShippingController
{
 static getShipping(ShippingSubmit res) async
  {  
    var body = res.toMap();
    print("URL >>> $apiShippingUrl");
    return http.post(apiShippingUrl, body: body).then((http.Response response)
    {
      final int statusCode = response.statusCode;
      
      if (statusCode < 200 || statusCode > 400 || json == null)
      {
        throw new Exception("Error while fetching data");
      } 
      return ShippingReturn.fromJson(json.decode(response.body));
    });
  }   
}