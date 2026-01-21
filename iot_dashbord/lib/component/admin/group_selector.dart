import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iot_dashboard/component/admin/action_button.dart';
import 'package:iot_dashboard/controller/user_controller.dart';
import 'package:iot_dashboard/component/common/dialog_form.dart';
import 'package:provider/provider.dart';
import 'package:iot_dashboard/state/user_role_state.dart'; // 직접 만든 클래스 경로

class GroupSelector extends StatefulWidget {
  final List<String> sourceRoles; // 왼쪽 리스트 조건 (포함할 역할)
  final String targetRole;         // 오른쪽 대상 역할
  final String? hintText;          // 설명 텍스트 (선택)
  final String demoteRole;
  final VoidCallback? onSaved;     // 저장 콜백

  const GroupSelector({
    Key? key,
    required this.sourceRoles,
    required this.targetRole,
    this.hintText,
    required this.demoteRole,
    this.onSaved,

  }) : super(key: key);

  @override
  State<GroupSelector> createState() => _GroupSelectorState();
}



class _GroupSelectorState extends State<GroupSelector> {
  List<String> availableUsers = [];
  List<String> selectedUsers = [];

  String searchTerm = "";

  String? selectedLeftUser;
  String? selectedRightUser;

  List<String> get filteredAvailableUsers =>
      availableUsers.where((user) => user.contains(searchTerm)).toList();
  @override
  void initState() {
    super.initState();
    // ✅ context가 아직 mount되지 않은 시점이므로 addPostFrameCallback 사용
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final roleState = Provider.of<UserRoleState>(context, listen: false);
      if (roleState.userRoles.isNotEmpty) {
        _fetchUsersByRole();
      } else {
        // 상태가 아직 비었을 경우, 상태 변화 감지하여 호출
        roleState.addListener(_fetchUsersByRole);
      }
    });
  }

  Future<void> _fetchUsersByRole() async {
    final roleState = Provider.of<UserRoleState>(context, listen: false);
    final allUsers = roleState.userRoles.entries
        .where((e) => widget.sourceRoles.contains(e.value))
        .map((e) => e.key)
        .toList();
    final selected = roleState.userRoles.entries
        .where((e) => e.value == widget.targetRole)
        .map((e) => e.key)
        .toList();

    setState(() {
      availableUsers = allUsers.where((id) => !selected.contains(id)).toList();
      selectedUsers = selected;

    });
  }

  bool get _hasChanges {
    final currentRoles = Provider.of<UserRoleState>(context, listen: false).userRoles;
    final selectedChanged = selectedUsers.any((u) => currentRoles[u] != widget.targetRole);
    final availableChanged = availableUsers.any((u) => currentRoles[u] != widget.demoteRole);
    return selectedChanged || availableChanged;
  }

  void _updateRoles() async {
    try {
      final roleState = Provider.of<UserRoleState>(context, listen: false);
      final promoteTargetIDs = selectedUsers;
      final demoteTargetIDs = availableUsers;

      final promoteSuccess =
      await UserController.updateUserRoles(promoteTargetIDs, widget.targetRole);
      final demoteSuccess =
      await UserController.updateUserRoles(demoteTargetIDs, widget.demoteRole);

      if (promoteSuccess && demoteSuccess) {
        await roleState.fetchRoles();
        await _fetchUsersByRole();
        if (widget.onSaved != null) widget.onSaved!();

        showDialog(
          context: context,
          builder: (_) => const DialogForm(
            mainText: '역할이 성공적으로 업데이트되었습니다.',
            btnText: '확인',
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (_) => const DialogForm(
            mainText: '일부 역할 업데이트에 실패했습니다.',
            btnText: '확인',
          ),
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (_) => DialogForm(
          mainText: '오류 발생: $e',
          btnText: '확인',
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      width: 2426.w,
      height: 880.h,
      color: const Color(0xff414c67),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserListPanel("이용 가능한 ID", filteredAvailableUsers,
              isLeft: true),
          SizedBox(
            width: 45.w,
          ),
          Column(
            children: [
              SizedBox(
                height: 283.h,
              ),
              _buildMoveButtons(),
            ],
          ),
          SizedBox(
            width: 45.w,
          ),
          _buildUserListPanel("선택된 ID", selectedUsers, isLeft: false),
          SizedBox(
            width: 170.w,
          ),
          Column(
            children: [
              SizedBox(height:818.h,),
              Container(
                child:       ActionButton(
                  '저장',
                  _hasChanges ? const Color(0xff3182ce) : Colors.grey,
                  onTap: _hasChanges ? _updateRoles : null,
                ),
              ),

            ],
          )


        ],
      ),
    );
  }

  Widget _buildUserListPanel(String title, List<String> users,
      {required bool isLeft}) {
    return Container(
      width: 980.w,
      child: Column(
        children: [
          Container(
            height: 80.h,
            color: Colors.grey[300],
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Text(title,
                style: TextStyle(
                    fontSize: 36.sp,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'PretendardGOV',
                    color: Color(0xff474747))),
          ),
          if (isLeft) _buildSearchBox(),
          Expanded(
            child: Container(
              color: Colors.white,
              child: ScrollbarTheme(
                data: ScrollbarThemeData(
                  thumbVisibility: MaterialStateProperty.all(true),
                  thickness: MaterialStateProperty.all(8.w),
                  radius: Radius.circular(4.r),
                  thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
                    if (states.contains(MaterialState.dragged)) {
                      return const Color(0xff3182ce); // 드래그 중
                    } else if (states.contains(MaterialState.hovered)) {
                      return const Color(0xff64a5f5); // 호버 중
                    }
                    return const Color(0xff3182ce); // 기본 파란색
                  }),
                ),
                child: Scrollbar(
                  interactive: true,
                  trackVisibility: true,
                  child: ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      final isSelected = isLeft
                          ? selectedLeftUser == user
                          : selectedRightUser == user;
                      return Container(
                        color: isSelected ? Colors.lightBlue[100] : null,
                        child: ListTile(
                          title: Text(
                            user,
                            style: TextStyle(
                              color: isSelected ? Colors.black : Colors.grey,
                              fontSize: 28.sp,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              fontFamily: 'PretendardGOV',
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              if (isLeft) {
                                selectedLeftUser = user;
                                selectedRightUser = null;
                              } else {
                                selectedRightUser = user;
                                selectedLeftUser = null;
                              }
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),



          SizedBox(height: 8.h),
          TextButton.icon(
            onPressed: () {
              setState(() {
                if (isLeft) {
                  selectedUsers.addAll(filteredAvailableUsers);
                  availableUsers.removeWhere(
                      (user) => filteredAvailableUsers.contains(user));
                  selectedLeftUser = null;
                } else {
                  availableUsers.addAll(selectedUsers);
                  selectedUsers.clear();
                  selectedRightUser = null;
                }
              });
            },
            icon: Icon(
              isLeft
                  ? Icons.arrow_circle_right_outlined
                  : Icons.arrow_circle_left_outlined,
              color: Color(0xff718ebf),
              size: 50.w,
            ),
            label: Text(
              isLeft ? "모두 선택" : "모두 제거",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 36.sp,
                fontFamily: 'Pretendard',
              ),
            ),
          ),
          SizedBox(height: 12.h),
          isLeft
              ? Container(
                  height: 50.h,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Text(
                        "${widget.hintText}",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24.sp,
                            fontFamily: 'PretendardGOV',
                            fontWeight: FontWeight.w400),
                      )
                    ],
                  ),
                )
              : Container(
                  height: 50.h,
            alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Text(
                        "",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24.sp,
                            fontFamily: 'PretendardGOV',
                            fontWeight: FontWeight.w400),
                      ),

                    ],
                  ),
                )
        ],
      ),
    );
  }

  Widget _buildSearchBox() {
    return Container(
      height: 93.h,
      color: Colors.white,
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.h,
            child: const Icon(Icons.search),
          ),
          SizedBox(
            width: 32.w,
          ),
          Container(
            width: 858.w,
            height: 60.h,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Color(0xffd7dedd), width: 1.w),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: TextField(
              textAlignVertical: TextAlignVertical.center,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 36.sp,
                  fontFamily: 'PretendardGOV',
                  fontWeight: FontWeight.w300),
              decoration: InputDecoration(
                hintText: '검색',
                hintStyle: TextStyle(
                    fontSize: 36.sp,
                    fontWeight: FontWeight.w300,
                    fontFamily: 'PretendardGOV',
                    color: Color(0xff9ea3a2)),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              ),
              onChanged: (value) => setState(() => searchTerm = value),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMoveButtons() {
    return Container(
      width: 60.w,
      height: 160.h,
      decoration: BoxDecoration(
        color: Color(0xffd9d9d9),
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            padding: EdgeInsets.zero, // ✅ 패딩 제거
            constraints: BoxConstraints(), // ✅ 제약 조건 제거
            onPressed: selectedLeftUser != null
                ? () {
                    setState(() {
                      availableUsers.remove(selectedLeftUser);
                      selectedUsers.add(selectedLeftUser!);
                      selectedLeftUser = null;
                    });
                  }
                : null,
            icon: Icon(Icons.arrow_circle_right_outlined,
                color: Color(0xff718ebf), size: 60.w),
          ),
          SizedBox(height: 27.h),
          IconButton(
            padding: EdgeInsets.zero, // ✅ 패딩 제거
            constraints: BoxConstraints(), // ✅ 제약 조건 제거
            onPressed: selectedRightUser != null
                ? () {
                    setState(() {
                      selectedUsers.remove(selectedRightUser);
                      availableUsers.add(selectedRightUser!);
                      selectedRightUser = null;
                    });
                  }
                : null,
            icon: Icon(Icons.arrow_circle_left_outlined,
                color: Color(0xff718ebf), size: 60.w),
          ),
        ],
      ),
    );
  }
}
