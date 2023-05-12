import 'package:flutter/services.dart';
import 'package:flutter_approval/blockchain/chain.dart';
import 'package:flutter_approval/blockchain/token.dart';
import 'package:toml/toml.dart';
import 'package:web3dart/web3dart.dart';

extension ChainToken on Chain {
  Future<Set<TokenWithMetadata>> get tokens async {
    var input = await rootBundle.loadString('assets/token.toml');
    var document = TomlDocument.parse(input);
    var config = document.toMap();
    return TokenConfig.from(config).chains[chainId]!;
  }
}

class TokenConfig {
  Map<int, Set<TokenWithMetadata>> chains;

  TokenConfig.from(Map<String, dynamic> map) : chains = {} {
    for (var chainTokens in map['tokens'].entries) {
      Set<TokenWithMetadata> tokens = {};
      chainTokens.value.forEach((e) {
        tokens.add(TokenWithMetadata(
            e["symbol"],
            TokenType.values.firstWhere((element) => element.name == e["type"]),
            EthereumAddress.fromHex(e["address"])));
      });
      chains[int.parse(chainTokens.key)] = tokens;
    }
  }
}
