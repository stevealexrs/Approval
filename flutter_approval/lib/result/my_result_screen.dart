import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_approval/blockchain/token.dart';
import 'package:flutter_approval/result/result_screen.dart';
import 'package:flutter_approval/utils/collection.dart';

class MyResultScreen extends StatelessWidget {
  const MyResultScreen({super.key, required this.result});

  final title = "Approval Result";

  final Stream<ApprovalResultProgress> result;

  /// NOT IMPLEMENTED
  void Function()? _handleDownload() {
    return null;
  }

  void Function(ApprovalResult) _handleCopy(BuildContext context) {
    return (ApprovalResult result) {
      String text;
      switch (result.token().type) {
        case TokenType.erc20:
          var data = result as Erc20ApprovalResult;
          text = data.approved.keys.foldToCommaSeparated((p0) => p0.hex);
          break;
        case TokenType.erc721:
          var data = result as Erc721ApprovalResult;
          text = data.approved.keys.foldToCommaSeparated((p0) => p0.hex);
          break;
        case TokenType.erc777:
          var data = result as Erc777ApprovalResult;
          text = data.approved.foldToCommaSeparated((p0) => p0.hex);
          break;
        case TokenType.erc1155:
          var data = result as Erc1155ApprovalResult;
          text = data.approved.foldToCommaSeparated((p0) => p0.hex);
          break;
      }
      Clipboard.setData(ClipboardData(text: text)).then((_) {
        var snackBar = const SnackBar(content: Text("Copied"));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    return ResultScreen(
        title: title,
        onDownload: _handleDownload(),
        onCopy: _handleCopy(context),
        onBack: () => Navigator.of(context).pop(),
        result: result);
  }
}
