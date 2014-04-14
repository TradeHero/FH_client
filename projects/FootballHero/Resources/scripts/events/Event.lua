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
    "Enter_Login_N_Reg",
    "Enter_Register",
    "Enter_Register_Name",
    "Enter_Login",
    "Enter_Forgot_Password",
    "Enter_Match_List",
    "Enter_Match",
    "Enter_Prediction_Confirm",

    "Do_Register",

    "Show_Error_Message",
}

EventList = CreatEnumTable( EventNameList )