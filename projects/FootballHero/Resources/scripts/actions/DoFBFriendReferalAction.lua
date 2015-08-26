module(..., package.seeall)

function action( param )
    FacebookDelegate:sharedDelegate():inviteFriend( "https://fb.me/1053951204628560", inviteFriendHandler )
end

function inviteFriendHandler( success )

end