import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pink/http/dao/profile_dao.dart';
import 'package:flutter_pink/model/user_center_mo.dart';
import 'package:flutter_pink/navigator/hi_navigator.dart';
import 'package:flutter_pink/provider/theme_provider.dart';
import 'package:flutter_pink/util/bottom_sheet.dart';
import 'package:flutter_pink/util/button.dart';
import 'package:flutter_pink/util/color.dart';
import 'package:flutter_pink/util/format_util.dart';
import 'package:flutter_pink/util/hi_constants.dart';
import 'package:flutter_pink/util/toast.dart';
import 'package:flutter_pink/util/view_util.dart';
import 'package:flutter_pink/widget/navigation_bar.dart';
import 'package:hi_net/core/hi_error.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserMeta? _profileMo;
  Color _color = Colors.white;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    var themeProvider = context.watch<ThemeProvider>().isDark();
    if (themeProvider) {
      _color = HiColor.dark_bg;
    } else {
      _color = Colors.white;
    }
    return Scaffold(
        body: Stack(
      children: [
        Column(
          children: [
            NavigationBar(
              child: _appBar(),
            ),
            _profileMo != null
                ? Container(
                    color: _color,
                    child: _tabBar(),
                  )
                : Container(),
          ],
        ),
      ],
    ));
  }

  void _loadData() async {
    try {
      UserMeta result = await ProfileDao.get();
      setState(() {
        _profileMo = result;
      });
    } on NeedAuth catch (e) {
      showToast(e.message);
    } on NeedLogin catch (e) {
      showToast(e.message);
    } on HiNetError catch (e) {
      showToast(e.message);
    }
  }

  _appBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        appBarButton(Icons.bedtime_outlined, () {
          HiNavigator.getInstance().onJumpTo(RouteStatus.darkMode);
        }),
        appBarButton(Icons.color_lens_outlined, () {}),
        hiSpace(width: 15)
      ],
    );
  }

  _tabBar() {
    return Column(
      children: [
        InkWell(
          onTap: () {
            HiNavigator.getInstance().onJumpTo(RouteStatus.userCenter,
                args: {"profileMo": _profileMo, "type": "current_user"});
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(left: 10),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(60),
                    child:
                        cachedImage(_profileMo!.avatar, width: 60, height: 60)),
              ),
              Expanded(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: 15),
                        child: Text(
                          "${_profileMo!.username}",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      hiSpace(width: 2),
                      Icon(
                        Icons.male_outlined,
                        size: 14,
                        color: Colors.blue,
                      ),
                      hiSpace(width: 2),
                      Text(
                        "LV5",
                        style: TextStyle(
                            fontSize: 10,
                            color: Colors.red,
                            fontWeight: FontWeight.w800),
                      )
                    ],
                  ),
                  _profileMo!.isVip == "1"
                      ? Container(
                          margin: EdgeInsets.only(left: 15, top: 5),
                          padding: EdgeInsets.only(
                              left: 2, right: 2, top: 0, bottom: 0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            color: primary,
                          ),
                          child: Text(
                            "???????????????",
                            style: TextStyle(color: Colors.white, fontSize: 8),
                          ),
                        )
                      : Container(),
                  Container(
                    margin: EdgeInsets.only(left: 15, top: 5),
                    child: Text(
                      "B??????${_profileMo!.coin}    ?????????${_profileMo!.coin}",
                      style: TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                  ),
                ],
              )),
              Text(
                "??????",
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
              Container(
                margin: EdgeInsets.only(right: 10),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey,
                  size: 20,
                ),
              )
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 30, bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              mySpaceFollow(_profileMo!.active.toString(), "??????", onTap: () {
                HiNavigator.getInstance().onJumpTo(RouteStatus.starCoinLikePost,
                    args: {
                      "post_type": "dynamic",
                      "user_id": _profileMo!.userId
                    });
              }),
              longString(),
              mySpaceFollow(_profileMo!.fans.toString(), "??????", onTap: () {
                HiNavigator.getInstance()
                    .onJumpTo(RouteStatus.followFans, args: {"type": "fans"});
              }),
              longString(),
              mySpaceFollow(_profileMo!.follows.toString(), "??????", onTap: () {
                HiNavigator.getInstance()
                    .onJumpTo(RouteStatus.followFans, args: {"type": "follow"});
              }),
            ],
          ),
        ),
        _myServer(),
        _creationCenter(),
        _moreServer()
      ],
    );
  }

  _myServer() {
    return Container(
      padding: EdgeInsets.only(top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildIconText(Icons.cloud_download_outlined, "????????????",
              onClick: () {}, tint: true),
          _buildIconText(Icons.restore_outlined, "????????????",
              onClick: () {}, tint: true),
          _buildIconText(Icons.star_outline, "????????????", onClick: () {
            HiNavigator.getInstance().onJumpTo(RouteStatus.starCoinLikePost,
                args: {"post_type": "star", "user_id": _profileMo!.userId});
          }, tint: true),
          _buildIconText(Icons.watch_later_outlined, "????????????",
              onClick: () {}, tint: true),
        ],
      ),
    );
  }

  _creationCenter() {
    return Column(
      children: [
        Container(
            margin: EdgeInsets.only(top: 20, bottom: 10, left: 20, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "????????????",
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                      onTap: _openPublish,
                      child: Container(
                          padding: EdgeInsets.only(
                              top: 5, bottom: 5, left: 20, right: 20),
                          color: primary,
                          child: Row(
                            children: [
                              Icon(
                                Icons.file_upload,
                                color: Colors.white,
                                size: 18,
                              ),
                              Text(
                                "??????",
                                style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white),
                              ),
                            ],
                          ))),
                )
              ],
            )),
        Container(
          padding: EdgeInsets.only(top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildIconText(Icons.article_outlined, "????????????",
                  onClick: () {}, tint: true),
              _buildIconText(Icons.people_alt_outlined, "????????????", onClick: () {
                HiNavigator.getInstance()
                    .onJumpTo(RouteStatus.followFans, args: {"type": "fans"});
              }, tint: true),
              _buildIconText(Icons.supervised_user_circle, "????????????", onClick: () {
                HiNavigator.getInstance()
                    .onJumpTo(RouteStatus.followFans, args: {"type": "follow"});
              }, tint: true),
              _buildIconText(Icons.star_border_outlined, "????????????", onClick: () {
                HiNavigator.getInstance().onJumpTo(RouteStatus.starCoinLikePost,
                    args: {"post_type": "star", "user_id": _profileMo!.userId});
              }, tint: true),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.only(top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildIconText(Icons.thumb_up_alt_outlined, "????????????", onClick: () {
                HiNavigator.getInstance().onJumpTo(RouteStatus.starCoinLikePost,
                    args: {"post_type": "like", "user_id": _profileMo!.userId});
              }, tint: true),
              _buildIconText(Icons.thumb_down_alt_outlined, "????????????",
                  onClick: () {
                HiNavigator.getInstance().onJumpTo(RouteStatus.starCoinLikePost,
                    args: {
                      "post_type": "unlike",
                      "user_id": _profileMo!.userId
                    });
              }, tint: true),
              _buildIconText(Icons.monetization_on_outlined, "????????????",
                  onClick: () {
                HiNavigator.getInstance().onJumpTo(RouteStatus.starCoinLikePost,
                    args: {"post_type": "coin", "user_id": _profileMo!.userId});
              }, tint: true),
              _buildIconText(Icons.drive_file_move_outline, "????????????",
                  onClick: () {
                HiNavigator.getInstance().onJumpTo(RouteStatus.starCoinLikePost,
                    args: {
                      "post_type": "video",
                      "user_id": _profileMo!.userId
                    });
              }, tint: true),
            ],
          ),
        ),
      ],
    );
  }

  _moreServer() {
    return Column(
      children: [
        Container(
            margin: EdgeInsets.only(top: 20, bottom: 10, left: 20, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "????????????",
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            )),
        Container(
          padding: EdgeInsets.only(top: 10),
          child: Column(
            children: [
              _bottomMenu("????????????", Icons.support_agent_outlined, () async {
                // android ??? ios ??? QQ ?????? url scheme ????????????
                var url;
                if (Platform.isAndroid) {
                  url = 'mqqwpa://im/chat?chat_type=wpa&uin=${HiConstants.qq}';
                } else {
                  url =
                      'mqq://im/chat?chat_type=wpa&uin=${HiConstants.qq}&version=1&src_type=web';
                }
                // ????????????url???????????????
                if (await canLaunch(url)) {
                  await launch(url); // ??????QQ
                } else {
                  // ????????????????????? Toast
                  showWarnToast('????????????QQ');
                }
              }),
              _bottomMenu("??????", Icons.settings_outlined, () {
                HiNavigator.getInstance().onJumpTo(RouteStatus.setting);
              })
            ],
          ),
        ),
      ],
    );
  }

  _buildIconText(IconData iconData, text, {onClick, bool tint = false}) {
    if (text is int) {
      text = countFormat(text);
    } else if (text == null) {
      text = "";
    }
    tint = tint == null ? false : tint;
    return InkWell(
      onTap: onClick,
      child: Column(
        children: [
          Icon(
            iconData,
            size: 26,
            color: tint ? primary : Colors.grey,
          ),
          hiSpace(height: 5),
          Text(
            text,
            style: TextStyle(color: Colors.grey, fontSize: 12),
          )
        ],
      ),
    );
  }

  _bottomMenu(String text, IconData icon, GestureTapCallback onTap) {
    return Container(
      padding: EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Icon(
              icon,
              size: 26,
              color: primary,
            ),
            hiSpace(width: 10),
            Expanded(child: Text(text)),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  _openPublish() {
    moreHandleDialog(
        context,
        1,
        Container(
          color: Color.fromRGBO(242, 242, 242, 1),
          child: Stack(
            children: [
              Positioned(
                bottom: 30,
                left: 5,
                right: 5,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width / 2 - 21,
                          margin: EdgeInsets.all(8),
                          child: publishButton("????????????", Icons.post_add_outlined,
                              () {
                            Navigator.of(context).pop();
                            HiNavigator.getInstance().onJumpTo(
                                RouteStatus.publish,
                                args: {"type": "post"});
                          }, isSpace: true),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width / 2 - 21,
                          margin: EdgeInsets.all(8),
                          child:
                              publishButton("????????????", Icons.movie_outlined, () {
                            Navigator.of(context).pop();
                            HiNavigator.getInstance().onJumpTo(
                                RouteStatus.publish,
                                args: {"type": "video"});
                          }, isSpace: true),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width / 3 - 19.33,
                          margin: EdgeInsets.all(8),
                          child: publishButton(
                              "?????????", Icons.dynamic_feed_outlined, () {
                            Navigator.of(context).pop();
                            HiNavigator.getInstance().onJumpTo(
                                RouteStatus.publish,
                                args: {"type": "dynamic"});
                          }),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width / 3 - 19.33,
                          margin: EdgeInsets.all(8),
                          child: publishButton(
                              "?????????", Icons.music_note_outlined, () {}),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width / 3 - 19.34,
                          margin: EdgeInsets.all(8),
                          child: publishButton(
                              "?????????", Icons.video_call_outlined, () {}),
                        )
                      ],
                    )
                  ],
                ),
              ),
              Positioned(
                  top: 30,
                  left: 10,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Icon(Icons.close_outlined),
                    style: ButtonStyle(
                      //????????????????????? ???????????????????????????????????????
                      textStyle: MaterialStateProperty.all(
                          TextStyle(fontSize: 18, color: Colors.white)),
                      //???????????????????????????????????????
                      //foregroundColor: MaterialStateProperty.all(Colors.deepPurple),
                      //???????????????????????????
                      foregroundColor: MaterialStateProperty.resolveWith(
                        (states) {
                          if (states.contains(MaterialState.focused) &&
                              !states.contains(MaterialState.pressed)) {
                            //????????????????????????
                            return Colors.grey[400];
                          } else if (states.contains(MaterialState.pressed)) {
                            //??????????????????
                            return Colors.grey[400];
                          }
                          //????????????????????????
                          return Colors.grey[400];
                        },
                      ),
                      //????????????
                      backgroundColor:
                          MaterialStateProperty.resolveWith((states) {
                        //??????????????????????????????
                        if (states.contains(MaterialState.pressed)) {
                          return Colors.grey[300];
                        }
                        //???????????????????????????
                        return Colors.grey[300];
                      }),
                      //?????????????????????
                      overlayColor: MaterialStateProperty.all(Colors.grey[300]),
                      //????????????  ?????????????????????TextButton
                      elevation: MaterialStateProperty.all(0),
                      //?????????????????????
                      padding: MaterialStateProperty.all(EdgeInsets.all(4)),
                      //?????????????????????
                      minimumSize: MaterialStateProperty.all(Size(20, 20)),

                      //??????????????? ????????? side ???????????????
                      shape: MaterialStateProperty.all(StadiumBorder()),
                    ),
                  ))
            ],
          ),
        ));
  }
}
