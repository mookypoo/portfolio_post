import 'package:flutter/material.dart';

import '../../class/checkbox_class.dart';

class AndroidCheckbox extends StatelessWidget {
  const AndroidCheckbox({Key? key, required this.data, required this.onChanged, this.margin}) : super(key: key);

  final CheckboxClass data;
  final void Function(CheckboxClass c) onChanged;
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35.0,
      margin: this.margin ?? null,
      child: Row(
        children: <Widget>[
          Checkbox(value: this.data.isChecked, onChanged: (bool? b) => this.onChanged(this.data), side: BorderSide(color: Color.fromRGBO(196, 199, 199, 1.0),),),
          Text(this.data.text, style: TextStyle(fontSize: 16.0),),
        ],
      ),
    );
  }
}