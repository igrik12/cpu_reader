/// A simple object that encapsulates the [min] and [max] frequencies
class MinMaxFrequency<T> {
  final T _min;
  final T _max;
  T get min => _min;
  T get max => _max;

  MinMaxFrequency(this._min, this._max);

  /// Converts instance [toJson] format
  Map<String, dynamic> toJson() => {"min": this.min, "max": this.max};
}
