import 'package:delern_flutter/flutter/styles.dart' as app_styles;
import 'package:flutter/material.dart';

typedef TextChangedCallback = void Function(String text);

class CardSideInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final TextChangedCallback onTextChanged;
  final FocusNode focusNode;
  final bool autofocus;
  final String hint;

  const CardSideInputWidget({
    @required Key key,
    @required this.controller,
    @required this.onTextChanged,
    @required this.hint,
    this.focusNode,
    this.autofocus = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    hint,
                    style: app_styles.primaryText
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              TextField(
                autofocus: autofocus,
                focusNode: focusNode,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                controller: controller,
                onChanged: onTextChanged,
                style: app_styles.primaryText,
              ),
            ],
          ),
        ),
      );
}
