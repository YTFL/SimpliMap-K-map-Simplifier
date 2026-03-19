class Minterm {
  final int value;
  final int numberOfOnes;
  bool isCovered = false;

  Minterm(this.value) : numberOfOnes = _countOnes(value);

  static int _countOnes(int n) {
    int count = 0;
    int temp = n;
    while (temp > 0) {
      temp &= (temp - 1);
      count++;
    }
    return count;
  }

  @override
  String toString() {
    return 'm$value';
  }
}