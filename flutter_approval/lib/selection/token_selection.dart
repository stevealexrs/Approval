import 'package:flutter/material.dart';
import 'package:flutter_approval/blockchain/chain.dart';
import 'package:flutter_approval/blockchain/chain_token.dart';
import 'package:flutter_approval/blockchain/token.dart';
import 'package:flutter_approval/blockchain/token_readable.dart';
import 'package:flutter_approval/utils/collection.dart';
import 'package:flutter_svg/svg.dart';

abstract class TokenSelectionValue {
  factory TokenSelectionValue.token(TokenWithMetadata token) =
      TokenSelectionTokenValue;
  factory TokenSelectionValue.custom() = TokenSelectionCustomValue;

  static Future<List<TokenSelectionValue>> values(Chain chain) async {
    var tokens = await chain.tokens;
    return tokens.map((e) => TokenSelectionValue.token(e)).toList() +
        [TokenSelectionValue.custom()];
  }
}

class TokenSelectionTokenValue implements TokenSelectionValue {
  const TokenSelectionTokenValue(this.token);
  final TokenWithMetadata token;

  @override
  bool operator ==(dynamic other) =>
      other != null &&
      other is TokenSelectionTokenValue &&
      token == other.token;

  @override
  int get hashCode => token.hashCode;
}

class TokenSelectionCustomValue implements TokenSelectionValue {
  static final TokenSelectionCustomValue _instance =
      TokenSelectionCustomValue._internal();

  factory TokenSelectionCustomValue() {
    return _instance;
  }

  TokenSelectionCustomValue._internal();
}

class CustomToken {
  CustomToken(this.type, this.addressController);

  TokenType type;
  final TextEditingController addressController;
}

class TokenSelection extends StatelessWidget {
  const TokenSelection({
    super.key,
    required this.selections,
    required this.selectedIndices,
    required this.onIndicesChange,
    required this.customTokens,
    required this.onCustomTokensChange,
    required this.currentIndex,
    required this.onIndexChange,
  });

  final int? currentIndex;
  final void Function(int? newValue) onIndexChange;
  final Set<int> selectedIndices;
  final void Function(Set<int> newValue) onIndicesChange;
  final List<TokenSelectionValue> selections;
  final List<CustomToken> customTokens;
  final void Function(List<CustomToken> newValue) onCustomTokensChange;

  void _handleIndexChange(int? newValue) {
    if (newValue != null) {
      var newIndices = selectedIndices;
      if (newIndices.contains(newValue)) {
        newIndices.remove(newValue);
      } else {
        newIndices.add(newValue);
      }
      if (newIndices.isEmpty) {
        onIndexChange(null);
      } else {
        onIndexChange(newValue);
      }
      onIndicesChange(newIndices);
    }
  }

  void Function()? _handleDeleteCustomToken(int index) {
    return () {
      customTokens[index].addressController.dispose();

      var currentTokens = customTokens;
      currentTokens.removeAt(index);
      onCustomTokensChange(currentTokens);
    };
  }

  void Function(String?) _handleTokenAddressChange(
      int index, List<CustomToken> responsiveTokens) {
    return (newValue) {
      var currentTokens = customTokens;
      if (index == customTokens.length && newValue != null && newValue != "") {
        currentTokens.add(CustomToken(responsiveTokens.last.type,
            responsiveTokens.last.addressController));
        onCustomTokensChange(currentTokens);
      }
    };
  }

  void Function(TokenType?) _handleTokenTypeChange(int index) {
    return (newValue) {
      var currentTokens = customTokens;
      if (index == customTokens.length && newValue != null) {
        currentTokens.add(CustomToken(newValue, TextEditingController()));
        onCustomTokensChange(currentTokens);
      } else if (newValue != null) {
        currentTokens[index] =
            CustomToken(newValue, currentTokens[index].addressController);
        onCustomTokensChange(currentTokens);
      }
    };
  }

  Widget _leadingIcon(TokenSelectionValue value) {
    const iconSize = 32.0;
    if (value is TokenSelectionTokenValue &&
        value.token.iconSvgAssetName != null) {
      return SvgPicture.asset(
        value.token.iconSvgAssetName!,
        width: iconSize,
        height: iconSize,
        fit: BoxFit.scaleDown,
        alignment: Alignment.center,
      );
    } else if (value is TokenSelectionTokenValue &&
        value.token.iconPngAsset != null) {
      return Image(
        image: value.token.iconPngAsset!,
        width: iconSize,
        height: iconSize,
        fit: BoxFit.scaleDown,
      );
    } else {
      return const Icon(Icons.question_mark, size: iconSize);
    }
  }

  DropdownMenuItem<int> _tokenDropdownMenuItem(
      BuildContext context, int value) {
    var selected = selections[value];
    return DropdownMenuItem(
        value: value,
        child: StatefulBuilder(
          builder: (context, menuSetState) {
            return InkWell(
                onTap: () {
                  _handleIndexChange(value);
                  menuSetState(() {});
                },
                child: Container(
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width - 50),
                  child: ListTile(
                    leading: _leadingIcon(selected),
                    title: (selected is TokenSelectionTokenValue)
                        ? Text(selected.token.symbol)
                        : const Text("Custom Token"),
                    trailing: (selectedIndices.contains(value)
                        ? const Icon(Icons.check_box_rounded)
                        : const Icon(Icons.check_box_outline_blank_rounded)),
                  ),
                ));
          },
        ));
  }

  DropdownMenuItem<TokenType> _tokenTypeDropdownMenuItem(
      BuildContext context, TokenType value) {
    return DropdownMenuItem(
        value: value,
        child: Container(
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 50),
          child: ListTile(
            title: Text(value.name),
          ),
        ));
  }

  List<Widget> Function(BuildContext)? _selectedTokenBuilder() {
    return (context) {
      var selected = selections.toSelectedList(selectedIndices).fold("",
          (previousValue, element) {
        var nextToken = "";
        if (element is TokenSelectionTokenValue) {
          nextToken = element.token.symbol;
        } else {
          nextToken = "Custom";
        }
        return (previousValue == "") ? nextToken : "$previousValue, $nextToken";
      });
      return List.generate(
          selections.length,
          (_) => Container(
                alignment: AlignmentDirectional.center,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  selected,
                ),
              ));
    };
  }

  @override
  Widget build(BuildContext context) {
    var responsiveTokens =
        customTokens + [CustomToken(TokenType.erc20, TextEditingController())];
    var isCustomSelected = selectedIndices
        .contains(selections.indexOf(TokenSelectionValue.custom()));
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DropdownButtonHideUnderline(
            child: DropdownButton<int>(
          hint: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Select Tokens"),
          ),
          isExpanded: true,
          value: currentIndex,
          items: List.generate(selections.length,
              (index) => _tokenDropdownMenuItem(context, index)).toList(),
          onChanged: _handleIndexChange,
          selectedItemBuilder: _selectedTokenBuilder(),
        )),
        if (isCustomSelected)
          const SizedBox(
            height: 10,
          ),
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: (isCustomSelected) ? responsiveTokens.length : 0,
            itemBuilder: (context, i) {
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 7,
                        child: TextField(
                          controller: responsiveTokens[i].addressController,
                          onChanged:
                              _handleTokenAddressChange(i, responsiveTokens),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Token Address",
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: DropdownButtonHideUnderline(
                            child: DropdownButton<TokenType>(
                          isExpanded: true,
                          value: responsiveTokens[i].type,
                          items: TokenType.values
                              .map(
                                  (e) => _tokenTypeDropdownMenuItem(context, e))
                              .toList(),
                          onChanged: _handleTokenTypeChange(i),
                        )),
                      ),
                      if (i != responsiveTokens.length - 1)
                        IconButton(
                          onPressed: _handleDeleteCustomToken(i),
                          icon: const Icon(Icons.delete),
                          color: Theme.of(context).colorScheme.error,
                        )
                    ],
                  ),
                  if (i < responsiveTokens.length - 1)
                    const SizedBox(
                      height: 10,
                    )
                ],
              );
            },
          ),
        ) //,
      ],
    );
  }
}
