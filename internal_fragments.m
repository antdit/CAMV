function [names, masses] = internal_fragments(seq)   
    global K k I L l M m F T t W V R r H A N D C c E Q G P S s Y y;
    global NH3 H2O H3PO4 HPO3 CO2 SOCH4;

    n_term = exact_mass(1,0,0,0,0,0);
    c_term = exact_mass(1,0,0,1,0,0);
    
    % CO loss for a-ion
    CO = exact_mass(0, 1, 0, 1, 0, 0);
        
    names = {};
    masses = [];
    
    for i = 2:length(seq) - 2
        for j = i+1:length(seq) - 1
            curr_pep = seq(i:j);
            
            curr_pep_mass = n_term;
            
            for a = i:j
                curr_pep_mass = curr_pep_mass + eval(seq(a));
            end
            
            names{end+1} = curr_pep;
            masses(end+1) = curr_pep_mass;
            
            names{end+1} = [curr_pep,'-H_2O'];
            masses(end+1) = curr_pep_mass - H2O;
            
            names{end+1} = [curr_pep,'-NH_3'];
            masses(end+1) = curr_pep_mass - NH3;
            
            names{end+1} = [curr_pep,'-28'];
            masses(end+1) = curr_pep_mass - CO;
            
            
            if regexp(curr_pep,'m')
                names{end+1} = [curr_pep,'-SOCH_4'];
                masses(end+1) = curr_pep_mass - SOCH4;                
            end
            
            if regexp(curr_pep,'[st]')
                names{end+1} = [curr_pep,'-H_3PO_4'];
                masses(end+1) = curr_pep_mass - H3PO4;                
            end
            
            if regexp(curr_pep,'y')
                names{end+1} = [curr_pep,'-HPO_3'];
                masses(end+1) = curr_pep_mass - HPO3;                
                
                names{end+1} = [curr_pep,'-HPO_3-H_2O'];
                masses(end+1) = curr_pep_mass - H3PO4;                                
            end
            
        end
    end
end