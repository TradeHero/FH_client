package com.myhero.fh.metrics;

import android.content.Context;
import com.myhero.fh.Constants;
import com.myhero.fh.metrics.events.AnalyticsEvent;
import com.myhero.fh.metrics.events.ParamStringEvent;
import com.myhero.fh.metrics.events.SingleAttributeEvent;
import com.myhero.fh.metrics.localytics.LocalyticsAdapter;
import java.util.Collections;
import java.util.HashSet;
import java.util.LinkedHashSet;
import java.util.Set;

public class Analytics {
  private final Set<Action> pendingActions = new LinkedHashSet<Action>();
  private final Set<AnalyticsAdapter> analyticsAdapters;
  private final Set<String> builtinDimensions;

  public static Analytics instance;

  public static void init(Context context) {
    if (instance == null) {
      LocalyticsAdapter localytics =
          new LocalyticsAdapter(context.getApplicationContext(), Constants.LOCALYTICS_APP_KEY);
      instance = new Analytics(
          Collections.singleton((AnalyticsAdapter) localytics),
          Collections.<String>emptySet());
    }
  }

  public static Analytics getInstance() {
    return instance;
  }

  public Analytics(Set<AnalyticsAdapter> analyticsAdapters, Set<String> builtinDimensions) {
    this.analyticsAdapters = analyticsAdapters;
    this.builtinDimensions = builtinDimensions;
  }

  public final Analytics addEvent(AnalyticsEvent analyticsEvent) {
    pendingActions.add(new AddEventAction(analyticsEvent));
    return this;
  }

  public final Analytics tagScreen(String screenName) {
    pendingActions.add(new TagScreenAction(screenName));
    return this;
  }

  /** Specially created for cocos2d */
  public static void fireEventWithParamString(String eventName, String paramString) {
    Analytics.getInstance().fireEvent(new ParamStringEvent(eventName, paramString));
  }

  public final void fireEvent(AnalyticsEvent analyticsEvent) {
    // TODO should create a policy for deciding whether to discard or to process pending action
    discardPendingActions();

    openSession();
    doAction(new AddEventAction(analyticsEvent));
    closeSession();
  }

  public final Analytics openSession() {
    return openSession(null);
  }

  public final Analytics openSession(Set<String> customDimensions) {
    doAction(new OpenSessionAction(customDimensions));
    return this;
  }

  public final void closeSession() {
    closeSession(null);
  }

  public final void closeSession(Set<String> customDimensions) {
    if (!pendingActions.isEmpty()) {
      doPendingActions();
    }
    doAction(new CloseSessionAction(customDimensions));
  }

  private void discardPendingActions() {
    pendingActions.clear();
  }

  private void doPendingActions() {
    for (Action action : pendingActions) {
      doAction(action);
    }
  }

  /** Functional programming can cure this pain * */
  private void doAction(Action action) {
    for (AnalyticsAdapter handler : analyticsAdapters) {
      action.setHandler(handler);
      action.process();
    }
  }

  //region Action classes
  private interface Action {
    void process();

    void setHandler(AnalyticsAdapter handler);
  }

  private abstract class HandlerAction implements Action {
    protected AnalyticsAdapter handler;

    @Override public void setHandler(AnalyticsAdapter handler) {
      this.handler = handler;
    }
  }

  private final class AddEventAction extends HandlerAction {
    private final AnalyticsEvent analyticsEvent;

    public AddEventAction(AnalyticsEvent analyticsEvent) {
      this.analyticsEvent = analyticsEvent;
    }

    @Override public void process() {
      handler.addEvent(analyticsEvent);
    }
  }

  private abstract class HandlerActionWithDimensions extends HandlerAction {
    protected final Set<String> customDimensions;

    public HandlerActionWithDimensions(Set<String> customDimensions) {
      HashSet<String> dimensions = new HashSet<String>(builtinDimensions);
      if (customDimensions != null) {
        dimensions.addAll(customDimensions);
      }
      this.customDimensions = dimensions;
    }
  }

  private final class OpenSessionAction extends HandlerActionWithDimensions {
    public OpenSessionAction(Set<String> customDimensions) {
      super(customDimensions);
    }

    @Override public void process() {
      handler.open(customDimensions);
    }
  }

  private final class CloseSessionAction extends HandlerActionWithDimensions {
    public CloseSessionAction(Set<String> customDimensions) {
      super(customDimensions);
    }

    @Override public void process() {
      handler.close(builtinDimensions);
    }
  }

  private class TagScreenAction extends HandlerAction {
    private final String screenName;

    public TagScreenAction(String screenName) {
      this.screenName = screenName;
    }

    @Override public void process() {
      handler.tagScreen(screenName);
    }
  }
  //endregion
}
