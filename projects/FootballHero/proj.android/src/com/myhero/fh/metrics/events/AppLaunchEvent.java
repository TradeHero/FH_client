package com.myhero.fh.metrics.events;

import com.myhero.fh.metrics.AnalyticsConstants;

public final class AppLaunchEvent extends AnalyticsEvent {
  public AppLaunchEvent() {
    super(AnalyticsConstants.AppLaunch);
  }
}
