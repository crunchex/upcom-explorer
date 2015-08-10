part of updroid_explorer_nodes;

class Node {
  String name;
  List info;
  NodeView view;
  var deselectAllNodes;
  bool isSelected;

  WebSocket _ws;
  bool _selectEnabled;

  Node(this.name, this.info, WebSocket ws, this.deselectAllNodes) {
    isSelected = false;

    _ws = ws;
    _selectEnabled = true;

    _setUpNodeView();
  }

  void stopNode() {
    if (!isSelected) return;

    _ws.send('[[STOP_NODE]]' + name);
  }


  void _setUpNodeView() {
    view = new NodeView(name, info);

    view.container.onClick.listen((e) {
      if (_selectEnabled) {
        if (!e.ctrlKey) deselectAllNodes();

        toggleSelected();
        _selectEnabled = false;

        new Timer(new Duration(milliseconds: 500), () {
          _selectEnabled = true;
        });
      }
    });

    view.container.onContextMenu.listen((e) {
      e.preventDefault();
      deselectAllNodes();
      select();
      List menu = [
        {'type': 'toggle', 'title': 'Stop', 'handler': stopNode}];
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