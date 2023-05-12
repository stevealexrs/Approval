import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_approval/result/table_style.dart';
import 'package:web3dart/web3dart.dart';

class Erc20Table extends StatelessWidget {
  const Erc20Table({
    super.key,
    required this.ownerToAmount,
    required this.tokenDecimal,
  });

  final BigInt tokenDecimal;
  final Map<EthereumAddress, BigInt> ownerToAmount;

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(color: Colors.grey),
      children: [
        const TableRow(children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Account",
              style: tableHeaderTextStyle,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Amount", style: tableHeaderTextStyle),
          )
        ]),
        for (var item in ownerToAmount.entries)
          TableRow(children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(item.key.hex, style: tableContentTextStyle),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                  Decimal.fromBigInt(item.value)
                      .shift(-tokenDecimal.toInt())
                      .toString(),
                  style: tableContentTextStyle),
            )
          ])
      ],
    );
  }
}
