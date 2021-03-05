library(DBI)
library(ggplot2)
library(data.table)
source('../r-code/custom_themes.R')
# Connect to the default postgres database
con <- dbConnect(RPostgres::Postgres(), dbname='f1db')

years <- 2000:2020

laps_query <- glue::glue_sql("SELECT 
	CONCAT(d.forename, ' ', d.surname) as driver_name,
	s.number,
	l.milliseconds, l.lap, l.position, 
	CASE WHEN s.laps = l.lap 
		THEN TRUE 
		ElSE FALSE
	END as final,
	r.name as race_name,
	r.date as race_date,
	c.name as constructor,
	r.year as season
FROM lap_times l 
JOIN drivers d 
	ON l.driver_id = d.driver_id
JOIN results s ON 
	l.driver_id = s.driver_id AND
	l.race_id = s.race_id
JOIN constructors c ON
	s.constructor_id = c.constructor_id
JOIN races r ON
	l.race_id = r.race_id
WHERE l.position = 1 AND r.year IN ({years*})
ORDER BY r.year, l.race_id, l.lap;")

dat <- setDT(dbGetQuery(con, laps_query))


waffleize <- function(data, rows=NULL){
  if (is.null(rows)){
    rows <-  round(sqrt(nrow(data)))
  }
  grid_data <- expand.grid(waffle_y=1:rows, waffle_x=seq_len(ceiling(nrow(data) / rows)))
  return(grid_data[1:nrow(data),])
}

dat[, race_sort := factor(paste(season, race_name), levels=dat[,paste(season, race_name), by='race_date,season,race_name'][,V1])]

dat[, c('waffle_x', 'waffle_y') := waffleize(dat)]

teamcols <- fread('data/color_codes_no_season.csv')
teamcols[, colorkey := factor(paste0(sort(.SD[,team]), collapse='/')) , by=.(fill, outline)]
colormap <- unique(teamcols[,.(colorkey, fill, outline)])
dat[teamcols, colorkey := i.colorkey, on=.(constructor=team)]

lap_waffles <- function(data){
  ggplot(data, aes(x=race_sort, y=lap, fill=colorkey, colour=colorkey)) +
    geom_tile(size=0.1, height=0.6, width=0.6) +  
    scale_colour_manual(
      name='colorkey',
      values=colormap[,outline],
      breaks=colormap[,colorkey],
      drop=F
    ) +
    scale_fill_manual(
      name='colorkey',
      values=colormap[,fill],
      breaks=colormap[,colorkey],
      drop=F
    ) +
    guides(color = guide_legend(title=element_blank(), nrow=2, override.aes = list(size=1)), fill = guide_legend(title=element_blank(), nrow=2)) +
    scale_y_continuous(expand=expansion(0,1)) +
    facet_grid(~season, switch = 'x', space='free', scales='free_x') +
    theme_F1() +
    theme(
      panel.grid.major = element_blank(),
      panel.border = element_blank(),
      panel.spacing.x = unit(0.5, 'lines'),
      axis.title = element_blank(),
      axis.ticks = element_blank(),
      axis.text = element_blank(),
      axis.line.y = element_blank(),
      axis.line.x = element_line(colour = 'black'),
      legend.position = "bottom",
      legend.box.margin = margin(b=1, unit='lines'),
      legend.key.size = unit(1, "lines"),
      strip.placement = 'outside'
    )
}

dat[,row_n:=.GRP, by=cut(season, breaks=c(1999, 2006, 2013, 2020))]

plts <- list()
for (n in unique(dat[,row_n])){
  plts[[n]] <- lap_waffles(dat[row_n == n,]) + theme(legend.position = 'none')
}

plts[[1]] <- plts[[1]] + labs(
  title = 'Lap Leading Constructor 2000-2020',
  subtitle = '1 column per race | Races in order | Laps in order from bottom to top'
)
int_plot <- plot_grid(plotlist = plts, ncol = 1)
shared_legend <- get_legend(lap_waffles(dat))

multi_plt <- ggpubr::ggarrange(plotlist=plts, nrow=3, common.legend = T, legend = "bottom")

final_plt <- ggpubr::annotate_figure(
  multi_plt,
  bottom = ggpubr::text_grob(
    "Chart: @awgymer | Data:Ergast Developer API", color = "black",
     hjust = 1, x = 0.98, family = 'Formula1 Display-Regular', size = 10
  )
) + ggpubr::bgcolor('grey98') + ggpubr::border(size=0)

ggsave('./plots/lap_waffles.png', final_plt, width=14.5, height=9.75, dpi = 1200)

plot_ly(dat[season==2000,]) %>% 
  add_trace(
    type='heatmap',
    x=~race_sort, 
    y=~lap, 
    z=as.numeric(~constructor),
    colorscale =  
  )
