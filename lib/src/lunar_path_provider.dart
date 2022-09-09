import 'dart:convert';
import 'dart:io';

class LunarPathProvider {
  static Map<String, dynamic> getAccountsJson() {
    return jsonDecode(
        File("${getAccountPath()}accounts.json").readAsStringSync());
  }

  static String getAccountPath() {
    return "C:\\Users\\Szczurek\\.lunarclient\\settings\\game\\";
  }
}
