# Despre distributia normala

# daca o functie incepe cu dxx urmata de 3-4 linitere e o densitate/functie de masa
# daca o functie incepe cu pxx e functia de repartitie/probabilitate
# daca e rxx genereaza valori aleatoare 
# qxx futia quantila

# 10 elemente
rnorm(10)

# 10 elemente cu media 5
rnorm(10, 5)

# seq(st, dr, eps)
# secventa de la [st, st+eps, st+2 * eps .. dr]
# t primeste secventa
t <- seq(-5, +5, 1e-3)

# plot(x, y)
# x, y vectori
# optional col (colour) - col="green" sau col=1
plot(t, dnorm(t), col="magenta")


# lines e similar cu plot dar scrie peste ultimul plot, nu creeaza unul nou
for (i in 2:5) 
	lines(t, dnorm(t, i - 4, i), col=i+5)

# valorile pentru axa ox/oy sunt calculate pentru prima functie plot
# se poate folosii ylim si xlim pentru a seta asta
# ylim=c(0,1) -> c functie de concatenare
plot(t, dnorm(t), col="magenta", ylim=c(0, 1), xlim=c(-2, 2))
for (i in 2:5) 
	lines(t, dnorm(t, i - 4, i), col=i+5)