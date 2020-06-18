%{
Ex.2 Fie ecuatia x^3 - 7 * x ^2 + 14 * x - 6 

a. Sa se construiasca in Matlab o procedura cu sintaxa [xaprox] = MetBisectie(f, a, b, ε).
b. Intr-un fisier script sa se construiasca ın Matlab graficul functiei f(x) = x^3 - 7 * x ^2 + 14 * x - 6;
pe intervalul [0, 4]. Sa se calculeze solutia aproximativa xaprox cu eroarea ε = 10−5, apeland
procedura MetBisectie pentru fiecare interval in parte: 1. [0, 1]; 2. [1; 3, 2]; 3. [3, 2; 4].
c. Sa se construiasca punctele (xaprox, f(xaprox)) calculate la b. ın acelasi grafic cu graficul functiei.
%}

function t12()
    Solve(0, 1);
    Solve(1, 3.2);
    Solve(3.2, 4);
    Solve(0, 4);
end

function Solve(a, b)
    f = @T12Evaluate;
    x_aprox = MetBisectie(f, a, b, 1e-20)
    
    x = linspace(a, b, 100);
    y = arrayfun(f, x);
    
    figure;
    hold on;
    plot(x, y) % the graph of the function
    plot([x_aprox], [f(x_aprox)], 'or') % our intersection point
    plot([a b], [0 0]) % line x = 0
    hold off
end

function answer = T12Evaluate(x)
    answer = x^3 - 7 * x ^2 + 14 * x - 6;
end

function x_aprox = MetBisectie(f, a, b, epsilon)
    x_aprox = (a + b) / 2;
    
    while ((b - a) > epsilon) 
        if (f(x_aprox) == 0)
            break;
        end
        
        if (f(a) * f(x_aprox) < 0)
            b = x_aprox; 
        else 
            a = x_aprox;
        end
        
        x_aprox = (a + b) / 2;
    end
end