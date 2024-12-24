library(readxl)
library(writexl)
library(seasonal)

# Septiembre 2024
autos01 = read_xlsx("15- Automotriz.xlsx",sheet = "Produccion Nacional",col_names = FALSE,range = "B7:B351")
autos01 = ts(autos01$...1, frequency = 12, start = c(1996,1))
autos02 = read_xlsx("15- Automotriz.xlsx",sheet = "Exportaciones",col_names = FALSE,range = "B7:B315")
autos02 = ts(autos02$...1, frequency = 12, start = c(1999,1))

autos01d = seas(autos01, x11="")
autos02d = seas(autos02, x11="")

write_xlsx(as.data.frame(autos01d$series$d11),"autos01_d11.xlsx")
write_xlsx(as.data.frame(autos01d$series$d12),"autos01_d12.xlsx")

write_xlsx(as.data.frame(autos02d$series$d11),"autos02_d11.xlsx")
write_xlsx(as.data.frame(autos02d$series$d12),"autos02_d12.xlsx")