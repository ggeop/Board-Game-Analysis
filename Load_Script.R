library(RODBC)

#DB connection            
dbhandle <- odbcDriverConnect('driver={SQL Server};server=.;database=dmbiDB;trusted_connection=true')


#Bulk insert Fact table
sqlSave(dbhandle, BoardGames, tablename = "fact")

#Insert Dimentions
sqlSave(dbhandle, nameDim, tablename = "nameDim")
sqlSave(dbhandle, maxplayersDim, tablename = "maxplayersDim")
sqlSave(dbhandle, yearDim, tablename = "yearDim")
sqlSave(dbhandle, minageDim, tablename = "minageDim")
sqlSave(dbhandle, minplayersDim, tablename = "minplayersDim")

#Insert category and mechanic tables
sqlSave(dbhandle, categoryDim, tablename = "categoryDim")
sqlSave(dbhandle, mechanicDim, tablename = "mechanicDim")

#Insert bridge tables
sqlSave(dbhandle, bridge_categories, tablename = "bridge_categories")
sqlSave(dbhandle, bridge_mechanic, tablename = "bridge_mechanic")




