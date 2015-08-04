part of updroid_explorer_workspace;

class WorkspaceView extends ExplorerView {
  /// Returns an initialized [PanelView] as a [Future] given all normal constructors.
  ///
  /// Use this instead of calling the constructor directly.
  static Future<WorkspaceView> createWorkspaceView(int id, DivElement content) {
    Completer c = new Completer();
    c.complete(new WorkspaceView(id, content));
    return c.future;
  }

  UListElement uList;

  WorkspaceView(int id, DivElement content) :
  super(id, content) {
    this.content = content;

    uList = new UListElement()
      ..classes.add("explorer-ul");
    explorersDiv.append(uList);

    viewWorkspace.classes.removeAll(['glyphicons-folder-closed', 'inactive']);
    viewWorkspace.classes.add('glyphicons-folder-open');
    viewLaunchers.classes.add('inactive');
  }

  void cleanUp() {
    content.innerHtml = '';
  }
}

abstract class FileSystemEntityView {
  final String selectedClass = 'selected';

  String name;
  LIElement element;
  DivElement container;
  SpanElement icon, filename;

  bool _selected;

  FileSystemEntityView(this.name) {
    _selected = false;

    element = new LIElement()
      ..classes.add('explorer-li');

    container = new DivElement()
      ..classes.add('explorer-fs-container')
      ..style.userSelect = 'none';

    icon = new SpanElement()
      ..classes.addAll(['glyphicons', 'explorer-icon']);
    container.children.add(icon);

    filename = new SpanElement()
      ..classes.add('explorer-fs-name')
      ..text = this.name
      ..title = this.name;
    container.children.add(filename);
  }

  InputElement startRename() {
    InputElement renameInput = new InputElement()
      ..classes.add('explorer-fs-rename')
      ..placeholder = name;
    filename.replaceWith(renameInput);

    renameInput.onClick.first.then((e) => e.stopPropagation());
    renameInput.focus();
    return renameInput;
  }

  void completeRename(InputElement renameInput) {
    renameInput.replaceWith(filename);
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

class FolderView extends FileSystemEntityView {
  final String openFolderClass = 'glyphicons-expand';
  final String closedFolderClass = 'glyphicons-collapse';
  final String iconClass = 'glyphicons-folder-closed';

  bool expanded = false;
  DivElement outerContainer;
  SpanElement expanderIcon;
  UListElement uElement;

  FolderView(String name, [bool expanded]) : super(name) {
    this.expanded = expanded;

    outerContainer = new DivElement()
    ..classes.add('explorer-fs-outer-container');
    element.children.add(outerContainer);

    expanderIcon = new SpanElement()
    ..classes.addAll(['glyphicons', 'explorer-expander-icon']);
    this.expanded ? expanderIcon.classes.add(openFolderClass) : expanderIcon.classes.add(closedFolderClass);
    outerContainer.children.add(expanderIcon);

    container.classes.add('explorer-folder');
    icon.classes.add(iconClass);
    outerContainer.children.add(container);

    uElement = new UListElement()
      ..hidden = true
      ..classes.add('explorer-ul');
    element.children.add(uElement);
  }

  void toggleExpansion() {
    if (expanded) {
      expanderIcon.classes.remove(openFolderClass);
      expanderIcon.classes.add(closedFolderClass);
      uElement.hidden = true;
      expanded = false;
    } else {
      expanderIcon.classes.remove(closedFolderClass);
      expanderIcon.classes.add(openFolderClass);
      uElement.hidden = false;
      expanded = true;
    }
  }

  void toggleBuildingIndicator() {
    if (icon.classes.contains('glyphicons-refresh')) {
      icon.classes.remove('glyphicons-refresh');
      icon.classes.add(iconClass);
    } else {
      icon.classes.remove(iconClass);
      icon.classes.add('glyphicons-refresh');
    }
  }
}

class FileView extends FileSystemEntityView {
  final String fileClass = 'glyphicons-file';

  FileView(String name) : super(name) {
    container.classes.add('explorer-file');
    icon.classes.add(fileClass);
    element.children.add(container);
  }
}