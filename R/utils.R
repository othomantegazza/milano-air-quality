library(tidyverse)
library(here)
library(tsibble)
library(lubridate)
library(ggiraph)

scale_pollutant <- 
  function(data, eu_limits, ...) {
    
    data <-
      data %>% 
      group_by(date) %>% 
      summarise(
        across(
          .cols = valore,
          .fns = ~median(., na.rm = T)
        )
      ) %>% 
      mutate(scaled = valore/eu_limits) %>% 
      ungroup() %>% 
      as_tsibble(index = 'date') %>% 
      fill_gaps() %>% 
      fill(valore, scaled, .direction = 'down') %>% 
      as_tibble()
    
    return(data)
  }

breaks_on_fortnight <- function(x,
                                n_days = 14,
                                offset = 1) {
  d <- seq.Date(from = min(x),
                to = max(x) + days(n_days - offset),
                by = n_days)
  return(d - days(n_days - offset))
}

plot_pollutant <- function(data,
                           eu_limits,
                           pollutant_name,
                           ...) {
  p <- 
    data %>%  
    group_by(date) %>% 
    mutate(
      tooltip = glue(
        '{unique(date) %>% format("%B %d, %Y")}\n',
        'Mean Value: {mean(valore, na.rm = T)} µg/m3'
      )
    ) %>% 
    ungroup() %>% 
    ggplot(
      aes(
        x = date,
        y = valore,
      )
    ) +
    geom_hline(yintercept = 0) +
    geom_hline_interactive(yintercept = eu_limits,
                           colour = mid_light,
                           linewidth = medium_line, 
                           tooltip = glue::glue('EU Limits: {eu_limits} µg/m3'),
                           lty = '31',
                           data_id = 1)  +
    geom_smooth(size = medium_line,
                colour = '#00000000',
                method = 'loess',
                span = loess_span) +
    geom_point_interactive(
      aes(tooltip = tooltip,
          data_id = date,
          colour = after_stat(y)
          ),
      size = 1,
      alpha = .8,
      hover_nearest = T) +
    scale_colour_gradient2(
      low = def_colour,
      mid = mid_colour,
      high = limits_colour,
      midpoint = eu_limits,
      limits = c(0, NA)
    ) +
    scale_x_date(
      breaks = breaks_on_fortnight,
      minor_breaks = NULL,
      expand = expansion(mult = c(.01, .02)),
      date_labels = '%b %d'
    ) +
    guides(colour = 'none') +
    labs(x = '',
         y = 'Concentration [µg/m3]')
  
  g <- 
    girafe(
      ggobj = p,
      height_svg = height_svg,
      pointsize = pointsize,
      options = list(
        opts_hover(
          css = glue("fill:{hover_colour};",
                     "stroke:black;",
                     "r:5px;")
        )
      )
    )
  
  return(g)
}

plot_heat <- function(air_q_scaled) {
  
  p_heat <- 
    air_q_scaled %>% 
    mutate(tooltip = glue('{inquinante}	→ {(scaled*100) %>% round(1)}%')) %>% 
    arrange(desc(inquinante)) %>% 
    # mutate(inquinante = as_factor(inquinante)) %>% 
    group_by(date) %>% 
    mutate(
      tooltip = glue_collapse(tooltip, sep = '\n') %>%
        {glue('{date %>% format("%B %d, %Y")}\n',
              'Percent of EU target limits:\n',
              '{.}')}
    ) %>% 
    ungroup() %>% 
    ggplot() +
    aes(
      x = date,
      y = inquinante, 
      fill = scaled,
      colour = after_stat(fill)
    ) +
    geom_tile_interactive(
      aes(tooltip = tooltip,
          data_id = date), 
      size = 0
    ) +
    # https://stackoverflow.com/questions/11299705/
    scale_fill_gradientn_interactive(
      colors = c(bkg_colour, mid_colour, limits_colour),
      values = scales::rescale(c(0, 1, max(air_q_scaled$scaled, na.rm = T))),
      limits = c(0, NA)
    ) +
    scale_colour_gradientn_interactive(
      colors = c(bkg_colour, mid_colour, limits_colour),
      values = scales::rescale(c(0, 1, max(air_q_scaled$scaled, na.rm = T))),
      limits = c(0, NA)
    ) +
    scale_x_date(
      breaks = ~breaks_on_fortnight(., offset = 2),
      minor_breaks = NULL,
      expand = expansion(mult = c(.01, .02)),
      date_labels = '%b %d'
    ) +
    guides(fill = 'none',
           colour = 'none') +
    labs(x = '',
         y = '') +
    theme(panel.grid = element_blank())
  
  
  g <- girafe(
    ggobj = p_heat,
    height_svg = height_svg,
    pointsize = pointsize,
    options = list(
      opts_hover(
        css = glue("fill:{hover_colour};",
                   "stroke:{hover_colour};")
      )
    )
  )
  
  return(g)
}
