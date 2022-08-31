library(knitr)
library(here)
library(tidyverse)
library(hscidbutil)
library(gghsci)
library(keyring)
library(gt)
library(DBI)
library(RMariaDB)

p <- function(number) {
  return(format(number, scientific = FALSE, big.mark = ","))
}
pp <- function(percentage, accuracy = 0.01) {
  return(scales::percent(percentage, accuracy = accuracy))
}

while (!exists("con")) {
  tryCatch(con <- dbConnect(
    drv = MariaDB(),
    host = "vm3634.kaj.pouta.csc.fi",
    dbname = "filter_statistical_overview",
    user = if (Sys.getenv("DB_USER")!="") Sys.getenv("DB_USER") else key_get("filter_overview","DB_USER"),
    password = if (Sys.getenv("DB_PASS")!="") Sys.getenv("DB_PASS") else key_get("filter_overview","DB_PASS"),
    bigint = "integer",
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
verse_poem <- tbl(con,dbplyr::in_schema("filter","verse_poem"))
collectors <- tbl(con,dbplyr::in_schema("filter","collectors"))
p_col <- tbl(con,dbplyr::in_schema("filter","p_col"))
locations <- tbl(con,dbplyr::in_schema("filter","locations"))
polygons <- tbl(con,dbplyr::in_schema("filter","polygons"))
p_loc <- tbl(con,dbplyr::in_schema("filter","p_loc"))
themes <- tbl(con,dbplyr::in_schema("filter","themes"))
poem_theme <- tbl(con,dbplyr::in_schema("filter","poem_theme"))
refs <- tbl(con,dbplyr::in_schema("filter","refs"))
raw_meta <- tbl(con,dbplyr::in_schema("filter","raw_meta"))

