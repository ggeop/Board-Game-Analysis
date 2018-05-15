#Library
require("bggAnalysis")

#Install package
install.packages("devtools")
devtools::install_github("9thcirclegames/bgg-analysis")

# Create our initial csv
data(BoardGames)
write.csv(BoardGames, 'BoardGames.csv', row.names = FALSE)