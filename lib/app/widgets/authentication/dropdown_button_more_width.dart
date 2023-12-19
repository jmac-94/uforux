import 'package:flutter/material.dart';

class CustomDropdownField extends StatelessWidget {
  final List<String> items;
  final ValueChanged<String?>? onChanged;
  final FormFieldValidator<String>? validator;
  final FormFieldSetter<String>? onSaved;
  final Color backgroundColor;
  final String hintText;

  const CustomDropdownField({
    super.key,
    required this.items,
    this.onChanged,
    this.validator,
    this.onSaved,
    this.backgroundColor = const Color.fromARGB(255, 178, 167, 202),
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color.fromARGB(255, 68, 35, 176),
          ),
          fillColor: backgroundColor,
          filled: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
          border: border(),
          enabledBorder: border(),
          focusedBorder: border(),
          disabledBorder: border(),
        ),
        items: items.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: const TextStyle(
                color: Color.fromARGB(255, 68, 35, 176),
              ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        validator: validator,
        onSaved: onSaved,
      ),
    );
  }

  border() {
    return const OutlineInputBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(10.0),
      ),
      borderSide: BorderSide(
        color: Color.fromARGB(255, 178, 167, 202),
        width: 1.0,
      ),
    );
  }
}
