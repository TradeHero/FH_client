package com.myhero.fh.metrics.events;

/** Event that identify itself by only event name * */
public final class SimpleEvent extends AnalyticsEvent {
  public SimpleEvent(String name) {
    super(name);
  }
}
