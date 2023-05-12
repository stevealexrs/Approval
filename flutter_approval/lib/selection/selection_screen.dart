import 'package:flutter/material.dart';
import 'package:flutter_approval/blockchain/chain.dart';
import 'package:flutter_approval/blockchain/token.dart';
import 'package:flutter_approval/blockchain/token_readable.dart';
import 'package:flutter_approval/selection/chain_selection.dart';
import 'package:flutter_approval/selection/contract_selection.dart';
import 'package:flutter_approval/selection/token_selection.dart';
import 'package:flutter_approval/utils/collection.dart';
import 'package:web3dart/web3dart.dart';

class SelectionScreen extends StatelessWidget {
  const SelectionScreen({
    super.key,
    required this.chainSelections,
    required this.title,
    required this.data,
    required this.onRun,
    required this.onAddItem,
    required this.onRemoveItem,
    required this.onToggleEditMode,
    required this.isEditMode,
  });

  final List<ChainSelectionValue> chainSelections;
  final List<SelectionData> data;
  final void Function(List<SelectionData>) onRun;
  final void Function() onAddItem;
  final void Function(int index) onRemoveItem;
  final void Function() onToggleEditMode;
  final bool isEditMode;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectionAppBar(),
      body: ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            return _selectionRow(context, index);
          }),
      floatingActionButton: _selectionRun(),
    );
  }

  FloatingActionButton _selectionRun() {
    return FloatingActionButton(
      onPressed: () => onRun(data),
      child: const Icon(Icons.play_arrow_rounded),
    );
  }

  AppBar _selectionAppBar() {
    return AppBar(
      title: Text(title),
      actions: [
        IconButton(
            onPressed: onToggleEditMode,
            icon: Icon(
              Icons.edit,
              color: (isEditMode) ? Colors.pinkAccent : null,
            )),
        IconButton(onPressed: onAddItem, icon: const Icon(Icons.add)),
      ],
    );
  }

  void Function() _handleRemoveItem(int index) {
    return () {
      onRemoveItem(index);
    };
  }

  Future<void> _selectDate(BuildContext context, int index) async {
    var firstDate = DateTime.utc(2015, 7, 30);
    var lastDate = DateTime.utc(2200);
    var initialDate = (data[index].fromDate.compareTo(firstDate) >= 0 &&
            data[index].fromDate.compareTo(lastDate) <= 0)
        ? data[index].fromDate
        : firstDate;
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate);
    if (picked != null && picked != data[index].fromDate) {
      data[index].onFromDateChange(picked);
    }
  }

  Widget _selectionRow(BuildContext context, int index) {
    const horizontalSpacer = SizedBox(
      width: 10,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.max,
                children: [
                  TextButton(
                      onPressed: () => _selectDate(context, index),
                      child: Text(
                          "From (UTC): ${data[index].fromDate.toIso8601String().split('T').first}"))
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isEditMode)
                    Container(
                      padding: const EdgeInsets.only(top: 5),
                      child: IconButton(
                          onPressed: _handleRemoveItem(index),
                          icon: const Icon(Icons.remove)),
                    ),
                  Flexible(
                      flex: 1,
                      child: ChainSelection(
                        currentValue: data[index].chain,
                        onValueChange: data[index].onChainChange,
                        selections: chainSelections,
                        customRpcController: data[index].customRpc,
                      )),
                  horizontalSpacer,
                  Flexible(
                    flex: 1,
                    child: ContractSelection(
                      currentValueController: data[index].contractAddress,
                      onPaste: data[index].onPasteContractAddress,
                    ),
                  ),
                  horizontalSpacer,
                  Flexible(
                    flex: 1,
                    child: TokenSelection(
                      selections: data[index].tokenSelections,
                      selectedIndices: data[index].tokenIndices,
                      onIndicesChange: data[index].onTokenIndicesChange,
                      customTokens: data[index].customTokens,
                      onCustomTokensChange: data[index].onCustomTokensChange,
                      currentIndex: data[index].tokenIndex,
                      onIndexChange: data[index].onTokenIndexChange,
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
        const Divider(
          height: 1,
        )
      ],
    );
  }
}

class SelectionData {
  DateTime fromDate;
  void Function(DateTime) onFromDateChange;

  ChainSelectionValue chain;
  void Function(ChainSelectionValue) onChainChange;

  TextEditingController customRpc;
  TextEditingController contractAddress;
  void Function() onPasteContractAddress;

  int? tokenIndex;
  void Function(int?) onTokenIndexChange;
  Set<int> tokenIndices;
  void Function(Set<int>) onTokenIndicesChange;
  List<TokenSelectionValue> tokenSelections;
  List<CustomToken> customTokens;
  void Function(List<CustomToken>) onCustomTokensChange;

  SelectionData(
    this.chain,
    this.onChainChange,
    this.customRpc,
    this.contractAddress,
    this.onPasteContractAddress,
    this.tokenIndex,
    this.onTokenIndexChange,
    this.tokenIndices,
    this.onTokenIndicesChange,
    this.tokenSelections,
    this.customTokens,
    this.onCustomTokensChange,
    this.fromDate,
    this.onFromDateChange,
  );

  Future<String> chainRpc() async {
    var selectedChain = chain;
    if (selectedChain is ChainSelectionChainValue) {
      return await selectedChain.chain.randomRpc();
    } else {
      return customRpc.text;
    }
  }

  Chain? knownChain() {
    var selectedChain = chain;
    if (selectedChain is ChainSelectionChainValue) {
      return selectedChain.chain;
    } else {
      return null;
    }
  }

  List<TokenWithOptionalMetadata> selectedTokens() {
    List<TokenWithOptionalMetadata> tokens = [];
    for (var selected in tokenSelections.toSelectedList(tokenIndices)) {
      if (selected is TokenSelectionTokenValue) {
        tokens.add(TokenWithOptionalMetadata(selected.token.symbol,
            selected.token.type, selected.token.tokenAddress));
      } else {
        tokens.addAll(customTokens.map((e) => TokenWithOptionalMetadata(
            null, e.type, EthereumAddress.fromHex(e.addressController.text))));
      }
    }
    return tokens;
  }
}

class TokenWithOptionalMetadata extends Token {
  TokenWithOptionalMetadata(
      this.symbol, TokenType type, EthereumAddress tokenAddress)
      : super(tokenAddress, type);

  final String? symbol;

  Widget? icon() {
    return TokenWithMetadata(symbol ?? "", type, tokenAddress).icon();
  }
}
