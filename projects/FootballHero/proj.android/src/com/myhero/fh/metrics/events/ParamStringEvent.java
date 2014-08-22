package com.myhero.fh.metrics.events;

import org.json.JSONObject;
import org.json.JSONException;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

public class ParamStringEvent extends AnalyticsEvent {

  public ParamStringEvent(String name, String paramString) {
    super(name, null);

      if (paramString != null)
      {
          try
          {
              JSONObject paramObject = new JSONObject(paramString);
              Map<String, String> paramMap = new HashMap<String, String>();

              Iterator<String> iterator = paramObject.keys();
              String key = null;
              String value = null;
              while (iterator.hasNext())
              {
                  key = iterator.next();
                  value = paramObject.getString(key);
                  paramMap.put(key, value);
              }
              setAttributes(paramMap);
          }
          catch (JSONException exception)
          {
              exception.printStackTrace();
          }
      }
  }

}
