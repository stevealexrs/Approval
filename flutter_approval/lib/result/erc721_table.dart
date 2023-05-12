import 'package:flutter/material.dart';
import 'package:flutter_approval/result/table_style.dart';
import 'package:flutter_approval/utils/collection.dart';
import 'package:web3dart/web3dart.dart';

class Erc721Table extends StatelessWidget {
  const Erc721Table({
    super.key,
    required this.ownerToTokenIds,
  });

  final Map<EthereumAddress, Set<BigInt>> ownerToTokenIds;

  String _tokenIdsToString(Set<BigInt> tokenIds) {
    var idList = tokenIds.toList();
    idList.sort((a, b) => a.compareTo(b));

    return idList.foldToCommaSeparated((p0) => p0.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(color: Colors.green),
      children: [
        const TableRow(children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Account", style: tableHeaderTextStyle),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Token Ids", style: tableHeaderTextStyle),
          )
        ]),
        for (var item in ownerToTokenIds.entries)
          TableRow(children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SelectableText(item.key.hex, style: tableContentTextStyle),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SelectableText(
                  (item.value.isEmpty) ? "ALL" : _tokenIdsToString(item.value),
                  style: tableContentTextStyle),
            )
          ])
      ],
    );
  }
}
