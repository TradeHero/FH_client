package com.myhero.fh.auth;

/**
 * Created by trdehero on 14-8-4.
 */
public interface AuthenticationCallback {
    void onStart();

    void onSuccess(String authenticationToken);

    void onError(Throwable error);
}
