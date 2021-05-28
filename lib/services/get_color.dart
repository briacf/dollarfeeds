import 'package:flutter/material.dart';
import 'sanitize_name.dart';

Color getThemeColor(BuildContext context) {
  if (MediaQuery.of(context).platformBrightness == Brightness.dark) {
    return Color(0xFF313131);
  }
  return Color(0xFFf7f7f7);
}

Color getTextFieldColor(BuildContext context) {
  if (MediaQuery.of(context).platformBrightness == Brightness.dark) {
    return Colors.grey[800];
  }
  return Colors.grey[200];
}

getErrorColor(BuildContext context) {
  if (MediaQuery.of(context).platformBrightness == Brightness.dark) {
    return Color(0xFFd86666);
  }
  return Color(0xFFbf0000);
}

getHighlightedColor(BuildContext context) {
  if (MediaQuery.of(context).platformBrightness == Brightness.dark) {
    return Color(0xFF9bc0ff);
  }
  return Color(0xFF2d2da3);
}

getShadowColor(BuildContext context) {
  if (MediaQuery.of(context).platformBrightness == Brightness.dark) {
    return Color(0xFF1d1c1b);
  }
  return Color(0xFFadadad);
}

Color getColor(var name) {
  name = sanitizeName(name);

  if (name == "default") {
    return Color(0xFFefba55);
  } else if (name == "nearby") {
    return Color(0xFF4698e3);
  } else if (name == "search") {
    return Color(0xFF00bd72);
  } else if (name == "favourites") {
    return Color(0xFFff4847);
  } else if (name == "hungryjacks") {
    return Color(0xFFe58200);
  } else if (name == "dominos") {
    return Color(0xFF352ab2);
  } else if (name == "mcdonalds") {
    return Color(0xFF950000);
  } else if (name == "subway") {
    return Color(0xFF154c1f);
  } else if (name == "pizzahut") {
    return Color(0xFFba193f);
  } else if (name == "kfc") {
    return Color(0xFFcb9d7e);
  } else if (name == "redrooster") {
    return Color(0xFF720c0c);
  } else if (name == "madmex") {
    return Color(0xFF176839);
  } else if (name == "starbucks") {
    return Color(0xFF1c6100);
  } else if (name == "guzmanygomez") {
    return Color(0xFFffb900);
  } else if (name == "merlocoffee") {
    return Color(0xFF167cb9);
  } else if (name == "carlsjr") {
    return Color(0xFFd14035);
  } else if (name == "7eleven") {
    return Color(0xFF1fb982);
  } else if (name == "tacobell") {
    return Color(0xFF56185e);
  } else if (name == "nandos") {
    return Color(0xFF4c0000);
  } else if (name == "oporto") {
    return Color(0xFFb75632);
  } else if (name == "pizzacapers") {
    return Color(0xFFcc451b);
  } else if (name == "alibaba") {
    return Color(0xFF8b0000);
  } else if (name == "krispykreme") {
    return Color(0xFF22594A);
  } else if (name == "ubereats") {
    return Color(0xFF838897);
  } else if (name == "menulog") {
    return Color(0xFF4ebf6e);
  } else if (name == "deliveroo") {
    return Color(0xFF91cde0);
  } else if (name == "skip") {
    return Color(0xFFf47153);
  }

  return Colors.grey[800];
}

// 4 colors used for each gradient
List<Color> getGradientColors(var name) {
  name = sanitizeName(name);
  if (name == "hungryjacks") {
    return [
      Color(0xFFeca74c),
      Color(0xFFea9b32),
      Color(0xFFe78e19),
      Color(0xFFe58200),
    ];
  } else if (name == "dominos") {
    return [
      Color(0xFF7169c9),
      Color(0xFF5d54c1),
      Color(0xFF493fb9),
      Color(0xFF352ab2),
    ];
  } else if (name == "mcdonalds") {
    return [
      Color(0xFFb44c4c),
      Color(0xFFaa3232),
      Color(0xFF9f1919),
      Color(0xFF950000),
    ];
  } else if (name == "subway") {
    return [
      Color(0xFF5b8162),
      Color(0xFF436f4b),
      Color(0xFF436f4b),
      Color(0xFF154c1f),
    ];
  } else if (name == "pizzahut") {
    return [
      Color(0xFFb25757),
      Color(0xFFa73e3e),
      Color(0xFF9c2626),
      Color(0xFF920f0f),
    ];
  } else if (name == "kfc") {
    return [
      Color(0xFFdabaa4),
      Color(0xFFd5b097),
      Color(0xFFd0a68a),
      Color(0xFFcb9d7e),
    ];
  } else if (name == "redrooster") {
    return [
      Color(0xFF9c5454),
      Color(0xFF8e3c3c),
      Color(0xFF802424),
      Color(0xFF720c0c),
    ];
  } else if (name == "starbucks") {
    return [
      Color(0xFF60904c),
      Color(0xFF498032),
      Color(0xFF327019),
      Color(0xFF1c6100),
    ];
  } else if (name == "merlocoffee") {
    return [
      Color(0xFF5ba3ce),
      Color(0xFF4496c7),
      Color(0xFF2d89c0),
      Color(0xFF167cb9),
    ];
  } else if (name == "7eleven") {
    return [
      Color(0xFF62cea7),
      Color(0xFF4bc79b),
      Color(0xFF35c08e),
      Color(0xFF1fb982),
    ];
  } else if (name == "madmex") {
    return [
      Color(0xFF5c9574),
      Color(0xFF458660),
      Color(0xFF2e774c),
      Color(0xFF176839),
    ];
  } else if (name == "guzmanygomez") {
    return [
      Color(0xFFffce4c),
      Color(0xFFffc732),
      Color(0xFFffc019),
      Color(0xFFffb900),
    ];
  } else if (name == "nandos") {
    return [
      Color(0xFF814c4c),
      Color(0xFF6f3232),
      Color(0xFF5d1919),
      Color(0xFF4c0000),
    ];
  } else if (name == "oporto") {
    return [
      Color(0xFFcf8e76),
      Color(0xFFc77c60),
      Color(0xFFbf6949),
      Color(0xFFb75632),
    ];
  } else if (name == "pizzacapers") {
    return [
      Color(0xFFdb7c5f),
      Color(0xFFd66a48),
      Color(0xFFd15731),
      Color(0xFFcc451b),
    ];
  } else if (name == "alibaba") {
    return [
      Color(0xFFad4c4c),
      Color(0xFFa23232),
      Color(0xFF961919),
      Color(0xFF8b0000),
    ];
  } else if (name == "krispykreme") {
    return [
      Color(0xFF648a80),
      Color(0xFF4e7a6e),
      Color(0xFF38695c),
      Color(0xFF22594A),
    ];
  } else if (name == "ubereats") {
    return [
      Color(0xFFa8abb6),
      Color(0xFF9b9fab),
      Color(0xFF8f93a1),
      Color(0xFF838897),
    ];
  } else if (name == "menulog") {
    return [
      Color(0xFF83d299),
      Color(0xFF71cb8b),
      Color(0xFF5fc57c),
      Color(0xFF4ebf6e),
    ];
  } else if (name == "deliveroo") {
    return [
      Color(0xFFb2dce9),
      Color(0xFFa7d7e6),
      Color(0xFF9cd2e3),
      Color(0xFF91cde0),
    ];
  } else if (name == "skip") {
    return [
      Color(0xFFf79b86),
      Color(0xFFf68d75),
      Color(0xFFf57f64),
      Color(0xFFf47153),
    ];
  }

  return [
    Colors.grey[800],
    Colors.grey[800],
    Colors.grey[800],
    Colors.grey[800]
  ];
}
