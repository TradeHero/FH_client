package com.myhero.fh.metrics.localytics;

import android.content.Context;
import com.localytics.android.LocalyticsSession;
import com.myhero.fh.metrics.AnalyticsAdapter;
import com.myhero.fh.metrics.events.AnalyticsEvent;
import java.util.ArrayList;
import java.util.Set;

public class LocalyticsAdapter implements AnalyticsAdapter {
  private final LocalyticsSession localytics;

  public LocalyticsAdapter(Context context, String appKey) {
    localytics = new LocalyticsSession(context, appKey);
  }

  @Override public void open(Set<String> customDimensions) {
    localytics.open(new ArrayList<String>(customDimensions));
  }

  @Override public void addEvent(AnalyticsEvent analyticsEvent) {
    localytics.tagEvent(analyticsEvent.getName(), analyticsEvent.getAttributes());
  }

  @Override public void tagScreen(String screenName) {
    localytics.tagScreen(screenName);
  }

  @Override public void close(Set<String> customDimensions) {
    localytics.close(new ArrayList<String>(customDimensions));
    localytics.upload();
  }
}
