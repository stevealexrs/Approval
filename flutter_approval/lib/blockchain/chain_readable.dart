import 'package:flutter/material.dart';
import 'package:flutter_approval/blockchain/chain.dart';
import 'package:flutter_svg/svg.dart';

extension ChainReadable on Chain {
  /// Pretty printable
  String get prettyName {
    switch (this) {
      case Chain.ethereum:
        return "Ethereum";
      case Chain.arbitrumNova:
        return "Arbitrum Nova";
      case Chain.arbitrumOne:
        return "Arbitrum One";
      case Chain.avalancheCChain:
        return "Avalanche C-Chain";
      case Chain.bobaNetwork:
        return "Boba Network";
      case Chain.binanceSmartChain:
        return "Binance Smart Chain";
      case Chain.fantomOpera:
        return "Fantom Opera";
      case Chain.fuse:
        return "Fuse";
      case Chain.gnosis:
        return "Gnosis";
      case Chain.moonbeam:
        return "Moonbeam";
      case Chain.moonriver:
        return "Moonriver";
      case Chain.optimism:
        return "Optimism";
      case Chain.polygon:
        return "Polygon";
      case Chain.polygonZkEvm:
        return "Polygon zkEVM";
    }
  }

  String get iconSvgAssetName {
    switch (this) {
      case Chain.ethereum:
        return "assets/logo/ETH.svg";
      case Chain.arbitrumNova:
        return "assets/logo/arb-nova.svg";
      case Chain.arbitrumOne:
        return "assets/logo/arb-one.svg";
      case Chain.avalancheCChain:
        return "assets/logo/AVAX.svg";
      case Chain.bobaNetwork:
        return "assets/logo/boba.svg";
      case Chain.binanceSmartChain:
        return "assets/logo/BNB.svg";
      case Chain.fantomOpera:
        return "assets/logo/ftm-blue.svg";
      case Chain.fuse:
        return "assets/logo/fuse.svg";
      case Chain.gnosis:
        return "assets/logo/gnosis.svg";
      case Chain.moonbeam:
        return "assets/logo/moonbeam.svg";
      case Chain.moonriver:
        return "assets/logo/moonriver.svg";
      case Chain.optimism:
        return "assets/logo/optimism.svg";
      case Chain.polygon:
        return "assets/logo/polygon.svg";
      case Chain.polygonZkEvm:
        return "assets/logo/polygon-zkevm.svg";
    }
  }

  Widget icon() {
    return SvgPicture.asset(iconSvgAssetName);
  }
}
