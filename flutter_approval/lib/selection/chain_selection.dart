import 'package:flutter/material.dart';
import 'package:flutter_approval/blockchain/chain.dart';
import 'package:flutter_approval/blockchain/chain_readable.dart';
import 'package:flutter_svg/svg.dart';

abstract class ChainSelectionValue {
  factory ChainSelectionValue.chain(Chain chain) = ChainSelectionChainValue;
  factory ChainSelectionValue.custom() = ChainSelectionCustomValue;

  static List<ChainSelectionValue> values =
      Chain.values.map((e) => ChainSelectionValue.chain(e)).toList() +
          [ChainSelectionValue.custom()];
}

class ChainSelectionChainValue implements ChainSelectionValue {
  const ChainSelectionChainValue(this.chain);
  final Chain chain;

  @override
  bool operator ==(dynamic other) =>
      other != null &&
      other is ChainSelectionChainValue &&
      chain == other.chain;

  @override
  int get hashCode => chain.hashCode;
}

class ChainSelectionCustomValue implements ChainSelectionValue {
  const ChainSelectionCustomValue();
}

class ChainSelection extends StatelessWidget {
  const ChainSelection({
    super.key,
    required this.currentValue,
    required this.onValueChange,
    required this.selections,
    required this.customRpcController,
  });

  final ChainSelectionValue currentValue;
  final TextEditingController customRpcController;
  final void Function(ChainSelectionValue newValue) onValueChange;
  final List<ChainSelectionValue> selections;

  void _handleChange(ChainSelectionValue? newValue) {
    if (newValue != null) {
      onValueChange(newValue);
    }
  }

  DropdownMenuItem<ChainSelectionValue> _chainDropdownMenuItem(
      BuildContext context, ChainSelectionValue value) {
    const iconSize = 32.0;
    return DropdownMenuItem(
        value: value,
        child: Container(
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 50),
          child: ListTile(
            leading: (value is ChainSelectionChainValue)
                ? SvgPicture.asset(
                    value.chain.iconSvgAssetName,
                    width: iconSize,
                    height: iconSize,
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.center,
                  )
                : const Icon(Icons.question_mark, size: iconSize),
            title: (value is ChainSelectionChainValue)
                ? Text(value.chain.prettyName)
                : const Text("Custom Rpc"),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonHideUnderline(
            child: DropdownButton<ChainSelectionValue>(
                isExpanded: true,
                value: currentValue,
                onChanged: _handleChange,
                items: selections
                    .map((e) => _chainDropdownMenuItem(context, e))
                    .toList())),
        if (currentValue is ChainSelectionCustomValue)
          TextField(
            controller: customRpcController,
            decoration: const InputDecoration(
                border: OutlineInputBorder(), labelText: "Custom Rpc"),
          )
      ],
    );
  }
}
