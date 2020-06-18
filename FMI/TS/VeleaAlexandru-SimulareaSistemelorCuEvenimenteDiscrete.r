# simularea sistemelor cu evenimente discrete
# Alexandru Velea
# 333

# clasa buna care sa tinem outputul unei simulari
setClass(
	'SimulationResult',
	slots = list(
		n = 'numeric',
		Tp = 'numeric',
		A = 'vector',
		D = 'vector'
	)
)

# avand timpul curent, valoarea maxima a lambda si functia lambda calculam cand o sa vina urmatorul client
NextArrivalTime <- function(current_t, max_lambda, lambda) {
	while (TRUE) {
		u1 = runif(1)
		current_t = current_t - 1 / max_lambda * log(u1)
		u2 = runif(1)

		if (u2 < lambda(current_t) / max_lambda) {
			return(current_t)
		}
	}
}

SimulateDay <- function(lambda, Y, T) {
	ans <- new('SimulationResult', n = 0, Tp = 0, A = vector(), D = vector())
	
	# initializam datele
	n <- 0
	Na <- 0
	Nd <- 0

	t <- 0
	TA <- NextArrivalTime(0, lambda, function(x)(lambda))
	TD <- +Inf

	# cat timp putem procesa clienti
	while (TRUE) {
		# cele 4 cazuri
		if (TA <= TD && TA <= T) {
			t <- TA
			Na <- Na + 1
			ans@A[Na] <- t

			n <- n + 1
			TA <- NextArrivalTime(t, lambda, function(x)(lambda))
			if (n == 1) {
				y <- Y()
				TD <- t + y
			}
		} else if (TD <= TA && TD <= T) {
			t <- TD
			n <- n - 1
			Nd <- Nd + 1
			ans@D[Nd] <- t

			if (n == 0) {
				TD <- +Inf
			} else {
				y <- Y()
				TD <- t + y
			}
		} else if (min(TA, TD) > T && n > 0) {
			t <- TD
			n <- n - 1
			Nd <- Nd + 1
			ans@D[Nd] <- t

			if (n > 0) {
				y <- Y()
				TD <- t + y
			}
		} else if(min(TA, TD) > T && n == 0) {
			ans@Tp <- max(t - T, 0)
			ans@n <- Na
			return(ans)
		}
	}
}

RunSimulation <- function(num_days, lambda=1/20, Y=function(x)(runif(1, 5, 25))) {
	Tsis_med <- 0
	Tp_med <- 0
	# simulam de num_days ori
	for (i in 1:num_days) {
		ans <- SimulateDay(lambda, Y, 8 * 60 * 60)

		# calculam timpul mediu in sistem pentru simularea curenta
		Tsis_med_now <- 0
		for (j in 1:ans@n) {
			Tsis_med_now <- Tsis_med_now + (ans@D[j] - ans@A[j])
		}

		# adaugam la media globala valorile curente
		Tsis_med <- Tsis_med + Tsis_med_now / ans@n
		Tp_med <- Tp_med + ans@Tp
	}

	# impartim la numarul de sampleuri
	Tsis_med <- Tsis_med / num_days
	Tp_med <- Tp_med / num_days

	return(c(Tsis_med, Tp_med))
}

RunSimulation(10)

# ans <- SimulateDay(1/10, function(x)(runif(1, 5, 25)), 8 * 60 * 60)