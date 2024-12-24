library(readxl)
library(writexl)
library(seasonal)

# Septiembre 2024
preci01 = read_xlsx("24 -Precio combustible RC.xlsx",sheet = "Super",col_names = FALSE,range = "B5:B217")
preci01 = ts(preci01$...1, frequency = 12, start = c(2007,1))
preci02 = read_xlsx("24 -Precio combustible RC.xlsx",sheet = "Super deflactado",col_names = FALSE,range = "B5:B217")
preci02 = ts(preci02$...1, frequency = 12, start = c(2007,1))
preci03 = read_xlsx("24 -Precio combustible RC.xlsx",sheet = "Premium",col_names = FALSE,range = "B5:B217")
preci03 = ts(preci03$...1, frequency = 12, start = c(2007,1))
preci04 = read_xlsx("24 -Precio combustible RC.xlsx",sheet = "Premium deflactado",col_names = FALSE,range = "B5:B217")
preci04 = ts(preci04$...1, frequency = 12, start = c(2007,1))
preci05 = read_xlsx("24 -Precio combustible RC.xlsx",sheet = "Grado 2",col_names = FALSE,range = "B5:B217")
preci05 = ts(preci05$...1, frequency = 12, start = c(2007,1))
preci06 = read_xlsx("24 -Precio combustible RC.xlsx",sheet = "Grado 2 deflactado",col_names = FALSE,range = "B6:B218")
preci06 = ts(preci06$...1, frequency = 12, start = c(2007,1))
preci07 = read_xlsx("24 -Precio combustible RC.xlsx",sheet = "Grado 3",col_names = FALSE,range = "B5:B192")
preci07 = ts(preci07$...1, frequency = 12, start = c(2009,2))
preci08 = read_xlsx("24 -Precio combustible RC.xlsx",sheet = "Grado 3 Deflactado",col_names = FALSE,range = "B5:B192")
preci08 = ts(preci08$...1, frequency = 12, start = c(2009,2))
preci09 = read_xlsx("24 -Precio combustible RC.xlsx",sheet = "GNC",col_names = FALSE,range = "B5:B216")
preci09 = ts(preci09$...1, frequency = 12, start = c(2007,1))
preci10 = read_xlsx("24 -Precio combustible RC.xlsx",sheet = "GNC deflactado",col_names = FALSE,range = "B5:B217")
preci10 = ts(preci10$...1, frequency = 12, start = c(2007,1))

getwd()

preci01d = seas(preci01, x11="")
preci02d = seas(preci02, x11="")
preci03d = seas(preci03, x11="")
preci04d = seas(preci04, x11="")
preci05d = seas(preci05, x11="")
preci06d = seas(preci06, x11="")
preci07d = seas(preci07, x11="")
preci08d = seas(preci08, x11="")
preci09d = seas(preci09, x11="")
preci10d = seas(preci10, x11="")

?seas

preci01_conc = cbind(preci01d$series$d11,blanco,blanco,preci01d$series$d12)
write_xlsx(as.data.frame(preci01_conc),"preci01_d11_d12.xlsx")
preci02_conc = cbind(preci02d$series$d11,blanco,blanco,preci02d$series$d12)
write_xlsx(as.data.frame(preci02_conc),"preci02_d11_d12.xlsx")
preci03_conc = cbind(preci03d$series$d11,blanco,blanco,preci03d$series$d12)
write_xlsx(as.data.frame(preci03_conc),"preci03_d11_d12.xlsx")
preci04_conc = cbind(preci04d$series$d11,blanco,blanco,preci04d$series$d12)
write_xlsx(as.data.frame(preci04_conc),"preci04_d11_d12.xlsx")
preci05_conc = cbind(preci05d$series$d11,blanco,blanco,preci05d$series$d12)
write_xlsx(as.data.frame(preci05_conc),"preci05_d11_d12.xlsx")
preci06_conc = cbind(preci06d$series$d11,blanco,blanco,preci06d$series$d12)
write_xlsx(as.data.frame(preci06_conc),"preci06_d11_d12.xlsx")
preci07_conc = cbind(preci07d$series$d11,blanco,blanco,preci07d$series$d12)
write_xlsx(as.data.frame(preci07_conc),"preci07_d11_d12.xlsx")
preci08_conc = cbind(preci08d$series$d11,blanco,blanco,preci08d$series$d12)
write_xlsx(as.data.frame(preci08_conc),"preci08_d11_d12.xlsx")
preci09_conc = cbind(preci09d$series$d11,blanco,blanco,preci09d$series$d12)
write_xlsx(as.data.frame(preci09_conc),"preci09_d11_d12.xlsx")
preci10_conc = cbind(preci10d$series$d11,blanco,blanco,preci10d$series$d12)
write_xlsx(as.data.frame(preci10_conc),"preci10_d11_d12.xlsx")


write_xlsx(as.data.frame(preci01d$series$d11),"preci01_d11.xlsx")
write_xlsx(as.data.frame(preci01d$series$d12),"preci01_d12.xlsx")

write_xlsx(as.data.frame(preci02d$series$d11),"preci02_d11.xlsx")
write_xlsx(as.data.frame(preci02d$series$d12),"preci02_d12.xlsx")

write_xlsx(as.data.frame(preci03d$series$d11),"preci03_d11.xlsx")
write_xlsx(as.data.frame(preci03d$series$d12),"preci03_d12.xlsx")

write_xlsx(as.data.frame(preci04d$series$d11),"preci04_d11.xlsx")
write_xlsx(as.data.frame(preci04d$series$d12),"preci04_d12.xlsx")

write_xlsx(as.data.frame(preci05d$series$d11),"preci05_d11.xlsx")
write_xlsx(as.data.frame(preci05d$series$d12),"preci05_d12.xlsx")

write_xlsx(as.data.frame(preci06d$series$d11),"preci06_d11.xlsx")
write_xlsx(as.data.frame(preci06d$series$d12),"preci06_d12.xlsx")

write_xlsx(as.data.frame(preci07d$series$d11),"preci07_d11.xlsx")
write_xlsx(as.data.frame(preci07d$series$d12),"preci07_d12.xlsx")

write_xlsx(as.data.frame(preci08d$series$d11),"preci08_d11.xlsx")
write_xlsx(as.data.frame(preci08d$series$d12),"preci08_d12.xlsx")

write_xlsx(as.data.frame(preci09d$series$d11),"preci09_d11.xlsx")
write_xlsx(as.data.frame(preci09d$series$d12),"preci09_d12.xlsx")

write_xlsx(as.data.frame(preci10d$series$d11),"preci10_d11.xlsx")
write_xlsx(as.data.frame(preci10d$series$d12),"preci10_d12.xlsx")