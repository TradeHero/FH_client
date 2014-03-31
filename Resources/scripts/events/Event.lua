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
    "Load_Match_List",
    "Enter_Match",
    "Prediction_Confirm"
}

EventList = CreatEnumTable( EventNameList )