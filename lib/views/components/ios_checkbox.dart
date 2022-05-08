import 'package:flutter/cupertino.dart';

import '../../class/checkbox_class.dart';

class IosCheckbox extends StatelessWidget {
  const IosCheckbox({Key? key, required this.data, required this.onChanged, this.margin}) : super(key: key);

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
          GestureDetector(
            onTap: () => this.onChanged(this.data),
            child: Stack(
              children: <Widget>[
                Icon(CupertinoIcons.check_mark, size: 27.0,
                  color: this.data.isChecked ? Color.fromRGBO(0,0,0, 1.0) : Color.fromRGBO(255, 255, 255, 0.0),),
                Positioned(
                  bottom: 5.0,
                  left: 5.0,
                  child: Container(
                    width: 14.0,
                    height: 14.0,
                    decoration: BoxDecoration(
                      border: Border.all(),
                    ),
                  ),
                ),
              ]
            ),
          ),
          Text(this.data.text, style: TextStyle(fontSize: 16.0),),
        ],
      ),
    );
  }
}
