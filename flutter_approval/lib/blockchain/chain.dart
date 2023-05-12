import 'dart:math';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:toml/toml.dart';

enum Chain {
  ethereum(chainId: 1),
  arbitrumNova(chainId: 42170),
  arbitrumOne(chainId: 42161),
  avalancheCChain(chainId: 43114),
  bobaNetwork(chainId: 288),
  binanceSmartChain(chainId: 56),
  fantomOpera(chainId: 250),
  fuse(chainId: 122),
  gnosis(chainId: 100),
  moonbeam(chainId: 1284),
  moonriver(chainId: 1285),
  optimism(chainId: 10),
  polygon(chainId: 137),
  polygonZkEvm(chainId: 1101);

  const Chain({
    required this.chainId,
  });

  final int chainId;
}

extension ChainRpc on Chain {
  Future<String> randomRpc() async {
    var input = await rootBundle.loadString('assets/rpc.toml');
    var document = TomlDocument.parse(input);
    var config = document.toMap();
    List<String> rpcs = [];
    for (var element in config['nodes'][chainId.toString()]) {
      rpcs.add(element as String);
    }
    return rpcs[Random().nextInt(rpcs.length)];
  }
}
