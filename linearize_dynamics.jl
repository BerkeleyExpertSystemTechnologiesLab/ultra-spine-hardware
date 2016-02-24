function linearize_dynamics(xbar, ubar, restLengths, dt)
  eps = .001;
  A = zeros(12, 12);

  for k = 1:12
      xlinU = zeros(12, 1);
      xlinL = zeros(12, 1);
      xlinU[k] = eps;
      xlinL[k] = -eps;
      A[:, k] = (simulate_dynamics(xbar + xlinU, restLengths, ubar, dt) - simulate_dynamics(xbar + xlinL, restLengths, ubar, dt))./(2*eps);
  end

  B = zeros(12, 8);
  for k = 1:8
      ulinU = zeros(8, 1);
      ulinL = zeros(8, 1);
      ulinU[k] = eps;
      ulinL[k] = -eps;
      B[:, k] = (simulate_dynamics(xbar, restLengths, ubar + ulinU, dt) - simulate_dynamics(xbar, restLengths, ubar + ulinL, dt))./(2*eps);
  end

  c = zeros(12, 1);
  c = simulate_dynamics(xbar, restLengths, ubar, dt) - A*xbar - B*ubar;

  linearized = cell(3);
  linearized[1] = A;
  linearized[2] = B;
  linearized[3] = c;

  return linearized;
end