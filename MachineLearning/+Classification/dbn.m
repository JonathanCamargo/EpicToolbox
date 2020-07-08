  function [mu,sigma] = kf(mu_p,sigma_p,mu_prev,sigma_prev,mu_curr,sigma_curr)
                % KALMAN  single variable kalman filter for current time
                %   inputs: Model Guassian
                %           - mu_p - Dynamic model mean
                %           - sigma_p - Dynamic model std deviation
                %           Prior Guassian
                %           - mu_prev - Previous time mean
                %           - sigma_prev - Previous time std. deviation
                %           Current Time Measurement
                %           - mu_curr - current measurement mean
                %           - sigma_curr - current measurement std. deviation
                %   output: mu - kalman filter estimate for current time
                %           sigma - kalman filter std. deviation for current time
                
                % Time Prediction Update: Convolution w/ Model Gaussian
                mu_c = mu_prev + mu_p;
                sigma_c = sqrt(sigma_prev^2 + sigma_p^2);
                
                % Measurement Update: Multpilication with Convolved Gaussian
                mu = (mu_c*sigma_curr^2 + mu_curr*sigma_c^2)/(sigma_curr^2 + sigma_c^2);
                sigma = sqrt(1/(1/sigma_curr^2+1/sigma_c^2));
            end