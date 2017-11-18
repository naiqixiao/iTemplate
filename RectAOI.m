function[lo] = RectAOI(CurrentAOI, X, Y)

lo = X >= CurrentAOI(1) & X <= (CurrentAOI(1) + CurrentAOI(3)) & Y >= CurrentAOI(2) & Y <= (CurrentAOI(2) + CurrentAOI(4));

end