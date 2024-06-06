% Load the CSV file
data = csvread('RSM_all5.csv', 1); % Assuming the first row is a header

% Extract data for x-axis
x = data(:, 1); % Column 1

% Extract data for y-axis
y1 = data(:, [5, 10]); % Column 5 and Column 10
y2 = data(:, [6, 11]); % Column 6 and Column 11
y3 = data(:, [7, 12]); % Column 7 and Column 12
y4 = data(:, [8, 13]); % Column 8 and Column 13
y5 = data(:, [9, 14]); % Column 9 and Column 14

% Plot comparison graphs
figure;

subplot(3, 2, 1);
plot(x, y1(:, 1), '-o', x, y1(:, 2), '-o');

xlabel('X-axis');
ylabel('Y-axis');
title('Comparison Graph - Ra');
grid on;

subplot(3, 2, 2);
plot(x, y2(:, 1), '-o', x, y2(:, 2), '-o');

xlabel('X-axis');
ylabel('Y-axis');
title('Comparison Graph - Rq');
grid on;

subplot(3, 2, 3);
plot(x, y3(:, 1), '-o', x, y3(:, 2), '-o');

xlabel('X-axis');
ylabel('Y-axis');
title('Comparison Graph -Rz');
grid on;

subplot(3, 2, 4);
plot(x, y4(:, 1), '-o', x, y4(:, 2), '-o');

xlabel('X-axis');
ylabel('Y-axis');
title('Comparison Graph - Rp');
grid on;

subplot(3, 2, 5);
plot(x, y5(:, 1), '-o', x, y5(:, 2), '-o');

xlabel('X-axis');
ylabel('Y-axis');
title('Comparison Graph - Rv');
grid on;
