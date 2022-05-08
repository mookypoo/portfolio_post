class CheckboxClass {
  final String text;
  final bool isChecked;

  CheckboxClass({required this.text, this.isChecked = false});

  factory CheckboxClass.onTap(CheckboxClass c) => CheckboxClass(
    text: c.text, isChecked: !c.isChecked
  );

  factory CheckboxClass.reset(CheckboxClass c) => CheckboxClass(
    text: c.text, isChecked: false,
  );
}