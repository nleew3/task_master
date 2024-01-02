import 'package:flutter/material.dart';
import 'database.dart';
import 'package:task_master/task_master.dart';

class ProjectViewer extends StatefulWidget {
  const ProjectViewer({
    Key? key,
    required this.width,
    required this.height,
    required this.epic,
    this.onTap,
    this.labels,
    this.startProject
  }):super(key: key);

  final double width;
  final double height;
  final String epic;
  final Function(String project)? onTap;
  final String? startProject;
  final dynamic labels;
  @override
  State<ProjectViewer> createState() => _ProjectViewerState();
}

class _ProjectViewerState extends State<ProjectViewer> {
  dynamic managemntData = {};
  dynamic completedData = {};
  String child = '';
  String currentEpic = '';
  dynamic labelData;
  @override
  void initState() {
    start();
    getData();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Initializes variables
  void start() {
    currentEpic = widget.epic;
    managemntData = {};
    child = 'department/$currentEpic';
    labelData = widget.labels;
  }

  // Listener to montior changes in database and update/reset application accordingly
  void getData() async {
    Database.once('complete/$currentEpic').then((value) {
      setState(() {
        completedData = value ?? {};
      });
    });

    Database.once(child).then((value) {
      setState(() {
        managemntData = value ?? {};
      });
    });
  }

  // Updates data based on event received
  void updateFunctions(event) {
    dynamic temp = event.snapshot.value;
    setState(() {
      if (labelData == null) {
        labelData = {event.snapshot.key: temp};
      } else {
        labelData[event.snapshot.key] = temp;
      }
    });
  }

  // Formats projectData to be used in ProjectManager
  List<ProjectData> projectData() {
    List<ProjectData> data = [];
    if (managemntData != {}) {
      for (String key in managemntData!.keys) {
        if (key != 'title') {
          if (managemntData![key]['complete'] == null) {
            data.add(ProjectData.fromJSON(managemntData![key], key));
          }
        }
      }
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return ProjectManager(
      labels: labelData,
      height: widget.height,
      width: widget.width,
      projectData: projectData(),
      startProject: widget.startProject,
      allowEditing: true,
      epic: currentEpic,
      onProjectTap: (val) {
        if (widget.onTap != null) {
          widget.onTap!(val);
        }
      },
      onSubmitLabel: (data) {
        String location = DateTime.now().microsecondsSinceEpoch.toString();
        labelData[currentEpic][location] = data;
        setState(() {});
      },
      onUpdateLabel: (data, location) {
        labelData[currentEpic][location] = data;
        setState(() {});
      },
      onDeleteLabel: (location) {
        labelData[currentEpic][location] = null;
        setState(() {});
      },
      onSubmit: (title, image, date, color) async {
        managemntData[DateTime.now().millisecondsSinceEpoch.toString()] = {
          'department': currentEpic,
          'createdBy': "example",
          'dateCreated': DateTime.now().toString(),
          'dueDate': (date != '') ? date : null,
          'title': title,
          'image': (image == ' ') ? 'temp' : image,
          'color': color,
        };
        setState(() {});
      },
      onUpdate: (title, image, date, color, project) async {
        managemntData[project]['dueDate'] = (date != '') ? date : null;
        managemntData[project]['title'] = title;
        managemntData[project]['image'] = (image == ' ') ? 'temp' : image;
        managemntData[project]['color'] = color;
        setState(() {});
      },
      onComplete: (project) async {
        completedData[project] = {
          "completedDate": DateTime.now().toString(),
          "createdBy": managemntData[project]['createdBy'],
          "dueDate": managemntData[project]['dueDate'],
          "title": managemntData[project]['title']
        };
        setState(() {});
      },
      onProjectDelete: (id) {
        managemntData[id] = null;
        setState(() {});
      },
    );
  }
}
