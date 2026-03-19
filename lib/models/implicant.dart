class Implicant {
  final List<int> minterms;
  final String binaryRepresentation;
  bool isPrime = true; // Initially, all implicants are considered prime

  Implicant(this.minterms, this.binaryRepresentation);

  bool covers(int minterm) {
    final mintermBinary = minterm.toRadixString(2).padLeft(binaryRepresentation.length, '0');
    for (int i = 0; i < binaryRepresentation.length; i++) {
      if (binaryRepresentation[i] != '-' && binaryRepresentation[i] != mintermBinary[i]) {
        return false;
      }
    }
    return true;
  }

  @override
  String toString() {
    return '$binaryRepresentation (m${minterms.join(', m')})';
  }
}