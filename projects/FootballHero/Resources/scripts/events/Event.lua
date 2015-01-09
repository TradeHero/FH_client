module(..., package.seeall)

function CreatEnumTable( tbl, index ) 
    assert( type( tbl ) == "table" ) 
    local enumtbl = {} 
    local enumindex = index or 0 
    for i, v in ipairs( tbl ) do 
        enumtbl[v] = enumindex + i 
    end 
    return enumtbl 
end 

function GetEventNameById( id )
	return EventNameList[id]
end

EventNameList = 
{ 
    "Check_Start_Tutorial",
    "Check_File_Version",

    "Enter_Login_N_Reg",
    "Enter_Email_Login_N_Reg",
    "Enter_Register",
    "Enter_Register_Name",
    "Enter_Login",
    "Enter_Forgot_Password",
    "Enter_Match_List",
    "Enter_Match",
    "Enter_Match_Center",
    "Enter_Prediction_Confirm",
    "Enter_Pred_Total_Confirm",
    "Enter_Sel_Fav_Team",
    "Enter_Next_Prediction",
    "Enter_History",
    "Enter_History_Detail",
    "Enter_Community",
    "Enter_League_Chat",
    "Enter_League_Chat_List",
    "Enter_Settings",
    "Enter_FAQ",
    "Enter_Minigame",
    "Enter_Minigame_Detail",
    "Enter_Minigame_Winners",
    "Enter_Create_Competition",
    "Enter_View_Selected_Leagues",
    "Enter_Competition_Detail",
    "Enter_Competition_More",
    "Enter_Competition_Chat",
    "Enter_Competition_Prize",
    "Enter_Competition_Rules",
    "Enter_Competition_Terms",
    "Enter_Tutorial_Ui_With_Type",
    "Enter_Share",
    "Enter_Push_Notification",
    "Enter_Sound_Settings",
    "Enter_Make_Discussion_Post",
    "Enter_Discussion_Details",

    "Do_Ask_For_Rate",
    "Do_Ask_For_Comment",
    "Do_Register",
    "Do_Login",
    "Do_FB_Connect",
    "Do_FB_Connect_With_User",
    "Do_Post_Predictions",
    "Do_Post_Fav_Team",
    "Do_Post_Logo",
    "Do_Post_PN_User_Settings",
    "Do_Post_PN_Comp_Settings",
    "Do_Post_Device_Token",
    "Do_Send_Feedback",
    "Do_Log_Out",
    "Do_Create_Competition",
    "Do_Join_Competition",
    "Do_Share_Competition",
    "Do_Leave_Competition",
    "Do_Password_Reset",
    "Do_Send_Chat_Message",
    "Do_Get_Chat_Message",
    "Do_Share_By_SMS",
    "Do_Share_By_Email",
    "Do_Make_Discussion_Post",
    "Do_Like_Discussion_Post",
    "Do_Share_Discussion_Post",

    "Show_Info",
    "Show_Error_Message",
    "Show_Choice_Message",
    "Show_Marketing_Message",
    "Show_Please_Update",

    "Load_More_In_Leaderboard",
    "Load_More_In_History",
    "Load_More_In_Competition_Detail",
}

EventNameDosenotTrackList = 
{ 
    "Enter_Share",
    
    "Do_Ask_For_Rate",
    "Do_Ask_For_Comment",
    "Do_Register",
    "Do_Register_Name",
    "Do_Login",
    "Do_FB_Connect",
    "Do_FB_Connect_With_User",
    "Do_Post_Predictions",
    "Do_Post_Fav_Team",
    "Do_Post_Logo",
    "Do_Post_PN_User_Settings",
    "Do_Post_PN_Comp_Settings",
    "Do_Post_Device_Token",
    "Do_Send_Feedback",
    "Do_Log_Out",
    "Do_Create_Competition",
    "Do_Join_Competition",
    "Do_Share_Competition",
    "Do_Password_Reset",
    "Do_Send_Chat_Message",
    "Do_Get_Chat_Message",
    "Do_Share_By_SMS",
    "Do_Share_By_Email",
    "Do_Make_Discussion_Post",
    "Do_Like_Discussion_Post",

    "Check_Start_Tutorial",
    "Check_File_Version",
    "Show_Info",
    "Show_Error_Message",
    "Show_Choice_Message",
    "Show_Marketing_Message",
    "Show_Please_Update",
    "Load_More_In_Leaderboard",
    "Load_More_In_History",
    "Load_More_In_Competition_Detail",
}

EventList = CreatEnumTable( EventNameList )
EventDosenotTrackList = CreatEnumTable( EventNameDosenotTrackList )