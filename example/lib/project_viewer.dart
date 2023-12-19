import 'dart:async';
import 'package:flutter/material.dart';
import 'database.dart';
import 'package:task_master/task_master.dart';
import 'package:intl/intl.dart';

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
    listenToFirebase();
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
    child = 'Epic/$currentEpic';
    labelData = widget.labels;
  }

  // Listener to montior changes in database and update/reset application accordingly
  void listenToFirebase() async {
    Database.once('complete/$currentEpic').then((value) {
      setState(() {
        completedData = value ?? {};
      });
    });

    completeAdded = Database.onValue('complete/$currentEpic').listen((event) {
      setState(() {
        completedData = event.snapshot.value ?? {};
      });
    });

    Database.once(child).then((value) {
      setState(() {
        managemntData = value ?? {};
      });
    });

    fbadded = Database.onValue(child).listen((event) {
      setState(() {
        managemntData = event.snapshot.value ?? {};
      });
    });

    try {
      DatabaseReference cardRef = Database.reference('Label/$currentEpic');
      labelAdded = cardRef.onChildAdded.listen((event) {
        updateFunctions(event);
      });
      labelChanged = cardRef.onChildChanged.listen((event) {
        updateFunctions(event);
      });
      labelRemoved = cardRef.onChildRemoved.listen((event) {
        setState(() {
          labelData[event.snapshot.key] = null;
          labelData = removeNull(labelData);
        });
      });
    } catch (e) {}
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
      labels: labelData == null ? null : labelData,
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
        Database.push(children: 'Label/${widget.epic}', data: data);
      },
      onUpdateLabel: (data, location) {
        Database.update(
            children: 'Label/${widget.epic}', location: location, data: data);
      },
      onDeleteLabel: (location) {
        Database.update(
            children: 'Label/$currentEpic', location: location, data: {});
      },
      onSubmit: (title, image, date, color) async {
        DateFormat dayFormatter = DateFormat('y-MM-dd hh:mm:ss');
        String createdDate =
            dayFormatter.format(DateTime.now()).replaceAll(' ', 'T');

        Database.push(children: '$child/', data: {
          'department': currentEpic,
          'createdBy': "example",
          'dateCreated': createdDate,
          'dueDate': (date != '') ? date : null,
          'title': title,
          'image': (image == ' ') ? 'temp' : image,
          'color': color,
        });
      },
      onUpdate: (title, image, date, color, project) async {
        Database.update(
            children: '$child/',
            data: {
              'boards': managemntData[project]['boards'],
              'cards': managemntData[project]['cards'],
              'department': currentEpic,
              'completed': managemntData[project]['completed'],
              'createdBy': managemntData[project]['createdBy'],
              'dateCreated': managemntData[project]['dateCreated'],
              'dueDate': (date != '') ? date : null,
              'title': title,
              'image': (image == ' ') ? 'temp' : image,
              'color': color,
            },
            location: project);
      },
      onComplete: (project) async {
        DateFormat dayFormatter = DateFormat('y-MM-dd hh:mm:ss');
        String createdDate =
            dayFormatter.format(DateTime.now()).replaceAll(' ', 'T');

        Database.update(
            children: '$child/$project/',
            location: 'completed',
            data: {
              'department': "example user",
              'date': createdDate,
            });
      },
      onProjectDelete: (id) {
        Database.update(children: '$child/', location: id, data: {});
      },
    );
  }
}
