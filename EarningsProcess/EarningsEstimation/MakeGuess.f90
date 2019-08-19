SUBROUTINE MakeGuess

USE Parameters
USE Globals

IMPLICIT NONE


lambda1guess 	= 0.08
rho1guess 		= 0.0
sigma1guess 	= 1.6
delta1guess 	= 0.7
zeta1guess 		= 5.0


lambda2guess 	= 0.001
rho2guess 		= 0.0
sigma2guess 	= 1.6
!delta2guess 	= 0.007
delta2guess 	= 0.0038434 !for a half life of 45 years (compute through AR process y2 = (1-delta2)*y2(-1)+e)
zeta2guess 		= 10.0

END SUBROUTINE MakeGuess
