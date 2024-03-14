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
library(glue)
library(plotly)
library(ggforce)

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

types_to_top_level_types <- tbl(con,sql("
WITH RECURSIVE type_ancestor AS (
  SELECT t_id, t_id AS ancestor_t_id FROM filter.types
  WHERE par_id = 23959
  UNION ALL
  SELECT types.t_id, ancestor_t_id
  FROM type_ancestor, filter.types
  WHERE types.par_id=type_ancestor.t_id
) 
SELECT * FROM type_ancestor
"))

polygons <- st_read(con, query="
SELECT pol_id, ST_AsBinary(geometry) AS geometry 
FROM filter.polygons 
WHERE geometry IS NOT NULL", geometry_column='geometry')
st_crs(polygons) <- 'urn:ogc:def:crs:EPSG::3067'
polygons <- st_make_valid(polygons) %>% inner_join(map_pol %>% inner_join(maps) %>% inner_join(pol_pl) %>% collect())
