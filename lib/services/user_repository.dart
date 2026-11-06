import 'dart:async';
import 'dart:convert';

import 'package:aebeze/app.dart';
import 'package:aebeze/services/model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserRepository {
  Future<bool> persistUser(User user) async {
    if (App.httpLogsOn) print("> persisting user : $user");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map map = user.toMap();
    return await prefs.setString("user", json.encode(map));
  }

  Future<User> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String value = prefs.getString("user");
    if (value == null) {
      if (App.httpLogsOn) print("> getUser: user is null");
      return null;
    }
    Map map = json.decode(value);
    User user = User.fromJson(map);
    if (App.httpLogsOn) print("> getUser: $user");
    return user;
  }

  Future<bool> reset() async {
    if (App.httpLogsOn) print("> resetting user");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.remove("user");
  }
}
