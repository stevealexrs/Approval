import 'package:flutter_approval/abi/erc777.g.dart';
import 'package:flutter_approval/blockchain/token.dart';
import 'package:flutter_approval/utils/converter.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

class Erc777Seeker {
  Web3Client web3Client;
  Erc777Seeker(this.web3Client);

  Future<Erc777TokenApproval> _exploitableToken(BlockNum from, BlockNum to,
      EthereumAddress spender, EthereumAddress token) async {
    var contract = Erc777(address: token, client: web3Client);
    var deployedContract = contract.self;
    var authorizedSignature = bytesToHex(
        deployedContract.event('AuthorizedOperator').signature,
        padToEvenLength: true,
        forcePadLength: 64,
        include0x: true);
    var revokedSignature = bytesToHex(
        deployedContract.event('RevokedOperator').signature,
        padToEvenLength: true,
        forcePadLength: 64,
        include0x: true);
    var operatorFilter =
        FilterOptions(fromBlock: from, toBlock: to, address: token, topics: [
      [authorizedSignature, revokedSignature],
      [
        bytesToHex(spender.addressBytes,
            padToEvenLength: true, forcePadLength: 64, include0x: true)
      ],
    ]);
    var approvals = await web3Client.getLogs(operatorFilter);
    Set<EthereumAddress> operatorOwners = {};
    for (var approval in approvals) {
      if (approval.topics![0] == authorizedSignature) {
        operatorOwners.add(topicToAddress(approval.topics![2]));
      } else if (approval.topics![0] == revokedSignature) {
        operatorOwners.remove(topicToAddress(approval.topics![2]));
      }
    }
    var isDefaultOperator =
        (await contract.defaultOperators()).contains(spender);
    return Erc777TokenApproval(
        token, spender, Erc777ApprovalData(operatorOwners, isDefaultOperator));
  }

  Future<Erc777TokenApprovals> exploitableTokens(BlockNum from, BlockNum to,
      EthereumAddress spender, List<EthereumAddress> tokens) async {
    Map<TokenWithMetadata, Erc777ApprovalData> tokenToData = {};
    for (var token in tokens) {
      var approval = await _exploitableToken(from, to, spender, token);
      var contract = Erc777(address: token, client: web3Client);
      var symbol = "";
      try {
        symbol = await contract.symbol();
      } on RangeError {
        // contract doesnt implement this function
      }
      tokenToData[TokenWithMetadata(symbol, TokenType.erc777, token)] =
          approval.data;
    }
    return Erc777TokenApprovals(spender, tokenToData);
  }
}

class Erc777ApprovalData {
  Erc777ApprovalData(this.owners, this.isDefaultOperator);

  final Set<EthereumAddress> owners;
  final bool isDefaultOperator;
}

class Erc777TokenApproval {
  Erc777TokenApproval(this.token, this.spender, this.data);

  final EthereumAddress token;
  final EthereumAddress spender;
  final Erc777ApprovalData data;
}

class Erc777TokenApprovals {
  Erc777TokenApprovals(this.spender, this.tokenToData);

  final EthereumAddress spender;
  final Map<TokenWithMetadata, Erc777ApprovalData> tokenToData;
}
