package com.myhero.fh.metrics;

import com.myhero.fh.metrics.events.AnalyticsEvent;
import java.util.Set;

public interface AnalyticsAdapter {
  void open(Set<String> customDimensions);

  void addEvent(AnalyticsEvent analyticsEvent);

  void tagScreen(String screenName);

  void close(Set<String> customDimensions);
}
