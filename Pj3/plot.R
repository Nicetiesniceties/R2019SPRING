# ���γ���
## ��rvest��U�ꪺ�����]�����H��r(���N�O<li>...</li>)���覡���U��
library("rvest")
url <- "https://www.havocscope.com/black-market-prices/heroin-prices/"
raw_data <- url %>%
  read_html() %>%
  html_nodes("li") %>%
  html_text()

# �M���(�]���O��r�ҥH�M�_�Ӥ�html����·Ф��֡^
raw_data <- raw_data[8:79] ## ���W�M�����]������������X��

raw_data[5] <- "Australia$50.4 per gram" ## ���U�ӧ�X�Ӥ�r�Φ�����ê����ؤ�ʸɻ�
raw_data[8] <- "USA$200 per gram"
raw_data[49] <- "Jordan$35.1 per gram"
raw_data <- unlist(raw_data)

##��"nation$xxx per gram ...."�q" per"���᪺�r��h��
raw_data <- strsplit(raw_data, ' per', fixed = TRUE) %>% lapply("[[", 1) %>%
  unlist %>%
  strsplit("$", fixed = TRUE) ##�A��'$'�N��W�P�����]�������}

nations <- lapply(raw_data, "[[", 1) %>% unlist ##��Ĥ@�檺��W�s�_��
heroin_price <- lapply(raw_data, "[", 2) %>% ##��ĤG�檺�����ন�Ʀr��]�s�_��
  unlist %>%
  as.numeric
dt <- data.frame(nations, heroin_price) ##�X���@��data.frame
names(dt) <- c("Name", "Price")

# �e��(�ڦ���Ϧs��png��)
## �̫�|�e�X�@�i�W�L�⪺�@�ɦa�ϡA�C��V�`���a��N�����a���������]����V��
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