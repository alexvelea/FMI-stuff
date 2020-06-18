# Ex 1
# X ~ f
# f(x) = x * e^(-x)

# Ex 1 a) met respingerii
# Luam Y ~ Exp(1/2)
# Astfel g(x) = 1/2 * e^(-x * 1/2)
# h(x) = f(x)/g(x) = 2 * x * e^(-x * 1/2)

# Punctul de maxim se afla la x = 2, cu mx = h(2) = 4/e
# In final, cautam un Y pentru care UY <= h(x) / mx 
#   = 2 * x * e^(-x * 1/2) / 4 * e
#   = x * e^(-x* 1/2) / 2 * e
#   = x * e^(-x * 1/2) / 2 * exp(1)
#   = x * e^(1 - x * 1/2) / 2
num_steps <- 0

while(TRUE) {
  num_steps <- num_steps + 1

  UX <- runif(1)
  Y <- -2 * log(UX)

  UY <- runif(1)
  UY_limit = Y * exp(1 - Y * 1/2) / 2

  # cat(Y, UY, UY_limit, '\n')
  if (UY <=  UY_limit) {
    X_met_resp <- Y
    break
  }
}

cat('x = ', X_met_resp, '\tPentru simulare am folosit: ', num_steps, ' pas(i)', '\n')


# Ex 1 b) met inversa
# nu stiu sa calculez inversa :(


# Ex 2 met respingerii

# X ~ f
# f(x) = 1/2 * x^2 * e^(-x)

# Luam Y ~ Exp(1/3)
# Astfel g(x) = 1/3 * e^(-x * 1/3)
# h(x) = f(x)/g(x) = 3/2 * x^2 * e^(-2/3 * x)

# Punctul de maxim se afla la x = 3, cu mx = h(3) = 27 * e^(-2) / 2
# In final, cautam un Y pentru care UY <= h(x) / mx 
#   = 3/2 * x^2 * e^(-2/3 * x) / (27 * e^(-2) / 2)
#   = 1/9 * x^2 * e^(2 + -2/3 * x)
num_steps <- 0

while(TRUE) {
  num_steps <- num_steps + 1

  UX <- runif(1)
  Y <- -3 * log(UX)

  UY <- runif(1)
  UY_limit = 1/9 * Y^2 * exp(2 - 2/3 * Y)

  cat(Y, UY, UY_limit, '\n')
  if (UY <=  UY_limit) {
    X_met_resp <- Y
    break
  }
}

cat('x = ', X_met_resp, '\tPentru simulare am folosit: ', num_steps, ' pas(i)', '\n')
