function Test_Simulation

    Npop = 10000000;                                % number of applicants
    Nlat=4;                                         % number of latent variables

    Latent = randn(Npop,Nlat);                      % sample standard normal deviations for latent variables    
    suffice=normcdf(Latent,-1,1);                   % determine sufficiency scores for each latent variable
    Complete=prod(suffice,2);                       % completion probability is multiplication of sufficiency scores
    Success = rand(size(Complete))<Complete;        % determine degree completion based on probabilities
    
    figure(1);
    MeasureNoise=1;
    
    GRADES=Percentile(  [0   1   0   0]);  % another predictor in application (e.g., GPA)
    LETTRS=Percentile(  [0   0   1   0]);  % another predictor in application (e.g., refernece letters)
    STATEM=Percentile(  [0   0   0   1]);  % another predictor in application (e.g., personal statement)
    
    for WhichSim=1:4 % 1 is correlated measures 2 is uncorrelated
        
        if WhichSim==1           % TESTs are not predictive
            TEST=randi(100,Npop,1);         
            TESTWeight=1;
        elseif WhichSim==2           % TESTs are predictive and uncorrelated
            TEST=Percentile(  [1   0   0   0]);  % loaded onto first latent variable        
            TESTWeight=1;
        elseif WhichSim==3       % Same as #2, but overweight TESTs
            TESTWeight=1.3; 
        elseif WhichSim==4       % TESTs are predictive and correlated
            TEST=Percentile(  sqrt([1    0    0    0  ])); 
            GRADES=Percentile(  sqrt([2/6  3/6  1/6  0  ]));  
            LETTRS=Percentile(  sqrt([0    1/6  3/6  2/6])); 
            STATEM=Percentile(  sqrt([0    0    0    1  ]));  
            TESTWeight=1;
        end
          
        disp(sprintf('sim %d: admit all',WhichSim));
        Policy=(TEST.*TESTWeight)+GRADES+STATEM+LETTRS;      % include TESTs
        PlotResults(Policy,0,100,1+(WhichSim-1)*3);    % everyone admitted
        
        disp(sprintf('sim %d: top 10 Percent including Test',WhichSim));
        PlotResults(Policy,90,100,2+(WhichSim-1)*3);   % top 10% admitted      
        
        disp(sprintf('sim %d: top 10 Pecent not including Test',WhichSim));
        Policy=GRADES+STATEM+LETTRS;                         % TESTs are ignored
        PlotResults(Policy,90,100,3+(WhichSim-1)*3);   % top 10% admitted
     
    end
    
    % calculate outcome variable from weights and latent variables
    function Outcome=Percentile(W)
        Outcome = Latent*W' + MeasureNoise*randn(Npop,1);
        [Y,I]=sort(Outcome);
        [Y2,I2]=sort(I);
        Outcome=ceil(100.*(I2./Npop)); % return percentile of each datapoint
    end

    % find average success at each TEST and plot results
    function PlotResults(Policy,Lower,Upper,Result)
         
        subplot(4,3,Result);
        Admit=Policy>=prctile(Policy,Lower) & Policy<=prctile(Policy,Upper);    % admit those between lower and upper percentile

        TestStats=[mean(TEST(Admit)) std(TEST(Admit))]                                    % print to screen mean and standard deviation of test scores for those admitted
        Among_admitted=corr([TEST(Admit) GRADES(Admit) LETTRS(Admit) STATEM(Admit)])  % correlation between predictors for those admitted
        
        for g=1:100  % step through all 100 TEST percentiles
            TEST_success(g)=mean(Success(TEST==g & Admit));  % average success at TEST percentile
            TEST_N(g)=sum(TEST==g & Admit);                  % number of successful students at TEST percentile
            TEST_T(g)=sum(TEST==g);                          % number of admitted students at TEST percentile
        end
        TEST_dist=TEST_N./TEST_T;                            % probability of admittance at TEST percentile
        
        % output average success

        SufficientN=find(TEST_dist>.01); % at least 1% admitted at TEST percentile (so .001% of total pop, or 1,000 for 10,000,000)
        hold off
        plot(SufficientN,TEST_success(SufficientN),'-k');
        [rho p]=corr([SufficientN' TEST_success(SufficientN)']); % calculate correlation
        
        AveSuccess=mean(Success(Admit))
        correlate=rho(1,2)
        significant=p(1,2)
        
        hold on
        plot(TEST_dist,'--k')
        axis([0 100 0 .8]);
        xlabel('TEST percentile');
        ylabel('Probability of Success for admitted students');
        
        FILENAME=sprintf('TEST_RESULT_%d.csv',Result);
        csvwrite(FILENAME,[TEST_dist' TEST_success']);
    end

end
