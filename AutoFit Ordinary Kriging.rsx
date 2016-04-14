##[R-Geostatistics]=group
##showplots
##layer=vector
##field=field layer
##model=selection Exp;Sph;Gau;Mat
##kriging_variance= output raster
##kriging_prediction= output raster

library('gstat')
library('sp')
create_new_data <- function (obj)
{
convex_hull = chull(coordinates(obj)[, 1], coordinates(obj)[,
2])
convex_hull = c(convex_hull, convex_hull[1])
d = Polygon(obj[convex_hull, ])
new_data = spsample(d, 5000, type = "regular")
gridded(new_data) = TRUE
attr(new_data, "proj4string") <-obj@proj4string
return(new_data)
}
mask<-create_new_data(layer)
names(layer)[names(layer)==field]="field"

layer$field <- as.numeric(as.character(layer$field))
str(layer)
layer <- remove.duplicates(layer)
layer <- layer[!is.na(layer$field),]
Models<-c("Exp","Sph","Gau","Mat")
model2<-Models[model+1]
g <- gstat(id = field, formula = field~1, data = layer)
vg <- variogram(g)
vgm <- vgm(nugget=0, range=sqrt(diff(layer@bbox[1,])^2 + diff(layer@bbox[2,])^2)/4, psill=var(layer$field), model=model2)
vgm = fit.variogram(vg, vgm)

>vgm
#>paste("SSErr:", attr(vgm, "SSErr"))
plot(vg, vgm, main = title , plot.numbers = TRUE)
prediction = krige(field~1, layer, newdata = mask, vgm)
kriging_prediction = raster(prediction)
kriging_variance = raster(prediction["var1.var"])
