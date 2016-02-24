function runControl()
  ## Serial Port Setup

  ## Simulation Parameters
  dt = .005;
  prev_input = [0; 0; 0; 0; 0; 0; 0; 0];
  systemStates = [0; 0; 0.1; 0; 0; 0; 0; 0; 0; 0; 0; 0];
  restLengths = [0.1; 0.1; 0.1; 0.1; 0.187; 0.187; 0.187; 0.187];
  horizon = 5;
  inputs = zeros(8, horizon);

  output = "";

  x_steps = zeros(12, 3);
  x_steps[1:12, 1] = [0; 0; 0; 0; 0; 0.2; 0; 0; 0; 0; 0; 0];
  x_steps[1:12, 2] = [0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0];
  x_steps[1:12, 3] = [0; 0; 0.2; 0; 0; 0; 0; 0; 0; 0; 0; 0];
  for j = 1:3
    x_final = x_steps[:, j];
    for k = 1:horizon
      horizonInputs = MPCcontroller(x_final, systemStates, prev_input, restLengths, dt);
      inputs[:, k] = horizonInputs[:, 1];
      #systemStates = simulate_dynamics(systemStates, restLengths, inputs[:, k], dt);
      prev_input = inputs[:, k];
    end

    inputDegrees = (inputs/(2*pi*0.012)*360) + 90;
    inputDegrees = max(inputDegrees, 0);
    inputDegrees = min(inputDegrees, 180);

    for p = 1:8
        str = dec(convert(Int64, round(inputDegrees[p, 1])), 3);
        output = string(output, str);
    end
    println(output)
    for k = 2:horizon
      #write(s, output);
      output = "";
      for p = 1:8
        str = dec(convert(Int64, round(inputDegrees[p, k])), 3);
        output = string(output, str);
      end

#       f = readavailable(s);
#       while (length(f) == 0)
#         f = readavailable(s);
#       end
      println(output);
    end
  end
  return output;
end
