%MODEL LOADING.
% Load and configure the Simulink model
model = 'Test_9_bus_system'; % Replace with your model name
load_system(model);
set_param(model, 'SimulationCommand', 'start');



while true

    %INITIALIZATION

    Vmag4simout = evalin('base', 'out.Vmag4.Data');
    Vmag7simout = evalin('base', 'out.Vmag7.Data');
    Vmag9simout = evalin('base', 'out.Vmag9.Data');

    Vang4simout = evalin('base', 'out.Vang4.Data');
    Vang7simout = evalin('base', 'out.Vang7.Data');
    Vang9simout = evalin('base', 'out.Vang9.Data');

    Imag4simout = evalin('base', 'out.Imag4.Data');
    Imag7simout = evalin('base', 'out.Imag7.Data');
    Imag9simout = evalin('base', 'out.Imag9.Data');

    Iang4simout = evalin('base', 'out.Iang4.Data');
    Iang7simout = evalin('base', 'out.Iang7.Data');
    Iang9simout = evalin('base', 'out.Iang9.Data');

 
    pause(0.1); 

    Vmag_4 = Vmag4simout(end); Vang_4 = deg2rad(Vang4simout(end));
    Vmag_7 = Vmag7simout(end); Vang_7 = deg2rad(Vang7simout(end));
    Vmag_9 = Vmag9simout(end); Vang_9 = deg2rad(Vang9simout(end));
    
    Imag_4 = Imag4simout(end); Iang_4 = deg2rad(Iang4simout(end));
    Imag_7 = Imag7simout(end); Iang_7 = deg2rad(Iang7simout(end));
    Imag_9 = Imag9simout(end); Iang_9 = deg2rad(Iang9simout(end));
    
    Vph_4 =  Vmag_4 .* (cos(Vang_4) + 1j * sin(Vang_4));
    Vph_7 =  Vmag_7 .* (cos(Vang_7) + 1j * sin(Vang_7));
    Vph_9 =  Vmag_9 .* (cos(Vang_9) + 1j * sin(Vang_9));
    
    Iph_4 =  Imag_4 .* (cos(Iang_4) + (1j * sin(Iang_4)));
    Iph_7 =  Imag_7 .* (cos(Iang_7) + (1j * sin(Iang_7)));
    Iph_9 =  Imag_9 .* (cos(Iang_9) + (1j * sin(Iang_9)));

    I = [Iph_4, Iph_7, Iph_9];


    %NETWORK TOPOLOGY

    Z_45 = 5.29 + (0.1192*1i); Z_54 = Z_45;
    Z_46 = 8.993 + (0.129*1i); Z_64 = Z_46;
    Z_57 = 16.928 + (0.2259*1i); Z_75 = Z_57;
    Z_69 = 20.631 + (0.238*1i); Z_96 = Z_69;
    Z_78 = 4.4965 + (0.101*1i); Z_87 = Z_78;
    Z_89 = 6.2951 + (0.1414*1i); Z_98 = Z_89;
    
    
    Z_14 = (30.4704*1j); Z_41 = Z_14;
    Z_27 = (33.0625*1j); Z_72 = Z_27;
    Z_39 = (31.1052*1j); Z_93 = Z_39;
    
    Z_11 = Z_14; Z_22 = Z_27; Z_33 = Z_39;
    Z_44 = Z_41 + Z_45 + Z_46;
    Z_55 = (343.596-(137.438*1j)) + Z_57 + Z_54;
    Z_66 = (519.325-(173.108*1j)) + Z_64 + Z_69;
    Z_77 = Z_72 + Z_75 + Z_78;
    Z_88 = (465.740-(163.009*1j)) + Z_87 + Z_89;
    Z_99 = Z_93 + Z_96 + Z_98;
    
    Z = [
        Z_11, 0.00, 0.00, Z_14, 0.00, 0.00, 0.00, 0.00, 0.00;
        0.00, Z_22, 0.00, 0.00, 0.00, 0.00, Z_27, 0.00, 0.00;
        0.00, 0.00, Z_33, 0.00, 0.00, 0.00, 0.00, 0.00, Z_39;
        Z_41, 0.00, 0.00, Z_44, Z_45, Z_46, 0.00, 0.00, 0.00;
        0.00, 0.00, 0.00, Z_54, Z_55, 0.00, Z_57, 0.00, 0.00;
        0.00, 0.00, 0.00, Z_64, 0.00, Z_66, 0.00, 0.00, Z_69;
        0.00, Z_72, 0.00, 0.00, Z_75, 0.00, Z_77, Z_78, 0.00;
        0.00, 0.00, 0.00, 0.00, 0.00, 0.00, Z_87, Z_88, Z_89;
        0.00, 0.00, Z_93, 0.00, 0.00, Z_96, 0.00, Z_98, Z_99;
       ];
    
    numBuses = [1, 2, 3, 4, 5, 6, 7, 8, 9];
    pmuBuses = [4, 7, 9];
    
    
    % CONSTANTS
    d0_BPZ1 = 0.10; d1_BPZ1 = 1.046;
    d0_BPZ2 = 0.30; d1_BPZ2 = 0.989;
    d0_BPZ3 = 0.40; d1_BPZ3 = 1.009;
    
    I_min_BPZ1 = 0.100;
    I_min_BPZ2 = 0.300;
    I_min_BPZ3 = 0.400;
    
    
    % POSITIVE SEQUENCE CURRENT ENTERING ZONES
    
    I1_ent_BPZ1 = Iph_4 + Iph_7;
    I1_ent_BPZ2 = Iph_7 + Iph_9;
    I1_ent_BPZ3 = Iph_4 + Iph_9;
    
  
    % THRESHOLD VALUES
    
    I0_Th_BPZ1 = 0.100;
    I0_Th_BPZ2 = 0.300;
    I0_Th_BPZ3 = 0.400;

    I1_ent_BPZ1n = 1.90970 - (0.09373*1j);
    I1_ent_BPZ2n = 0.62437 + (0.33380*1j);
    I1_ent_BPZ3n = -1.20460 - (0.72896*1j);
    
    I1_Th_BPZ1 = max(d1_BPZ1 * abs(I1_ent_BPZ1n), I_min_BPZ1);
    I1_Th_BPZ2 = max(d1_BPZ2 * abs(I1_ent_BPZ2n), I_min_BPZ2);
    I1_Th_BPZ3 = max(d1_BPZ3 * abs(I1_ent_BPZ3n), I_min_BPZ3);

    % FAULT DETECTION LOGIC

    if (abs(I1_ent_BPZ1) > I1_Th_BPZ1)
        disp('A fault has been detected in Zone 1');
        % Boundary voltages and impedance matrix
        V_boundary = [Vph_4, Vph_7, Vph_9];
        Z_boundary = [
            Z(4, 4),  Z(4, 7);
            Z(7, 4),  Z(7, 7)
            ];
        Y_boundary = inv(Z_boundary);
        
        % Initialize variables
        x = zeros(size(Y_boundary, 1), 1);
        f_x = zeros(size(Y_boundary, 1), 1);
        
        % Least Square Method
        H = [];
        m = []; 
        Z_full = calculateImpedanceMatrix(Z, numBuses); 
        
        % Populate H matrix and m vector
        for i = 1:length(pmuBuses)
            for j = 1:length(pmuBuses)
                H(i, j) = Z_full(pmuBuses(i), pmuBuses(j)); 
            end
            m(i) = V_boundary(i) - I(i);  
        end
        
        % Perform least squares solution
        H_transpose = H'; 
        H_transpose_H = H_transpose * H;
        H_transpose_m = H_transpose * m';
        u = H_transpose_H \ H_transpose_m; 
        
        % Calculate f_x for each bus
        for i = 1:length(pmuBuses)
            f_x(i) = abs(V_boundary(i) - H(i,:) * u);
        end
        
        % Interpret results
        If = u(1);
        x_estimated = u(2); 
        [~, FL_index] = min(f_x); 
        fault_location = x_estimated(FL_index);
        
        % Display results
        disp(['Fault detected on line ', num2str(FL_index)]);
        disp(['Estimated fault location: ', num2str(fault_location), ' pu']);


    elseif (abs(I1_ent_BPZ1) < I1_Th_BPZ1)
        disp('Safe. ');
        
    end


    if (abs(I1_ent_BPZ2) > I1_Th_BPZ2)
        disp('A fault has been detected in Zone 2');
        % Boundary voltages and impedance matrix
        V_boundary = [Vph_4, Vph_7, Vph_9];
        Z_boundary = [
            Z(7, 7), Z(7, 9);
            Z(9, 7), Z(9, 9)
            ];
        Y_boundary = inv(Z_boundary);
        
        % Initialize variables
        x = zeros(size(Y_boundary, 1), 1);
        f_x = zeros(size(Y_boundary, 1), 1);
        
        % Least Square Method
        H = [];
        m = []; 
        Z_full = calculateImpedanceMatrix(Z, numBuses); 
        
        % Populate H matrix and m vector
        for i = 1:length(pmuBuses)
            for j = 1:length(pmuBuses)
                H(i, j) = Z_full(pmuBuses(i), pmuBuses(j)); 
            end
            m(i) = V_boundary(i) - I(i);  
        end
        
        % Perform least squares solution
        H_transpose = H'; 
        H_transpose_H = H_transpose * H;
        H_transpose_m = H_transpose * m';
        u = H_transpose_H \ H_transpose_m; 
        
        % Calculate f_x for each bus
        for i = 1:length(pmuBuses)
            f_x(i) = abs(V_boundary(i) - H(i,:) * u);
        end
        
        % Interpret results
        If = u(1);
        x_estimated = u(2); 
        [~, FL_index] = min(f_x); 
        fault_location = x_estimated(FL_index);
        
        % Display results
        disp(['Fault detected on line ', num2str(FL_index)]);
        disp(['Estimated fault location: ', num2str(fault_location), ' pu']);

    elseif (abs(I1_ent_BPZ2) < I1_Th_BPZ2)
        disp('Safe. ');
        
    end


    if (abs(I1_ent_BPZ3) > I1_Th_BPZ3)
        disp('A fault has been detected in Zone 3');
        % Boundary voltages and impedance matrix
        V_boundary = [Vph_4, Vph_7, Vph_9];
        Z_boundary = [
            Z(4, 4), Z(4, 9);
            Z(9, 4), Z(9, 9)
            ];
        Y_boundary = inv(Z_boundary);
        
        % Initialize variables
        x = zeros(size(Y_boundary, 1), 1);
        f_x = zeros(size(Y_boundary, 1), 1);
        
        % Least Square Method
        H = [];
        m = []; 
        Z_full = calculateImpedanceMatrix(Z, numBuses); 
        
        % Populate H matrix and m vector
        for i = 1:length(pmuBuses)
            for j = 1:length(pmuBuses)
                H(i, j) = Z_full(pmuBuses(i), pmuBuses(j)); 
            end
            m(i) = V_boundary(i) - I(i);  
        end
        
        % Perform least squares solution
        H_transpose = H'; 
        H_transpose_H = H_transpose * H;
        H_transpose_m = H_transpose * m';
        u = H_transpose_H \ H_transpose_m; 
        
        % Calculate f_x for each bus
        for i = 1:length(pmuBuses)
            f_x(i) = abs(V_boundary(i) - H(i,:) * u);
        end
        
        % Interpret results
        If = u(1);
        x_estimated = u(2); 
        [~, FL_index] = min(f_x); 
        fault_location = x_estimated(FL_index);
        
        % Display results
        disp(['Fault detected on line ', num2str(FL_index)]);
        disp(['Estimated fault location: ', num2str(fault_location), ' pu']);

    elseif (abs(I1_ent_BPZ3) < I1_Th_BPZ3)
        disp('Safe. ');

    end

    
    
    if ~strcmp(get_param(model, 'SimulationStatus'), 'running')
        disp('Simulation stopped.');
        break;
    end
end

% Close the Simulink model
close_system(model, 0);



