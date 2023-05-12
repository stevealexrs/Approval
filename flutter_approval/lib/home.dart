import 'package:flutter/material.dart';
import 'package:flutter_approval/blockchain/chain_readable.dart';
import 'package:flutter_approval/blockchain/token.dart';
import 'package:flutter_approval/result/my_result_screen.dart';
import 'package:flutter_approval/result/result_screen.dart';
import 'package:flutter_approval/seeker/seeker.dart';
import 'package:flutter_approval/selection/my_selection_screen.dart';
import 'package:flutter_approval/selection/selection_screen.dart';
import 'package:web3dart/web3dart.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Stream<ApprovalResultProgress> _fetchApproval(
      List<SelectionData> input) async* {
    List<ApprovalResult> approvalResult = [];
    for (var entries in input.asMap().entries) {
      var element = entries.value;
      var index = entries.key;
      yield ApprovalInProgress(index, input.length, null, null);
      var seeker = Seeker.createFromRpc(await element.chainRpc());
      var fromDate = DateTime.utc(
          element.fromDate.year, element.fromDate.month, element.fromDate.day);
      var fromBlock =
          BlockNum.exact(await seeker.getBlockNumberByDate(fromDate));
      var toBlock = const BlockNum.current();
      var spender = EthereumAddress.fromHex(element.contractAddress.text);
      var approvalChain = ApprovalChain(
          element.knownChain()?.prettyName,
          element.knownChain()?.chainId ??
              (await seeker.web3Client.getChainId()).toInt(),
          element.knownChain()?.icon());
      var selectedTokens = element.selectedTokens();
      for (var tokenEntries in selectedTokens.asMap().entries) {
        var token = tokenEntries.value;
        var tokenIndex = tokenEntries.key;
        yield ApprovalInProgress(index, input.length, tokenIndex, selectedTokens.length);
        var approvalToken = ApprovalToken(
            token.symbol, token.tokenAddress, token.icon(), token.type);
        switch (token.type) {
          case TokenType.erc20:
            var approvals = await seeker.erc20Seeker.exploitableAmounts(
                fromBlock, toBlock, spender, [token.tokenAddress]);
            var erc20Results = approvals.tokenToOwnerToAmount.entries.map((e) {
              var sortedEntries = e.value.entries.toList()
                ..sort((e1, e2) {
                  var diff = e2.value.compareTo(e1.value);
                  if (diff == 0) diff = e2.key.compareTo(e1.key);
                  return diff;
                });
              return Erc20ApprovalResult(
                  e.value
                    ..clear()
                    ..addEntries(sortedEntries),
                  approvalChain,
                  approvalToken,
                  spender,
                  e.key.decimal);
            });
            approvalResult.addAll(erc20Results);
            break;
          case TokenType.erc721:
            var approvals = await seeker.erc721seeker.exploitableTokens(
                fromBlock, toBlock, spender, [token.tokenAddress]);
            var erc721Results = approvals.tokenToOwnerToTokenIds.entries.map(
                (e) => Erc721ApprovalResult(
                    e.value, approvalChain, approvalToken, spender));
            approvalResult.addAll(erc721Results);
            break;
          case TokenType.erc777:
            var approvals = await seeker.erc777seeker.exploitableTokens(
                fromBlock, toBlock, spender, [token.tokenAddress]);
            var erc777Results = approvals.tokenToData.entries.map((e) =>
                Erc777ApprovalResult(e.value.owners, approvalChain,
                    approvalToken, spender, e.value.isDefaultOperator));
            approvalResult.addAll(erc777Results);
            break;
          case TokenType.erc1155:
            var approvals = await seeker.erc1155seeker.exploitableTokens(
                fromBlock, toBlock, spender, [token.tokenAddress]);
            var erc1155Results = approvals.tokenToOwners.entries.map((e) =>
                Erc1155ApprovalResult(
                    e.value, approvalChain, approvalToken, spender));
            approvalResult.addAll(erc1155Results);
            break;
        }
      }
    }
    yield ApprovalCompleted(approvalResult);
  }

  void Function(List<SelectionData>) _handleRun(BuildContext context) {
    return (input) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => MyResultScreen(
            result: _fetchApproval(input),
          ),
        ),
      );
    };
  }

  @override
  Widget build(BuildContext context) {
    return MySelectionScreen(
      onRun: _handleRun(context),
    );
  }
}
