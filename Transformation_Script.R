###########################################################################################################
################################################ Libraries ################################################
###########################################################################################################

library(readr)
library(tidyr)

###########################################################################################################
############################################ Import First CSV #############################################
###########################################################################################################

BoardGames <- read_csv("C:/Users/georg/Desktop/board-games-dataset/InitialData/BoardGames.csv",
                       col_types = cols(attributes.boardgameartist = col_skip(), 
                                        attributes.boardgamecompilation = col_skip(), 
                                        attributes.boardgamedesigner = col_skip(), 
                                        attributes.boardgamefamily = col_skip(), 
                                        attributes.boardgameimplementation = col_skip(), 
                                        attributes.boardgameintegration = col_skip(), 
                                        attributes.boardgamepublisher = col_skip(), 
                                        details.description = col_skip(), 
                                        details.image = col_skip(), details.thumbnail = col_skip(), 
                                        game.id = col_skip(), stats.bayesaverage = col_skip(), 
                                        stats.family.abstracts.bayesaverage = col_skip(), 
                                        stats.family.abstracts.pos = col_skip(), 
                                        stats.family.cgs.bayesaverage = col_skip(), 
                                        stats.family.cgs.pos = col_skip(), 
                                        stats.family.childrensgames.bayesaverage = col_skip(), 
                                        stats.family.childrensgames.pos = col_skip(), 
                                        stats.family.familygames.bayesaverage = col_skip(), 
                                        stats.family.familygames.pos = col_skip(), 
                                        stats.family.partygames.bayesaverage = col_skip(), 
                                        stats.family.partygames.pos = col_skip(), 
                                        stats.family.strategygames.bayesaverage = col_skip(), 
                                        stats.family.strategygames.pos = col_skip(), 
                                        stats.family.thematic.bayesaverage = col_skip(), 
                                        stats.family.thematic.pos = col_skip(), 
                                        stats.family.wargames.bayesaverage = col_skip(), 
                                        stats.family.wargames.pos = col_skip(), 
                                        stats.median = col_skip(), stats.stddev = col_skip(),
                                        attributes.boardgameexpansion = col_skip(),
                                        polls.suggested_numplayers.1 = col_skip(),
                                        polls.suggested_numplayers.2 = col_skip(),
                                        polls.suggested_numplayers.3 = col_skip(),
                                        polls.suggested_numplayers.4 = col_skip(),
                                        polls.suggested_numplayers.5 = col_skip(),
                                        polls.suggested_numplayers.6 = col_skip(),
                                        polls.suggested_numplayers.7 = col_skip(),
                                        polls.suggested_numplayers.8 = col_skip(),
                                        polls.suggested_numplayers.9 = col_skip(),
                                        polls.suggested_numplayers.10 = col_skip(),
                                        stats.family.amiga.bayesaverage = col_skip(),
                                        stats.family.amiga.pos = col_skip(),
                                        stats.family.arcade.pos = col_skip(),
                                        stats.family.atarist.pos = col_skip(),
                                        stats.family.commodore64.pos = col_skip(),
                                        stats.subtype.rpgitem.pos = col_skip(),
                                        stats.subtype.videogame.pos = col_skip(),
                                        stats.family.arcade.bayesaverage = col_skip(),
                                        stats.family.atarist.bayesaverage = col_skip(),
                                        stats.family.commodore64.bayesaverage = col_skip(),
                                        stats.subtype.rpgitem.bayesaverage = col_skip(),
                                        stats.subtype.videogame.bayesaverage = col_skip(),
                                        attributes.t.links.concat.2....= col_skip(),
                                        stats.bayesaverage= col_skip(),
                                        stats.subtype.boardgame.bayesaverage= col_skip(),
                                        stats.subtype.boardgame.pos= col_skip(),
                                        polls.language_dependence= col_skip(),
                                        polls.suggested_numplayers.Over= col_skip(),
                                        polls.suggested_playerage= col_skip()
                                        
                                                                       
                                        ))


###########################################################################################################################
################################################### Cleaning Procedure ####################################################
###########################################################################################################################

#########################################################################
########### We divide the Boardgames with their Expansions ##############
#########################################################################

BoardGames<-BoardGames[BoardGames$game.type=="boardgame",]
BoardGames<-BoardGames[,-c(1)]

#NOTE: THERE ARE 2 TYPE OF GAMES THE BOARDGAMES AND THE EXPANSIONS OF THEM. 
#THE EXPANSIONS ARE THE SAME GAMES WITH FEW EXTRA FEATURES

#########################################################################
########### Remove dublicate game records & Add limits ##################
#########################################################################

##### Delete Dublications in Board games
BoardGames<-BoardGames[!duplicated(BoardGames$details.name),]

##### Date limitsPublish year limits
BoardGames<-BoardGames[2017>BoardGames$details.yearpublished & BoardGames$details.yearpublished>1980,]

##### Date limits
BoardGames<-BoardGames[100>BoardGames$details.minage & BoardGames$details.minage>0,]

##### Rating limints according to the site
BoardGames<-BoardGames[BoardGames$stats.average>0 & BoardGames$stats.average<=10,]

##### Difficulty limits according to the site
BoardGames<-BoardGames[BoardGames$stats.averageweight>0 & BoardGames$stats.averageweight<=5,]

##### Number of Players limits
BoardGames<-BoardGames[100>BoardGames$details.maxplayers & BoardGames$details.maxplayers>0,]
BoardGames<-BoardGames[!is.na(BoardGames$details.maxplayers),] #Remove NULL values

BoardGames<-BoardGames[100>BoardGames$details.minplayers & BoardGames$details.minplayers>0,]
BoardGames<-BoardGames[!is.na(BoardGames$details.minplayers),] #Remove NULL values

##### Filter the attribute counts
BoardGames<-BoardGames[BoardGames$attributes.total>0,]

##### Removing characters from dataset
BoardGames<-BoardGames[!grepl('<',BoardGames$details.name),]
BoardGames<-BoardGames[!grepl('>',BoardGames$details.name),]

###########################################################################################################################
############################################# Create Dimentions Tables ################################################
###########################################################################################################################


##########################################################################
###################### Create Name Dimention #############################
##########################################################################

nameDim<-as.data.frame(unique(BoardGames$details.name))
names(nameDim)<-paste("NameLabel")
nameDim$id <- seq.int(nrow(nameDim))
write.csv(nameDim,'nameDim.csv',row.names = FALSE)

#### Replace the details.name with id
BoardGames$details.name<- nameDim$id[match(BoardGames$details.name,nameDim$NameLabel)]

#### Convert details.name into id
colnames(BoardGames)[6]<-"id"

##### Separate the multivalues in different rows (by categories)
bridge_categories<-subset(BoardGames,select=c(id,attributes.boardgamecategory))
bridge_categories<-separate_rows(bridge_categories,attributes.boardgamecategory,convert = TRUE, sep = ",")

##### Separate the multivalues in different rows (by mechanic)
bridge_mechanic<-subset(BoardGames,select=c(id,attributes.boardgamemechanic))
bridge_mechanic<-separate_rows(bridge_mechanic,attributes.boardgamemechanic,convert = TRUE, sep = ",")

##########################################################################
###################### Create Category Dimention #########################
##########################################################################

categoryDim<-as.data.frame(unique(bridge_categories$attributes.boardgamecategory))
names(categoryDim)<-paste("CategoryLabel")
categoryDim$CategoryID <- seq.int(nrow(categoryDim))
write.csv(categoryDim,'categoryDim.csv',row.names = FALSE)

##########################################################################
###################### Create mechanic Dimention #########################
##########################################################################

mechanicDim<-as.data.frame(unique(bridge_mechanic$attributes.boardgamemechanic))
names(mechanicDim)<-paste("MechanicLabel")
mechanicDim$MechanicID <- seq.int(nrow(mechanicDim))
write.csv(mechanicDim,'mechanicDim.csv',row.names = FALSE)

##########################################################################
###################### Create yearpublished Dimention ####################
##########################################################################

yearDim<-as.data.frame(unique(BoardGames$details.yearpublished))
names(yearDim)<-paste("YearLabel")
yearDim$id <- seq.int(nrow(yearDim))
write.csv(yearDim,'yearDim.csv',row.names = FALSE)

##########################################################################
###################### Create maxplayers Dimention #######################
##########################################################################

maxplayersDim<-as.data.frame(unique(BoardGames$details.maxplayers))
names(maxplayersDim)<-paste("maxplayersLabel")
maxplayersDim$id <- seq.int(nrow(maxplayersDim))
write.csv(maxplayersDim,'maxplayersDim.csv',row.names = FALSE)

##########################################################################
###################### Create minage Dimention ###########################
##########################################################################

minageDim<-as.data.frame(unique(BoardGames$details.minage))
names(minageDim)<-paste("minageLabel")
minageDim$id<- seq.int(nrow(minageDim))
write.csv(minageDim,'minageDim.csv',row.names = FALSE)

##########################################################################
###################### Create minplayers Dimention #######################
##########################################################################

minplayersDim<-as.data.frame(unique(BoardGames$details.minplayers))
names(minplayersDim)<-paste("minplayersLabel")
minplayersDim$id <- seq.int(nrow(minplayersDim))
write.csv(minplayersDim,'minplayersDim.csv',row.names = FALSE)

###########################################################################################################################
############################################# Finalize the Bridge Tables ################################################
###########################################################################################################################

bridge_categories$attributes.boardgamecategory<- categoryDim$CategoryID[match(bridge_categories$attributes.boardgamecategory,categoryDim$CategoryLabel)]
colnames(bridge_categories)[2]<-"categoryID"
write.csv(bridge_categories,'bridge_categories.csv',row.names = FALSE)


bridge_mechanic$attributes.boardgamemechanic <- mechanicDim$MechanicID[match(bridge_mechanic$attributes.boardgamemechanic,mechanicDim$MechanicLabel)]
colnames(bridge_mechanic)[2]<-"mechanicID"
write.csv(bridge_mechanic,'bridge_mechanic.csv',row.names = FALSE)

###########################################################################################################################
############################################# Remove columns category and mechanics ################################################
###########################################################################################################################

BoardGames$attributes.boardgamecategory<-NULL
BoardGames$attributes.boardgamemechanic<-NULL

###########################################################################################################################
################################################### Create Fact table #####################################################
###########################################################################################################################

BoardGames$details.maxplayers<- maxplayersDim$id[match(BoardGames$details.maxplayers,maxplayersDim$maxplayersLabel)]
BoardGames$details.yearpublished<- yearDim$id[match(BoardGames$details.yearpublished,yearDim$YearLabel)]
BoardGames$details.minage<- minageDim$id[match(BoardGames$details.minage,minageDim$minageLabel)]
BoardGames$details.minplayers<- minplayersDim$id[match(BoardGames$details.minplayers,minplayersDim$minplayersLabel)]

#fact<-na.omit(BoardGames)
write.csv(BoardGames,'fact_table.csv',row.names = FALSE)

