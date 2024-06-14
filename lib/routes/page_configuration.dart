class PageConfiguration {
  final bool unknown;
  final bool register;
  final bool? loggedIn;
  final String? storyId;
  final bool addStory;

  PageConfiguration.splash()
      : unknown = false,
        register = false,
        loggedIn = null,
        storyId = null,
        addStory = false;

  PageConfiguration.login()
      : unknown = false,
        register = false,
        loggedIn = false,
        storyId = null,
        addStory = false;

  PageConfiguration.register()
      : unknown = false,
        register = true,
        loggedIn = false,
        storyId = null,
        addStory = false;

  PageConfiguration.home()
      : unknown = false,
        register = false,
        loggedIn = true,
        storyId = null,
        addStory = false;

  PageConfiguration.detailStory(String id)
      : unknown = false,
        register = false,
        loggedIn = true,
        storyId = id,
        addStory = false;

  PageConfiguration.unknown()
      : unknown = true,
        register = false,
        loggedIn = null,
        storyId = null,
        addStory = false;

  PageConfiguration.addStory()
      : unknown = false,
        register = false,
        loggedIn = true,
        storyId = null,
        addStory = true;

  bool get isSplashPage => !unknown && loggedIn == null;
  bool get isLoginPage => !unknown && loggedIn == false;
  bool get isHomePage => !unknown && loggedIn == true && storyId == null;
  bool get isDetailStoryPage => !unknown && loggedIn == true && storyId != null;
  bool get isAddStoryPage => !unknown && loggedIn == true && addStory;
  bool get isRegisterPage => register;
  bool get isUnknownPage => unknown;
}
