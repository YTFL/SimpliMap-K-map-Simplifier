
class Term {
  final String term;
  final bool negated;

  Term(this.term, {this.negated = false});

  @override
  String toString() {
    return term + (negated ? "'" : "");
  }
}
