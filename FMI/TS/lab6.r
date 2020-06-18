myFunc <- function(x, p, num_elements=1) 
{	
	n <- length(p)
	partial_sums = cumsum(p)

	log_n <- 0

	while (2^log_n <= n) 
	{
		log_n <- log_n + 1
	}

	answer = c() # declare empty object
	for (num in 1:num_elements) 
	{
		u <- runif(1)

		number <- 0
		for (p in log_n:0)
		{
			if (number + (2^p) <= n && partial_sums[number + (2^p)] < u)
			{
				number <- number + (2^p)
			}
		}

		# number is the biggest number such partial_sums[number] < u
		answer[num] = x[number + 1]
	}

	return(answer)
}