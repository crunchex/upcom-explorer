library updroid_explorer_launchers;

import 'dart:html';
import 'dart:async';
import 'dart:convert';

import 'package:path/path.dart' as pathLib;
import 'package:upcom-api/web/menu/context_menu.dart';
import 'package:upcom-api/web/mailbox/mailbox.dart';

import '../../panel_controller.dart';
import '../explorer.dart';

part 'launchers_view.dart';
part 'ros_entity.dart';

class LaunchersController implements ExplorerController {
  String type = 'launchers';

  PanelView _view;
  LaunchersView _launchersView;
  Mailbox _mailbox;
  Function _toggleView;

  AnchorElement _runLaunchersButton;

  Map<String, Package> packages = {};
  String workspacePath;
  Set<StreamSubscription> _listenersToCleanUp;
  bool _launchersFound;

  LaunchersController(int id, this.workspacePath, PanelView view, Mailbox mailbox, List<AnchorElement> actionButtons, Function toggleView) {
    _view = view;
    _mailbox = mailbox;
    _runLaunchersButton = actionButtons[0];
    _toggleView = toggleView;

    registerMailbox();

    _listenersToCleanUp = new Set<StreamSubscription>();
    _launchersFound = false;

    LaunchersView.createLaunchersView(id, _view.content).then((launchersView) {
      _launchersView = launchersView;

      _mailbox.ws.send('[[REQUEST_NODE_LIST]]');

      registerEventHandlers();
    });
  }

  void registerMailbox() {
    _mailbox.registerWebSocketEvent(EventType.ON_MESSAGE, 'LAUNCH', addLaunch);
    _mailbox.registerWebSocketEvent(EventType.ON_MESSAGE, 'BUILD_COMPLETE', _buildComplete);

  }

  void registerEventHandlers() {
    _listenersToCleanUp.add(_runLaunchersButton.onClick.listen((e) => _runLaunchers()));
    _listenersToCleanUp.add(_launchersView.viewWorkspace.onClick.listen((e) => _toggleView()));
  }

  void addLaunch(Msg um) {
    if (!_launchersFound) _launchersView.placeholderText.replaceWith(_launchersView.uList);
    _launchersFound = true;

    Map data = JSON.decode(um.body);
    String packagePath = data['package-path'];
    String launcherName = data['node'];
    List args = data['args'];

    if (!packages.containsKey(packagePath)) _addPackage(packagePath);

    String packageName = packagePath.split('/').last;
    Launcher launcher = new Launcher(launcherName, args, packageName, _mailbox.ws, _deselectAllLaunchers);
    packages[packagePath].launchers.add(launcher);
    packages[packagePath].view.uElement.children.add(launcher.view.element);
  }

  void _addPackage(String packagePath) {
    List<String> split = packagePath.split('/');
    String parentPath = '/';
    parentPath += pathLib.joinAll(split.sublist(0, split.length - 1));

    if (parentPath != '$workspacePath/src' && !packages.containsKey(parentPath)) {
      _addPackage(parentPath);
    }

    String packageName = split.last;
    Package package = new Package(packageName, packagePath);
    packages.putIfAbsent(packagePath, () => package);

    if (parentPath == '$workspacePath/src') {
      _launchersView.uList.children.add(package.view.element);
    } else {
      packages[parentPath].view.uElement.children.add(package.view.element);
    }

  }

  /// Sends a list of multiple selected package paths to be built.
  void _buildPackages() {
    List<String> packageBuildList = [];
    for (Package package in packages.values) {
      if (!package.hasSelectedLaunchers()) continue;

      packageBuildList.add(package.path);
    }

    if (packageBuildList.isNotEmpty) {
      _mailbox.ws.send('[[BUILD_PACKAGES]]' + JSON.encode(packageBuildList));
    }
  }

  void _buildComplete(Msg um) {
    List<String> packagePaths = JSON.decode(um.body);
    packagePaths.forEach((String packagePath) {
      packages[packagePath].launchers.forEach((Launcher n) => n.runLauncher());
    });
  }

  void _runLaunchers() {
    packages.values.forEach((Package p) => p.launchers.forEach((Launcher n) => n.runLauncher()));
  }

  void _deselectAllLaunchers() {
    packages.values.forEach((Package p) => p.launchers.forEach((Launcher n) => n.deselect()));
  }

  void cleanUp() {
    _listenersToCleanUp.forEach((StreamSubscription s) => s.cancel());
    _listenersToCleanUp = null;

    packages.values.forEach((Package p) => p.cleanUp());
    packages = null;

    _launchersView.cleanUp();
  }
}