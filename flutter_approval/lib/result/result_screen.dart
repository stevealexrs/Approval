import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_approval/blockchain/token.dart';
import 'package:flutter_approval/result/erc1155_table.dart';
import 'package:flutter_approval/result/erc20_table.dart';
import 'package:flutter_approval/result/erc721_table.dart';
import 'package:flutter_approval/result/erc777_table.dart';
import 'package:flutter_approval/utils/duration.dart';
import 'package:web3dart/web3dart.dart';

class ApprovalChain {
  final String? name;
  final int chainId;
  final Widget? icon;

  ApprovalChain(this.name, this.chainId, this.icon);
}

class ApprovalToken {
  final String? symbol;
  final EthereumAddress address;
  final TokenType type;
  final Widget? icon;

  ApprovalToken(this.symbol, this.address, this.icon, this.type);
}

sealed class ApprovalResult {
  ApprovalChain chain();
  ApprovalToken token();
  EthereumAddress contract();
}

class Erc20ApprovalResult implements ApprovalResult {
  final Map<EthereumAddress, BigInt> approved;
  final ApprovalChain _chain;
  final EthereumAddress _contract;
  final ApprovalToken _token;
  final BigInt decimals;

  Erc20ApprovalResult(
      this.approved, this._chain, this._token, this._contract, this.decimals);

  @override
  ApprovalChain chain() {
    return _chain;
  }

  @override
  ApprovalToken token() {
    return _token;
  }

  @override
  EthereumAddress contract() {
    return _contract;
  }
}

class Erc721ApprovalResult implements ApprovalResult {
  final Map<EthereumAddress, Set<BigInt>> approved;
  final ApprovalChain _chain;
  final ApprovalToken _token;
  final EthereumAddress _contract;

  Erc721ApprovalResult(this.approved, this._chain, this._token, this._contract);

  @override
  ApprovalChain chain() {
    return _chain;
  }

  @override
  ApprovalToken token() {
    return _token;
  }

  @override
  EthereumAddress contract() {
    return _contract;
  }
}

class Erc777ApprovalResult implements ApprovalResult {
  final Set<EthereumAddress> approved;
  final bool isDefaultOperator;
  final ApprovalChain _chain;
  final ApprovalToken _token;
  final EthereumAddress _contract;

  Erc777ApprovalResult(this.approved, this._chain, this._token, this._contract,
      this.isDefaultOperator);

  @override
  ApprovalChain chain() {
    return _chain;
  }

  @override
  ApprovalToken token() {
    return _token;
  }

  @override
  EthereumAddress contract() {
    return _contract;
  }
}

class Erc1155ApprovalResult implements ApprovalResult {
  final Set<EthereumAddress> approved;
  final ApprovalChain _chain;
  final ApprovalToken _token;
  final EthereumAddress _contract;

  Erc1155ApprovalResult(
      this.approved, this._chain, this._token, this._contract);

  @override
  ApprovalChain chain() {
    return _chain;
  }

  @override
  ApprovalToken token() {
    return _token;
  }

  @override
  EthereumAddress contract() {
    return _contract;
  }
}

sealed class ApprovalResultProgress {}

class ApprovalCompleted extends ApprovalResultProgress {
  final List<ApprovalResult> result;

  ApprovalCompleted(this.result);
}

class ApprovalInProgress extends ApprovalResultProgress {
  final int currentContract;
  final int totalContract;
  final int? currentToken;
  final int? totalToken;

  ApprovalInProgress(this.currentContract, this.totalContract,
      this.currentToken, this.totalToken);
}

class ResultScreen extends StatefulWidget {
  const ResultScreen({
    super.key,
    required this.title,
    required this.onDownload,
    required this.onCopy,
    required this.result,
    this.onBack,
  });

  final String title;
  final void Function()? onDownload;
  final void Function(ApprovalResult)? onCopy;
  final void Function()? onBack;
  final Stream<ApprovalResultProgress> result;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final Stopwatch _stopwatch = Stopwatch();
  Duration _elapsed = Duration.zero;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 30), (Timer t) {
      setState(() {
        _elapsed = _stopwatch.elapsed;
      });
    });
    _stopwatch.start();
  }

  void _stopStopwatchTimer() {
    _stopwatch.stop();
    _timer.cancel();
  }

  @override
  void dispose() {
    _stopStopwatchTimer();
    super.dispose();
  }

  void Function() _handleCopy(ApprovalResult selectedResult) {
    return () {
      widget.onCopy?.call(selectedResult);
    };
  }

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: Scaffold(
          appBar: _resultAppBar(),
          body: StreamBuilder(
              stream: widget.result,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var progress = snapshot.data!;
                  switch (progress) {
                    case ApprovalCompleted():
                      return _approvalCompleted(progress);
                    case ApprovalInProgress():
                      return _approvalInProgress(progress);
                  }
                } else if (snapshot.hasError) {
                  _stopStopwatchTimer();
                  return Center(
                    child: Text(
                      "Error: ${snapshot.error!}",
                      style:
                          TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              })),
    );
  }

  Widget _approvalCompleted(ApprovalCompleted progress) {
    _stopStopwatchTimer();
    return (progress.result.isNotEmpty)
        ? Container(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
                itemCount: progress.result.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      _groupTitle(
                          progress.result[index].chain(),
                          progress.result[index].contract().hex,
                          progress.result[index].token(),
                          _handleCopy(progress.result[index])),
                      _tabularResult(progress.result[index]),
                      if (index != progress.result.length - 1)
                        const SizedBox(
                          height: 20,
                        )
                    ],
                  );
                }),
          )
        : const Center(child: Text("No Result 😔"));
  }

  Widget _approvalInProgress(ApprovalInProgress progress) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Transforming...",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Container(
              constraints: const BoxConstraints(maxWidth: 500),
              padding: const EdgeInsets.all(8.0),
              child: const LinearProgressIndicator()),
          Text(
              (progress.totalToken == null || progress.currentToken == null)
                  ? "Processing (${progress.currentContract + 1}/${progress.totalContract}) contract"
                  : "Processing (${progress.currentToken! + 1}/${progress.totalToken}) token of (${progress.currentContract + 1}/${progress.totalContract}) contract",
              style: const TextStyle(
                  fontWeight: FontWeight.w100, fontStyle: FontStyle.italic))
        ],
      ),
    );
  }

  Widget _tabularResult(ApprovalResult data) {
    switch (data.token().type) {
      case TokenType.erc20:
        var input = data as Erc20ApprovalResult;
        return Erc20Table(
            ownerToAmount: input.approved, tokenDecimal: input.decimals);
      case TokenType.erc721:
        var input = data as Erc721ApprovalResult;
        return Erc721Table(ownerToTokenIds: input.approved);
      case TokenType.erc777:
        var input = data as Erc777ApprovalResult;
        return Erc777Table(
            approvers: input.approved,
            isDefaultOperator: input.isDefaultOperator);
      case TokenType.erc1155:
        var input = data as Erc1155ApprovalResult;
        return Erc1155Table(approvers: input.approved);
    }
  }

  Widget _groupTitle(ApprovalChain chain, String contractAddress,
      ApprovalToken token, void Function() onCopyPressed) {
    const iconSize = 32.0;
    var symbol = token.symbol;
    return Row(
      children: [
        if (chain.icon != null)
          SizedBox(height: iconSize, width: iconSize, child: chain.icon),
        Container(
            padding: const EdgeInsets.all(4.0),
            child: Text(
              contractAddress,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
            )),
        Container(
          height: iconSize,
          padding: const EdgeInsets.only(right: 8.0),
          child: const VerticalDivider(
            width: 1,
            thickness: 2,
            indent: 4,
          ),
        ),
        if (token.icon != null)
          SizedBox(height: iconSize, width: iconSize, child: token.icon),
        Container(
            padding:
                const EdgeInsets.only(left: 8, right: 4, top: 4, bottom: 4),
            child: Text((symbol != null) ? symbol : token.address.hex,
                style: const TextStyle(
                    fontWeight: FontWeight.w500, fontSize: 20))),
        Container(
            padding: const EdgeInsets.all(4.0), child: Text(token.type.name)),
        if (widget.onCopy != null)
          Container(
              padding: const EdgeInsets.all(4.0),
              child: IconButton(
                  onPressed: onCopyPressed, icon: const Icon(Icons.copy)))
      ],
    );
  }

  AppBar _resultAppBar() {
    return AppBar(
      title: Text("${widget.title} (${_elapsed.toFormatString()})"),
      leading: (widget.onBack != null)
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: widget.onBack,
            )
          : null,
      actions: [
        if (widget.onDownload != null)
          IconButton(
              onPressed: widget.onDownload, icon: const Icon(Icons.download))
      ],
    );
  }
}
