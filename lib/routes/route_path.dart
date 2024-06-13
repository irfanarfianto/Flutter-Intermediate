class RoutePath {
  final bool isLogin;
  final bool isRegister;
  final bool isStoryList;
  final bool isDetailStory;
  final bool isAddStory;
  final bool isUnknown;
  final int? storyId;

  RoutePath({
    this.isLogin = false,
    this.isRegister = false,
    this.isStoryList = false,
    this.isDetailStory = false,
    this.isAddStory = false,
    this.isUnknown = false,
    this.storyId,
  });

  factory RoutePath.home() => RoutePath();

  factory RoutePath.login() => RoutePath(isLogin: true);

  factory RoutePath.register() => RoutePath(isRegister: true);

  factory RoutePath.storyList() => RoutePath(isStoryList: true);

  factory RoutePath.detailStory(int storyId) =>
      RoutePath(isDetailStory: true, storyId: storyId);

  factory RoutePath.addStory() => RoutePath(isAddStory: true);

  factory RoutePath.unknown() => RoutePath(isUnknown: true);
}
