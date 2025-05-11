import 'package:flutter/material.dart';
import 'package:ogma_trainer/models/user_profile_data.dart';
import 'package:ogma_trainer/view/objectivo/define_tu_meta_page.dart';

class CualEsTuObjectivoView extends StatefulWidget {
  const CualEsTuObjectivoView({super.key});

  @override
  State<CualEsTuObjectivoView> createState() => _CualEsTuObjectivoViewState();
}

class _CualEsTuObjectivoViewState extends State<CualEsTuObjectivoView> {

  int selectPage = 0;
  PageController controller = PageController();
  final UserProfileData profileData = UserProfileData();

  @override
  Widget build(BuildContext context) {
    return DefineTuMetaPage(profileData: profileData);
  }
}