import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_approval/selection/chain_selection.dart';
import 'package:flutter_approval/selection/selection_screen.dart';
import 'package:flutter_approval/selection/token_selection.dart';
import 'package:flutter_approval/blockchain/chain.dart';

class MySelectionScreen extends StatefulWidget {
  const MySelectionScreen({super.key, required this.onRun});

  final title = "Approval Searcher";
  final void Function(List<SelectionData>) onRun;

  @override
  State<MySelectionScreen> createState() => _MySelectionScreenState();
}

class _MySelectionScreenState extends State<MySelectionScreen> {
  final List<SelectionData> _data = [];
  bool isEditMode = false;
  bool isUtc = false;

  @override
  void initState() {
    super.initState();
    _addItem();
  }

  @override
  void dispose() {
    for (var fields in _data) {
      fields.contractAddress.dispose();
      fields.customRpc.dispose();
      for (var element in fields.customTokens) {
        element.addressController.dispose();
      }
    }
    super.dispose();
  }

  void _addItem() async {
    var index = _data.length;
    var chain = ChainSelectionValue.chain(Chain.ethereum);
    SelectionData newData = SelectionData(
      chain,
      _updateChain(index),
      TextEditingController(),
      TextEditingController(),
      _onPasteContractAddress(index),
      null,
      _updateTokenIndex(index),
      {},
      _updateTokenIndices(index),
      await _tokenSelections(chain),
      [],
      _updateCustomTokens(index),
      DateTime.now(),
      _updateFromDate(index),
    );
    setState(() {
      _data.add(newData);
    });
  }

  void _removeItem(int index) {
    _data[index].customRpc.dispose();
    _data[index].contractAddress.dispose();
    for (var customTokens in _data[index].customTokens) {
      customTokens.addressController.dispose();
    }
    setState(() {
      _data.removeAt(index);
    });
  }

  void Function(ChainSelectionValue) _updateChain(int index) {
    return (newValue) {
      _tokenSelections(newValue).then((tokenSelections) {
        setState(() {
          _data[index].chain = newValue;
          _data[index].customRpc.clear();
          _data[index].contractAddress.clear();
          _data[index].tokenIndices = {};
          _data[index].tokenIndex = null;
          _data[index].customTokens = [];
          _data[index].tokenSelections = tokenSelections;
        });
      });
    };
  }

  void Function() _onPasteContractAddress(int index) {
    return () {
      Clipboard.getData(Clipboard.kTextPlain).then((value) {
        final text = value?.text;
        if (text != null) {
          setState(() {
            _data[index].contractAddress.text = text;
          });
        }
      });
    };
  }

  void Function(int?) _updateTokenIndex(int index) {
    return (newValue) {
      setState(() {
        _data[index].tokenIndex = newValue;
      });
    };
  }

  void Function(Set<int>) _updateTokenIndices(int index) {
    return (newValue) {
      setState(() {
        _data[index].tokenIndices = newValue;
      });
    };
  }

  void Function(List<CustomToken>) _updateCustomTokens(int index) {
    return (newValue) {
      setState(() {
        _data[index].customTokens = newValue;
      });
    };
  }

  void Function(DateTime) _updateFromDate(int index) {
    return (newValue) {
      setState(() {
        _data[index].fromDate = newValue;
      });
    };
  }

  Future<List<TokenSelectionValue>> _tokenSelections(
      ChainSelectionValue chain) async {
    if (chain is ChainSelectionChainValue) {
      return TokenSelectionValue.values(chain.chain);
    } else {
      return [TokenSelectionValue.custom()];
    }
  }

  void _toggleEditMode() {
    setState(() {
      isEditMode = !isEditMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SelectionScreen(
      chainSelections: ChainSelectionValue.values,
      title: widget.title,
      data: _data,
      onRun: widget.onRun,
      onAddItem: _addItem,
      onToggleEditMode: _toggleEditMode,
      onRemoveItem: _removeItem,
      isEditMode: isEditMode,
    );
  }
}
