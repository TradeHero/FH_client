module(..., package.seeall)

function action( param )
	Misc:sharedDelegate():sendMail("support@footballheroapp.com", "FootballHero - Support", "")
end