package com.myhero.fh.metrics.events;

import java.util.Collections;

public class SingleAttributeEvent extends AnalyticsEvent {
  public SingleAttributeEvent(String name, String attributeKey, String attributeValue) {
    super(name, attributeKey == null || attributeKey.isEmpty() ? null :
        Collections.singletonMap(attributeKey, attributeValue));
  }
}
