import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
class Loading{
  ProgressDialog pr;

  
   Loading(context){
      pr = new ProgressDialog(context,type: ProgressDialogType.Normal);
      //Optional
      pr.style(
        message: 'Loading, please wait...',
        borderRadius: 5.0,
        backgroundColor: Colors.white,
        progressWidget:  Image.asset('assets/img/loading-2.gif'),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        progressTextStyle: TextStyle(
            color: Colors.black, fontSize: 12.0, fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: 12.0, fontWeight: FontWeight.w600),
      );
    }

  ProgressDialog load(){
      return pr;
    }
}