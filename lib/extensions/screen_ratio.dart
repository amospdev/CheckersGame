import 'package:flutter/cupertino.dart';

extension MediaQueryExtension on MediaQueryData {
  double get sizeByOrientation =>
      size.width > size.height ? size.height : size.width;
}
