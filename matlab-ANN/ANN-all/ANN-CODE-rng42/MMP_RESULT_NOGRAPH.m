                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     % Load data from edm-all5.csv
data = readtable('edm_all5.csv');
inputs = data{1:end, 2:4};
outputs = data{1:end, 5:9};

% Normalize input data
inputs = zscore(inputs);
rng(42);
% Set up parameters
architectures = 3:10; % Adjust the range as needed

optimizers = {'trainlm', 'traingd', 'traingda', 'trainrp'};
results = cell(4, 1); % 4 Optimizers

% Iterate over optimizers
for o = 1:length(optimizers)
    optimizer = optimizers{o};
    
    % Initialize results structure
    results{o}.architecture = architectures';
    results{o}.train_MSE = cell(8, 5);
    results{o}.train_MAPE = cell(8, 5);
    results{o}.train_R2 = cell(8, 5);
    results{o}.test_MSE = cell(8, 5);
    results{o}.test_MAPE = cell(8, 5);
    results{o}.test_R2 = cell(8, 5);
    results{o}.train_actual = cell(8, 5);
    results{o}.train_predicted = cell(8, 5);
    results{o}.test_actual = cell(8, 5);
    results{o}.test_predicted = cell(8, 5);
    
    % Iterate over architectures
    for a = 1:8
        hidden_layers = ones(1, architectures(a)-2) * 10; % Change 10 to the desired number of neurons per hidden layer
        architecture = [3, hidden_layers, 5]; % Assuming 1 output neuron based on your code
        
        % Initialize cross-validation indices
        cv = cvpartition(size(inputs, 1), 'KFold', 5);
        % Initialize arrays to store results across folds
        fold_train_results(o).MSE = cell(1, 5);
        fold_train_results(o).MAPE = cell(1, 5);
        fold_train_results(o).R2 = cell(1, 5);
        
        fold_test_results(o).MSE = cell(1, 5);
        fold_test_results(o).MAPE = cell(1, 5);
        fold_test_results(o).R2 = cell(1, 5);
        fold_test_results(o).actual = cell(1, 5);
        fold_test_results(o).predicted = cell(1, 5);
        
        % Iterate over folds
        for k = 1:5
            % Extract training and testing sets for this fold
            train_indices = training(cv, k);
            test_indices = test(cv, k);
            
            train_inputs = inputs(train_indices, :);
            train_outputs = outputs(train_indices, :);
            
            test_inputs = inputs(test_indices, :);
            test_outputs = outputs(test_indices, :);
            
            net.divideFcn = 'dividerand';
            net.divideParam.trainRatio = 0.7;
            net.divideParam.valRatio = 0.15;
            net.divideParam.testRatio = 0.15;
            net.trainParam.epochs = 10;
            net.trainParam.lr = 0.01;
            
            net = feedforwardnet(architecture, optimizer);
            
            [net, tr] = train(net, train_inputs', train_outputs');
            
            % Evaluate performance on training set
            train_predictions = net(train_inputs');
            train_mse = mean( (train_predictions' - train_outputs) .^2 );
            train_mape   = mean((abs((train_predictions' - train_outputs) ./ train_outputs)) * 100, 1);
            % train_mape = mean(abs((train_predictions' - train_outputs) ./ train_outputs)) * 100;
            train_mape = (100- train_mape) ;
            train_r2= 1 - (sum((train_predictions' - train_outputs) .^2) ./ sum((train_outputs)  .^2));
            train_r2= (train_r2)*100;
            
            % Save training results for this fold
            fold_train_results(o).MSE{k} = train_mse;
            fold_train_results(o).MAPE{k} = train_mape;
            fold_train_results(o).R2{k} = train_r2;
            
            % Save actual and predicted values for training set
            fold_train_results(o).actual{k} = train_outputs;
            fold_train_results(o).predicted{k} = train_predictions';
            
            % Evaluate performance on testing set
            test_predictions = net(test_inputs');
            test_mse = mean((test_predictions' - test_outputs).^2);
            test_mape = mean((abs( (test_predictions' - test_outputs) ./ test_outputs) ) * 100, 1);
            test_mape  = 100-test_mape ;
            test_r2 =  1-sum((test_predictions' - test_outputs) .^2) ./ sum(test_outputs .^2);
            test_r2 = test_r2*100;
           
            

            % Save testing results for this fold
            fold_test_results(o).MSE{k} = test_mse;
            fold_test_results(o).MAPE{k} = test_mape;
            fold_test_results(o).R2{k} = test_r2;
            
            % Save actual and predicted values for testing set
            fold_test_results(o).actual{k} = test_outputs;
            fold_test_results(o).predicted{k} = test_predictions';
            
        end
        
        % Compute the mean across rows for each column
        k=1:5;
        data_mse = cat(1,fold_train_results(o).MSE{k});
        data_mape= cat(1,fold_train_results(o).MAPE{k});
        data_r2 =   cat(1,fold_train_results(o).R2{k});
        
        results{o}.train_MSE{a}  = (mean(data_mse,1));
        results{o}.train_MAPE{a} = (mean(data_mape,1));
        results{o}.train_R2{a}    = (mean(data_r2,1));
        
        data_mse = cat(1,fold_test_results(o).MSE{k});
        data_mape= cat(1,fold_test_results(o).MAPE{k});
        data_r2 =   cat(1,fold_test_results(o).R2{k});
        
        results{o}.test_MSE{a}  = (mean(data_mse,1));
        results{o}.test_MAPE{a} = (mean(data_mape,1));
        results{o}.test_R2{a}    = (mean(data_r2,1));
    end

     for a = 1:8
        train_R2_values(a, :) = results{o}.train_R2{a};
        test_R2_values(a, :) = results{o}.test_R2{a};
     end
    % Construct file names with optimizer variable
train_filename = [optimizer, '_train_R2_values.csv'];
test_filename = [optimizer, '_test_R2_values.csv'];

% Save train_R2_values to a CSV file
csvwrite(train_filename, train_R2_values);

% Save test_R2_values to a CSV file
csvwrite(test_filename, test_R2_values);

    % Save results to CSV file
    results_table = table(architectures', results{o}.train_MSE, results{o}.train_MAPE, results{o}.train_R2,'VariableNames', {'Architecture', 'Train_MSE','Train_100-MAPE', 'Train_R2'});
    results_file = [optimizer, '_train_results.csv'];
    writetable(results_table, results_file);
    
    results_table = table(architectures', results{o}.test_MSE, results{o}.test_MAPE, results{o}.test_R2,'VariableNames', {'Architecture', 'Test_MSE', 'Test_100-MAPE', 'Test_R2'});
    results_file = [optimizer, '_test_results.csv'];
    writetable(results_table, results_file);
   
end
