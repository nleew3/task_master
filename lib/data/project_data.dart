class ProjectData {
  ProjectData({
    required this.color,
    required this.title,
    required this.dateCreated,
    required this.createdBy,
    this.department,
    required this.id,
    this.dueDate,
  });

  /// Color of project text in card
  final int color;

  /// Title of project
  String title;

  /// Date project created
  final String dateCreated;

  /// Date project due
  final String? dueDate;

  /// User (uid) that created the project
  final String createdBy;

  /// Department/epic of the project
  final String? department;

  /// Project ID
  final String id;

  /// Used to convert JSON data to ProjectData object
  factory ProjectData.fromJSON(Map<String, dynamic> data, String key) {
    return ProjectData(
      color: data['color'] as int,
      id: key,
      title: data['title'] as String,
      dateCreated: data['dateCreated'] as String,
      createdBy: data['createdBy'] as String,
      department: data['department'] as String?,
      dueDate: data['dueDate'] as String?
    );
  }

  /// Used to convert ProjectData object to JSON data string
  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      'color': color,
      'id': id,
      'title': title,
      'dateCreated': dateCreated,
      'createdBy': createdBy,
      'department': department,
      'dueDate': dueDate
    };
  }
}
