library(readxl)
library(writexl)
library(seasonal)

# Septiembre 2024
porci01 = read_xlsx("25-Porcinos.xlsx",sheet = "SF",col_names = FALSE,range = "B5:B169")
porci01 = ts(porci01$...1, frequency = 12, start = c(2011,1))
porci02 = read_xlsx("25-Porcinos.xlsx",sheet = "C",col_names = FALSE,range = "B5:B169")
porci02 = ts(porci02$...1, frequency = 12, start = c(2011,1))
porci03 = read_xlsx("25-Porcinos.xlsx",sheet = "ER",col_names = FALSE,range = "B5:B169")
porci03 = ts(porci03$...1, frequency = 12, start = c(2011,1))
porci04 = read_xlsx("25-Porcinos.xlsx",sheet = "Precio Capón General",col_names = FALSE,range = "B4:B123")
porci04 = ts(porci04$...1, frequency = 12, start = c(2014,10))
porci05 = read_xlsx("25-Porcinos.xlsx",sheet = "Precio deflactado Capón General",col_names = FALSE,range = "B4:B123")
porci05 = ts(porci05$...1, frequency = 12, start = c(2014,10))

model04 = auto.arima(porci04)
forecast(model04,h=3)
model05 = auto.arima(porci05)
forecast(model05,h=3)



porci01d = seas(porci01, x11="")
porci02d = seas(porci02, x11="")
porci03d = seas(porci03, x11="")
porci04d = seas(porci04, x11="")
porci05d = seas(porci05, x11="")

porci01_conc = cbind(porci01d$series$d11,blanco,blanco,porci01d$series$d12)
write_xlsx(as.data.frame(porci01_conc),"porci01_d11_d12.xlsx")
porci02_conc = cbind(porci02d$series$d11,blanco,blanco,porci02d$series$d12)
write_xlsx(as.data.frame(porci02_conc),"porci02_d11_d12.xlsx")
porci03_conc = cbind(porci03d$series$d11,blanco,blanco,porci03d$series$d12)
write_xlsx(as.data.frame(porci03_conc),"porci03_d11_d12.xlsx")
porci04_conc = cbind(porci04d$series$d11,blanco,blanco,porci04d$series$d12)
write_xlsx(as.data.frame(porci04_conc),"porci04_d11_d12.xlsx")
porci05_conc = cbind(porci05d$series$d11,blanco,blanco,porci05d$series$d12)
write_xlsx(as.data.frame(porci05_conc),"porci05_d11_d12.xlsx")


write_xlsx(as.data.frame(porci01d$series$d11),"porci01_d11.xlsx")
write_xlsx(as.data.frame(porci01d$series$d12),"porci01_d12.xlsx")

write_xlsx(as.data.frame(porci02d$series$d11),"porci02_d11.xlsx")
write_xlsx(as.data.frame(porci02d$series$d12),"porci02_d12.xlsx")

write_xlsx(as.data.frame(porci03d$series$d11),"porci03_d11.xlsx")
write_xlsx(as.data.frame(porci03d$series$d12),"porci03_d12.xlsx")

write_xlsx(as.data.frame(porci04d$series$d11),"porci04_d11.xlsx")
write_xlsx(as.data.frame(porci04d$series$d12),"porci04_d12.xlsx")

write_xlsx(as.data.frame(porci05d$series$d11),"porci05_d11.xlsx")
write_xlsx(as.data.frame(porci05d$series$d12),"porci05_d12.xlsx")
