SUBROUTINE SetParameters

USE Parameters
USE Globals
USE random

IMPLICIT NONE


INTEGER	   		:: iseed(2),isize
INTEGER			:: in,it

OutputDir = "earnings_estimation_output/"

Display							= 0
SaveSimulations 		= 1
RevertToMedianWithSkew 	= 0
UseNormalDist 			= 1
UseDoubleParetoDist = 0
Include2ndProcess 	= 1
AdditiveDrift 			= 0


EstimateLambda1 = 1
EstimateZeta1P 	= 0
EstimateZeta1N 	= 0
EstimateLambda2 = 1
EstimateZeta2P 	= 0
EstimateZeta2N 	= 0
EstimateRho1 		= 0
EstimateRho2 		= 0
EstimateSigma1 	= 1
EstimateSigma2 	= 1
EstimateDelta1 	= 1
EstimateDelta2 	= 1

MatchVarLogY 			= 1
MatchVarD1LogY 		= 1
MatchSkewD1LogY 	= 0!1 		!Set to 1 when matching Mexico
MatchKurtD1LogY 	= 1
MatchVarD5LogY  	= 1
MatchSkewD5LogY 	= 0
MatchKurtD5LogY 	= 1
MatchFracD1Less5 	= 0
MatchFracD1Less10 = 1
MatchFracD1Less20 = 1
MatchFracD1Less50 = 1

!USA
!TargetVarLogY 	 = 0.7
!TargetVarD1LogY	 = 0.23
!TargetSkewD1LogY = -1.35
!TargetKurtD1LogY = 17.8
!TargetVarD5LogY  = 0.46
!TargetSkewD5LogY = -1.01
!TargetKurtD5LogY = 11.55
!TargetFracD1Less5 = 0.35
!TargetFracD1Less10 = 0.54
!TargetFracD1Less20 = 0.71
!TargetFracD1Less50 = 0.86

!Mexico
!TargetVarLogY				=	0.7183
!TargetVarD1LogY			=	0.0661
!TargetSkewD1LogY		=	-0.1213
!TargetKurtD1LogY		=	17.0877
!TargetVarD5LogY			=	0.2332
!TargetSkewD5LogY		=	-0.0854
!TargetKurtD5LogY		=	8.9691
!TargetFracD1Less5		=	0.3
!TargetFracD1Less10	=	0.60187
!TargetFracD1Less20	=	0.768761
!TargetFracD1Less50	=	0.941248

!Mexico, Counterfactual
TargetVarLogY				=	0.551333
TargetVarD1LogY			=	0.109460
TargetSkewD1LogY		=	-0.1213
TargetKurtD1LogY		=	15.316316
TargetVarD5LogY			=	0.308008
TargetSkewD5LogY		=	-0.0854
TargetKurtD5LogY		=	9.608139
TargetFracD1Less5		=	0.3
TargetFracD1Less10	=	0.582200
TargetFracD1Less20	=	0.724600
TargetFracD1Less50	=	0.906560

ndfls = 3
rhobeg = 5.0
rhoend = 1.0D-4
iprint = 4
lambdamax = 2.0	!jump process cant arrive more frequently than quarterly on average
sigmamax = 2.0
zetamax = 1000.0
zetamin = 1.0
deltamax = 1.0

CALL system ("mkdir -p " // trim(OutputDir))


!set random seed
isize = 2
!US
iseed(1) = 7755
iseed(2) = 7744

!MX
!iseed(1) = 2457
!iseed(2) = 2456

CALL RANDOM_SEED(size = isize)
CALL RANDOM_SEED(put = iseed)
CALL RANDOM_NUMBER(y1jumprand)
CALL RANDOM_NUMBER(y2jumprand)
IF (UseNormalDist==1) THEN
	DO in = 1,nsim
	DO it = 1,Tsim
			y1rand(in,it) = random_normal()
			y2rand(in,it) = random_normal()
	END DO
	END DO
ELSE IF (UseDoubleParetoDist==1) THEN
	CALL RANDOM_NUMBER(y1rand)
	CALL RANDOM_NUMBER(y2rand)
END IF
END SUBROUTINE SetParameters
