library(knitr)
library(here)
library(tidyverse)
library(hscidbutil)
library(gghsci)
library(keyring)
library(gt)
library(DBI)
library(RMariaDB)
library(sf)
library(tmap)
library(ggridges)
library(ggrepel)

p <- function(number) {
  return(format(number, scientific = FALSE, big.mark = ","))
}
pp <- function(percentage, accuracy = 0.01) {
  return(scales::percent(percentage, accuracy = accuracy))
}
is_html_output <- function() {
  is.null(knitr::pandoc_to()) || (!str_detect(knitr::pandoc_to(), "^gfm") && knitr::is_html_output())
}

con <- get_connection()

register_tables(con, "filter")
register_tables(con, "filter_statistical_overview")

themes_to_top_level_themes <- tbl(con,sql("
WITH RECURSIVE theme_ancestor AS (
  SELECT t_id, t_id AS ancestor_t_id FROM filter.themes
  WHERE par_id = 23959
  UNION ALL
  SELECT themes.t_id, ancestor_t_id
  FROM theme_ancestor, filter.themes
  WHERE themes.par_id=theme_ancestor.t_id
) 
SELECT * FROM theme_ancestor
"))

polygons <- st_read(con, query='SELECT name, ST_AsBinary(geometry) AS geometry FROM filter.polygons', geometry_column='geometry')
st_crs(polygons) <- 'urn:ogc:def:crs:EPSG::3857'
