class CardData {
  CardData({
    this.title,
    this.dateCreated,
    this.createdBy,
    this.id,
    this.priority,
    this.level,
    this.description,
    this.dueDate,
    this.points,
    this.assigned = const [],
    this.editors = const [],
    this.checkList,
    this.comments,
    this.boardId,
    this.labels
  });

  /// Card title
  String? title;

  /// Date card created
  final String? dateCreated;

  /// User (UID) that created the card
  final String? createdBy;

  /// Card ID
  final String? id;

  /// JSON map of comments
  Map<String, dynamic>? comments;

  /// JSON map of checklist
  Map<String, dynamic>? checkList;

  /// List of assigned UIDs to task
  List<String> assigned;

  /// List of editors for task card
  List<String> editors;

  /// Points to assign to the task
  int? points;

  /// Due date of the task
  String? dueDate;

  /// Description of the task
  String? description;

  /// Board in which the task/card is located
  String? boardId;

  /// Card priority to determine card ordering
  int? priority;

  /// Used to determine card importance (High, Medium, Low, etc.)
  String? level;

  /// JSON data of labels assigned to task card
  Map<String, dynamic>? labels;

  /// convert JSON data to CardData object
  factory CardData.fromJSON(Map<String, dynamic> data, String key) {
    List<String> editors = [];
    if (data[key]['data']['editors'] != null) {
      for (int i = 0; i < data[key]['data']['editors'].length; i++) {
        editors.add(data[key]['data']['editors'][i]);
      }
    }

    List<String> assigned = [];
    if (data[key]['data']['assign'] != null) {
      assigned.add(data[key]['data']['assign']);
    }
    if (data[key]['data']['assigned'] != null) {
      for (int i = 0; i < data[key]['data']['assigned'].length; i++) {
        assigned.add(data[key]['data']['assigned'][i]);
      }
    }
    return CardData(
      title: data[key]['data']['title'] as String?,
      dateCreated: data[key]['data']['dateCreated'] as String?,
      id: key,
      priority: data[key]['priority'] as int?,
      level: data[key]['data']['level'] as String?,
      description: data[key]['data']['description'] as String?,
      dueDate: data[key]['data']['dueDate'] as String?,
      points: data[key]['data']['points'] as int?,
      assigned: assigned,
      editors: editors,
      checkList: data[key]['data']['subTasks'] as Map<String, dynamic>?,
      comments: data[key]['data']['comments'] as Map<String, dynamic>?,
      boardId: data[key]['board'] as String?,
      labels: data[key]['data']['labels'] as Map<String, dynamic>?
    );
  }

  /// Convert cardData object to JSON data
  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      'title': title,
      'dateCreated': dateCreated,
      'id': id,
      'priority': priority,
      'level': level,
      'description': description,
      'dueDate': dueDate,
      'points': points,
      'assigned': assigned,
      'editors': editors,
      'checkList': checkList,
      'comments': comments,
      'board': boardId,
      'labels': labels
    };
  }
}
