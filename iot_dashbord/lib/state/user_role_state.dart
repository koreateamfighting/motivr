import 'package:flutter/material.dart';
import 'package:iot_dashboard/controller/user_controller.dart';

class UserRoleState extends ChangeNotifier {
  Map<String, String> userRoles = {}; // { userID: role }

  Future<void> fetchRoles() async {
    final allRoles = await UserController.getAllUsersAndRoles(); // 새로운 API 필요
    userRoles = allRoles;
    notifyListeners();
  }

  Future<void> updateRoles(List<String> ids, String newRole) async {
    final success = await UserController.updateUserRoles(ids, newRole);
    if (success) {
      for (final id in ids) {
        userRoles[id] = newRole;
      }
      notifyListeners();
    }
  }
}
