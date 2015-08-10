part of updroid_explorer_nodes;

class NodesView extends ExplorerView {
  /// Returns an initialized [PanelView] as a [Future] given all normal constructors.
  ///
  /// Use this instead of calling the constructor directly.
  static Future<NodesView> createNodesView(int id, DivElement content) {
    Completer c = new Completer();
    c.complete(new NodesView(id, content));
    return c.future;
  }

  ParagraphElement placeholderText;
  UListElement uList;

  NodesView(int id, DivElement content) :
  super(id, content) {
    this.content = content;

    placeholderText = new ParagraphElement()
      ..classes.add('explorer-placeholder')
      ..text = 'No running nodes detected. Start one from the Launchers View!';
    explorersDiv.children.add(placeholderText);

    uList = new UListElement()
      ..classes.add("explorer-ul");
//    explorersDiv.append(uList);

    viewWorkspace.classes.remove('glyphicons-folder-open');
    viewWorkspace.classes.addAll(['glyphicons-folder-closed', 'inactive']);
    viewLaunchers.classes.add('inactive');
    viewNodes.classes.remove('inactive');
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
      ..text = this.name
      ..title = this.name;
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

class NodeView extends RosEntityView {
  final String fileClass = 'glyphicons-turtle';

  bool expanded = false;
  UListElement uElement;

  NodeView(String name, List<List<String>> info, [bool expanded]) : super(name) {
    this.expanded = expanded;

    container.classes.add('explorer-node');
    icon.classes.add(fileClass);
    element.children.add(container);

    uElement = new UListElement()
      ..hidden = true
      ..classes.add('explorer-ul');
    element.children.add(uElement);

    info.forEach((List<String> argument) {
      LIElement li = new LIElement()
        ..classes.add('explorer-li');
      uElement.children.add(li);

      DivElement container = new DivElement()
        ..classes.addAll(['explorer-ros-container', 'explorer-arg-container'])
        ..style.userSelect = 'none';
      li.children.add(container);

      DivElement infoLine = new DivElement()
        ..classes.add('explorer-arg-name')
        ..text = argument[0];
      container.children.add(infoLine);
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