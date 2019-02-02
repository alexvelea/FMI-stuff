%{
Fie ecuatia x^3 − 7x^2 + 14x − 6 = 0.

a. Sa se construiasca ın Matlab o procedura cu sintaxa 
    [xaprox] = MetNR(f, df, x0, ε) conform
    algoritmului metodei Newton-Raphson.
b. Intr-un fisier script sa se construiasca graficul functiei 
    f(x) = x^3 − 7x^2 + 14x − 6 pe inter-valul [0, 4]. 
    Alegeti din grafic trei subintervale si valorile initiale 
    x0 corespunzatoare fiecarui subinterval, astfel ıncat sa fie 
    respectate ipotezele teoremei I.2. Aflati cele trei soluţii 
    apeland procedura MetNR cu eroarea de aproximare ε = 10−3
%}

function t16()  
    global x f f_1 f_2
    syms x;
    sf = x^3 - 7 * x^2 + 14 * x - 6;
    sf_1 = diff(f, x);
    
    f = matlabFunction(sf)
    f_1 = matlabFunction(sf_1)
    f_2 = matlabFunction(diff(f_1, x))
    
    % Plot(0, 4)
    
    % a = 0; b = 1;
    % a = 2; b = 3.1;
    % a = 3.3; b = 4;
    
    
    x_0 = MetNewthonRaphsonGetInitial(a, b)
    x_aprox = MetNewthonRaphson(a, b, x_0, 1e-4)
end

function Plot(a, b)
    global x f f_1
    x_p = linspace(a, b, 100);
    y_p = arrayfun(f, x_p)
    figure;
    hold on;
    plot(x_p, y_p)
    plot([a b], [0 0])
    
    hold off;
end

function x_0 = MetNewthonRaphsonGetInitial(a, b)
    global x f f_2
    if (f_2(a) > 0)
        if (f(a) > 0)
            x_0 = a;
        else
            x_0 = b;
        end
    else
        if (f(a) < 0)
            x_0 = a;
        else
            x_0 = b;
        end
    end
end

function x_new = MetNewthonRaphson(a, b, x_0, epsilon)
    global x f f_1
    x_old = x_0;

    while true
        x_new = x_old - f(x_old) / f_1(x_old);
        
        if (abs(f(x_new)) < epsilon)
            break;
        end
        
        x_old = x_new;
    end
end