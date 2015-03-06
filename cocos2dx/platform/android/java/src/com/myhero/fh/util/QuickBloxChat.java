package com.myhero.fh.util;


import android.content.Context;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.util.Log;
import com.quickblox.auth.QBAuth;
import com.quickblox.auth.model.QBSession;
import com.quickblox.chat.QBChatService;
import com.quickblox.chat.QBGroupChat;
import com.quickblox.chat.listeners.QBMessageListenerImpl;
import com.quickblox.core.QBEntityCallbackImpl;
import com.quickblox.core.QBSettings;
import com.quickblox.users.QBUsers;
import com.quickblox.users.model.QBUser;
import org.jivesoftware.smack.SmackException;
import org.jivesoftware.smackx.muc.DiscussionHistory;

import java.util.Arrays;
import java.util.List;

public class QuickBloxChat extends QBMessageListenerImpl<QBGroupChat> {
    private static final String APP_ID = "18975";
    private static final String AUTH_KEY = "zencjPNL6BUKjTn";
    private static final String AUTH_SECRET = "kMjSLXRcHxqftVT";
    private static final String QUICK_BLOX_PASSWORD = "11111111";
    private static final int AUTO_PRESENCE_INTERVAL_IN_SECONDS = 30;
    private static QBChatService chatService;
    private static QBUser currentUser;

    private static String currentUserName;
    private static String currentUserProfileImg;
    private static int currentUserId;

    public static void init(Context context) {
        QBChatService.setDebugEnabled(true);
        QBSettings.getInstance().fastConfigInit(APP_ID, AUTH_KEY, AUTH_SECRET);
        if (!QBChatService.isInitialized()) {
            QBChatService.init(context);
        }
        chatService = QBChatService.getInstance();
    }

    public static void signin(String userName, String profileImg, int userId) {
        // create QB user
        //
        currentUserName = userName;
        currentUserProfileImg = profileImg;
        currentUserId = userId;

        QuickbloxSigninHandler.sendMessage(new Message());
    }

    public static void signout() {
        chatService.logout(new QBEntityCallbackImpl() {
            @Override
            public void onSuccess() {
                super.onSuccess();
                Log.i(this.getClass().getName(), "Chat user log out.");
            }
        });
    }

    public static void joinChatRoom(String jid) {
        final QBGroupChat groupChat = QBChatService.getInstance().getGroupChatManager().createGroupChat(jid);

        DiscussionHistory history = new DiscussionHistory();
        history.setMaxStanzas(0);

        groupChat.join(history, new QBEntityCallbackImpl() {
            @Override
            public void onSuccess() {
                groupChat.addMessageListener(this);
                quickbloxJoinChatRoomResult(true);
                Log.w("Chat", "Join successful");
            }

            @Override
            public void onError(final List list) {
                quickbloxJoinChatRoomResult(false);
                Log.w("Could not join chat, errors:", Arrays.toString(list.toArray()));
            }
        });
    }

    private static void signup() {
        QBAuth.createSession(new QBEntityCallbackImpl<QBSession>() {
            @Override
            public void onSuccess(QBSession session, Bundle params) {
                // success
                final QBUser user = new QBUser(currentUserName, QUICK_BLOX_PASSWORD);
                user.setWebsite(currentUserProfileImg);
                user.setExternalId(String.valueOf(currentUserProfileImg));

                QBUsers.signUp(user, new QBEntityCallbackImpl<QBUser>() {
                    @Override
                    public void onSuccess(QBUser user, Bundle args) {
                        // success
                        signin(currentUserName, currentUserProfileImg, currentUserId);
                    }

                    @Override
                    public void onError(List<String> errors) {
                        // error
                        Log.e(this.getClass().getName(), errors.toString());
                    }
                });
            }

            @Override
            public void onError(List<String> errors) {
                // errors
            }
        });
    }

    private static void loginToChat(final QBUser user){

        chatService.login(user, new QBEntityCallbackImpl() {
            @Override
            public void onSuccess() {

                // Start sending presences
                //
                try {
                    chatService.startAutoSendPresence(AUTO_PRESENCE_INTERVAL_IN_SECONDS);
                } catch (SmackException.NotLoggedInException e) {
                    e.printStackTrace();
                }
            }

            @Override
            public void onError(List errors) {
                Log.e(this.getClass().getName(), errors.toString());
            }
        });
    }


    public static native void quickbloxLoginResult(String token);
    public static native void quickbloxJoinChatRoomResult(boolean success);

    private static Handler QuickbloxSigninHandler = new Handler()
    {
        @Override
        public void handleMessage(Message msg)
        {
            super.handleMessage(msg);
            final QBUser user = new QBUser();
            user.setLogin(currentUserName);
            user.setPassword(QUICK_BLOX_PASSWORD);

            QBAuth.createSession(user, new QBEntityCallbackImpl<QBSession>() {
                @Override
                public void onSuccess(QBSession session, Bundle args) {

                    // save current user
                    //
                    user.setId(session.getUserId());
                    currentUser = user;

                    // login to Chat
                    //
                    loginToChat(user);

                    quickbloxLoginResult(session.getToken());
                }

                @Override
                public void onError(List<String> errors) {
                    signup();
                }
            });
        }
    };
}
