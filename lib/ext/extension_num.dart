/// 扩展函数
extension StringExtension on num {
  String formatPercentNumber() {
    String result = (this * 100).toStringAsFixed(2);
    if (result.endsWith('.00')) {
      result = result.replaceAll('.00', '');
    } else if (result.endsWith('0')) {
      result = result.substring(0, result.length - 1);
    }
    return result;
  }
}
