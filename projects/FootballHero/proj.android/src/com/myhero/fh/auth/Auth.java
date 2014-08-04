package com.myhero.fh.auth;

/**
 * Created by trdehero on 14-8-4.
 */
public interface Auth {
    void authenticate(AuthenticationCallback callback);

    String getAccessToken();
}
