import 'package:flutter/material.dart';
import 'package:flutter_approval/blockchain/token.dart';
import 'package:flutter_svg/svg.dart';

extension TokenLogo on TokenWithMetadata {
  String? get iconSvgAssetName {
    switch (symbol) {
      case "BTC":
      case "BTC.b":
      case "BTCB":
        return "assets/logo/BTC.svg";
      case "ETH":
        return "assets/logo/ETH.svg";
      case "WETH":
      case "WETH.e":
        return "assets/logo/WETH.svg";
      case "WBTC":
      case "WBTC.e":
        return "assets/logo/WBTC.svg";
      case "stETH":
        return "assets/logo/stETH.svg";
      case "USDC":
      case "USDC.e":
        return "assets/logo/USDC.svg";
      case "USDT":
      case "USDt":
      case "USDT.e":
      case "BSC-USD":
        return "assets/logo/USDT.svg";
      case "DAI":
      case "DAI.e":
        return "assets/logo/DAI.svg";
      case "TUSD":
        return "assets/logo/TUSD.svg";
      case "BUSD":
        return "assets/logo/BUSD.svg";
      case "MATIC":
        return "assets/logo/polygon.svg";
      case "ARB":
        return "assets/logo/ARB.svg";
      case "OP":
        return "assets/logo/optimism.svg";
      case "WXDAI":
        return "assets/logo/WXDAI.svg";
      case "GNO":
        return "assets/logo/gnosis.svg";
      case "BNB":
      case "WBNB":
        return "assets/logo/BNB.svg";
      case "WAVAX":
        return "assets/logo/AVAX.svg";
      case "UNI":
        return "assets/logo/UNI.svg";
      case "LINK":
      case "LINK.e":
        return "assets/logo/LINK.svg";
      case "LDO":
        return "assets/logo/LDO.svg";
      case "SNX":
        return "assets/logo/SNX.svg";
      case "FRAX":
        return "assets/logo/FRAX.svg";
      case "XRP":
        return "assets/logo/XRP.svg";
      case "ADA":
        return "assets/logo/ADA.svg";
      case "DOGE":
        return "assets/logo/DOGE.svg";
      case "SHIB":
        return "assets/logo/SHIB.svg";
      case "MANA":
        return "assets/logo/MANA.svg";
      case "WFTM":
      case "SFTM":
        return "assets/logo/ftm-blue.svg";
      case "WFUSE":
        return "assets/logo/WFUSE.svg";
      case "VOLT":
        return "assets/logo/VOLT.svg";
      case "BOBA":
        return "assets/logo/boba.svg";
      case "WGLMR":
        return "assets/logo/moonbeam.svg";
      case "WMOVR":
        return "assets/logo/moonriver.svg";
      case "BLOCKS":
        return "assets/logo/BLOCKS.svg";
      case "BAYC":
        return "assets/logo/BAYC.svg";
      case "MAYC":
        return "assets/logo/MAYC.svg";
      default:
        return null;
    }
  }

  AssetImage? get iconPngAsset {
    switch (symbol) {
      case "MOON":
        return const AssetImage("assets/logo/MOON.png");
      case "fUSD":
        return const AssetImage("assets/logo/fUSD.png");
      case "GLINT":
        return const AssetImage("assets/logo/GLINT.png");
      case "MLOOT":
        return const AssetImage("assets/logo/MLOOT.png");
      case "STELLA":
        return const AssetImage("assets/logo/STELLA.png");
      default:
        return null;
    }
  }

  Widget? icon() {
    var svgName = iconSvgAssetName;
    var pngAsset = iconPngAsset;
    if (svgName != null) {
      return SvgPicture.asset(svgName);
    } else if (pngAsset != null) {
      return Image(
        image: pngAsset,
      );
    } else {
      return null;
    }
  }
}
