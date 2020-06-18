%{
Ex.3
a. Sa se construiasca ın Matlab graficele functiilor y = e^x − 2 si y = cos(e^x − 2);
b. Sa se implementeze ın Matlab metoda bisectiei pentru a calcula o aproximare a solutiei ecuatiei 
	e^x − 2 = cos(e^x − 2) cu eroarea ε = 10−5 pe intervalul x ∈ [0, 5; 1, 5].
%}

function t13()
    PlotFunction(@(x)(exp(x) - 2), -4, 2);
    PlotFunction(@(x)(cos(exp(x) - 2)), -4, 3);
    FindSolAndPlot(@(x)((exp(x) - 2) - (cos(exp(x) - 2))), 0.5, 1.5);
end

function FindSolAndPlot(f, a, b)
    figure;
    hold on;
    Plot(f, a, b);
    
    x_aprox = MetBisectie(f, a, b, 1e-5);
    plot([x_aprox], [f(x_aprox)], 'or') % our intersection point
    plot([a b], [0 0]) % line x = 0
    hold off
end

function PlotFunction(f, a, b)
    figure;
    hold on;
    Plot(f, a, b)
    hold off
end

function Plot(f, a, b)
    x = linspace(a, b, 100);
    y = arrayfun(f, x);
    plot(x, y) % the graph of the function
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