import 'dart:async';
import 'package:flutter/material.dart';
import 'package:task_master/task_master.dart';
import 'database.dart';
import 'ui.dart';
import 'package:intl/intl.dart';

class BoardViewer extends StatefulWidget {
  const BoardViewer({
    Key? key,
    this.completedData,
    required this.epic,
    required this.project,
    required this.currentUID,
    required this.users,
    required this.width,
    required this.labels,
    required this.height
  }):super(key: key);

  final dynamic labels;
  final String epic;
  final String project;
  final String currentUID;
  final Map<String, dynamic> users;
  final double width;
  final double height;
  final dynamic completedData;

  @override
  State<BoardViewer> createState() => _BoardViewerState();
}

class _BoardViewerState extends State<BoardViewer> {
  String child = '';
  String selectedProject = '';
  String currentEpic = '';
  Map<String, BoardData> currentBoardData = {};
  Map<String, CardData> currentCardData = {};
  dynamic labelsData;
  double startingWidth = 0;

  bool showChart = false;

  bool update = false;
  dynamic points;

  bool hasStarted = false;
  dynamic completedTasks;

  @override
  void initState() {
    super.initState();
    start();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Initialize variables and start listeners
  void start() async {
    firebaseReset();
    completedTasks = widget.completedData;
    selectedProject = widget.project;
    currentEpic = widget.epic;
    child = 'department/$currentEpic/$selectedProject';

    if (selectedProject != '') showChart = true;

    startingWidth = widget.width;

    startingWidth = widget.width;

    await Database.once('$child/boards').then((value) {
      currentBoardData = boardData(value);
      update = true;
      setState(() {});
    });

    labelsData = widget.labels;

    await Database.once('$child/cards').then((value) {
      currentCardData = cardData(value);
      update = true;
      hasStarted = true;
      setState(() {});
    });

    await Database.once("points/$currentEpic").then((value) {
      points = value;
    });

    listenToFirebase();
    setState(() {});
  }

  // Closes listeners and resets data
  void firebaseReset() {
    currentBoardData = {};
    currentCardData = {};
    hasStarted = false;
    labelsData = null;
    showChart = false;

    completedTasks = null;
    points = null;
    update = true;
  }

  // Listener to montior changes in database and update/reset application accordingly
  void listenToFirebase() {
    boardAdded = Database.onValue('$child/boards').listen((event) {
      setState(() {
        currentBoardData = boardData(event.snapshot.value);
        update = true;
      });
    });
    cardAdded = Database.onValue('$child/cards').listen((event) {
      setState(() {
        currentCardData = cardData(event.snapshot.value);
        update = true;
      });
    });

    try {
      DatabaseReference cardRef = Database.reference('Label/$currentEpic');
      labelAdded = cardRef.onChildAdded.listen((event) {
        updateFunction(event);
      });
      labelChanged = cardRef.onChildChanged.listen((event) {
        updateFunction(event);
      });
      labelRemoved = cardRef.onChildRemoved.listen((event) {
        setState(() {
          labelsData[event.snapshot.key] = null;
          labelsData = removeNull(labelsData);
        });
      });
    } catch (e) {}
  }

  // Updates data based on event received
  void updateFunction(event) {
    dynamic temp = event.snapshot.value;
    setState(() {
      if (labelsData == null) {
        labelsData = {event.snapshot.key: temp};
      } else {
        labelsData[event.snapshot.key] = temp;
      }
    });
  }

  void callback() {
    setState(() {
      update = false;
    });
  }

  // Drop down function included in the package
  List<DropDownItems> createDropDown() {
    List<DropDownItems> dropDownNames = [
      DropDownItems(value: '', text: 'Pick a person')
    ];

    dropDownNames.add(DropDownItems(
        value: widget.currentUID,
        text: widget.users[widget.currentUID]['displayName']));

    for (String uid in widget.users.keys) {
      if (uid == dropDownNames[1].value) continue;

      dropDownNames.add(
          DropDownItems(value: uid, text: widget.users[uid]['displayName']));
    }

    return dropDownNames;
  }

  // Pull important data from JSON and to be used in boardManager
  Map<String, BoardData> boardData(dynamic projectBoardData) {
    Map<String, BoardData> data = {};
    if (projectBoardData != null) {
      for (String key in projectBoardData.keys) {
        data[key] = BoardData.fromJSON(
            projectBoardData[key], key, Colors.lightBlue.value);
      }
    }
    return data;
  }

  // Used to pull data from cardData JSON and format it to be used in the managers
  Map<String, CardData> cardData(dynamic projectCardData) {
    Map<String, CardData> data = {};
    if (projectCardData != null) {
      for (String key in projectCardData.keys) {
        Map<String, dynamic>? labels;
        if (labelsData != null &&
            projectCardData[key]['data']['labels'] != null) {
          for (int i = 0;
              i <= projectCardData[key]['data']['labels'].length - 1;
              i++) {
            if (labelsData[projectCardData[key]['data']['labels'][i]] != null) {
              if (labels == null) {
                labels = {
                  projectCardData[key]['data']['labels'][i]:
                      labelsData[projectCardData[key]['data']['labels'][i]]
                };
              } else {
                labels[projectCardData[key]['data']['labels'][i]] =
                    labelsData[projectCardData[key]['data']['labels'][i]];
              }
            }
          }
        }

        List<String> assigned = [];
        if (projectCardData[key]['data']['assign'] != null) {
          assigned.add(projectCardData[key]['data']['assign']);
        }
        if (projectCardData[key]['data']['assigned'] != null) {
          for (int i = 0;
              i < projectCardData[key]['data']['assigned'].length;
              i++) {
            assigned.add(projectCardData[key]['data']['assigned'][i]);
          }
        }

        List<String> editors = [];
        if (projectCardData[key]['data']['editors'] != null) {
          for (int i = 0;
              i < projectCardData[key]['data']['editors'].length;
              i++) {
            editors.add(projectCardData[key]['data']['editors'][i]);
          }
        }

        // Formats data to be sent to database
        data[key] = CardData(
            id: key,
            title: projectCardData[key]['data']['title'],
            createdBy: projectCardData[key]['data']['createdBy'],
            dateCreated: projectCardData[key]['data']['createdDate'],
            priority: projectCardData[key]['priority'],
            description: (projectCardData[key]['data']['description'] == null)
                ? ''
                : projectCardData[key]['data']['description'],
            dueDate: projectCardData[key]['data']['dueDate'],
            points: projectCardData[key]['data']?['points'] ?? 0,
            assigned: assigned,
            editors: editors,
            checkList: projectCardData[key]['data']['subTasks'],
            comments: projectCardData[key]['data']['comments'],
            boardId: projectCardData[key]['board'],
            level: projectCardData[key]['data']['priority'],
            labels: labels);
      }
    }

    return data;
  }

  // Creates side chart that displays tasks and points
  Widget chartInfo() {
    List<String> names = ['Complete', 'Overdue', 'Planned', 'No Due Date'];
    List<Color> colors = [Colors.blue, Colors.red, Colors.orange, Colors.grey];
    List<int> amount = [0, 0, 0, 0];

    // Cricle indicator that shows how many tasks are in progress, completed, overdue, etc.
    Widget indicator(String text, Color color, int amount, int total) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryTextTheme.subtitle1!.color,
                    //color: color,
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                    border: Border.all(width: 2.5, color: color)),
              ),
              Text(
                ' $text',
                style: TextStyle(
                    fontFamily: 'MuseoSans',
                    package: 'css',
                    fontSize: 10,
                    color: Theme.of(context).primaryTextTheme.subtitle1!.color,
                    decoration: TextDecoration.none),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                amount.toString(),
                style: TextStyle(
                    fontFamily: 'MuseoSans',
                    package: 'css',
                    fontSize: 10,
                    color: Theme.of(context).primaryTextTheme.subtitle1!.color,
                    decoration: TextDecoration.none),
              ),
              Text(
                ' (${(total == 0 || amount == 0) ? 0 : (amount / total * 100).floor()}%',
                style: TextStyle(
                    fontFamily: 'MuseoSans',
                    package: 'css',
                    fontSize: 10,
                    color: Theme.of(context).primaryTextTheme.subtitle1!.color,
                    decoration: TextDecoration.none),
              ),
            ],
          )
        ],
      );
    }

    int total = 0;
    if (currentCardData.isNotEmpty) {
      total = currentCardData.length;
    }

    List<Widget> info = [];
    List<Widget> circles = [];

    // Adds completed tasks to total tasks to display on indicators
    if (completedTasks != null && showChart) {
      int tasks = 0;

      if (completedTasks[currentEpic][selectedProject] != null) {
        tasks += completedTasks[currentEpic][selectedProject].length as int;
      }

      total += tasks;
      amount[0] = tasks;
    }

    List<String> emp = [];
    int maxVal = 0;
    // complete, overdue, planned, pts
    List<List<int>> work = [];
    int i = 0;
    if (points != null) {
      for (String key in points.keys) {
        emp.add(key);
        work.add([0, 0, 0, 0]);
        if (points[key][selectedProject] != null) {
          for (String cKey in points[key][selectedProject].keys) {
            work[i][0]++;
            work[i][3] += points[key][selectedProject][cKey]['points'] as int;
          }
        }
        i++;
      }
    }

    void checkEmp(String? per, int loc) {
      if (per != null) {
        bool hasPer = false;
        for (int i = 0; i < emp.length; i++) {
          if (per == emp[i]) {
            hasPer = true;
            work[i][loc]++;
            break;
          }
        }
        if (!hasPer) {
          emp.add(per);
          if (loc == 1) {
            work.add([0, 1, 0, 0]);
          } else {
            work.add([0, 0, 1, 0]);
          }
        }
      }
    }

    void getMax() {
      for (int i = 0; i < emp.length; i++) {
        int temp = work[i][0] + work[i][1] + work[i][2];
        if (temp > maxVal) {
          maxVal = temp;
        }
      }
    }

    // Adds tasks to indicators
    if (currentCardData.isNotEmpty) {
      for (String i in currentCardData.keys) {
        if (currentCardData[i]!.dueDate != null) {
          DateTime now = DateTime.now();
          DateTime due =
              DateTime.parse(currentCardData[i]!.dueDate!.replaceAll('T', ' '));
          if (currentCardData[i]!.assigned.isNotEmpty) {
            for (int j = 0; j < currentCardData[i]!.assigned.length; j++) {
              if (now.isAfter(due)) {
                amount[1]++;
                checkEmp(currentCardData[i]!.assigned[j], 1);
              } else {
                amount[2]++;
                checkEmp(currentCardData[i]!.assigned[j], 2);
              }
            }
          }
        } else {
          amount[3]++;
        }
      }
    }
    getMax();

    // Bar charts that display users points
    List<Widget> barChart = [];
    if (completedTasks != null) {
      for (int i = 0; i < emp.length; i++) {
        barChart.add(SizedBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SingleUserIcon(
                    uid: emp[i],
                    color: Colors.teal,
                    loc: 0,
                    iconSize: 35,
                    usersProfile: widget.users,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 5, bottom: 5),
                    height: 20,
                    width: maxVal == 0 ? 0 : 115 * work[i][0] / maxVal,
                    color: Colors.blue,
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 5, bottom: 5),
                    height: 20,
                    width: maxVal == 0 ? 0 : 115 * work[i][1] / maxVal,
                    color: Colors.red,
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 5, bottom: 5),
                    height: 20,
                    width: maxVal == 0 ? 0 : 115 * work[i][2] / maxVal,
                    color: Colors.orange,
                  ),
                ],
              ),
              RichText(
                  text: TextSpan(
                text: "Pts: ", //+work[i][3].toString(),
                children: [
                  TextSpan(
                    text: work[i][3].toString(),
                    style: TextStyle(
                        fontFamily: 'Klavika Bold',
                        package: 'css',
                        fontSize: 10,
                        color:
                            Theme.of(context).primaryTextTheme.subtitle1!.color,
                        decoration: TextDecoration.none),
                  )
                ],
                style: TextStyle(
                    fontFamily: 'MuseoSans',
                    package: 'css',
                    fontSize: 10,
                    color: Theme.of(context).primaryTextTheme.subtitle1!.color,
                    decoration: TextDecoration.none),
              )),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ));
      }
    } else {
      barChart.add(Container());
    }

    double start = 0;
    double finish = 0;
    for (int i = 0; i < 4; i++) {
      info.add(indicator(names[i], colors[i], amount[i], total));
      if (total != 0) {
        start += finish.ceil();
        finish = 360 * (amount[i] / total);

        circles.add(ClipRect(
            child: Align(
                alignment: Alignment.center,
                child: Container(
                  width: 120,
                  height: 120,
                  alignment: Alignment.center,
                  child: CustomPaint(
                    painter: OpenPainter(
                      color: colors[i],
                      innerRadius: 150 / 1.9,
                      outerRadius: 150 / 1.9 / (1 + 0.15),
                      total: 1,
                      useStroke: false,
                      percentage: 0.99,
                      startAngle: 360 - start,
                      sweepAngle: finish,
                      setOffset: const Offset(0, 0),
                    ),
                  ),
                ))));
      }
    }
    circles.add(Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              total.toString(),
              style: TextStyle(
                  fontFamily: 'MuseoSans',
                  package: 'css',
                  fontSize: 36,
                  color: Theme.of(context).primaryTextTheme.subtitle1!.color,
                  decoration: TextDecoration.none),
            ),
            Text(
              'Total Tasks',
              style: TextStyle(
                  fontFamily: 'MuseoSans',
                  package: 'css',
                  fontSize: 10,
                  color: Theme.of(context).primaryTextTheme.subtitle1!.color,
                  decoration: TextDecoration.none),
            ),
          ],
        )));

    return Container(
        height: widget.height,
        decoration:
            BoxDecoration(color: Theme.of(context).canvasColor, boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor,
            blurRadius: 5,
            offset: const Offset(-5, 3),
          ),
        ]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 180,
              height: 180,
              //padding: EdgeInsets.all(10),
              child: Stack(children: circles),
            ),
            Container(
              width: 180,
              height: 80,
              padding: const EdgeInsets.all(10),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: info),
            ),
            Container(
              width: 180,
              height: widget.height - 180 - 80,
              padding: const EdgeInsets.all(10),
              child: ListView(
                  padding: const EdgeInsets.all(0),
                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: barChart),
            ),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (selectedProject != widget.project) {
        setState(() {
          start();
        });
      } else if (widget.completedData != completedTasks) {
        setState(() {
          start();
        });
      }
      if (update) {
        setState(() {});
      } else if (startingWidth != widget.width) {
        setState(() {
          startingWidth = widget.width;
        });
      }
    });
    return hasStarted
        ? SizedBox(
            width: widget.width,
            height: widget.height,
            child: Stack(
              children: [
                BoardManager(
                    assignPoints: (name, points, id) {
                      List<String> pushTo = [];
                      DateFormat dayFormatter = DateFormat('y-MM-dd hh:mm:ss');
                      String createdDate = dayFormatter
                          .format(DateTime.now())
                          .replaceAll(' ', 'T');

                      dynamic archiveData = {
                        'createdBy': currentCardData[id]!.createdBy,
                        'createdDate': currentCardData[id]!.dateCreated,
                        'dueDate': currentCardData[id]!.dueDate,
                        'title': currentCardData[id]!.title,
                        'completedDate': createdDate
                      };

                      if (name != null && points != null) {
                        dynamic pointData = {
                          'assignedBy': widget.currentUID,
                          'dateAssigned': createdDate,
                          'points': points
                        };
                        for (int i = 0; i < name.length; i++) {
                          if (name[i] != widget.currentUID) {
                            pushTo.add(name[i]);
                          }
                          Database.update(
                              children:
                                  'points/$currentEpic/${name[i]}/$selectedProject',
                              location: id,
                              data: pointData);
                        }
                        Database.update(
                                children:
                                    'complete/$currentEpic/$selectedProject',
                                location: id,
                                data: archiveData)
                            .then((value) {
                          Database.update(
                              children: '$child/cards/',
                              location: id,
                              data: {});
                        });
                      } else {
                        Database.update(
                                children:
                                    'complete/$currentEpic/$selectedProject',
                                location: id,
                                data: archiveData)
                            .then((value) {
                          Database.update(
                              children: '$child/cards/',
                              location: id,
                              data: {});
                        });
                      }
                    },
                    screenOffset: const Offset(180, 0),
                    onPriorityBoardChange: (pri) {
                      for (String key in pri.keys) {
                        Database.update(
                            children: '$child/boards/',
                            location: key,
                            data: {
                              'createdBy': currentBoardData[key]!.createdBy,
                              'dateCreated': currentBoardData[key]!.dateCreated,
                              'title': currentBoardData[key]!.title,
                              'priority': pri[key],
                              'notify': currentBoardData[key]!.notify
                            });
                      }

                      setState(() {});
                    },
                    onSubmit: (title, priority, notify) async {
                      DateFormat dayFormatter = DateFormat('y-MM-dd hh:mm:ss');
                      String date = dayFormatter
                          .format(DateTime.now())
                          .replaceAll(' ', 'T');

                      Database.push(children: '$child/boards', data: {
                        'createdBy': widget.currentUID,
                        'dateCreated': date,
                        'title': title,
                        'priority': priority,
                        'notify': notify
                      });

                      setState(() {});
                    },
                    onCreateCard: (data) {
                      if (data['data']['assigned'] != null) {
                        List<String> sendTo = [];
                        for (int i = 0;
                            i < data['data']['assigned'].length;
                            i++) {
                          if (data['data']['assigned'][i] !=
                              widget.currentUID) {
                            sendTo.add(data['data']['assigned'][i]);
                          }
                        }

                        Database.push(children: '$child/cards', data: data);
                      }
                    },
                    onEditCard: (data, cardLoc) {
                      List<String> uids = [];
                      int currentCards = 0;

                      for (String i in currentCardData.keys) {
                        if (currentCardData[i]!.id == cardLoc) {
                          currentCards = (currentCardData[i]!.comments == null)
                              ? 0
                              : currentCardData[i]!.comments!.length;
                        }
                      }
                      if (data['assign'] != null &&
                          data['assign'] != widget.currentUID) {
                        uids.add(data['assign']);
                      }
                      if (data['comments'] != null) {
                        if (currentCards != data['comments'].length) {
                          for (String key in data['comments'].keys) {
                            if (data['comments'][key]['createdBy'] !=
                                widget.currentUID) {
                              uids.add(data['comments'][key]['createdBy']);
                            }
                          }
                        }
                      }

                      if (data['assigned'] != null && uids.isNotEmpty) {
                        for (int i = 0; i < data['assigned'].length; i++) {
                          if (data['assigned'][i] != widget.currentUID) {
                            uids.add(data['assigned'][i]);
                          }
                        }
                      }

                      Database.update(
                          children: '$child/cards/$cardLoc',
                          location: 'data',
                          data: data);
                    },
                    onCardDelete: (id) {
                      Database.update(
                          children: '$child/cards', location: id, data: {});
                    },
                    onCardPriorityChange: (val, change) {
                      for (String j in currentCardData.keys) {
                        if (currentCardData[j]!.id == change['card'] &&
                            currentCardData[j]!.assigned.isNotEmpty) {}
                        if (currentCardData[j]!.id == change['card'] &&
                            currentCardData[j]!.boardId != change['board'] &&
                            currentCardData[j]!.assigned.isNotEmpty) {
                          List<String> allowSend = [];
                          for (int i = 0;
                              i < currentCardData[j]!.assigned.length;
                              i++) {
                            if (currentCardData[j]!.assigned[i] ==
                                widget.currentUID) {
                              allowSend.add(currentCardData[j]!.assigned[i]);
                            }
                          }
                        }
                      }
                      for (String key in val.keys) {
                        CardData currentCard = currentCardData[key]!;

                        Database.update(
                            children: '$child/cards',
                            location: key,
                            data: {
                              "board": val[key]['boardId'],
                              "priority": val[key]['priority'],
                              "data": {
                                "assigned": currentCard.assigned,
                                "createdBy": currentCard.createdBy,
                                "createdDate": currentCard.dateCreated,
                                "editors": currentCard.editors,
                                "points": currentCard.points,
                                "title": currentCard.title,
                                "labels": currentCard.labels?.keys.toList(),
                                "subTasks": currentCard.checkList,
                                "comments": currentCard.comments,
                                "description": currentCard.description,
                                "priority": currentCard.level,
                                "dueDate": currentCard.dueDate
                              }
                            });
                      }
                    },
                    onBoardDelete: (id) {
                      Database.update(
                          children: '$child/boards', location: id, data: {});
                    },
                    height: widget.height,
                    width: showChart ? widget.width - 180 : widget.width,
                    labels: labelsData,
                    update: update,
                    callback: callback,
                    projectId: selectedProject,
                    boardData: currentBoardData,
                    cards: currentCardData,
                    users: createDropDown(),
                    usersProfiles: widget.users,
                    currentUser:
                        UserData.fromJSON(widget.users[widget.currentUID])),
                selectedProject == ''
                    ? Container()
                    : Align(
                        alignment: Alignment.centerRight, child: chartInfo())
              ],
            ),
          )
        : Container();
  }
}
