part of updroid_explorer;

abstract class ExplorerView {
  DivElement content, explorersDiv;
  SpanElement viewWorkspace, viewLaunchers, viewNodes;
  ParagraphElement placeholderText;

  ExplorerView(int id, DivElement content) {
    this.content = content;

    explorersDiv = new DivElement()
      ..classes.add('exp-container');
    content.children.add(explorersDiv);

    // Placeholder-text element is created, but must be explicitly
    // presented where appropriate.
    placeholderText = new ParagraphElement()
      ..classes.add('explorer-placeholder');
//    explorersDiv.children.add(placeholderText);

    DivElement toolbar = new DivElement()
      ..classes.add('toolbar');
    content.children.add(toolbar);

    viewWorkspace = new SpanElement()
      ..title = 'Workspace View'
      ..classes.add('glyphicons');
    viewLaunchers = new SpanElement()
      ..title = 'Launchers View'
      ..classes.addAll(['glyphicons', 'glyphicons-cluster']);
    viewNodes = new SpanElement()
      ..title = 'Nodes View'
      ..classes.addAll(['glyphicons', 'glyphicons-turtle']);

    toolbar.children.addAll([viewNodes, viewLaunchers, viewWorkspace]);
  }
}
