import 'package:flutter/cupertino.dart';

class UploadSubmit {
  final String deliverID;
  final String batchNo;
  final FileImage signature;

  UploadSubmit({this.deliverID, this.batchNo, this.signature});

  factory UploadSubmit.fromJson(Map<String, dynamic> json) {
    return UploadSubmit(
        deliverID: json['deliverID'],
        batchNo: json['batchNo'],
        signature: json['signature']);
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["deliverID"] = deliverID;
    map["batchNo"] = batchNo;
    map["signature"] = signature;
    return map;
  }
}

class UploadReturn {
  final int apiReturn;
  final String apiMsg; 

  UploadReturn({this.apiReturn, this.apiMsg});

  factory UploadReturn.fromJson(Map<String, dynamic> parsedJson) {
    return UploadReturn(
      apiReturn: parsedJson['apiReturn'],
      apiMsg: parsedJson['apiMsg'], 
    );
  }
}
