part of updroid_explorer_workspace;

/// Container class that extracts data from the raw file text passed in from
/// the server over [WebSocket]. Primarily used for generating the HTML views
/// in the file explorer that represent the filesystem.
abstract class FileSystemEntity {
  static bool testForWorkspace(String path, String workspacePath) => path == '$workspacePath/src';

  static String getNameFromPath(String path, String workspacePath) {
    List<String> pathList = path.split('/');
    return (testForWorkspace(path, workspacePath)) ? pathList[pathList.length - 2] : pathList.last;
  }

  static String getParentFromPath(String path, String workspacePath) {
    List<String> pathList = path.split('/');
    if (testForWorkspace(path, workspacePath)) return null;

    String parent = '';
    pathList.sublist(0, pathList.length - 1).forEach((String s) => parent += '$s/');
    return pathLib.normalize(parent);
  }

  String path, workspacePath, name, parent;
  bool isDirectory, isPackage, selected;
  WebSocket ws;
  FileSystemEntityView view;
  var deselectAllEntities;

  bool get isWorkspace => testForWorkspace(path, workspacePath);

  bool _selectEnabled;

  FileSystemEntity(String path, String workspacePath, bool isFolder, this.ws, this.deselectAllEntities) {
    selected = false;
    _selectEnabled = true;

    this.path = pathLib.normalize(path);
    this.workspacePath = pathLib.normalize(workspacePath);

    name = getNameFromPath(this.path, this.workspacePath);
    parent = getParentFromPath(this.path, this.workspacePath);

    //print('workspacePath: $workspacePath, path: $path, name: $name, parent: $parent');
  }

  void toggleSelected() => selected ? deselect() : select();

  void select() {
    view.select();
    selected = true;
  }

  void deselect() {
    view.deselect();
    selected = false;
  }

  void rename() {
    InputElement renameInput = view.startRename();
    renameInput.onKeyUp.listen((e) {
      if (e.keyCode == KeyCode.ENTER) {
        String newPath = pathLib.normalize('$parent/${renameInput.value}');
        ws.send('[[RENAME]]$path:$newPath');
        view.completeRename(renameInput);
      }
    });

    document.body.onClick.first.then((_) => view.completeRename(renameInput));
  }

  void cleanUp() {
    //_contextListeners.forEach((StreamSubscription listener) => listener.cancel());
    view.cleanUp();
  }
}

class FolderEntity extends FileSystemEntity {
  FolderEntity(String path, String workspacePath, WebSocket ws, var deselectAllEntities) :
  super(path, workspacePath, true, ws, deselectAllEntities) {
    isDirectory = true;
    setUpView();
  }

  void setUpView() {
    view = new FolderView(name);

    view.container.onClick.listen((e) {
      if (_selectEnabled) {
        if (!e.ctrlKey) deselectAllEntities();

        toggleSelected();
        _selectEnabled = false;

        new Timer(new Duration(milliseconds: 500), () {
          _selectEnabled = true;
        });
      }
    });

    FolderView folderView = view;
    folderView.expanderIcon.onClick.listen((e) {
//      deselectAllEntities();
      folderView.toggleExpansion();
//      select();
    });

    view.container.onContextMenu.listen((e) {
      e.preventDefault();
      deselectAllEntities();
      select();
      List menu = [
        {'type': 'toggle', 'title': 'New File', 'handler': () => ws.send('[[NEW_FILE]]' + path)},
        {'type': 'toggle', 'title': 'New Folder', 'handler': () => ws.send('[[NEW_FOLDER]]' + path + '/untitled')},
        {'type': 'toggle', 'title': 'Rename', 'handler': rename},
        {'type': 'toggle', 'title': 'Delete', 'handler': () => ws.send('[[DELETE]]' + path)}];

      if (isPackage) {
        menu.add({'type': 'divider', 'title': ''});
        menu.add({'type': 'toggle', 'title': 'Verify', 'handler': build});
        menu.add({'type': 'toggle', 'title': 'Clean', 'handler': clean});
      }
      ContextMenu.createContextMenu(e.page, menu);
    });
  }

  void build() {
    toggleBuildingIndicator();

    // Special case if workspace folder.
    if (name != path.split('/').last) {
      ws.send('[[WORKSPACE_BUILD]]');
      return;
    }

    ws.send('[[BUILD_PACKAGE]]' + path);
  }

  void clean() {
    // Special case if workspace folder.
    if (name != path.split('/').last) {
      ws.send('[[WORKSPACE_CLEAN]]');
      return;
    }

    ws.send('[[CLEAN_PACKAGE]]' + path);
  }

  void toggleBuildingIndicator() {
    FolderView folderView = view;
    folderView.toggleBuildingIndicator();
  }
}

class FileEntity extends FileSystemEntity {

  FileEntity(String path, String workspacePath, WebSocket ws, var deselectAllEntities) :
  super(path, workspacePath, true, ws, deselectAllEntities) {
    setUpView();
  }

  void setUpView() {
    view = new FileView(name);

    view.container.onClick.listen((e) {
      if (_selectEnabled) {
        if (!e.ctrlKey) deselectAllEntities();

        toggleSelected();
        _selectEnabled = false;

        new Timer(new Duration(milliseconds: 500), () {
          _selectEnabled = true;
        });
      }
    });

    view.container.onDoubleClick.listen((e) {
      deselectAllEntities();
      ws.send('[[OPEN_FILE]]' + path);
      select();
    });

    view.container.onContextMenu.listen((e) {
      e.preventDefault();
      deselectAllEntities();
      select();

      List menu = [
        {'type': 'toggle', 'title': 'Rename', 'handler': rename},
        {'type': 'toggle', 'title': 'Delete', 'handler': () => ws.send('[[DELETE]]' + path)}];

      ContextMenu.createContextMenu(e.page, menu);
      ws.send('[[REQUEST_EDITOR_LIST]]' + path);
    });
  }
}