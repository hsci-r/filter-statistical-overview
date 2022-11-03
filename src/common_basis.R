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

p <- function(number) {
  return(format(number, scientific = FALSE, big.mark = ","))
}
pp <- function(percentage, accuracy = 0.01) {
  return(scales::percent(percentage, accuracy = accuracy))
}
is_html_output <- function() {
  is.null(knitr::pandoc_to()) || (!str_detect(knitr::pandoc_to(), "^gfm") && knitr::is_html_output())
}

while (!exists("con")) {
  tryCatch(con <- dbConnect(
    drv = MariaDB(),
    host = "vm3634.kaj.pouta.csc.fi",
    dbname = "filter_statistical_overview",
    user = if (Sys.getenv("DB_USER")!="") Sys.getenv("DB_USER") else key_get("filter_overview","DB_USER"),
    password = if (Sys.getenv("DB_PASS")!="") Sys.getenv("DB_PASS") else key_get("filter_overview","DB_PASS"),
    bigint = "integer",
    timeout = Inf,
    load_data_local_infile = TRUE,
    autocommit = TRUE,
    reconnect = TRUE
  ), error = function(e) {
    print(e)
    key_set("filter_overview","DB_USER", prompt="DB username: ")
    key_set("filter_overview","DB_PASS", prompt="DB password: ")
  })
}

poems <- tbl(con,dbplyr::in_schema("filter","poems"))
poem_stats <- tbl(con,dbplyr::in_schema("filter","poem_stats"))
p_year <- tbl(con,dbplyr::in_schema("filter","p_year"))
verses <- tbl(con,dbplyr::in_schema("filter","verses"))
verses_cl <- tbl(con,dbplyr::in_schema("filter","verses_cl"))
verse_poem <- tbl(con,dbplyr::in_schema("filter","verse_poem"))
collectors <- tbl(con,dbplyr::in_schema("filter","collectors"))
p_col <- tbl(con,dbplyr::in_schema("filter","p_col"))
locations <- tbl(con,dbplyr::in_schema("filter","locations"))
p_loc <- tbl(con,dbplyr::in_schema("filter","p_loc"))
themes <- tbl(con,dbplyr::in_schema("filter","themes"))
poem_theme <- tbl(con,dbplyr::in_schema("filter","poem_theme"))
refs <- tbl(con,dbplyr::in_schema("filter","refs"))
raw_meta <- tbl(con,dbplyr::in_schema("filter","raw_meta"))

words <- tbl(con,dbplyr::in_schema("filter","words"))
word_freq <- tbl(con,dbplyr::in_schema("filter","word_freq"))
word_occ <- tbl(con,dbplyr::in_schema("filter","word_occ"))

polygons <- st_read(con, query='SELECT name, ST_AsBinary(geometry) AS geometry FROM filter.polygons', geometry_column='geometry')
st_crs(polygons) <- 'urn:ogc:def:crs:EPSG::3857'
