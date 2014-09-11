function init_fragments(iTRAQ_type)

global iTRAQ_masses;
global iTRAQ_names;
global c_term;
global n_term;

global K k;
global I;
global L l;
global M m;
global F;
global T t;
global W;
global V;
global R r;
global H;
global A;
global N;
global D;
global C c;
global E;
global Q;
global G;
global P;
global S s;
global Y y;

global NH3;
global H2O;
global H3PO4;
global HPO3;
global CO2;
global SOCH4;

% Create iTRAQ Fragments
if iTRAQ_type == 8
    iTRAQ_masses = [113.11, 114.11, 115.11, 116.11, 117.11, 118.11, 119.11, 121.12];
    iTRAQ_names = {'iTRAQ 113', 'iTRAQ 114', 'iTRAQ 115', 'iTRAQ 116', 'iTRAQ 117', 'iTRAQ 118', 'iTRAQ 119', 'iTRAQ 121'};
elseif iTRAQ_type == 4
    iTRAQ_masses = [114.11, 115.11, 116.11, 117.11];
    iTRAQ_names = {'iTRAQ 114', 'iTRAQ 115', 'iTRAQ 116', 'iTRAQ 117'};
else
    iTRAQ_masses = [];
    iTRAQ_names = {};
end

% Add iTRAQ to all N-terminal and lysine residues
c_term = exact_mass(1,0,0,1,0,0);
% iTRAQ
if iTRAQ_type == 4
    iTRAQ = 144.1021 + exact_mass(1,0,0,0,0,0);
    n_term = iTRAQ;
    % Lysine
    K = exact_mass(14,6,2,2,0,0) - exact_mass(2,0,0,1,0,0) + iTRAQ - exact_mass(1,0,0,0,0,0);
elseif iTRAQ_type == 8
    iTRAQ = 304.2054 + exact_mass(1,0,0,0,0,0);
    n_term = iTRAQ;
    % Lysine
    K = exact_mass(14,6,2,2,0,0) - exact_mass(2,0,0,1,0,0) + iTRAQ - exact_mass(1,0,0,0,0,0);
else
    n_term = exact_mass(1,0,0,0,0,0);
    % Lysine
    K = exact_mass(14,6,2,2,0,0) - exact_mass(2,0,0,1,0,0);
end
% k = K + exact_mass(6,0,0,0,0,0);
% Acetyl Lysine
k = exact_mass(14,6,2,2,0,0) - exact_mass(2,0,0,1,0,0) - exact_mass(1,0,0,0,0,0) + exact_mass(3,2,0,1,0,0);

% Isoleucine
I = exact_mass(13,6,1,2,0,0) - exact_mass(2,0,0,1,0,0);

% Leucine
L = exact_mass(13,6,1,2,0,0) - exact_mass(2,0,0,1,0,0);
l = L + exact_mass(6,0,0,0,0,0);

% Methionine
M = exact_mass(11,5,1,2,1,0) - exact_mass(2,0,0,1,0,0);
% M(Ox)
m = M + exact_mass(0,0,0,1,0,0);

% Phenylalanine
F = exact_mass(11,9,1,2,0,0) - exact_mass(2,0,0,1,0,0);

% Threonine
T = exact_mass(9,4,1,3,0,0) - exact_mass(2,0,0,1,0,0);
% Phosphothreonine
t = T + exact_mass(1,0,0,3,0,1);

% Tryptophan
W = exact_mass(12,11,2,2,0,0) - exact_mass(2,0,0,1,0,0);

% Valine
V = exact_mass(11,5,1,2,0,0) - exact_mass(2,0,0,1,0,0);

% Arginine
R = exact_mass(14,6,4,2,0,0) - exact_mass(2,0,0,1,0,0);
r = R + exact_mass(6,0,0,0,0,0);

% Histidine
H = exact_mass(9,6,3,2,0,0) - exact_mass(2,0,0,1,0,0);

% Alanine
A = exact_mass(7,3,1,2,0,0) - exact_mass(2,0,0,1,0,0);

% Asparagine
N = exact_mass(8,4,2,3,0,0) - exact_mass(2,0,0,1,0,0);

% Aspartate
D = exact_mass(7,4,1,4,0,0) - exact_mass(2,0,0,1,0,0);

% Cysteine
C = exact_mass(7,3,1,2,1,0) - exact_mass(2,0,0,1,0,0);
% Carbamidomethyl cysteine
c = C + 57.0214;

% Glutamate
E = exact_mass(9,5,1,4,0,0) - exact_mass(2,0,0,1,0,0);

% Glutamine
Q = exact_mass(10,5,2,3,0,0) - exact_mass(2,0,0,1,0,0);

% Glycine
G = exact_mass(5,2,1,2,0,0) - exact_mass(2,0,0,1,0,0);

% Proline
P = exact_mass(9,5,1,2,0,0) - exact_mass(2,0,0,1,0,0);

% Serine
S = exact_mass(7,3,1,3,0,0) - exact_mass(2,0,0,1,0,0);
% Phosphoserine
s = S + exact_mass(1,0,0,3,0,1);

% Tyrosine
Y = exact_mass(11,9,1,3,0,0) - exact_mass(2,0,0,1,0,0);
% Phosphotyrosine
y = Y + exact_mass(1,0,0,3,0,1);

% Possible Losses
NH3 = exact_mass(3,0,1,0,0,0);
H2O = exact_mass(2,0,0,1,0,0);
H3PO4 = exact_mass(3,0,0,4,0,1);
HPO3 = exact_mass(1,0,0,3,0,1); % HPO3 accompanied by H2O for pY
CO2 = exact_mass(0,1,0,2,0,0);

SOCH4 = exact_mass(4,1,0,1,1,0);


end
