# 爬蟲部分
## 用rvest把各國的海洛因價錢以文字(其實就是<li>...</li>)的方式爬下來
library("rvest")
url <- "https://www.havocscope.com/black-market-prices/heroin-prices/"
raw_data <- url %>%
  read_html() %>%
  html_nodes("li") %>%
  html_text()

# 清資料(因為是文字所以清起來比html表格麻煩不少）
raw_data <- raw_data[8:79] ## 把國名和海洛因價錢的部分選出來

raw_data[5] <- "Australia$50.4 per gram" ## 接下來把幾個文字形式比較亂的項目手動補齊
raw_data[8] <- "USA$200 per gram"
raw_data[49] <- "Jordan$35.1 per gram"
raw_data <- unlist(raw_data)

##把"nation$xxx per gram ...."從" per"之後的字串去除
raw_data <- strsplit(raw_data, ' per', fixed = TRUE) %>% lapply("[[", 1) %>%
  unlist %>%
  strsplit("$", fixed = TRUE) ##再用'$'將國名與海洛因價錢分開

nations <- lapply(raw_data, "[[", 1) %>% unlist ##把第一欄的國名存起來
heroin_price <- lapply(raw_data, "[", 2) %>% ##把第二欄的價錢轉成數字後也存起來
  unlist %>%
  as.numeric
dt <- data.frame(nations, heroin_price) ##合成一個data.frame
names(dt) <- c("Name", "Price")

# 畫圖(我有把圖存成png檔)
## 最後會畫出一張上過色的世界地圖，顏色越深的地方代表當地的單位海洛因價格越高
library(ggplot2)
library(dplyr)

WorldData <- map_data('world')
WorldData %>% filter(region != "Antarctica") -> WorldData 
WorldData <- fortify(WorldData)
p <- ggplot()
p <- p + geom_map(data=WorldData, map=WorldData,
                  aes(x=long, y=lat, group=group, map_id=region),
                  fill="white", colour="#7f7f7f", size=0.5)
p <- p + geom_map(data=dt, map=WorldData, aes(fill=Price, map_id=Name), colour="#7f7f7f", size=0.5) + 
  scale_fill_continuous(low="thistle2", high="darkred", guide="colorbar") + 
  ggtitle("Heroine Prices in Different Countries (USD per gram)") +
  xlab("longtitude") +  ylab("latitude")
p
ggsave(plot = p, file = "Heroine Price World Map.png", device = "png", width = 11, 
       height = 6, units = "in", dpi = 600, family = "ArialMT")
