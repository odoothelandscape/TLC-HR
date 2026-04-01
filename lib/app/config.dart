import 'package:shared_preferences/shared_preferences.dart';

class Config {
  static const url = 'https://thelandscape.odoo.com/';
  static const database = 'upward-landscape-production-11343869';

  static loadConfigInfo() async {
    var pref = await SharedPreferences.getInstance();
    var urlVar = pref.getString('url');
    var databaseVar = pref.getString('database');
    if (urlVar == '' || urlVar == null) {
      await pref.setString('url', url);
    }
    if (databaseVar == '' || databaseVar == null) {
      await pref.setString('database', database);
    }
  }
}
