# ai_vocabulary

A new Flutter project.

# Good Codes
* [lib/pages/speech_confirm_dialog.dart](lib/pages/speech_confirm_dialog.dart)\
Resolve InkWell issue when the page without Scaffold, the alternative way is to wrap Material widget.\
Good example on IntrinsicHeight when you want Stack size follow its children who has the maximum height.

* [lib/main.dart](lib/main.dart)\
override CupertinoTheme's colors with MaterialTheme

* [lib/painters/bubble_shape.dart](lib/painters/bubble_shape.dart)\
A customized shape which can used to every decoration with [ShapeDecoration](lib/widgets/chat_bubble.dart?plain=1#L48-L52).

* [lib/pages/favorite_words_page.dart](lib/pages/favorite_words_page.dart)\
Used sliver_tools package to implement alphabet list view. In addition, the list has UITableView behavior like UIKit feature.

* [lib/utils/gesture_route_page.dart](lib/utils/gesture_route_page.dart)\
Approached gesture navigation push a new page

* [lib/widgets/count_picker_tile.dart](lib/widgets/count_picker_tile.dart)\
Used build-in context to get RenderBox of the return widget's position and size, instead of GlobalKey.(include main example)


## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.