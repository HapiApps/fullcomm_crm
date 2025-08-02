

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';


final SharedPref sharedPref = SharedPref._();

class SharedPref {
  SharedPref._();

  read(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return json.decode(prefs.getString(key)!);
    //return prefs.getString(key);
  }

  save(String key, value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, json.encode(value));
    //prefs.setString(key,value);
  }

  remove(String key)async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }

}