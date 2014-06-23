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
    "Check_File_Version",

    "Enter_Login_N_Reg",
    "Enter_Register",
    "Enter_Register_Name",
    "Enter_Login",
    "Enter_Forgot_Password",
    "Enter_Match_List",
    "Enter_Match",
    "Enter_Prediction_Confirm",
    "Enter_Pred_Total_Confirm",
    "Enter_Sel_Fav_Team",
    "Enter_Next_Prediction",
    "Enter_History",
    "Enter_History_Detail",
    "Enter_Leaderboard",
    "Enter_Leaderboard_List",
    "Enter_Settings",
    "Enter_FAQ",
    "Enter_Create_Competition",
    "Enter_View_Selected_Leagues",
    "Enter_Competition_Leagues",
    "Enter_Competition_Detail",

    "Do_Register",
    "Do_Register_Name",
    "Do_Login",
    "Do_FB_Connect",
    "Do_FB_Connect_With_User",
    "Do_Post_Predictions",
    "Do_Post_Fav_Team",
    "Do_Send_Feedback",
    "Do_Log_Out",
    "Do_Create_Competition",

    "Show_Error_Message",

    "Load_More_In_Leaderboard",
    "Load_More_In_History",
    "Load_More_In_Competition_Detail",
}

EventNameDosenotTrackList = 
{ 
    "Do_Register",
    "Do_Register_Name",
    "Do_Login",
    "Do_FB_Connect",
    "Do_FB_Connect_With_User",
    "Do_Post_Predictions",
    "Do_Post_Fav_Team",
    "Do_Send_Feedback",
    "Do_Log_Out",
    "Do_Create_Competition",

    "Check_File_Version",
    "Show_Error_Message",
    "Load_More_In_Leaderboard",
    "Load_More_In_History",
    "Load_More_In_Competition_Detail",
}

EventList = CreatEnumTable( EventNameList )
EventDosenotTrackList = CreatEnumTable( EventNameDosenotTrackList )