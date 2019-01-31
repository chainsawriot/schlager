require(rvest)
require(stringr)
require(purrr)

main_url <- "https://www.songtexte.com/artist/helene-fischer-43d60bbf.html"

args <- commandArgs(trailingOnly=TRUE)

main_url <- args[1]

song_urls <- c()
page <- read_html(main_url)

page %>% html_nodes('div.albumDetail') -> albums

albums %>% html_nodes('li') %>% html_nodes('a') %>% html_attr('href') %>% c(song_urls) -> song_urls

page %>% html_node('ul.listPagingNavigator') %>% html_nodes('li') %>% html_text %>% as.numeric %>% max(na.rm = TRUE) -> max_page

print(max_page)

if (max_page != -Inf) {
    for (i in 2:max_page) {
        print(i)
        page <- read_html(paste0(main_url, "?page=", i))
        page %>% html_nodes('div.albumDetail') -> albums
        albums %>% html_nodes('li') %>% html_nodes('a') %>% html_attr('href') %>% c(song_urls) -> song_urls
    }
}

song_urls %>% unique %>% str_replace("\\.\\.", "https://www.songtexte.com") -> queue

scrap_lyric <- function(url) {
    lyric_page <- read_html(url)
    Sys.sleep(2)
    lyric_page %>% html_node('div.lyricsContainer') %>% html_node('div#lyrics') %>% html_text -> lyrics
    lyric_page %>% html_node('h1') %>% html_text %>% str_trim %>% str_replace_all('\\n|/', " ") -> title
    print(title)
    writeLines(lyrics, paste0("./songtexte/", title, ".txt"))
}

x <- map(queue, scrap_lyric)
