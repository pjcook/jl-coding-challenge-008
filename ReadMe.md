# Challenge #8

In this challenge the objective will be to create some complex data types.

This challenge is the first part of creating a board game called “Shopopoly” which is a bit like the game Monopoly. In this game the objective of each player is to acquire assets such as shops and then make money by charging other players a fee when they visit your shops or other assets. When a player runs out of money they leave the game and the winner is the last player to be left in the game.

This challenge only requires you to design the data types that represent each Location on the playing board.

For now, a Location can be any of the following:

  * Free Parking. There is only one of these. Players are not charged a fee for visiting this location and cannot purchase this location.

  * Go. This is the location on the board that all players start from. Players passing through this location pick up a fee of £100.

  * A factory or warehouse. There are four of these, each with a unique name. They all have a purchase price of £100 and the rent is £20 for anybody visiting any of them.

  * A retail site. There will be up to 20 of these. They each have a unique name and a purchase price. It is possible for an owner to build a shop on a retail site in one of three sizes (mini store, supermarket, megastore) . The cost of building each type of shop is a property of the retail site. Each retail sites with an owner will charge different amounts to any visitors that aren’t the owner. The rent at each site is different depending on whether the site is undeveloped, contains a ministore, a supermarket or a megastore. Each retail site belongs to a group which can contain either two or three retail sites.

In this challenge you need to create the Location data type that is easy to use and as far as reasonably possible, prevents you from creating an invalid instance of a Location. Instances of Location are never changed after they’ve been created and each instance doesn’t know it’s position on the board or whether anybody is visiting it or owns it.

We may add additional types of Location in later challenges but apply YAGNI principle for now.

Unit tests on simple constructors are not always necessary but it would be good to have tests which show examples of each variant of Location being constructed.

N.b. Any monetary values are whole positive values of GBP sterling.

Entries should be submitted by 15th July.

## Additional Notes

Things have been very quite about challenge-8! I bumped into Paul Fiddler who asked for some clarification. This challenge is about creating the data types to represent the locations on the board. Its not about creating mechanisms to control how many instances of locations are created within an application. e.g. I've said there is only one free parking location but I've specified that so people don't create a general purpose free parking class that enables different variety of free parking locations to be created. In theory to complete this challenge you could create a single class called Location with a lots of optional properties but unless you put elaborate code into your constructor someone could use the class to create a free parking space that players could purchase and build shops on (and is therefore a bad idea).

Had another question about Challenge 8. The Location data type doesn't need to hold any state so doesn't need to contain information about whether anybody owns it or has built on it. For anybody learning about Kotlin you may find Kotlin Sealed Class useful for this challenge (I've not tried this challenge yet so not totally sure!). For anybody using Swift you may find  Swift Enum type with associated values useful.


# Challenge #9

In challenge 8 we created a Location data structure which represented each of the different types of locations found on a new game called “Shopopoly”.

In Shopopoly it will be important to know things such as how much money each player has, who owns each location and whether any location has been developed to add a ministore, a supermarket or a megastore. The objective of challenge-9 will be to create a GameLedger which will hold a record of all financial transactions in the game. There will be a single instance of GameLedger that will be initialised at the start of each game.

You are also required to create the following functions that add transactions to the GameLedger:

  * A function that adds a transaction for an amount being transferred from the Bank to a Player. This is the starting balance for each player in the game.

  * A function that adds a transaction for the Bank paying a fee to a Player, e.g. when the player passes through the Go location.

  * A function that adds a transaction for rent being paid from one player to another, e.g. when a player lands on a RetailSite location owned by another player.

  * A function that adds a transaction for when a Player has paid the Bank to purchase a Location.

  * A function that adds a transaction for when a Player has paid the Bank for building a specific type of building on a Location. Types of building include ministore, supermarket or megastore.

We haven’t defined Player yet so for this challenge just create a simple type (e.g. a class or interface) that contains a property that uniquely identify each instance of a player.

To keep this simple please assume the following about GameLedger:

  * All data is stored in memory - you don’t have to keep data in a file or database system.

  * In a later challenge you will be asked to create functions to query the GameLedger.

  * You will need to know the sequence that transactions were added to GameLedger in order to query it accurately in some cases.

  * GameLedger just does what it is told. It does not know whether a request is valid, e.g. it doesn’t know whether a player is purchasing a location that someone else has already purchased.

  * GameLedger is likely to need to hold different types of transactions as Shopopoly evolves.

  * Any monetary values are whole positive values of GBP sterling.

  * You don’t need to worry about concurrency.

Entries should be submitted by 5th August.
