import 'package:flutter_approval/abi/erc1155.g.dart';
import 'package:flutter_approval/blockchain/token.dart';
import 'package:flutter_approval/utils/converter.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

class Erc1155Seeker {
  Web3Client web3Client;
  Erc1155Seeker(this.web3Client);

  Future<Erc1155TokenApproval> _exploitableToken(BlockNum from, BlockNum to,
      EthereumAddress spender, EthereumAddress token) async {
    var contract = Erc1155(address: token, client: web3Client);
    var deployedContract = contract.self;
    var approvalForAllSignature = bytesToHex(
        deployedContract.event('ApprovalForAll').signature,
        padToEvenLength: true,
        forcePadLength: 64,
        include0x: true);
    var operatorFilter =
        FilterOptions(fromBlock: from, toBlock: to, address: token, topics: [
      [approvalForAllSignature],
      [],
      [
        bytesToHex(spender.addressBytes,
            padToEvenLength: true, forcePadLength: 64, include0x: true)
      ],
    ]);
    var approvals = await web3Client.getLogs(operatorFilter);
    Set<EthereumAddress> operatorOwners = {};
    for (var approval in approvals) {
      if (hexToDartInt(approval.data ?? '0x0') == 1) {
        operatorOwners.add(topicToAddress(approval.topics![1]));
      } else {
        operatorOwners.remove(topicToAddress(approval.topics![1]));
      }
    }
    return Erc1155TokenApproval(token, spender, operatorOwners);
  }

  Future<Erc1155TokenApprovals> exploitableTokens(BlockNum from, BlockNum to,
      EthereumAddress spender, List<EthereumAddress> tokens) async {
    Map<TokenWithMetadata, Set<EthereumAddress>> tokenToOwners = {};
    for (var token in tokens) {
      var approval = await _exploitableToken(from, to, spender, token);
      if (approval.owners.isNotEmpty) {
        tokenToOwners[TokenWithMetadata("", TokenType.erc1155, token)] =
            approval.owners;
      }
    }
    return Erc1155TokenApprovals(spender, tokenToOwners);
  }
}

class Erc1155TokenApproval {
  Erc1155TokenApproval(this.token, this.spender, this.owners);

  final EthereumAddress token;
  final EthereumAddress spender;
  final Set<EthereumAddress> owners;
}

class Erc1155TokenApprovals {
  Erc1155TokenApprovals(this.spender, this.tokenToOwners);

  final EthereumAddress spender;
  final Map<TokenWithMetadata, Set<EthereumAddress>> tokenToOwners;
}
