class LabelData {
  LabelData({
    required this.name,
    required this.color,
  });

  /// Name of the label
  final String name;

  /// Color of the label (as a int)
  final int color;

  /// Convert JSON data to LabelData object
  factory LabelData.fromJSON(Map<String, dynamic> data) {
    return LabelData(color: data['color'] as int, name: data['name'] as String);
  }

  /// Convert LabelData object to JSON data string
  Map<String, dynamic> toJSON() {
    return <String, dynamic>{'color': color, 'name': name};
  }
}
