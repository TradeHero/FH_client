module(..., package.seeall)

function action( param )
    FacebookDelegate:sharedDelegate():gameRequest("my title", "my message.")
end