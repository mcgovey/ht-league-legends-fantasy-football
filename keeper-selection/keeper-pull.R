install.packages('XML')
install.packages('RCurl')
install.packages('rlist')

library(XML)
library(RCurl)
library(rlist)

library(tidyverse)
library(stringr)

# theurl <- getURL("https://en.wikipedia.org/wiki/Brazil_national_football_team",.opts = list(ssl.verifypeer = FALSE) )
# tables <- readHTMLTable(theurl)
# tables <- list.clean(tables, fun = is.null, recursive = FALSE)
# n.rows <- unlist(lapply(tables, function(t) dim(t)[1]))
# 
# tables[[which.max(n.rows)]]

datalist = list()

# beginning of dynamic rerun
i <- 12
for(i in 1:12){
dynamicURL <- paste("http://games.espn.com/ffl/clubhouse?leagueId=481107&teamId=",i,"&seasonId=2016", sep="")

theurl <- getURL(dynamicURL,.opts = list(ssl.verifypeer = FALSE) )
tables <- readHTMLTable(theurl)
tables <- list.clean(tables, fun = is.null, recursive = FALSE)
n.rows <- unlist(lapply(tables, function(t) dim(t)[1]))

myRoster <- tables[[which.max(n.rows)]]

myRoster <- myRoster[complete.cases(myRoster),]

myRoster_split <- str_split_fixed(myRoster$V2, ", ", 2)
myRoster$Player <- toupper(myRoster_split[,1])
myRoster$Pos <- myRoster_split[,2]
myRoster$teamId <- i;
myRoster <- myRoster[myRoster$V1!='SLOT',]

datalist[[i]] <- myRoster
}
#end of dynamic rerun

prevYearRosters = do.call(rbind, datalist)

draftPicks <- read.table('data/DraftPicks.csv',header = TRUE, sep=',', quote="\"")
draftPicks$PlayerUpper <- toupper(draftPicks$Player)

keptPicks <- read.table('data/2016Keepers.csv', header=TRUE, sep=',', quote="\"")
keptPicks$PlayerUpper <- toupper(keptPicks$Player)

myRoster_Joined <- left_join(prevYearRosters, draftPicks, by = c("Player" = "PlayerUpper"))
myRoster_Joined <- left_join(myRoster_Joined, keptPicks, by = c("Player" = "PlayerUpper"))


leagueMembers <- data.frame(1:12, c("McGov", "Burns", "Hutch", "AJ", "Krowl", "Danktron", "Pete", "Ellery", "Joe", "Keef", "Flemdog", "Whit"))
colnames(leagueMembers) <- c("id", "Member")

myRoster_Joined <- left_join(myRoster_Joined, leagueMembers, by = c("teamId" = "id"))

myRosterClean <- myRoster_Joined[,c(2,14,19,20,26,27)]

write_csv(myRosterClean, 'data/2016EndingRosters.csv')
