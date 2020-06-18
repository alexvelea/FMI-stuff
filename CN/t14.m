%{
Ex.4 Sa se gaseasca o aproximare a valorii √3 cu eroarea ε = 10−5
%}

function t14
    x_aprox = MetBisectiei(@(x)(x ^ 2 - 3), 0, 3, 1e-5)
end

function x_aprox = MetBisectiei(f, a, b, epsilon)
    x_aprox = (a + b) / 2;
    while ((b - a) / 2 > epsilon)
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