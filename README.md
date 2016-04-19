# Project Overview

Our project was to, given an enemy [Pokemon](https://en.wikipedia.org/wiki/Pok%C3%A9mon_(video_game_series)),
to find candidate counter-Pokemon (basically who would have a high chance of winning in a 1v1 battle),
then to narrow down the list to a single suggested Pokemon to counter the chosen enemy.

To do so, we hand-rolled an algorithm that takes in all the factors used in a typical battle
scenario, and applied a bit of decision-making logic to the factors to select a prime candidate
as a counter to a chosen enemy. These factors include type effectiveness, same-type attack bonus,
resistance to enemy Pokemon's moves, minimum, maximum and average damage per move vs the enemy Pokemon,
move accuracy, status effect afflictions, and stat-buff and stat-debuff moves.

Our AI win ratio in a 1v1 is not perfectly consistent, because the AI does not choose to use
moves against the other Pokemon as a normal human being would - thus, *some* RNG is involved. However,
the candidate Pokemon and their moves are almost entirely consistent, as RNG plays only a small
part in the AI's decision-making.

# Install Prelude

We developed this project on Cloud9, a free web IDE service. Because the workspaces are Ubuntu
virtual machines, it may be worth the time to simply create an account and create a workspace,
then run the commands. We don't know if the installation steps will work on OSX or even non-Ubuntu
distros of Linux. Therefore, we highly recommend Cloud9 (Ruby on Rails container type during creation).
You can also clone our Github repository when creating the Cloud9 container.

However, this project is known to work without a hitch on `ruby 2.3.0` and `rails 5.0.0.beta3`,
which should be consistent across any system that can run both. So, if one could install them both,
the project should run fine. We have an install setup specifically for Ubuntu, though.

# Requirements

Okay, so we didn't actually need the entire Ruby on Rails framework for this project. Originallly
we wanted to use Rails' ActiveRecord library for its fancy database abstractions, but we decided
to use the whole framework in the project so that we could more easily extend it into a web
application to demonstrate how the AI works a bit more visually instead of through a terminal.

We ran out of time to do that, unfortunately.

## Pull from Git

If you didn't clone the repository through a Cloud9 container, run the following commands to pull
the code from the [Github repository]()

`git init` (in an empty repository)
`git remote add origin https://github.com/cireficc/pokemon-ai-rails.git`
`git pull origin master`

You should now see an `app` directory with a typical

## Installing Rails 5 and RVM

Simply run the following commands in order on a Linux OS (we use Ubuntu)

1. `sudo apt-get update` - updates Ubuntu packages to latest version so you don't install out-of-date versions
2. `sudo apt-get install curl` - installs the cURL utility that is used to send HTTP requests (like in the next command)
3. `\curl -L https://get.rvm.io | bash -s stable --ruby` - downloads and installs RVM (Ruby Version Manager)
4. `rvmsudo rvm get stable --autolibs=enable` - RVM updates itself to the most recent stable version
5. `rvm --default use ruby-2.3.0` - tells RVM to use Ruby 2.3.0 (for Rails 5)
6. `gem update --system` - updates **gem** (the Ruby package manager)
7. `gem install rails --pre` - installs the most recent stable Rails version
8. `rails -v` - checks the Rails version. It should be 5
9. `bundle install` - install the necessary gems (libraries) used by Rails
10. `rake db:setup` - set up the Pokemon database (may take a minute or two, SQLite is kind of slow)

# Running the project

The project is terminal-based because we didn't have time to extend it as we wanted. Thus, the
main code for the project is found in `/lib` as the files `ai.rb` and `battle.rb`.

`ai.rb` is the main script which will demonstrate the effectiveness of the AI. `battle.rb` contains
the code necessary to simulate a Pokemon battle (1v1 scenario).

To run the AI and print out results:

`rails runner lib/ai.rb` -- run from the root directory of the repository

You will be asked to input a Pokemon's name as the enemy for the AI to fight against.
You can type in **Venusaur** if you aren't familiar with Pokemon.

You should now see output of how many candidate Pokemon can combat against your choice. For
Venusaur, there should be 26 candidate counter-Pokemon. The list will then be narrowed down
to a single Pokemon that would be the best candidate against the enemy.

### More-detailed output from simulations

If you want to see what math went into the battle scenario, simply open `battle.rb` and
find + replace `#puts` with `puts`. This will un-comment all print statements for the battle
simulation. However, it will significantly slow the AI script (as one could imagine).