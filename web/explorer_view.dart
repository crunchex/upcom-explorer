part of updroid_explorer;

abstract class ExplorerView {
  DivElement content, explorersDiv;
  SpanElement viewWorkspace, viewLaunchers;

  ExplorerView(int id, DivElement content) {
    this.content = content;

    explorersDiv = new DivElement()
      ..classes.add('exp-container');
    content.children.add(explorersDiv);

    DivElement toolbar = new DivElement()
      ..classes.add('toolbar');
    content.children.add(toolbar);

    viewWorkspace = new SpanElement()
      ..title = 'Workspace View'
      ..classes.add('glyphicons');
    viewLaunchers = new SpanElement()
      ..title = 'Launchers View'
      ..classes.addAll(['glyphicons', 'glyphicons-cluster']);

    toolbar.children.addAll([viewLaunchers, viewWorkspace]);
  }
}
