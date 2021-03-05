library(ggplot2)
library(ggthemes)

F1_FONT = 'Formula1 Display-Regular'
F1_FONT_BOLD = 'Formula1 Display-Bold'

theme_F1 <-  function(base_size = 12, base_family = F1_FONT) {
  theme_foundation(base_size = base_size, base_family = base_family) +
  theme(
    line = element_line(lineend = 'round', color='black'),
    text = element_text(color='black'),
    plot.background = element_rect(fill = 'grey98', color = 'transparent'),
    panel.background = element_rect(fill = 'grey98', color = 'transparent'),
    axis.line = element_line(color = 'black'),
    axis.ticks = element_line(color = 'black', size = 0.5),
    axis.ticks.length = unit(2.75, 'pt'),
    axis.title = element_text(size = rel(1)),
    axis.text = element_text(size = rel(0.6), color = 'black'),
    plot.title = element_text(family=F1_FONT_BOLD, face='bold', size = rel(1.5), hjust = 0),
    plot.title.position = 'panel',
    plot.subtitle = element_text(size = rel(1)),
    plot.caption = element_text(size = rel(0.75)),
    panel.grid.minor = element_blank(),
    panel.grid.major = element_line(color='grey85', size = 0.3),
    panel.spacing.y = unit(0, 'lines'),
    panel.spacing.x = unit(0.1, 'lines'),
    strip.background = element_blank(),
    strip.text = element_text(size =rel(0.7), color = 'black'),
    legend.position = 'bottom',
    legend.background = element_rect(fill = 'grey95', color = 'black'),
    legend.key = element_blank(),
    legend.text = element_text(size=rel(0.7)),
    legend.title = element_text(size=rel(1.2))
  )
}
