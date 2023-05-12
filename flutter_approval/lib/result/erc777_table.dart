import 'package:flutter/material.dart';
import 'package:flutter_approval/result/table_style.dart';
import 'package:web3dart/web3dart.dart';

class Erc777Table extends StatelessWidget {
  const Erc777Table({
    super.key,
    required this.approvers,
    required this.isDefaultOperator,
  });

  final bool isDefaultOperator;
  final Set<EthereumAddress> approvers;

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(color: Colors.blue),
      children: [
        TableRow(children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
                "Account${(isDefaultOperator) ? ' (Default Operator)' : ''}",
                style: tableHeaderTextStyle),
          )
        ]),
        for (var item in approvers.toList())
          TableRow(children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SelectableText(item.hex, style: tableContentTextStyle),
            ),
          ])
      ],
    );
  }
}
