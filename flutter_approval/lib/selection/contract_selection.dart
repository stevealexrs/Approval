import 'package:flutter/material.dart';

class ContractSelection extends StatelessWidget {
  const ContractSelection(
      {super.key, required this.currentValueController, required this.onPaste});

  final TextEditingController currentValueController;
  final void Function() onPaste;

  @override
  Widget build(BuildContext context) {
    return TextField(
        controller: currentValueController,
        decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: "Contract Address",
            suffixIcon:
                IconButton(onPressed: onPaste, icon: const Icon(Icons.paste))));
  }
}
