import 'dart:convert';   
import 'package:connectivity/connectivity.dart';
import 'package:flushbar/flushbar.dart';
import 'package:galaxy_warehouse/config/global.dart'; 
import 'package:http/http.dart' as http; 
import 'package:flutter/material.dart'; 
class MyHttpRequest  
{
  String url; 
  var body;
  BuildContext context;
  var _result;
  MyHttpRequest({this.url,this.body,this.context});
   
  snackBarPrompt()
  {
     Flushbar(
            title: "Something wrong!",
            message: "Server connection failed!.",
            icon: Icon(
               Icons.warning,
              size: 28,
              color: Colors.white,
            ),
            backgroundColor:Colors.orange,
            duration: Duration(seconds: 3),
          ).show(this.context);
      return false;
  }

  Future validateConnection()
  async 
  {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult != ConnectivityResult.mobile && connectivityResult != ConnectivityResult.wifi) 
    {
       Flushbar(
            title: "Something wrong!",
            message: "Mobile device connectivity problem!.",
            icon: Icon(
               Icons.warning,
              size: 28,
              color: Colors.white,
            ),
            backgroundColor:Colors.orange,
            duration: Duration(seconds: 3),
          ).show(this.context); 
           return false; 
    } 
      try 
      {
        print(apiUrl);
         var response = await http.post(apiUrl, body:null).timeout(
            Duration(seconds: 60),
            onTimeout: ()
            {  
              print(">>>>>>>>>>>>>>>>> Timeout");
              return null;
            },
          ); 
          if(response == null)
          {
            return Flushbar(
            title: "Something wrong!",
            message: "Server connection timeout!.",
            icon: Icon(
               Icons.warning,
              size: 28,
              color: Colors.white,
            ),
            backgroundColor:Colors.orange,
            duration: Duration(seconds: 3),
          ).show(this.context);  
          }
          
         print(">>>>>>>>>>>>>>>>> ${response.statusCode}");
         if(response.statusCode == 200)
         {
           return true;
         }
         Flushbar(
            title: "Server connection error",
            message: "Response status code: ${response.statusCode} !.",
            icon: Icon(
               Icons.warning,
              size: 28,
              color: Colors.white,
            ),
            backgroundColor:Colors.orange,
            duration: Duration(seconds: 3),
          ).show(this.context);
          return false; 
      }
      catch (e)
      {  
        print(">> Error during server connection validation!.");
          Flushbar(
            title: "Something wrong!",
            message: "Error during server connection validation!.",
            icon: Icon(
               Icons.warning,
              size: 28,
              color: Colors.white,
            ),
            backgroundColor:Colors.orange,
            duration: Duration(seconds: 3),
          ).show(this.context); 
          return false; 
      }
  }

  Future post() async
  { 
    if(await validateConnection())
    {
      try
      {    
        return http.post(url,body: body).then((http.Response response)
        {
          final int statusCode = response.statusCode;
          if (statusCode < 200 || statusCode > 400 || json == null)
          { 
            //throw new Exception("Error while fetching data");
            _result = json.decode(null);
            return false;
          }   
          _result = json.decode(response.body);
          return true;
        });
      }
       catch (e)
      {  
       return false;
      }
    }
    else
    {
      return false;
    } 
  } 

   get() => this._result; 
}