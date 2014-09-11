% Calculates the exact molar mass of a chemical formula
% 
% Inputs:
%   nH: Number of Hydrogen
%   nC: Number of Carbon
%   nN: Number of Nitrogen
%   nO: Number of Oxygen
%   nS: Number of Sulfur
%   nP: Numer of Phosphorus


function out = exact_mass(nH, nC, nN, nO, nS, nP)

% Hydrogen
H = [1.007825, 99.99;
      2.014102, 0.015];

% Carbon
C = [12.000000, 98.9;
      13.003355, 1.10];

% Nitrogen
N = [14.003074, 99.63;
     15.000109, 0.37];

% Oxygen
O = [15.994915, 99.76;
     16.999131, 0.038;
     17.999159, 0.20];

% Sulfur
S = [31.972072, 95.02;
     32.971459, 0.75;
     33.967868, 4.21;
     35.967079, 0.020];
 
% Phosphorus
P = [30.973763, 100];

 out = nH*H(1,1) + nC*C(1,1) + nN*N(1,1) + nO*O(1,1) + nS*S(1,1) + nP*P(1,1);