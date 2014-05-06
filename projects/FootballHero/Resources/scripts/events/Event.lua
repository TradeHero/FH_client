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
    "Enter_Sel_Fav_Team",
    "Enter_Next_Prediction",

    "Do_Register",
    "Do_Register_Name",
    "Do_Login",
    "Do_FB_Connect",
    "Do_Post_Predictions",

    "Show_Error_Message",
}

EventList = CreatEnumTable( EventNameList )