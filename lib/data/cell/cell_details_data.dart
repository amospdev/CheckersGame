import 'package:flutter/material.dart';

class CellDetailsData {
  final Color tmpColor;

  CellDetailsData({
    required this.tmpColor,
  });

  static CellDetailsData createEmpty() =>
      CellDetailsData(tmpColor: Colors.transparent);

}
