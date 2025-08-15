import 'package:article_spinner/text_spinner_state.dart';
import 'package:article_spinner/widget/bg.dart';
import 'package:article_spinner/widget/input_and_spun_text.dart';
import 'package:article_spinner/widget/replacements.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TextSpinnerPage extends StatelessWidget {
  const TextSpinnerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TextSpinnerState(),
      child: Consumer(
        builder: (BuildContext context, TextSpinnerState state, _) {
          return Stack(
            children: [
              BgTextSpinner(),
              Scaffold(
                backgroundColor: Colors.transparent,
                body: Row(
                  children: [
                    // Input & Spun Text
                    Expanded(flex: 2, child: InputAndSpunText(state: state)),
                    // Replacements
                    Expanded(flex: 1, child: Replacements(state: state)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
