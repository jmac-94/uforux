import 'package:flutter/material.dart';

class DropdownButtonSelector extends StatefulWidget {
  final List<String> list;
  final void Function(String?)? onChanged;

  const DropdownButtonSelector({
    super.key,
    required this.list,
    this.onChanged,
  });

  @override
  State<DropdownButtonSelector> createState() => _DropdownButtonSelectorState();
}

class _DropdownButtonSelectorState extends State<DropdownButtonSelector> {
  String? dropdownValue;

  @override
  void initState() {
    super.initState();
    dropdownValue = widget.list.first;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      style: const TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (String? value) {
        setState(() {
          dropdownValue = value!;
          widget.onChanged?.call(value);
        });
      },
      items: widget.list.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}
