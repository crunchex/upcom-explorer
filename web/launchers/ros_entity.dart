part of updroid_explorer_launchers;

class Package {
  String name, path;
  List<Package> packages;
  List<Launcher> launchers;
  PackageView view;

  Package(this.name, this.path) {
    packages = [];
    launchers = [];

    setUpPackageView();
  }

  void setUpPackageView() {
    view = new PackageView(name);

    PackageView packageView = view;
    packageView.expanderIcon.onClick.listen((e) {
      view.toggleExpansion();
    });
  }

  bool hasSelectedLaunchers() {
    for (Launcher l in launchers) {
      if (l.isSelected) return true;
    }

    return false;
  }

  void cleanUp() {
    launchers.forEach((Launcher n) => n.cleanUp());
    view.cleanUp();
  }
}

class Launcher {
  String name, packageName;
  List args;
  LauncherView view;
  var deselectAllLaunchers;
  bool isSelected;

  WebSocket _ws;
  bool _selectEnabled;

  Launcher(this.name, this.args, this.packageName, WebSocket ws, this.deselectAllLaunchers) {
    isSelected = false;

    _ws = ws;
    _selectEnabled = true;

    _setUpLauncherView();

    //print('workspacePath: $workspacePath, path: $path, name: $name, parent: $parent');
  }

  void runLauncher() {
    if (!isSelected) return;

    List runCommand = [];
    runCommand.addAll([packageName, name]);
    view.uElement.children.forEach((LIElement li) {
      List<String> arg = [];

      DivElement container = li.firstChild;
      arg.add(container.firstChild.text);
      InputElement input = container.lastChild;
      arg.add(input.value);

      runCommand.add(arg);
    });

    _ws.send('[[RUN_NODE]]' + JSON.encode(runCommand));
  }


  void _setUpLauncherView() {
    view = new LauncherView(name, args);

    view.container.onClick.listen((e) {
      if (_selectEnabled) {
        if (!e.ctrlKey) deselectAllLaunchers();

        toggleSelected();
        _selectEnabled = false;

        new Timer(new Duration(milliseconds: 500), () {
          _selectEnabled = true;
        });
      }
    });

    view.container.onContextMenu.listen((e) {
      e.preventDefault();
      deselectAllLaunchers();
      select();
      List menu = [
        {'type': 'toggle', 'title': 'Run', 'handler': runLauncher}];
      ContextMenu.createContextMenu(e.page, menu);
    });
  }

  void toggleSelected() => isSelected ? deselect() : select();

  void select() {
    view.select();
    view.expand();
    isSelected = true;
  }

  void deselect() {
    view.deselect();
    view.collapse();
    isSelected = false;
  }

  void cleanUp() {
    //_contextListeners.forEach((StreamSubscription listener) => listener.cancel());
    view.cleanUp();
  }
}