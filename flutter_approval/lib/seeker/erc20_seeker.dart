import 'package:flutter_approval/abi/erc20.g.dart';
import 'package:flutter_approval/blockchain/token.dart';
import 'package:flutter_approval/utils/converter.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

class Erc20Seeker {
  Web3Client web3Client;
  Erc20Seeker(this.web3Client);

  Future<Erc20TokenApproval> _approvalEvents(BlockNum from, BlockNum to,
      EthereumAddress spender, EthereumAddress token) async {
    var contract = Erc20(address: token, client: web3Client);
    var event = contract.self.event('Approval');
    var approvalFilter =
        FilterOptions(fromBlock: from, toBlock: to, address: token, topics: [
      [
        bytesToHex(event.signature,
            padToEvenLength: true, forcePadLength: 64, include0x: true)
      ],
      [],
      [
        bytesToHex(spender.addressBytes,
            padToEvenLength: true, forcePadLength: 64, include0x: true)
      ]
    ]);
    var approvals = await web3Client.getLogs(approvalFilter);
    Map<EthereumAddress, BigInt> ownerToAmount = {};
    for (var approval in approvals) {
      ownerToAmount[topicToAddress(approval.topics![1])] =
          hexToInt(approval.data ?? '0x0');
    }
    return Erc20TokenApproval(token, spender, ownerToAmount);
  }

  Future<BigInt> _allowance(
      EthereumAddress token, EthereumAddress owner, EthereumAddress spender) {
    var contract = Erc20(address: token, client: web3Client);
    return contract.allowance(owner, spender);
  }

  Future<BigInt> _balance(EthereumAddress token, EthereumAddress owner) {
    var contract = Erc20(address: token, client: web3Client);
    return contract.balanceOf(owner);
  }

  Future<Erc20TokenApproval> _exploitableAmount(BlockNum from, BlockNum to,
      EthereumAddress spender, EthereumAddress token) async {
    var pastApprovals = await _approvalEvents(from, to, spender, token);
    Map<EthereumAddress, BigInt> ownerToExploitableAmount = {};
    for (var approval in pastApprovals.ownerToAmount.entries) {
      if (approval.value != BigInt.zero) {
        var allowance = await _allowance(token, approval.key, spender);
        var balance = await _balance(token, approval.key);
        var exploitableAmount = BigInt.zero;
        if (balance > allowance) {
          exploitableAmount = allowance;
        } else {
          exploitableAmount = balance;
        }

        if (exploitableAmount > BigInt.zero) {
          ownerToExploitableAmount[approval.key] = exploitableAmount;
        }
      }
    }
    return Erc20TokenApproval(token, spender, ownerToExploitableAmount);
  }

  Future<Erc20TokenApprovals> exploitableAmounts(BlockNum from, BlockNum to,
      EthereumAddress spender, List<EthereumAddress> tokens) async {
    Map<Erc20Token, Map<EthereumAddress, BigInt>> tokenToOwnerToAmount = {};
    for (var token in tokens) {
      var contract = Erc20(address: token, client: web3Client);
      var symbol = "";
      var decimal = await contract.decimals();
      try {
        symbol = await contract.symbol();
      } on RangeError {
        // contract doesnt implement this function
      }
      var approval = await _exploitableAmount(from, to, spender, token);
      if (approval.ownerToAmount.isNotEmpty) {
        tokenToOwnerToAmount[
              Erc20Token(symbol, TokenType.erc20, token, decimal)] =
          approval.ownerToAmount;
      }
    }
    return Erc20TokenApprovals(spender, tokenToOwnerToAmount);
  }
}

class Erc20TokenApproval {
  Erc20TokenApproval(this.token, this.spender, this.ownerToAmount);

  final EthereumAddress token;
  final EthereumAddress spender;
  final Map<EthereumAddress, BigInt> ownerToAmount;
}

class Erc20TokenApprovals {
  Erc20TokenApprovals(this.spender, this.tokenToOwnerToAmount);

  final EthereumAddress spender;
  final Map<Erc20Token, Map<EthereumAddress, BigInt>> tokenToOwnerToAmount;
}
