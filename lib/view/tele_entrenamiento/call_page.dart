import 'package:flutter/material.dart';
import 'package:ogma_trainer/config/app_config.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class CallPage extends StatelessWidget {  
  final String userId;
  final String userName;
  final String callID;
  const CallPage({Key? key, required this.callID, required this.userId, required this.userName}) : super(key: key);
  

  @override
  Widget build(BuildContext context) {    
    return ZegoUIKitPrebuiltCall(
      appID: AppConfig.getAppId(), 
      appSign: AppConfig.getAppSign(),
      userID: userId,
      userName: userName,
      callID: callID,      
      config: ZegoUIKitPrebuiltCallConfig.groupVideoCall(),
    );
  }
}
