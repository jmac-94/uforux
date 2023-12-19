import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String? initialValue;
  final bool? enabled;
  final String? hintText;
  final TextInputType? textInputType;
  final TextEditingController? controller;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode, nextFocusNode;
  final VoidCallback? submitAction;
  final bool obscureText;
  final FormFieldValidator<String>? validateFunction;
  final void Function(String?)? onSaved, onChange;
  final Color backgroundColor;
  final int? maxLines;

  const CustomTextField({
    this.initialValue,
    this.enabled,
    this.hintText,
    this.textInputType,
    this.controller,
    this.textInputAction,
    this.focusNode,
    this.nextFocusNode,
    this.submitAction,
    this.obscureText = false,
    this.validateFunction,
    this.onSaved,
    this.onChange,
    this.backgroundColor = const Color.fromARGB(255, 178, 167, 202),
    this.maxLines = 1,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: TextFormField(
          maxLines: maxLines,
          initialValue: initialValue,
          enabled: enabled,
          onChanged: onChange,
          style: const TextStyle(
            fontSize: 15.0,
          ),
          key: key,
          controller: controller,
          obscureText: obscureText,
          keyboardType: textInputType,
          validator: validateFunction,
          onSaved: onSaved,
          textInputAction: textInputAction,
          focusNode: focusNode,
          onFieldSubmitted: (String term) {
            if (nextFocusNode != null) {
              focusNode!.unfocus();
              FocusScope.of(context).requestFocus(nextFocusNode);
            } else {
              submitAction!();
            }
          },
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
          )),
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
