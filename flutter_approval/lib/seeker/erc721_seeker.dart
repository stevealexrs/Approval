import 'package:flutter_approval/abi/erc721.g.dart';
import 'package:flutter_approval/blockchain/token.dart';
import 'package:flutter_approval/utils/converter.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

class Erc721Seeker {
  Web3Client web3Client;
  Erc721Seeker(this.web3Client);

  Future<Erc721RawTokenApproval> _approvalEvents(BlockNum from, BlockNum to,
      EthereumAddress spender, EthereumAddress token) async {
    var contract = Erc721(address: token, client: web3Client);
    var approvalSignature = bytesToHex(
        contract.self.event('Approval').signature,
        padToEvenLength: true,
        forcePadLength: 64,
        include0x: true);
    var approvalForAllSignature = bytesToHex(
        contract.self.event('ApprovalForAll').signature,
        padToEvenLength: true,
        forcePadLength: 64,
        include0x: true);
    var approvalFilter =
        FilterOptions(fromBlock: from, toBlock: to, address: token, topics: [
      [approvalSignature, approvalForAllSignature],
      [],
      [
        bytesToHex(spender.addressBytes,
            padToEvenLength: true, forcePadLength: 64, include0x: true)
      ]
    ]);
    var approvals = await web3Client.getLogs(approvalFilter);
    Map<EthereumAddress, Set<BigInt>> ownerToTokenIds = {};
    Map<EthereumAddress, bool> isOperator = {};
    Set<EthereumAddress> operators = {};
    for (var approval in approvals) {
      if (approval.topics![0] == approvalSignature) {
        var original =
            ownerToTokenIds[topicToAddress(approval.topics![1])] ?? {};
        original.add(hexToInt(approval.topics![3]));
        ownerToTokenIds[topicToAddress(approval.topics![1])] = original;
      } else if (approval.topics![0] == approvalForAllSignature) {
        isOperator[topicToAddress(approval.topics![1])] =
            hexToDartInt(approval.data ?? '0x0') == 1;
      }
    }
    for (var operatorStatus in isOperator.entries) {
      if (operatorStatus.value) {
        operators.add(operatorStatus.key);
      }
    }
    return Erc721RawTokenApproval(token, spender, ownerToTokenIds, operators);
  }

  Future<bool> _isApproved(EthereumAddress token, EthereumAddress owner,
      EthereumAddress spender, BigInt tokenId) async {
    var contract = Erc721(address: token, client: web3Client);
    if (spender != await contract.getApproved(tokenId)) {
      return false;
    }
    if (owner != await contract.ownerOf(tokenId)) {
      return false;
    }
    return true;
  }

  Future<Erc721TokenApproval> _exploitableToken(BlockNum from, BlockNum to,
      EthereumAddress spender, EthereumAddress token) async {
    var pastApprovals = await _approvalEvents(from, to, spender, token);
    Map<EthereumAddress, Set<BigInt>> ownerToExploitableToken = {};
    var operators = pastApprovals.ownersOfOperator;
    for (var approval in pastApprovals.ownerToTokenIds.entries) {
      if (operators.contains(approval.key)) {
        ownerToExploitableToken[approval.key] = {};
      } else {
        Set<BigInt> tokenIds = {};
        for (var tokenId in approval.value) {
          if (await _isApproved(token, approval.key, spender, tokenId)) {
            tokenIds.add(tokenId);
          }
        }
        ownerToExploitableToken[approval.key] = tokenIds;
      }
    }
    return Erc721TokenApproval(token, spender, ownerToExploitableToken);
  }

  Future<Erc721TokenApprovals> exploitableTokens(BlockNum from, BlockNum to,
      EthereumAddress spender, List<EthereumAddress> tokens) async {
    Map<TokenWithMetadata, Map<EthereumAddress, Set<BigInt>>>
        tokenToOwnerToTokenIds = {};
    for (var token in tokens) {
      var approval = await _exploitableToken(from, to, spender, token);
      var contract = Erc721(address: token, client: web3Client);
      var symbol = "";
      try {
        symbol = await contract.symbol();
      } on RangeError {
        // contract doesnt implement this function
      }
      if (approval.ownerToTokenIds.isNotEmpty) {
        tokenToOwnerToTokenIds[
                TokenWithMetadata(symbol, TokenType.erc721, token)] =
            approval.ownerToTokenIds;
      }
    }
    return Erc721TokenApprovals(spender, tokenToOwnerToTokenIds);
  }
}

class Erc721RawTokenApproval {
  Erc721RawTokenApproval(
      this.token, this.spender, this.ownerToTokenIds, this.ownersOfOperator);

  final EthereumAddress token;
  final EthereumAddress spender;
  final Map<EthereumAddress, Set<BigInt>> ownerToTokenIds;
  // account that approve spender as operators
  final Set<EthereumAddress> ownersOfOperator;
}

class Erc721TokenApproval {
  Erc721TokenApproval(this.token, this.spender, this.ownerToTokenIds);

  final EthereumAddress token;
  final EthereumAddress spender;
  // empty set means all tokens
  final Map<EthereumAddress, Set<BigInt>> ownerToTokenIds;
}

class Erc721TokenApprovals {
  Erc721TokenApprovals(this.spender, this.tokenToOwnerToTokenIds);

  final EthereumAddress spender;
  // empty set means all tokens
  final Map<TokenWithMetadata, Map<EthereumAddress, Set<BigInt>>>
      tokenToOwnerToTokenIds;
}
