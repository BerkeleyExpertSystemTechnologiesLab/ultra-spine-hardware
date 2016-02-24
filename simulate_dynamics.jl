function simulate_dynamics(systemStates, restLengths, inputs, dt)
  systemStates0 = systemStates;

  Te = getTensions(systemStates[1],systemStates[2],systemStates[3],systemStates[4],systemStates[5],systemStates[6],systemStates[7],systemStates[8],systemStates[9],systemStates[10],systemStates[11],systemStates[12], inputs[1],inputs[2],inputs[3],inputs[4],inputs[5],inputs[6],inputs[7],inputs[8],restLengths[1],restLengths[2],restLengths[3],restLengths[4],restLengths[5],restLengths[6],restLengths[7],restLengths[8]);
  K1 = zeros(12, 1);
  K2 = zeros(12, 1);
  K3 = zeros(12, 1);
  K4 = zeros(12, 1);

  K1[1:6] = systemStates[7:12];
  K1[7:12] = accel(systemStates[1],systemStates[2],systemStates[3],systemStates[4],systemStates[5],systemStates[6],systemStates[7],systemStates[8],systemStates[9],systemStates[10],systemStates[11],systemStates[12],Te[1],Te[2],Te[3],Te[4],Te[5],Te[6],Te[7],Te[8]);

  Te = getTensions(systemStates[1],systemStates[2],systemStates[3],systemStates[4],systemStates[5],systemStates[6],systemStates[7],systemStates[8],systemStates[9],systemStates[10],systemStates[11],systemStates[12], inputs[1],inputs[2],inputs[3],inputs[4],inputs[5],inputs[6],inputs[7],inputs[8],restLengths[1],restLengths[2],restLengths[3],restLengths[4],restLengths[5],restLengths[6],restLengths[7],restLengths[8]);
  systemStates = systemStates+K1*dt/2;

  K2[1:6] =  systemStates[7:12];
  K2[7:12] =  accel(systemStates[1],systemStates[2],systemStates[3],systemStates[4],systemStates[5],systemStates[6],systemStates[7],systemStates[8],systemStates[9],systemStates[10],systemStates[11],systemStates[12],Te[1],Te[2],Te[3],Te[4],Te[5],Te[6],Te[7],Te[8]);

  Te = getTensions(systemStates[1],systemStates[2],systemStates[3],systemStates[4],systemStates[5],systemStates[6],systemStates[7],systemStates[8],systemStates[9],systemStates[10],systemStates[11],systemStates[12], inputs[1],inputs[2],inputs[3],inputs[4],inputs[5],inputs[6],inputs[7],inputs[8],restLengths[1],restLengths[2],restLengths[3],restLengths[4],restLengths[5],restLengths[6],restLengths[7],restLengths[8]);
  systemStates = systemStates+K2*dt/2;

  K3[1:6] =  systemStates[7:12];
  K3[7:12] =  accel(systemStates[1],systemStates[2],systemStates[3],systemStates[4],systemStates[5],systemStates[6],systemStates[7],systemStates[8],systemStates[9],systemStates[10],systemStates[11],systemStates[12],Te[1],Te[2],Te[3],Te[4],Te[5],Te[6],Te[7],Te[8]);

  Te = getTensions(systemStates[1],systemStates[2],systemStates[3],systemStates[4],systemStates[5],systemStates[6],systemStates[7],systemStates[8],systemStates[9],systemStates[10],systemStates[11],systemStates[12], inputs[1],inputs[2],inputs[3],inputs[4],inputs[5],inputs[6],inputs[7],inputs[8],restLengths[1],restLengths[2],restLengths[3],restLengths[4],restLengths[5],restLengths[6],restLengths[7],restLengths[8]);
  systemStates = systemStates+K3*dt;

  K4[1:6] =  systemStates[7:12];
  K4[7:12] =  accel(systemStates[1],systemStates[2],systemStates[3],systemStates[4],systemStates[5],systemStates[6],systemStates[7],systemStates[8],systemStates[9],systemStates[10],systemStates[11],systemStates[12],Te[1],Te[2],Te[3],Te[4],Te[5],Te[6],Te[7],Te[8]);
  systemStates = systemStates0+dt/6*(K1+2*K2+2*K3+K4);

  return systemStates;
end
