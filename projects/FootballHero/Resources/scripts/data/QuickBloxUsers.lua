module(..., package.seeall)

--[[
Data structure of Quickblox Users:
{
    "current_page": 1,
    "per_page": 10,
    "total_entries": 3,
    "items": [
        {
            "user": {
                "id": 2243714,
                "owner_id": 23943,
                "full_name": null,
                "email": null,
                "login": "test001",
                "phone": null,
                "website": null,
                "created_at": "2015-01-28T06:20:54Z",
                "updated_at": "2015-02-13T10:14:55Z",
                "last_request_at": "2015-02-15T03:47:14Z",
                "external_user_id": null,
                "facebook_id": null,
                "twitter_id": null,
                "blob_id": null,
                "custom_data": null,
                "user_tags": null
            }
        },
        {
            "user": {
                "id": 2244374,
                "owner_id": 23943,
                "full_name": null,
                "email": null,
                "login": "test004",
                "phone": null,
                "website": null,
                "created_at": "2015-01-28T09:48:12Z",
                "updated_at": "2015-01-28T09:48:12Z",
                "last_request_at": "2015-01-28T09:51:27Z",
                "external_user_id": null,
                "facebook_id": null,
                "twitter_id": null,
                "blob_id": null,
                "custom_data": null,
                "user_tags": null
            }
        }
    ]
}

--]]

local Json = require("json")

local mUsers = {}

function hasUserById( id )
	if mUsers[id] then
		return true
	else
		return false
	end
end

function getUserById( id )
	if mUsers[id] then
		return mUsers[id]
	else
		return nil
	end
end

function addUser( id, user )
	mUsers[id] = user
end