function GRE_simulation

    Npop = 1000000;  % number of applicants
    Nlat=3;          % number of latent variables (knowledge, motivation, curiousity)

    Latent = randn(Npop,Nlat); % sample standard normal deviations for latent variables
    
    % determine observed variables in percentil scores from latent variables 
    
    GRE=Percentile(  [1  0   0]);  % knowledge only 
    GPA=Percentile(  [1  1   0]);  % knowledge and motivation 
    LET=Percentile(  [0  1   1]);  % motivation and curiousity
    SOP=Percentile(  [0  0   1]);  % curiousity

    suffice=normcdf(Latent,0,.5);   % determine sufficiency scores for each latent variable
    Complete=prod(suffice,2);       % completion probability is multiplication of sufficiency scores
    Complete = rand(size(Complete))<Complete; % determine PhD completion based on probabilities
    Success = Complete;
    
    figure(1);
    Policy=GRE.*GPA.*LET.*SOP;      % uase all 4 observed variables in equal weighting
    PlotResults(Policy,90,100);     % between 90% and 100% admitted based on this policy
    
    figure(2);
    Policy=GPA.*LET.*SOP;           % GREs are ignored
    PlotResults(Policy,90,100);     % between 90% and 100% admitted based on this policy
    
    % calculate outcome variable from weights and latent variables
    function Outcome=Percentile(W)
        Outcome = Latent*W';
        [Y,I]=sort(Outcome);
        [Y2,I2]=sort(I);
        Outcome=ceil(100.*(I2./Npop)); % return percentile of each datapoint
    end

    % find average success at each GRE and plot results
    function PlotResults(Policy,Lower,Upper)
        
        Admit=Policy>=prctile(Policy,Lower) & Policy<=prctile(Policy,Upper); % admit those between lower and upper percentile

        for g=1:100  % step through all 100 GRE percentiles
            GRE_success(g)=mean(Success(GRE==g & Admit));  % average success at GRE percentile
            GRE_N(g)=sum(GRE==g & Admit);                  % number of successful students at GRE percentile
            GRE_T(g)=sum(GRE==g);                          % number of admitted students at GRE percentile
        end
        GRE_dist=GRE_N./GRE_T;                            % probabo;otu of admittance at GRE percentile
        
        % output numbers
        AveSuccess=mean(Success(Admit))
        AveGRE_PHD_success=mean(GRE(Admit & Success==1))
        AveGRE_PHD_failure=mean(GRE(Admit & Success==0))

        
        % plot probability of admittance as function of GRE scores
        subplot(3,1,1);
        plot(GRE_dist,'-k');
        axis([0 100 0 1]);
        xlabel('GRE percentile');
        ylabel('Probability of Admittance');
        
        % plot distribution of success as function of GRE percentile
        subplot(3,1,2);
        plot(GRE_success,'-k')
        axis([0 100 0 1]);
        xlabel('GRE percentile');
        ylabel('Probability of Success for admitted students');
        
        % plot distribution of success based on GRE quartiles
        subplot(3,1,3);
        Cuts=prctile(GRE(Admit),[0 25 50 75 100]);
        for p=1:4
            y(p)=mean(Success(GRE>Cuts(p) & GRE<=Cuts(p+1) & Admit));
        end
        bar(y);
        axis([0 5 0 1]);
        xlabel('GRE quartile amongst admitted students (low to high)');
        ylabel('Probability of Success for admitted students');
        
    end

end
