import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';

class Utils{

  static unFocusTextField({required BuildContext context}) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.focusedChild?.unfocus();
    }
  }

  static Future<bool> askPermission(List<Permission> permissions) async{
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
      Permission.mediaLibrary,
      Permission.camera,
    ].request();

    if(statuses[permissions] == true)
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