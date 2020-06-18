# email this to simona.cojocea@live.com

# Exemplul 1
n <- 1:100 # toate valorile de la 1..100
U <- runif(1)
X <- U^(1/n) # X o sa fie un vector pt toate valorile lui n

# Exemplul 2
U <- runif(10)
lambda <- 2
X <- -(1/lambda) * log(U)

# repartitia exponentiala
t <- seq(0,100,0.01)
plot(t, dexp(t,1),col="magenta", ylim=c(0, 0.01))

# Exemplul 3
n <- 2
lambda <- 2
U <- runif(n)
X <- - 1 / lambda * log(U)
Y <- sum(X)