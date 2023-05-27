import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';

String adminUserName = 'admin';
String adminPassword = 'w@r3h0us3_@dm1n';

String appServer = 'Production';
String apiUrl = 'http://10.13.188.162/Galaxy/api_v2/?/apiNew';

// String appServer = 'Development';
// String apiUrl = 'http://10.245.11.47/Galaxy/api_v2/?/apiNew';

String apiSignatureFolder = '';

String appVersion = '2.2.0';
String appVersionName = '2.2.0';
String appName = 'Warehouse: CBS';
String apiLoginUrl = '$apiUrl/login';
String apiDeliveryUrl = '$apiUrl/delivery';
String apiZoneUrl = '$apiUrl/delivery_details';
String apiDetailsZoneUrl = '$apiUrl/details_zone';
String apiUpdateContUrl = '$apiUrl/update_cont';
String apiDDZoneUrl = '$apiUrl/dd_zone';
String apiLocationUrl = '$apiUrl/location';
String apiScanZoneUrl = '$apiUrl/delivery_details_zone';
String apiWarehouseScanUlr = '$apiUrl/update_cont';
String apiZoneBarcodeUrl = '$apiUrl/d_barcode';

String apiZoneContainerUrl = '$apiUrl/dd_cont_zone';
String apiContainerUrl = '$apiUrl/dd_cont';
String apiIssuingDeliveryUrl = '$apiUrl/d_loaded';
String apiIssuingScanUrl = '$apiUrl/update_status';
String apiTruckUrl = '$apiUrl/truck';
String apiDriverUrl = '$apiUrl/driver';
String apiShippingUrl = '$apiUrl/insert_da';
String apiShippingUpdateUrl = '$apiUrl/update_da';
String apiDeliveryUpdateUrl = '$apiUrl/update_deliver';
String apiIssuingScannedUrl = '$apiUrl/d_barcode';
String apiDetailsContTypeUrl = '$apiUrl/dd_contype';
String apiBatchUrl = '$apiUrl/d_batches';
String apiUploadUrl = '$apiUrl/upload_sign';
String apiWitnessUrl = '$apiUrl/d_witness';
String apiWitnessUpdateUrl = '$apiUrl/update_witness';
String apiDelDetContainerUrl = '$apiUrl/dd_cont_check';
String apiDelDetUpdaterUrl = '$apiUrl/update_dd_wh_cont';
String apiDelDetUpdateStatusUrl = '$apiUrl/update_dd_status';
String apiUpdateDelShipUrl = '$apiUrl/update_del_ship';
String apiDeliveryCountUrl = '$apiUrl/d_count';
String apiDOSContent = '$apiUrl/dos_content';
String appSettingsUrl = '$apiUrl/app_settings_warehouse';

String soundsPath = 'assets/sounds/';
String scanAudioFile = 'scanner.mp3';
String scanErrorAudioFile = 'error-scan.wav';

Flushbar flush;

class GlobalDialog {
  BuildContext context;
  String title;
  String message;
  int dismiss;

  GlobalDialog({this.context, this.title, this.message, this.dismiss});

  void showWarningDialog() {
    Flushbar(
      isDismissible: true,
      dismissDirection: FlushbarDismissDirection.HORIZONTAL,
      flushbarPosition: FlushbarPosition.TOP,
      margin: new EdgeInsets.fromLTRB(0, 0, 0, 80),
      boxShadows: [
        BoxShadow(
            color: Colors.blue[800], offset: Offset(0.0, 2.0), blurRadius: 3.0)
      ],
      backgroundGradient:
          LinearGradient(colors: [Colors.blueGrey, Colors.black]),
      showProgressIndicator: false,
      title: this.title,
      message: this.message,
      icon: Icon(
        Icons.warning,
        size: 28,
        color: Colors.white,
      ),
      backgroundColor: Colors.orange,
      duration: Duration(seconds: 5),
    ).show(context);
  }

  void showErrorDialog() {
    if (flush != null) {
      flush.dismiss(true);
    }
    flush = Flushbar(
      title: this.title,
      message: this.message,
      flushbarPosition: FlushbarPosition.TOP,
      flushbarStyle: FlushbarStyle.FLOATING,
      reverseAnimationCurve: Curves.decelerate,
      forwardAnimationCurve: Curves.elasticOut,
      backgroundColor: Colors.red,
      boxShadows: [
        BoxShadow(
            color: Colors.orange[800],
            offset: Offset(0.0, 2.0),
            blurRadius: 3.0)
      ],
      backgroundGradient:
          LinearGradient(colors: [Colors.blueGrey, Colors.orangeAccent]),
      isDismissible: true,
      duration: Duration(seconds: 4),
      icon: Icon(
        Icons.error_outline,
        color: Colors.white,
      ),
      mainButton: FlatButton(
        onPressed: () {
          flush.dismiss(true);
        },
        child: Text(
          "SEARCH",
          style: TextStyle(color: Colors.red),
        ),
      ),
      showProgressIndicator: false,
      progressIndicatorBackgroundColor: Colors.blueGrey,
      titleText: Text(
        this.title,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
            color: Colors.white,
            fontFamily: "ShadowsIntoLightTwo"),
      ),
      messageText: Text(
        this.message,
        style: TextStyle(
            fontSize: 18.0,
            color: Colors.white,
            fontFamily: "ShadowsIntoLightTwo"),
      ),
    );
    flush.show(context);
  }

  void showSuccessDialog() {
    Flushbar(
      isDismissible: true,
      dismissDirection: FlushbarDismissDirection.HORIZONTAL,
      flushbarPosition: FlushbarPosition.TOP,
      margin: new EdgeInsets.fromLTRB(0, 0, 0, 80),
      showProgressIndicator: false,
      title: this.title,
      message: this.message,
      icon: Icon(
        Icons.warning,
        size: 28,
        color: Colors.white,
      ),
      backgroundColor: Colors.green,
      duration: Duration(seconds: 5),
    ).show(context);
  }
}
