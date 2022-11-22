import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';

class Utils{

  static unFocusTextField({required BuildContext context}) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.focusedChild?.unfocus();
    }
  }

  static Future<bool> askPermission() async{
    PermissionStatus status = await Permission.storage.request();
    if(status.isDenied == true)
    {
      //openAppSettings();
      return false;
    }
    else
    {
      return true;
    }
  }
}