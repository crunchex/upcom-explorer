library updroid_explorer_nodes;

import 'dart:html';
import 'dart:async';
import 'dart:convert';

import 'package:path/path.dart' as pathLib;
import 'package:upcom-api/tab_frontend.dart';
import '../explorer.dart';

part 'nodes_view.dart';
part 'ros_entity.dart';

class NodesController implements ExplorerController {
  String type = 'nodes';

  PanelView _view;
  NodesView _nodesView;
  Mailbox _mailbox;
  Function _showWorkspaceView, _showLaunchersView;

  AnchorElement _runLaunchersButton;

  Map<String, Node> nodes = {};
  String workspacePath;
  Set<StreamSubscription> _listenersToCleanUp;
  bool _nodesFound;

  NodesController(int id, this.workspacePath, PanelView view, Mailbox mailbox, List<AnchorElement> actionButtons, Function showWorkspaceView, Function showLaunchersView) {
    _view = view;
    _mailbox = mailbox;
    _runLaunchersButton = actionButtons[0];
    _showWorkspaceView = showWorkspaceView;
    _showLaunchersView = showLaunchersView;

    registerMailbox();

    _listenersToCleanUp = new Set<StreamSubscription>();
    _nodesFound = false;

    NodesView.createNodesView(id, _view.content).then((nodesView) {
      _nodesView = nodesView;

      _mailbox.ws.send('[[REQUEST_RUNNING_NODES_LIST]]');

      registerEventHandlers();
    });
  }

  void registerMailbox() {
    _mailbox.registerWebSocketEvent(EventType.ON_MESSAGE, 'RUNNING_NODES_LIST', refreshNodesList);
  }

  void registerEventHandlers() {
    _listenersToCleanUp.add(_nodesView.viewWorkspace.onClick.listen((e) => _showWorkspaceView()));
    _listenersToCleanUp.add(_nodesView.viewLaunchers.onClick.listen((e) => _showLaunchersView()));
  }

  void refreshNodesList(Msg um) {
    if (!_nodesFound) _nodesView.placeholderText.replaceWith(_nodesView.uList);
    _nodesFound = true;

//    List<Map> nodesList = JSON.decode(um.body);
    List<String> nodesList = JSON.decode(um.body);
    nodesList.forEach((String nodeName) {
//      String nodeName = nodeMap['name'];
//      List nodeInfo = nodeMap['info'];
      Node node = new Node(nodeName, [], _mailbox.ws, _deselectAllNodes);
      nodes[nodeName] = node;
      _nodesView.uList.children.add(node.view.element);
    });
  }

  void _deselectAllNodes() {
    nodes.values.forEach((Node n) => n.deselect());
  }

  void cleanUp() {
    _listenersToCleanUp.forEach((StreamSubscription s) => s.cancel());
    _listenersToCleanUp = null;

    nodes.values.forEach((Node n) => n.cleanUp());
    nodes = null;

    _nodesView.cleanUp();
  }
}