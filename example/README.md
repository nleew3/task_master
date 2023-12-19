# task_master_example

Example implementation of the package with Firebase Realtime Database as the back-end

Additional features present in the example application:
- Implementation of a points counter/progress monitor chart on the right of the application
- Dynamic update of task manager when changes detected in Firebase database
    - See the board_viewer.dart and project_viewer.dart for example implementations of this

** Example application won't run unless you initialize Firebase on the application and appropiately change certain code to link to your database **


## Features implemented in Example application

Project Creation
![](../docs/Project%20Creation.gif)

Project Editing and Board Creation
![](../docs/Project%20Editing%20and%20Board%20Creation.gif)

Task/card creation
![](../docs/Card%20Creation.gif)

Task reordering/dragging
![](../docs/Card%20Drag.gif)

Label Creation
![](../docs/Label%20Creation%20and%20Update.gif)

Label adding to task
![](../docs/Adding%20label%20to%20card.gif)

Board Dragging/Reordering
![](../docs/Board%20Drag.gif)

Task Completion (note scores kept on side chart)
![](../docs/Task%20Completion.gif)

