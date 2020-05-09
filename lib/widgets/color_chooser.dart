import 'package:flutter/material.dart';
import 'package:chain_reaction_game/utils/constants.dart';
import 'package:chain_reaction_game/widgets/orb_button.dart';

class ColorChooser extends StatefulWidget {
  final String activeColor;
  final bool disabled;
  final List<String> disableColors;
  final Function onSelection;

  ColorChooser(
      {Key key,
      this.activeColor = '',
      this.disabled = false,
      this.disableColors = const [],
      this.onSelection})
      : super(key: key);

  _ColorChooserState createState() => _ColorChooserState();
}

class _ColorChooserState extends State<ColorChooser> {
  List<String> colors = PlayerColors;
  String selectedColor = '';

  @override
  void didUpdateWidget(ColorChooser oldWidget) {
    selectedColor =
        widget.activeColor != '' ? widget.activeColor : selectedColor;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: colors.map((color) {
          bool disabled = widget.disabled;
          if (widget.disableColors.length > 0 &&
              widget.disableColors.indexOf(color) > -1) {
            disabled = true;
          }
          return OrbButton(
              color: color,
              width: (MediaQuery.of(context).size.width / 5) - 8,
              height: 60.0,
              isSelected: selectedColor == color,
              onPressed: () {
                if (widget.onSelection != null && !disabled) {
                  setState(() {
                    selectedColor = color;
                  });
                  widget.onSelection(selectedColor);
                }
              });
        }).toList(),
      ),
    );
  }
}
