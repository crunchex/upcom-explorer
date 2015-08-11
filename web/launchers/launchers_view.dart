part of updroid_explorer_launchers;

class LaunchersView extends ExplorerView {
  /// Returns an initialized [PanelView] as a [Future] given all normal constructors.
  ///
  /// Use this instead of calling the constructor directly.
  static Future<LaunchersView> createLaunchersView(int id, DivElement content) {
    Completer c = new Completer();
    c.complete(new LaunchersView(id, content));
    return c.future;
  }

  UListElement uList;

  LaunchersView(int id, DivElement content) :
  super(id, content) {
    this.content = content;

    placeholderText.text = 'No Launchers found. Create one!';

    uList = new UListElement()
      ..classes.add("explorer-ul");
    explorersDiv.append(uList);

    viewWorkspace.classes.remove('glyphicons-folder-open');
    viewWorkspace.classes.addAll(['glyphicons-folder-closed', 'inactive']);
    viewNodes.classes.add('inactive');
    viewLaunchers.classes.remove('inactive');
  }

  void cleanUp() {
    content.innerHtml = '';
  }
}

abstract class RosEntityView {
  final String selectedClass = 'selected';

  String name;
  LIElement element;
  DivElement container;
  SpanElement icon, filename;

  bool _selected;

  RosEntityView(this.name) {
    _selected = false;

    element = new LIElement()
      ..classes.add('explorer-li');

    container = new DivElement()
      ..classes.add('explorer-ros-container')
      ..style.userSelect = 'none';

    icon = new SpanElement()
      ..classes.addAll(['glyphicons', 'explorer-icon']);
    container.children.add(icon);

    filename = new SpanElement()
      ..classes.add('explorer-ros-name')
      ..text = this.name.replaceAll('.launch', '')
      ..title = this.name.replaceAll('.launch', '');
    container.children.add(filename);
  }

  void select() {
    container.classes.add(selectedClass);
    _selected = true;
  }

  void deselect() {
    container.classes.remove(selectedClass);
    _selected = false;
  }

  void cleanUp() {
    for (Element child in element.children) {
      child.remove();
    }
    element.remove();
  }
}

class PackageView extends RosEntityView {
  final String openFolderClass = 'glyphicons-expand';
  final String closedFolderClass = 'glyphicons-collapse';
  final String iconClass = 'glyphicons-cluster';

  bool expanded = false;
  DivElement outerContainer;
  SpanElement expanderIcon;
  UListElement uElement;

  PackageView(String name, [bool expanded]) : super(name) {
    this.expanded = expanded;

    outerContainer = new DivElement()
      ..classes.add('explorer-ros-outer-container');
    element.children.add(outerContainer);

    expanderIcon = new SpanElement()
      ..classes.addAll(['glyphicons', 'explorer-expander-icon']);
    this.expanded ? expanderIcon.classes.add(openFolderClass) : expanderIcon.classes.add(closedFolderClass);
    outerContainer.children.add(expanderIcon);

    container.classes.add('explorer-package');
    icon.classes.add(iconClass);
    outerContainer.children.add(container);

    uElement = new UListElement()
      ..hidden = true
      ..classes.add('explorer-ul');
    element.children.add(uElement);
  }

  void toggleExpansion() {
    if (expanded) {
      icon.classes.remove(openFolderClass);
      icon.classes.add(closedFolderClass);
      uElement.hidden = true;
      expanded = false;
    } else {
      icon.classes.remove(closedFolderClass);
      icon.classes.add(openFolderClass);
      uElement.hidden = false;
      expanded = true;
    }
  }
}

class LauncherView extends RosEntityView {
  final String fileClass = 'glyphicons-circle-arrow-right';

  bool expanded = false;
  UListElement uElement;

  LauncherView(String name, List<List<String>> args, [bool expanded]) : super(name) {
    this.expanded = expanded;

    container.classes.add('explorer-node');
    icon.classes.add(fileClass);
    element.children.add(container);

    uElement = new UListElement()
      ..hidden = true
      ..classes.add('explorer-ul');
    element.children.add(uElement);

    args.forEach((List<String> argument) {
      LIElement li = new LIElement()
        ..classes.add('explorer-li');
      uElement.children.add(li);

      DivElement container = new DivElement()
        ..classes.addAll(['explorer-ros-container', 'explorer-arg-container'])
        ..style.userSelect = 'none';
      li.children.add(container);

      DivElement arg = new DivElement()
        ..classes.add('explorer-arg-name')
        ..text = argument[0];
      container.children.add(arg);

      InputElement argValue = new InputElement()
        ..classes.add('explorer-arg-input');
      if (argument[1] != null) argValue.placeholder = argument[1];
      container.children.add(argValue);
    });
  }

  void toggleExpansion() {
    if (expanded) {
      uElement.hidden = true;
      expanded = false;
    } else {
      uElement.hidden = false;
      expanded = true;
    }
  }

  void expand() {
    uElement.hidden = false;
    expanded = true;
  }

  void collapse() {
    uElement.hidden = true;
    expanded = false;
  }
}