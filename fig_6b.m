final_human = zeros(10,2);
final_comp = zeros(10,2);

for i = 1:length(data_human)
    accepted_human = 0;
    accepted_comp = 0;
    if isfield(data_human{i}, 'fragments')
        for j = 1:length(data_human{i}.fragments)
            if data_human{i}.fragments{j}.status == 1
                accepted_human = 1;
                j = length(data_human{i}.fragments);
            end
        end
    end
   
    if isfield(data_comp{i}, 'fragments')        
        accepted_comp = 1;        
    end
    
    score = data_human{i}.pep_score;
    j = 1;
    
    if score < 20
        j = 1;
    elseif score < 30
        j = 2;
    elseif score < 40
        j = 3;
    elseif score < 50
        j = 4;
    elseif score < 60
        j = 5;
    elseif score < 70
        j = 6;
    elseif score < 80
        j = 7;
    elseif score < 90
        j = 8;
    elseif score < 100
        j = 9;
    elseif score < 200
        j = 10;
    end
    
    if accepted_human
        final_human(j,1) = final_human(j,1) + 1;
    else
        final_human(j,2) = final_human(j,2) + 1;
    end
    if accepted_comp
        final_comp(j,1) = final_comp(j,1) + 1;
    else
        final_comp(j,2) = final_comp(j,2) + 1;
    end    
end

temp = [];

% temp(:,:,1) = [final_human(:,1), final_comp(:,1)];
% temp(:,:,2) = [final_human(:,2), final_comp(:,2)];
temp(:,:,1) = [final_human(:,1), zeros(10,1)];
temp(:,:,2) = [final_human(:,2), zeros(10,1)];
temp(:,:,3) = [zeros(10,1), final_comp(:,1)];
temp(:,:,4) = [zeros(10,1), final_comp(:,2)];

names = {'15-20'; '20-30'; '30-40'; '40-50'; '50-60'; '60-70'; '70-80'; '80-90'; '90-100'; '>100'};

plotBarStackGroups(temp, names);
legend('Accept', 'Reject');
% legend('Accept (human)', 'Reject(human)', 'Accept(comp)', 'Reject(comp)');
set(gca,'FontSize',12) 
xlabel('Mascot Score', 'Fontsize', 18);
ylabel('Number', 'Fontsize', 18);

set(gcf,'Position',[100 100 1000 650]) 
xlim([0,11]);

a = get(gca, 'Children');

% Change bar colors
set(get(a(1), 'Children'), 'Facecolor', [.5 0 0]) % Computer Rejected
set(get(a(2), 'Children'), 'Facecolor', [0 0 .5]) % Computer Accepted

set(get(a(7), 'Children'), 'Facecolor', [.8 0 0]) % Human Rejected
set(get(a(8), 'Children'), 'Facecolor', [0 0 .8]) % Human Accepted

a = get(gcf,'Children');
b = get(a(1),'Children');

set(get(b(1),'Children'), 'Facecolor', [.8 0 0]); % Legend Rejected
set(get(b(3),'Children'), 'Facecolor', [0 0 .8]); % Legend Accepted


print -dtiff -r600 fig_6b