extension FormattedString on Duration {
  String toFormatString() {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String hours = twoDigits(inHours);
    String minutes = twoDigits(inMinutes.remainder(60));
    String seconds = twoDigits(inSeconds.remainder(60));
    return "${(hours != '00' ? '$hours:' : '')}$minutes:$seconds";
  }
}
