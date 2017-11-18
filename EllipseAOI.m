function[lo] = EllipseAOI(CurrentAOI, X, Y)

c = [CurrentAOI(1) + CurrentAOI(3)/2 CurrentAOI(2) + CurrentAOI(4)/2];
A = CurrentAOI(3)/2;
B = CurrentAOI(4)/2;

lo = (X - c(1)) .^ 2 / A .^ 2 + (Y - c(2)) .^ 2 / B .^ 2 <= 1;

end
