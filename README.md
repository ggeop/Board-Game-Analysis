# BoardGameAnalysis

## Introduction

It is undeniable fact that board games have been making a comeback lately, and deeper, more strategic board games, like Scythe or Catan have become hugely popular all over the world. In Greece there are many associations and “fan clubs” of popular board games, which they organized many tournaments with many participants and a rich variety of awards. 

Most game designers have full time jobs and creating games is merely their hobby (yes, even for popular games!). They typically only make enough profit to break even or at best squeeze out a couple expansions.
That is, until Kickstarter. Kickstarter is a global crowdfunding platform that helps bring creative projects to life. Kickstarter has been revolutionary to the board game market, as it gives avid gamers a chance to put their idea out in front of other like minded people. It gave the table top community a way to bring silent ideas to life. 

Based on the above reasons, this assignment is an excellent opportunity to study and analyze a huge dataset of board games, so as to investigate which attributes and users’ stats exactly define a successful and popular board game.
We are going to use SQL Server Database to define our schema, to design and develop our data warehouse. Moreover we are going to use SQL Server Analysis Services to define our multi-dimensional model over our schema. Furthermore we will connect our cube to Tableau and we are going show some OLAP reports and visualize the most interesting results. 

At last, we are going to create a linear regression model through IBM SPSS Statistics Platform, to make predictions for newly created board games and to understand which stats from BGG community and main attributes of games affect the rating of a game more.
Our main approach to this report, in exploring the BoardGameGeek (BGG) dataset, will be an effort on trying to answer the question “Wouldn’t it be nice to know if a board game is good before you buy it?” This is a very broad question and cannot be answered without a deep knowledge of the data itself.


## Application

Both of us we are board games enthousiasts, so we chose to do our project with a dataset from BoardGameGeek (BGG).

BoardGameGeek is an online forum for board gaming hobbyists and a game database that holds reviews, images and videos for over 90,000 different tabletop games, including European-style board games, wargames, and card games. In addition to the game database, the site allows users to rate games on a 1–10 scale and publishes a ranked list of board games. Since 2005, BoardGameGeek hosts an annual board game convention, BGG.CON,  that has a focus on playing games. New games are showcased and convention staff is provided to teach rules.

## Dataset

We use as our dataset which contains the attributes and the ratings for around 94.000 among board games and expansions, from BoardGameGeek. A few details about our initial dataset:
•	The initial size was around 150MB
•	Around 94.000 rows & 80 columns
Each row represents a single board game and has descriptive statistics about the board game, as well as review information. Some interesting columns for analysis are:
•	game.type – Board games are divided in two categories, “BoardGames” & “BoardGames Expanions”
•	details.maxplayers – Suggested max number of players (given by the manufacturer)
•	details.maxplaytime – Maximum playing time (given by the manufacturer)
•	details.minage – Minimum recommended age to play
•	details.minplayers – Suggested min number of players (given by the manufacturer)
•	details.minplaytime – Minimum playing time (given by the manufacturer)
•	details.name – Name of the board game
•	details.yearpublished – Published year
•	attributes.boardgamecategory – Board games categories
•	attributes.boardgamemechanic – Type of mechanics (e.g. Hand Management,Set Collection,Trading)
•	attributes.total – Number of attributes (e.g. dices, cards, pawns...)
•	stats.average –  Average rating given to the game by users (0-10)
•	stats.averageweight –  Average of all the subjective weights (0-5)
•	stats.numcomments – Number of comments in each game given by the BoardGameGeek)
•	stats.numweights – Number of votes in  weight/difficulty
•	stats.owned  –  Number of players who have a game
•	stats.trading  – Number of players who trade a game
•	stats.usersrated – Users rate in each game
•	stats.wanting – Number of player who want a game
•	stats.wishing – Number of players who added a game in wish list

We drop bayes_average_rating since it is almost analogous to our target.For regression analysis we have chosen the columns:


## ETL - Extract Transform Load

ETL is a process in data warehousing responsible for pulling data out of the source systems and placing it into a data warehouse. We did all the ETL procedure via Rstudio.

### Extract
We extracted the data from a github repository. 

```
#Install package
2.	install.packages("devtools")
3.	devtools::install_github("9thcirclegames/bgg-analysis")
```

