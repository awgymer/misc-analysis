library(data.table)
library(ggplot2)
library(ggrepel)
source('../../custom_themes.R')

driver_colors <- data.table(
  name=c(
  'L. Hamilton', 'M. Schumacher', 'S. Vettel', 'F. Alonso', 'N. Rosberg', 'K. Räikkönen', 'D. Hill', 'J. Fangio',
  'J. Clark', 'M. Häkkinen', 'J. Stewart', 'N. Mansell', 'A. Prost', 'N. Piquet', 'A. Senna', 'N. Lauda'
  ),
  color=c(
    '#00D2BE', '#C00000', '#0600EF', '#E5C200', '#00D2BE', '#C00000', '#194BB0', '#960000',
    '#004225', '#AAA9AD', '#16345D', '#194BB0', '#C60000', '#194BB0', '#009C3B', '#C00000'
    )
)


dat <- fread('data/20_plus_wins.csv')
dat[,win:=position==1]
dat[is.na(win), win:=F]
setorder(dat, name, year, round)
dat[, wins:=cumsum(win), by=name]
dat[, races:=1:.N, by=name]

dat[driver_colors, col:=i.color, on='name']
dat[is.na(col), col:='#ABABAB']

ggplot(dat[,.SD[which.max(races)],by=name], aes(x=races, y=wins, group=name)) +
  geom_line(data=dat[name %in% c('M. Schumacher', 'L. Hamilton', 'S. Vettel')], aes(colour=col)) +
  geom_line(data=dat[!(name %in% c('M. Schumacher', 'L. Hamilton', 'S. Vettel'))], aes(colour=col), alpha=0.6) +
  geom_point(aes(colour=col)) +
  geom_label_repel(
    aes(label=name, colour=col),
    family = 'Formula1 Display-Regular',
    hjust=0, force=1,
    direction='y',
    min.segment.length = 0.1,
    size = 2
  ) +
  labs(
    title = 'F1 Wins by Career Races',
    subtitle = 'Min. 20 career wins',
    x = 'Career Race No.', y = 'Wins',
    caption = 'Chart: @awgymer | Data: ergast.com'
  ) +
  scale_colour_identity() +
  theme_F1
