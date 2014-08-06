package com.myhero.fh.metrics.events;

import com.myhero.fh.metrics.AnalyticsConstants;

public class ScreenFlowEvent extends SingleAttributeEvent {
  public ScreenFlowEvent(String name, String fromScreen) {
    super(name, AnalyticsConstants.FollowedFromScreen, fromScreen);
  }
}
