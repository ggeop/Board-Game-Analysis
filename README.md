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
install.packages("devtools")
devtools::install_github("9thcirclegames/bgg-analysis")

```

After we created a .csv file in order to insert it in Rstudio and start the cleaning procedure:

```
# Create our initial csv
data(BoardGames)
write.csv(BoardGames, 'BoardGames.csv', row.names = FALSE)

```

### Transform 

We transformed the data by doing the following tasks: 
1.	Filter the columns and we keeped only certain columns to load that have potential value to our analysis.

2.	We categorized to Dimensions and Measures according to our analysis needs.

3.	Apply rules according to BoardGameGeek platform
o	Players age limits (0-100)
o	Rating score range(1-10)
o	Difficulty score range (1-5)
o	Publish year range, (1980-2016)
o	Number of player limits (1-100)

4.	Cleaning
o	Removing records with destroy titles (e.g. no-English titles)
o	Removing records with no titles or only special character titles
o	Delete duplications
o	Insert ranges in measures (e.g. average rating between 1 and 10)

5.	Splitting columns, we spitted columns with multiple values to different cells. Specifically, we created two bridge tables (categories and mechanic)

6.	We created one data frame for each dimension and one for the fact. 
7.	We convert the schema of the table. We converted to a star-flake schema by replacing the dimension columns with their ids.

We created and run the following code* in order to clean the dataset:
*We have omitted a couple of lines for cleaning the columns

```
1.	BoardGames<-BoardGames[BoardGames$game.type=="boardgame",]
2.	BoardGames<-BoardGames[,-c(1)]
3.	
4.	#NOTE: THERE ARE 2 TYPE OF GAMES THE BOARDGAMES AND THE EXPANSIONS OF THEM. 
5.	#THE EXPANSIONS ARE THE SAME GAMES WITH FEW EXTRA FEATURES
6.	
7.	##### Delete Dublications in Board games
8.	BoardGames<-BoardGames[!duplicated(BoardGames$details.name),]
9.	
10.	##### Date limitsPublish year limits
11.	BoardGames<-BoardGames[2017>BoardGames$details.yearpublished & BoardGames$details.yearpublished>1980,]
12.	
13.	##### Date limits
14.	BoardGames<-BoardGames[100>BoardGames$details.minage & BoardGames$details.minage>0,]
15.	
16.	##### Rating limints according to the site
17.	BoardGames<-BoardGames[BoardGames$stats.average>0 & BoardGames$stats.average<=10,]
18.	
19.	##### Difficulty limits according to the site
20.	BoardGames<-BoardGames[BoardGames$stats.averageweight>0 & BoardGames$stats.averageweight<=5,]
21.	
22.	##### Number of Players limits
23.	BoardGames<-BoardGames[100>BoardGames$details.maxplayers & BoardGames$details.maxplayers>0,]
24.	BoardGames<-BoardGames[!is.na(BoardGames$details.maxplayers),] #Remove NULL values
25.	
26.	BoardGames<-BoardGames[100>BoardGames$details.minplayers & BoardGames$details.minplayers>0,]
27.	BoardGames<-BoardGames[!is.na(BoardGames$details.minplayers),] #Remove NULL values
28.	
29.	##### Filter the attribute counts
30.	BoardGames<-BoardGames[BoardGames$attributes.total>0,]
31.	
32.	##### Removing characters from dataset
33.	BoardGames<-BoardGames[!grepl('<',BoardGames$details.name),]
34.	BoardGames<-BoardGames[!grepl('>',BoardGames$details.name),]
```

Also, how we created the dimension tables:

```
1.	nameDim<-as.data.frame(unique(BoardGames$details.name))
2.	names(nameDim)<-paste("NameLabel")
3.	nameDim$id <- seq.int(nrow(nameDim))
4.	write.csv(nameDim,'nameDim.csv',row.names = FALSE)
5.	
6.	#### Replace the details.name with id
7.	BoardGames$details.name<- nameDim$id[match(BoardGames$details.name,nameDim$NameLabel)]
8.	
9.	#### Convert details.name into id
10.	colnames(BoardGames)[6]<-"id"

11.	##### Separate the multivalues in different rows (by categories)
12.	bridge_categories<-subset(BoardGames,select=c(id,attributes.boardgamecategory))
13.	bridge_categories<-separate_rows(bridge_categories,attributes.boardgamecategory,convert = TRUE, sep = ",")
14.	
15.	##### Separate the multivalues in different rows (by mechanic)
16.	bridge_mechanic<-subset(BoardGames,select=c(id,attributes.boardgamemechanic))
17.	bridge_mechanic<-separate_rows(bridge_mechanic,attributes.boardgamemechanic,convert = TRUE, sep = ",")

18.	##########################################################################
19.	###################### Create Category Dimention #########################
20.	##########################################################################

21.	categoryDim<-as.data.frame(unique(bridge_categories$attributes.boardgamecategory))
22.	names(categoryDim)<-paste("CategoryLabel")
23.	categoryDim$CategoryID <- seq.int(nrow(categoryDim))
24.	write.csv(categoryDim,'categoryDim.csv',row.names = FALSE)

25.	##########################################################################
26.	###################### Create mechanic Dimention #########################
27.	##########################################################################

28.	mechanicDim< as.data.frame(unique(bridge_mechanic$attributes.boardgamemechanic))
29.	names(mechanicDim)<-paste("MechanicLabel")
30.	mechanicDim$MechanicID <- seq.int(nrow(mechanicDim))
31.	write.csv(mechanicDim,'mechanicDim.csv',row.names = FALSE)

32.	##########################################################################
33.	###################### Create yearpublished Dimention ####################
34.	##########################################################################

35.	yearDim<-as.data.frame(unique(BoardGames$details.yearpublished))
36.	names(yearDim)<-paste("YearLabel")
37.	yearDim$id <- seq.int(nrow(yearDim))
38.	write.csv(yearDim,'yearDim.csv',row.names = FALSE)

39.	##########################################################################
40.	###################### Create maxplayers Dimention #######################
41.	##########################################################################

42.	maxplayersDim<-as.data.frame(unique(BoardGames$details.maxplayers))
43.	names(maxplayersDim)<-paste("maxplayersLabel")
44.	maxplayersDim$id <- seq.int(nrow(maxplayersDim))
45.	write.csv(maxplayersDim,'maxplayersDim.csv',row.names = FALSE)

46.	##########################################################################
47.	###################### Create minage Dimention ###########################
48.	##########################################################################

49.	minageDim<-as.data.frame(unique(BoardGames$details.minage))
50.	names(minageDim)<-paste("minageLabel")
51.	minageDim$id<- seq.int(nrow(minageDim))
52.	write.csv(minageDim,'minageDim.csv',row.names = FALSE)

53.	##########################################################################
54.	###################### Create minplayers Dimention #######################
55.	##########################################################################

56.	minplayersDim<-as.data.frame(unique(BoardGames$details.minplayers))
57.	names(minplayersDim)<-paste("minplayersLabel")
58.	minplayersDim$id <- seq.int(nrow(minplayersDim))
59.	write.csv(minplayersDim,'minplayersDim.csv',row.names = FALSE)
```

Creating the bridge tables for categories and mechanic:
```
1.	bridge_categories$attributes.boardgamecategory<- categoryDim$CategoryID[match(bridge_categories$attributes.boardgamecategory,categoryDim$CategoryLabel)]
2.	colnames(bridge_categories)[2]<-"categoryID"
3.	write.csv(bridge_categories,'bridge_categories.csv',row.names = FALSE)

4.	bridge_mechanic$attributes.boardgamemechanic <- mechanicDim$MechanicID[match(bridge_mechanic$attributes.boardgamemechanic,mechanicDim$MechanicLabel)]
5.	colnames(bridge_mechanic)[2]<-"mechanicID"
6.	write.csv(bridge_mechanic,'bridge_mechanic.csv',row.names = FALSE)
```

Finally, creating the fact table:

```
1.	 BoardGames$details.maxplayers<- maxplayersDim$id[match(BoardGames$details.maxplayers,maxplayersDim$maxplayersLabel)]
2.	BoardGames$details.yearpublished<- yearDim$id[match(BoardGames$details.yearpublished,yearDim$YearLabel)]
3.	BoardGames$details.minage<- minageDim$id[match(BoardGames$details.minage,minageDim$minageLabel)]
4.	BoardGames$details.minplayers<- minplayersDim$id[match(BoardGames$details.minplayers,minplayersDim$minplayersLabel)]

5.	write.csv(BoardGames,'fact_table.csv',row.names = FALSE) 
```

After cleaning procedure we have a dataset with:

•	10 CSVs
o	Fact_table.csv
o	Bridge_categories.csv
o	Bridge_mechanic.scv
o	MechanicDim.csv
o	CategoriesDim.csv
o	maxplayersDim.csv
o	minplayersDim.csv
o	minageDim.csv 
o	nameDim.csv
o	yearDim.csv
•	21.371 rows & 18 columns
•	Total size 2.6 MB

### Load Dataset to SQL Server
In this step firstly we create the database DATADB2 in Microsoft SQL Server.

We run the following code:

```
1.	#DB connection            
2.	dbhandle <- odbcDriverConnect('driver={SQL Server};server=.;database=dmbiDB;trusted_connection=true')
3.	
4.	
5.	#Bulk insert Fact table
6.	sqlSave(dbhandle, BoardGames, tablename = "fact")
7.	
8.	#Insert Dimentions
9.	sqlSave(dbhandle, nameDim, tablename = "nameDim")
10.	sqlSave(dbhandle, maxplayersDim, tablename = "maxplayersDim")
11.	sqlSave(dbhandle, yearDim, tablename = "yearDim")
12.	sqlSave(dbhandle, minageDim, tablename = "minageDim")
13.	sqlSave(dbhandle, minplayersDim, tablename = "minplayersDim")
14.	
15.	#Insert category and mechanic tables
16.	sqlSave(dbhandle, categoryDim, tablename = "categoryDim")
17.	sqlSave(dbhandle, mechanicDim, tablename = "mechanicDim")
18.	
19.	#Insert bridge tables
20.	sqlSave(dbhandle, bridge_categories, tablename = "bridge_categories")
21.	sqlSave(dbhandle, bridge_mechanic, tablename = "bridge_mechanic")  

```
### Star Schema
In this step we have to create table relationships. We have attached the database Schema in the directory.

## Statistical Analysis

### SPSS

In SPSS Statistics, we used fifteen (15) variables: 1) “stats.average”, which is the average score for every game, 2) “stats.wishing”, the users who wish to get the game, 3) “details.minplayers”, the minimum players to play the game, 4)  “details.maxplaytime”, the maximum playing time, 5) “details.minage” the minimum age to play the game, 6) “details.maxplayers” the maximum players to play the game, 7) “attributes.total” the tags description for the game, 8) “stats.averageweight” the average difficulty of the game, 9) “stats.trading”, the users who want to trade the game, 10) “details.minplaytime”, the minimum playing time, 11) “stats.numweights”, the number of users who give the difficulty value, 12) “stats.owned”, the number of users who own the game , 13) “stats.wanting”, the number of users who want the game, 14) “stats.numcomments”, the number of users who comment about the game, 15) “stats.usersrated”, the number of users who rated the game.

### Correlations

Correlations tell you what columns are closely related to the column you are interested in. The closer to 0 the correlation, the weaker the connection. The closer to 1, the stronger the positive correlation, and the closer to -1, the stronger the negative correlation.
As we see above a couple of columns show higher values of correlating with our average_rating column. The average_weight column seems to be correlated with our average_rating column implying the more "weight" a game has the more highly it tends to be rated. Weight is a subjective measure that is made up by BoardGameGeek. It describes how "deep" or involved a game is.
We can also note that games for older players, where minage is high, tend to have higher average rating. The yearpublished correlation values tell us that newer games tend to have a higher rating.


### Visualizations in Tableau

![alt text](https://github.com/ggeop/Board-Game-Analysis/blob/master/Visualizations/Capture.PNG)

![alt text](https://github.com/ggeop/Board-Game-Analysis/blob/master/Visualizations/Capture2.PNG)

![alt text](https://github.com/ggeop/Board-Game-Analysis/blob/master/Visualizations/Capture3.PNG)

![alt text](https://github.com/ggeop/Board-Game-Analysis/blob/master/Visualizations/Capture4.PNG)

![alt text](https://github.com/ggeop/Board-Game-Analysis/blob/master/Visualizations/Capture5.PNG)

![alt text](https://github.com/ggeop/Board-Game-Analysis/blob/master/Visualizations/Capture6.PNG)

![alt text](https://github.com/ggeop/Board-Game-Analysis/blob/master/Visualizations/Capture7.PNG)

![alt text](https://github.com/ggeop/Board-Game-Analysis/blob/master/Visualizations/Capture8.PNG)

![alt text](https://github.com/ggeop/Board-Game-Analysis/blob/master/Visualizations/Capture9.PNG)
