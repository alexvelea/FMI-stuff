# random_shuffle
sample(c(1:10, 1:5))

# size = cate returneaza
# replace = permite duplicate ca indici
#	daca dam sample(c(1, 1, 2), size=s, replace=TRUE) numarul de 1-uri o sa fie 2/3 * s si numarul de 2-uri o sa fie 1/3 * s
sample(c(1:5, 1:5), size=3, replace=TRUE)

# prob primeste un array de probabilitati
#	prob e defapt nu vector de ponderi/suma nu trebuie sa fie 100
y <- sample(c(1, 2), prob=c(0.2, 1.0), size = 84, replace=TRUE)
# afisam la misto o histograma sa vedem ce e pe acolo
hist(y)