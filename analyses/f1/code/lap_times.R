library(data.table)
library(ggplot2)
library(ggridges)

teamcols <- fread('data/color_codes.csv') 

laps <- fread('data/2020_laps.csv')
laps[teamcols[season==2020,], hex:=i.hex, on=.(team_name=team)]

driver_lap_compare <- function(data, d1, d2){
  sub_data <- data[driver_name == d1,][
    data[driver_name == d2,],
    .(lap=lap,
      driver_1=driver_name, 
      driver_2=i.driver_name, 
      d1_time=milliseconds, 
      d2_time=i.milliseconds, 
      time_diff=(milliseconds-i.milliseconds)/1000,
      cum_diff=cumsum((milliseconds-i.milliseconds)/1000),
      race_name=race_name
    ),
    on='lap'
    ]
  return(sub_data)
  ggplot(sub_data, aes(x=lap, y=time_diff)) + geom_area() + scale_y_continuous(labels=abs) + theme_bw()
}

ggplot(laps[race_name=='Hungarian Grand Prix'], aes(x=milliseconds, fill=hex, y=driver_name)) + 
  geom_density_ridges() + 
  scale_fill_identity()
