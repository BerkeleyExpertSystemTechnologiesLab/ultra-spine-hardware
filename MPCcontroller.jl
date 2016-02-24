function MPCcontroller(x_final, systemStates, prev_input, restLengths, dt)
  # x_final = 12x1 array
  # systemStates = 12x1 array
  # prev_input = 8x1 array
  # dt = 0.05

  include("C:/Users/Abishek/Documents/Classes/Grad/EmbeddedMPC/linearize_dynamics.jl");
  include("C:/Users/Abishek/Documents/Classes/Grad/EmbeddedMPC/simulate_dynamics.jl");
  include("C:/Users/Abishek/Documents/Classes/Grad/EmbeddedMPC/getTensions.jl");
  include("C:/Users/Abishek/Documents/Classes/Grad/EmbeddedMPC/accel.jl");
  include("C:/Users/Abishek/Documents/Classes/Grad/EmbeddedMPC/dlengths_dt.jl");
  include("C:/Users/Abishek/Documents/Classes/Grad/EmbeddedMPC/lengths.jl");

  controlIndex = indmax(x_final);

  linearizedMatrices = linearize_dynamics(systemStates, prev_input, restLengths, dt);
  A = linearizedMatrices[1];
  B = linearizedMatrices[2];
  c = linearizedMatrices[3];

  N = 3;
  m = Model(solver= ECOS.ECOSSolver(verbose=0));
  @defVar(m, inputs[1:8, 1:(N-1)]);
  @defVar(m, states[1:12, 1:N]);
  @defVar(m, state_lim[1:N]);
  @defVar(m, input_lim1[1:(N-1)])
  @defVar(m, input_lim2[1:(N-1)])
  @defVar(m, input_lim3[1:(N-1)])
  @defVar(m, input_lim4[1:(N-1)])
  @defVar(m, input_lim5[1:(N-1)])
  @defVar(m, input_lim6[1:(N-1)])
  @defVar(m, input_lim7[1:(N-1)])
  @defVar(m, input_lim8[1:(N-1)])
  @defVar(m, diff);

  input_lim = 0.02*ones(8, 1);
  println(prev_input);

  @addConstraint(m, states[j=1:12, 1] .== systemStates[j=1:12]);
  @addConstraint(m, prev_input[j=1:8] - inputs[j=1:8, 1] .<= .01);
  @addConstraint(m, -prev_input[j=1:8] + inputs[j=1:8, 1] .<= .01);
  for k = 1:(N-1)
    @addConstraint(m, inputs[j=1:8, k] .>= -input_lim);
    @addConstraint(m, inputs[j=1:8, k] .<= input_lim);
    @addConstraint(m, states[j=1:12, k+1] .== A*states[j=1:12, k] + B*inputs[j=1:8, k] + c)
  end
  objective = 0;
  for k = 1:(N-1)
    @addConstraint(m, (states[controlIndex, k] - x_final[controlIndex]) <= state_lim[k]);
    @addConstraint(m, -(states[controlIndex, k] - x_final[controlIndex]) <= state_lim[k]);
    @addConstraint(m, inputs[1] <= input_lim1[k]);
    @addConstraint(m, -inputs[1] <= input_lim1[k]);
    @addConstraint(m, inputs[2] <= input_lim2[k]);
    @addConstraint(m, -inputs[2] <= input_lim2[k]);
    @addConstraint(m, inputs[3] <= input_lim3[k]);
    @addConstraint(m, -inputs[3] <= input_lim3[k]);
    @addConstraint(m, inputs[4] <= input_lim4[k]);
    @addConstraint(m, -inputs[4] <= input_lim4[k]);
    @addConstraint(m, inputs[5] <= input_lim5[k]);
    @addConstraint(m, -inputs[5] <= input_lim5[k]);
    @addConstraint(m, inputs[6] <= input_lim6[k]);
    @addConstraint(m, -inputs[6] <= input_lim6[k]);
    @addConstraint(m, inputs[7] <= input_lim7[k]);
    @addConstraint(m, -inputs[7] <= input_lim7[k]);
    @addConstraint(m, inputs[8] <= input_lim8[k]);
    @addConstraint(m, -inputs[8] <= input_lim8[k]);
    objective = objective + (15^k)*state_lim[k] + (0^k)*(input_lim1[k] + input_lim2[k] + input_lim3[k]+ input_lim4[k] + input_lim5[k] + input_lim6[k] + input_lim7[k] + input_lim8[k]);
  end
  @addConstraint(m, sum(inputs[j=1:8] - prev_input) <= diff);
  @addConstraint(m, sum(-inputs[j=1:8] + prev_input) <= diff);
  objective = objective;
  @addConstraint(m, (states[controlIndex, N] - x_final[controlIndex]) <= state_lim[N]);
  @addConstraint(m, -(states[controlIndex, N] - x_final[controlIndex]) <= state_lim[N]);
  objective = objective + (15^N)*state_lim[N];
  #objective = objective[1];
  @setObjective(m, Min, objective);

  solve(m)
  return getValue(inputs);
end
