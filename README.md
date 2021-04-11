# chess

## Eric Miller

Completed as part of the Odin Project: 

https://www.theodinproject.com/courses/ruby-programming/lessons/ruby-final-project

## To Play

- Clone this repo to your machine

- Navigate to the lib directory

- run `ruby chess.rb`

- follow the prompts and enter a move by entering "{rowOfPiece}{colOfPiece} {rowOfTarget}{colOfTarget}"

## Description

Command line Chess where two players can play against each other. A simple AI will perform random legal moves if you don't have an opponent to play with. 

Coded with Ruby. RSpec was used to create a series of tests. Players also have the option of saving a game's progress (data serialized with YAML). 

*There currently is no castling implemented :(

To test with RSpec, comment out the last menu line in lib/chess.rb, then run "rspec spec/". Obviously there's a better way to skip the menu... but I haven't taken the time to dig back into the project and figure out how yet.



