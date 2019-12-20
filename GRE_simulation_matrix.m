function GRE_simulation_matrix

    Npop = 10000000;  % number of applicants
    Nlat=4;          % number of latent variables (knowledge, motivation, curiousity)

    Latent = randn(Npop,Nlat); % sample standard normal deviations for latent variables    
    suffice=normcdf(Latent,-1,1);   % determine sufficiency scores for each latent variable
    Complete=prod(suffice,2);       % completion probability is multiplication of sufficiency scores
    Success = rand(size(Complete))<Complete; % determine PhD completion based on probabilities
    
    figure(1);
    MeasureNoise=1;
    GPA=Percentile(  [0   1   0   0]);  % motivation 
    LET=Percentile(  [0   0   1   0]);  % curiosity
    SOP=Percentile(  [0   0   0   1]);  % expressivity 
    GRE=Percentile(  [1   0   0   0]);  % knowledge 
    for WhichSim=1:4 % 1 is correlated measures 2 is uncorrelated
        
        if WhichSim==1           % GREs are not predictive
            GRE=randi(100,Npop,1);         
            GREWeight=1;
        elseif WhichSim==2           % GREs are predictive and uncorrelated
            GRE=Percentile(  [1   0   0   0]);  % knowledge       
            GREWeight=1;
        elseif WhichSim==3       % Same as #2, but overweight GREs
            GREWeight=1.3; 
        elseif WhichSim==4       % GREs are predictive and correlated
            GRE=Percentile(  sqrt([1    0    0    0  ])); 
            GPA=Percentile(  sqrt([1/6  3/6  2/6  0  ]));  
            LET=Percentile(  sqrt([0    2/6  3/6  1/6])); 
            SOP=Percentile(  sqrt([0    0    0    1  ]));  
            GREWeight=1;
            corr([GRE GPA LET SOP])
        end
               
        Policy=(GRE.*GREWeight)+GPA+SOP+LET;           % include GREs
        PlotResults(Policy,0,100,1+(WhichSim-1)*3);    % everyone admitted
           
        if WhichSim==2
        else
            Policy=(GRE.*GREWeight)+GPA+SOP+LET;       % include GREs in compensatory score
        end
        PlotResults(Policy,90,100,2+(WhichSim-1)*3);   % top 10% admitted
            
        Policy=GPA+SOP+LET;                            % GREs are ignored
        PlotResults(Policy,90,100,3+(WhichSim-1)*3);   % top 10% admitted
     
    end
    
    % calculate outcome variable from weights and latent variables
    function Outcome=Percentile(W)
        Outcome = Latent*W' + MeasureNoise*randn(Npop,1);
        [Y,I]=sort(Outcome);
        [Y2,I2]=sort(I);
        Outcome=ceil(100.*(I2./Npop)); % return percentile of each datapoint
    end

    % find average success at each GRE and plot results
    function PlotResults(Policy,Lower,Upper,Result)
         
        subplot(4,3,Result);
        Admit=Policy>=prctile(Policy,Lower) & Policy<=prctile(Policy,Upper); % admit those between lower and upper percentile

        for g=1:100  % step through all 100 GRE percentiles
            GRE_success(g)=mean(Success(GRE==g & Admit));  % average success at GRE percentile
            GRE_N(g)=sum(GRE==g & Admit);                  % number of successful students at GRE percentile
            GRE_T(g)=sum(GRE==g);                          % number of admitted students at GRE percentile
        end
        GRE_dist=GRE_N./GRE_T;                            % probability of admittance at GRE percentile
        
        % output average success
        AveSuccess=mean(Success(Admit))

        SufficientN=find(GRE_dist>.01); % at least 1% admitted at GRE percentile (so .001% of total pop, or 1,000 for 10,000,000)
        hold off
        plot(SufficientN,GRE_success(SufficientN),'-k')
        hold on
        plot(GRE_dist,'--k')
        axis([0 100 0 .8]);
        xlabel('GRE percentile');
        ylabel('Probability of Success for admitted students');
        
        FILENAME=sprintf('GRE_RESULT_%d.csv',Result);
        csvwrite(FILENAME,[GRE_dist' GRE_success']);
    end

end
