library(data.table)
library(glue)

boundaries <- rjson::fromJSON(
  file='../data/football_borders_geo.json')

geodat <- fread('../data/first_football_match_with_geo.csv')

# Drop the second occurances for some teams
geodat <- geodat[, .SD[which.min(ko_year)], by=team_name]

gms <- geodat[, 
  .(geounit=unlist(tstrsplit(geounits, ",", fixed=TRUE))), 
  by=setdiff(colnames(geodat), 'geounits')
]

# Remove Russia, Lithuania, Latvia and Estonia from USSR and Czech Rep from Czechoslovakia
# A little confusing but that's the way it's going to be
gms <- gms[!(team_name=='Czechoslovakia' & geounit=='CZE'),]
gms <- gms[!(team_name=='USSR' & geounit %in% c('RUS', 'EST', 'LVA', 'LTU')),]

setorder(gms, ko_year)
gms[, end_year := shift(ko_year, type='lead', fill=2021) ,by=geounit]

# Handle end dates for breakup of multi-nation states
# Set the end date for teams of USSR that have not played since to be first game for Russia
USSR_breakup <- 1991
gms[team_name == 'USSR', end_year := min(USSR_breakup, end_year), by=geounit]

# Set Yugoslavian end date to '91 breakup of Yugoslavia for everyone except Serbia & Montenegro and Kosovo
yugoslav_breakup1 <- 1991
ex_yugoslavs <- c("BIH", "HRV", "MKD", "SVN")
gms[team_name == 'Yugoslavia' & geounit %in% ex_yugoslavs, end_year := min(yugoslav_breakup1, end_year), by=geounit]
ex_yugoslavs2 <- c("MNE", "SRB")
yugoslav_breakup2 <- 2006
gms[team_name == 'Yugoslavia' & geounit %in% ex_yugoslavs2, end_year := min(yugoslav_breakup2, end_year), by=geounit]
kosovo_ind <- 2008
gms[team_name == 'Yugoslavia' & geounit == "KOS", end_year := min(kosovo_ind, end_year), by=geounit]

# Set the end date for Czechoslovakia to 1 Jan 93 - dissolution of the state
end_czslo <- 1993
gms[team_name == 'Czechoslovakia', end_year := min(end_czslo, end_year), by=geounit]


# Get the end and start years
gms[, year := ko_year]

# Create all year/geounit combinations as a data.table
all_years <- seq(1870, 2020)
all_geos <- as.data.table(transpose(
  lapply(boundaries$features, function(x){ 
    c(x$properties$GU_A3, x$properties$GEOUNIT, x$properties$SOVEREIGNT) 
  })
))
setnames(all_geos, c('V1', 'V2', 'V3'), c('geounit', 'geoname', 'sovname'))
# Fix for Kazakhstan mislabelling!
all_geos[sovname=='Kazakhstan', geoname := sovname]
all_idx <- CJ(all_geos[['geounit']], all_years, unique=TRUE)
setnames(all_idx, c('V1', 'all_years'), c('geounit', 'year'))
setorder(all_idx, year)

# Set keys for all_geos and idx tables - must key of geounit THEN year
setkey(all_idx, geounit, year)
setkey(all_geos, geounit)
all_idx <- all_geos[all_idx]
setkey(all_idx, geounit, year)
# Perform a forward rolling join
# fills missing data for years after first game
setkey(gms, geounit, year)
rolld_gms <- gms[all_idx, roll=T]
# If a team stopped playing then set their values for years after that to NA
rolld_gms[end_year<year, setdiff(colnames(rolld_gms), colnames(all_idx)) := NA]
rolld_gms[,statename := ifelse(geoname==sovname, geoname, glue_data(.SD, '{geoname} ({sovname})'))]
rolld_gms[, years_played := year-ko_year]
# Create scaled values for length of time played to be used for colouring
# Then set NA (not played) to -1
rolld_gms[, colorscale := scales::rescale(years_played)]
rolld_gms[is.na(colorscale), colorscale := -1]

fwrite(rolld_gms, '../data/first_football_match_plot_data.csv')
