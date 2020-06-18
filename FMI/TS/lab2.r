n <- 1e4;
x <- runif(n, -1, +1);
y <- runif(n, -1, +1);
num_match = 0;

plot(x={}, y={}, ylim=c(-1, +1), xlim=c(-1, +1))

for (i in 1:n) {
	if (x[i] * x[i] + y[i] * y[i] <= 1) {
		points(x[i], y[i], col=1);
		num_match = num_match + 1;
	} else {
		points(x[i], y[i], col=2);
	}
}

print(num_match / n);

# pi * r * r = aria cercului
# aria patratului = 4
# cercul e in interiorul patratului
# ai o sansa de num_match / n sa nimeresti cercul
# raza = 1
# -> pi / 4 = num_match / n -> pi = num_match / n * 4

print(num_match / n * 4);
