set.seed(1)
x<-runif(10, min = 0, max = 1)
options(digits = 3, show.signif.stars = T)
heat.df<-read.table("heat.txt", header = T)
library(ggplot2)
ggplot(heat.df, aes(Exposure, Fecundity))+
  geom_point(colour = "blue", shape = 21, size = 2, alpha = 1, fill = 8)+
  geom_smooth(se = FALSE, colour = "red")+
  labs(title = "Exploratory plot", x="Exposure (hours)", y="Fecundity")
heat<-lm(Fecundity~ poly(Exposure, 3, raw = FALSE), data = heat.df)
summary(heat)
pheat<-predict(heat)
par(mfrow=c(3,2))
plot(heat, which = 1:5)
shapiro.test(heat$residuals)
sort(cooks.distance(heat))
pf(0.095, 2, 148)
pf(0.075, 2, 148)
pf(0.054, 2, 148)
ggplot(heat.df, aes(Exposure, Fecundity))+
  geom_point(colour = "blue", shape = 21, size = 2, alpha = 1, fill = 8)+
  geom_smooth(method = "lm", formula = y ~ poly(x, 3), colour = "red")+
  labs(title = "3rd degree polynomial with 95% confidence bands", x="Exposure (hours)", y="Fecundity")
#Kernel estimators 
library(sm)
library(splines)
library(splines2)
hm<-hcv(heat.df$Exposure, heat.df$Fecundity, display = "lines")
sm.regression(heat.df$Exposure, heat.df$Fecundity, h=hm)
fit1<-ksmooth(heat.df$Exposure, heat.df$Fecundity, bandwidth = 1.0, kernel = "normal")
fit2<-ksmooth(heat.df$Exposure, heat.df$Fecundity, bandwidth = 0.2, kernel = "normal")
fit3<-ksmooth(heat.df$Exposure, heat.df$Fecundity, bandwidth = 2.0, kernel = "normal")
x<-fit1$x
kernfit1<-fit1$y
kernfit2<-fit2$y
kernfit3<-fit3$y
kernreg<-data.frame(x, kernfit1, kernfit2, kernfit3)
ggplot(heat.df, aes(Exposure, Fecundity))+
  geom_point(colour = "blue", shape = 21, size = 2, alpha = 1, fill = 8)+
  geom_line(kernreg, mapping=aes(x=x, y=kernfit1, colour = "1.0"))+
  geom_line(kernreg, mapping=aes(x=x, y=kernfit2, colour = "0.2"))+
  geom_line(kernreg, mapping=aes(x=x, y=kernfit3, colour = "2.0"))+
  labs(x= "Exposure (hours)", y="Fecundity", colour = "Bandwidth")
#Smoothing splines
spline<-smooth.spline(heat.df$Exposure, heat.df$Fecundity)
fits1<-smooth.spline(heat.df$Exposure, heat.df$Fecundity, spar = 0.4)
fits2<-smooth.spline(heat.df$Exposure, heat.df$Fecundity, spar = 0.1)
fits3<-smooth.spline(heat.df$Exposure, heat.df$Fecundity, spar = 1.0)
xs<-fits1$x
smoothfits1<-fits1$y
smoothfits2<-fits2$y
smoothfits3<-fits3$y
splinedata<-data.frame(xs, smoothfits1, smoothfits2, smoothfits3)
ggplot(heat.df, aes(Exposure, Fecundity))+
  geom_point(colour = "blue", shape = 21, size = 2, alpha = 1, fill = 8)+
  geom_line(splinedata, mapping=aes(x=xs, y=smoothfits1, colour = "0.4"))+
  geom_line(splinedata, mapping=aes(x=xs, y=smoothfits2, colour = "0.1"))+
  geom_line(splinedata, mapping=aes(x=xs, y=smoothfits3, colour = "1.0"))+
  labs(x= "Exposure (hours)", y="Fecundity", colour = "span")
#B-spline
bsp<-lm(heat.df$Fecundity~bs(heat.df$Exposure))
bsp1<-lm(heat.df$Fecundity~bs(heat.df$Exposure, df = 3))
bsp2<-lm(heat.df$Fecundity~bs(heat.df$Exposure, df = 4))
bsp3<-lm(heat.df$Fecundity~bs(heat.df$Exposure, df = 5))
by1<-predict(bsp1)
by2<-predict(bsp2)
by3<-predict(bsp3)
bsplinedata<-data.frame(by1, by2, by3)
ggplot(heat.df, aes(Exposure, Fecundity))+
  geom_point(colour = "blue", shape = 21, size = 2, alpha = 1, fill = 8)+
  geom_line(data = bsplinedata, mapping = aes(x=heat.df$Exposure, y=by1, colour = "3"))+
  geom_line(data = bsplinedata, mapping = aes(x=heat.df$Exposure, y=by2, colour = "4"))+
  geom_line(data = bsplinedata, mapping = aes(x=heat.df$Exposure, y=by3, colour = "5"))+
  labs(x= "Exposure (hours)", y="Fecundity", colour = "df")
#Loess
ls<-loess(heat.df$Fecundity~heat.df$Exposure)
ls1<-loess(heat.df$Fecundity~heat.df$Exposure, normalize = TRUE, span = 0.50)
ls2<-loess(heat.df$Fecundity~heat.df$Exposure, normalize = TRUE, span = 0.25)
ls3<-loess(heat.df$Fecundity~heat.df$Exposure, normalize = TRUE, span = 0.90)
loessdata<-data.frame(heat.df$Exposure, ls1$fitted, ls2$fitted, ls3$fitted)
ggplot(heat.df, aes(Exposure, Fecundity))+
  geom_point(colour = "blue", shape = 21, size = 2, alpha = 1, fill = 8)+
  geom_line(data = loessdata, mapping = aes(x=heat.df$Exposure, y=ls1.fitted, colour = "0.50"))+
  geom_line(data = loessdata, mapping = aes(x=heat.df$Exposure, y=ls2.fitted, colour = "0.25"))+
  geom_line(data = loessdata, mapping = aes(x=heat.df$Exposure, y=ls3.fitted, colour = "0.90"))+
  labs(x= "Exposure (hours)", y="Fecundity", colour = "span")

allfits<-data.frame(kernfit1, by1, ls3$fitted, pheat)
ggplot(heat.df, aes(Exposure, Fecundity))+
  geom_point(colour = "blue", shape = 21, size = 2, alpha = 1, fill = 8)+
  geom_line(data = allfits, mapping = aes(x=x, y=kernfit1, colour = "Kernel regression"))+
  geom_line(data = allfits, mapping = aes(x=heat.df$Exposure, y=by1, colour = "B-spline regression"))+
  geom_line(data = allfits, mapping = aes(x=heat.df$Exposure, y=ls3$fitted, colour = "Loess regression"))+
  geom_line(data = allfits, mapping = aes(x=heat.df$Exposure, y=pheat, colour = "3rd degree polynomial"))+
  labs(x= "Exposure (hours)", y="Fecundity", colour = "Various types of fittted curves")