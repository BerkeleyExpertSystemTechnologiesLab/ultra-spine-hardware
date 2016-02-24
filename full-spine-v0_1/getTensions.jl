function getTensions(x2,y2,z2,T2,G2,P2,dx2,dy2,dz2,dT2,dG2,dP2,inp1,inp2,inp3,inp4,inp5,inp6,inp7,inp8,u1,u2,u3,u4,u5,u6,u7,u8)
  K = 2000;
  c = -100;
  x2 = x2 + (abs(x2)<1e-8)*1e-6;
  y2 = y2 + (abs(y2)<1e-8)*1e-6;
  z2 = z2 + (abs(z2)<1e-8)*1e-6;
  T2 = T2 + (abs(T2)<1e-8)*1e-6;
  G2 = G2 + (abs(G2)<1e-8)*1e-6;
  P2 = P2 + (abs(P2)<1e-8)*1e-6;

  L = lengths(x2,y2,z2,T2,G2,P2);
  dlengths = dlengths_dt(x2,y2,z2,T2,G2,P2,dx2,dy2,dz2,dT2,dG2,dP2);

  stretch_length = zeros(8, 1);
  stretch_length[1] = L[1] - u1 + inp1;
  stretch_length[2] = L[2] - u2 + inp2;
  stretch_length[3] = L[3] - u3 + inp3;
  stretch_length[4] = L[4] - u4 + inp4;
  stretch_length[5] = L[5] - u5 + inp5;
  stretch_length[6] = L[6] - u6 + inp6;
  stretch_length[7] = L[7] - u7 + inp7;
  stretch_length[8] = L[8] - u8 + inp8;
  Te = (stretch_length .> 0) .* ((K*stretch_length) -(c*dlengths));
  Te = max(Te, 0);
  return Te;
end