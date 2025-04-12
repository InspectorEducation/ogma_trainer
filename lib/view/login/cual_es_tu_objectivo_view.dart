import 'package:flutter/material.dart';
import 'package:ogma_trainer/view/objectivo/define_tu_meta_page.dart';

class CualEsTuObjectivoView extends StatefulWidget {
  const CualEsTuObjectivoView({super.key});

  @override
  State<CualEsTuObjectivoView> createState() => _CualEsTuObjectivoViewState();
}

class _CualEsTuObjectivoViewState extends State<CualEsTuObjectivoView> {

  int selectPage = 0;
  PageController controller = PageController();

  @override
  Widget build(BuildContext context) {
    return DefineTuMetaPage();
  }
}