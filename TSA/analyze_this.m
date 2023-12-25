function QT_interest = analyze_this(y)
    y = max(y, 0) + 1e-8;
    nphase = size(y, 1);    
%     A = y(:, 1);
%     B = y(:, 2);
%     C = y(:, 3);
%     QT_interest(((1 - 1)*nphase) + 1: (1*nphase) , 1)   = log10(A);
%     QT_interest(((2 - 1)*nphase) + 1: (2*nphase) , 1)   = log10(B);
%     QT_interest(((3 - 1)*nphase) + 1: (3*nphase) , 1)   = log10(C);
    QT_interest(((1 - 1)*nphase) + 1: (1*nphase) , 1)   = y(:, 1);
    QT_interest(((2 - 1)*nphase) + 1: (2*nphase) , 1)   = y(:, 2);
    QT_interest(((3 - 1)*nphase) + 1: (3*nphase) , 1)   = y(:, 3);

end
