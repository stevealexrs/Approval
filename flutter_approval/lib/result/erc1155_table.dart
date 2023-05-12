import 'package:flutter/material.dart';
import 'package:flutter_approval/result/table_style.dart';
import 'package:web3dart/web3dart.dart';

class Erc1155Table extends StatelessWidget {
  const Erc1155Table({
    super.key,
    required this.approvers,
  });

  final Set<EthereumAddress> approvers;

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(color: Colors.lime),
      children: [
        const TableRow(children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Account", style: tableHeaderTextStyle),
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
