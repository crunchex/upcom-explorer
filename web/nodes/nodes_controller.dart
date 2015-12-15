library updroid_explorer_nodes;

import 'dart:html';
import 'dart:async';
import 'dart:convert';

import 'package:upcom-api/web/mailbox/mailbox.dart';
import 'package:upcom-api/web/menu/context_menu.dart';
import '../explorer.dart';

part 'nodes_view.dart';
part 'ros_entity.dart';

class NodesController implements ExplorerController {
  String type = 'nodes';

  NodesView _nodesView;
  Mailbox _mailbox;
  Function _showWorkspaceView, _showLaunchersView;

  AnchorElement _stopNodesButton;

  Map<String, Node> nodes = {};
  String workspacePath;
  Set<StreamSubscription> _listenersToCleanUp;
  bool _nodesFound;

  NodesController(int id, this.workspacePath, DivElement content, Mailbox mailbox, List<AnchorElement> actionButtons, Function showWorkspaceView, Function showLaunchersView) {
    _mailbox = mailbox;
    _stopNodesButton = actionButtons[0];
    _showWorkspaceView = showWorkspaceView;
    _showLaunchersView = showLaunchersView;

    registerMailbox();

    _listenersToCleanUp = new Set<StreamSubscription>();
    _nodesFound = false;

    NodesView.createNodesView(id, content).then((nodesView) {
      _nodesView = nodesView;

      _mailbox.ws.send('[[REQUEST_RUNNING_NODES_LIST]]');

      registerEventHandlers();
    });
  }

  void registerMailbox() {
    _mailbox.registerWebSocketEvent(EventType.ON_MESSAGE, 'RUNNING_NODES_LIST', refreshNodesList);
    _mailbox.registerWebSocketEvent(EventType.ON_MESSAGE, 'ADD_NODE', _addNodeToList);
    _mailbox.registerWebSocketEvent(EventType.ON_MESSAGE, 'REMOVE_NODE', _removeNodeFromList);
    _mailbox.registerWebSocketEvent(EventType.ON_MESSAGE, 'STOP_DONE', _stopDone);
    _mailbox.registerWebSocketEvent(EventType.ON_MESSAGE, 'STOP_ALL_DONE', _stopAllDone);
  }

  void registerEventHandlers() {
    _listenersToCleanUp.add(_stopNodesButton.onClick.listen((e) => _stopNodes()));
    _listenersToCleanUp.add(_nodesView.viewWorkspace.onClick.listen((e) => _showWorkspaceView()));
    _listenersToCleanUp.add(_nodesView.viewLaunchers.onClick.listen((e) => _showLaunchersView()));
  }

  void refreshNodesList(Msg um) {
    //    List<Map> nodesList = JSON.decode(um.body);
    List<String> nodesList = JSON.decode(um.body);
    if (nodesList.isNotEmpty) {
      nodes.values.forEach((Node n) => n.cleanUp());
      nodes = {};
      _nodesView.placeholderText.replaceWith(_nodesView.uList);
    } else {
      _nodesView.uList.replaceWith(_nodesView.placeholderText);
      return;
    }

    nodesList.forEach((String nodeName) {
//      String nodeName = nodeMap['name'];
//      List nodeInfo = nodeMap['info'];
      Node node = new Node(nodeName, [], _mailbox.ws, _deselectAllNodes);
      nodes[nodeName] = node;
      _nodesView.uList.children.add(node.view.element);
    });
  }

  void _addNodeToList(Msg um) {
    if (nodes == null) return;

    String nodeName = um.body;

    Node node = new Node(nodeName, [], _mailbox.ws, _deselectAllNodes);
    nodes[nodeName] = node;
    _nodesView.uList.children.add(node.view.element);
  }

  void _removeNodeFromList(Msg um) {
    if (nodes == null) return;

    String nodeName = um.body;
    nodes[nodeName].cleanUp();
    nodes.remove(nodeName);
  }

  void _stopNodes() {
    bool noNodesSelected = true;
    for (Node n in nodes.values) {
      if (!n.isSelected) continue;

      noNodesSelected = false;
      n.stopNode();
    }

    if (noNodesSelected) _mailbox.ws.send('[[STOP_ALL]]');
  }

  void _stopDone(Msg um) {
    List msgList = um.body.split(':');
    String nodeName = msgList[1];
    if (msgList[0] == 'true') {
      nodes[nodeName].cleanUp();
      nodes.remove(nodeName);
    }
  }

  void _stopAllDone(Msg um) {
    if (um.body != 'true') return;
    _mailbox.ws.send('[[REQUEST_RUNNING_NODES_LIST]]');
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