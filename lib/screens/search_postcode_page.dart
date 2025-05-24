// lib/screens/search_postcode_page.dart

import 'package:flutter/material.dart';
import 'package:daum_postcode_view/daum_postcode_view.dart';

class SearchPostcodePage extends StatelessWidget {
  static const String routeName = '/postcode';

  const SearchPostcodePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DaumPostcodeView(
        onComplete: (model) {
          Navigator.of(context).pop(model.address); // ✅ address만 넘김
        },
        options: const DaumPostcodeOptions(
          animation: true,
          hideEngBtn: true,
          themeType: DaumPostcodeThemeType.defaultTheme,
        ),
      ),
    );
  }
}
