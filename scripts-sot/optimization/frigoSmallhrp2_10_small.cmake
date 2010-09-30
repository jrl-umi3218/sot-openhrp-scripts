debugtrace true

echo Setting up the fridge demo

dyn.createOpPoint rh 22
# done in forceL dyn.createOpPoint lh 29

new OpPointModifior rh
new Compose<R+T> rhPose
set rhPose.in1 [3,3]((1,0,0),(0,1,0),(0,0,1))
new VectorConstant rhPoint
rhPoint.resize 3
rhPoint.fill 0
# rhPoint.[] 2 -.08
rhPoint.[] 2 -.18
plug rhPoint.out rhPose.in2
compute rhPose.out 
rh.transfoSignal rhPose.out
plug dyn.Jrh rh.jacobianIN
plug dyn.rh rh.positionIN

new OpPointModifior lh
new Compose<R+T> lhPose
set lhPose.in1 [3,3]((1,0,0),(0,1,0),(0,0,1))
new VectorConstant lhPoint
lhPoint.resize 3
lhPoint.fill 0
lhPoint.[] 2 -.08
lhPoint.[] 1 .01
plug lhPoint.out lhPose.in2
compute lhPose.out 
lh.transfoSignal lhPose.out
plug dyn.Jlh lh.jacobianIN
plug dyn.lh lh.positionIN

new Selec<vector> griperRhPos
plug OpenHRP.state griperRhPos.in
griperRhPos.selec 28 29

new Selec<vector> griperLhPos
plug OpenHRP.state griperLhPos.in
griperLhPos.selec 35 38

new MatrixConstant JgripRh
JgripRh.resize 1 38
JgripRh.fill 0
JgripRh.[] 0 28 1

new MatrixConstant JgripLh
JgripLh.resize 1 38
JgripLh.fill 0
JgripLh.[] 0 35 1

plug dyn.Jrh JRHact.in

wsot.clear
wsot.clearConstraint

sot.clear
sot.clearConstraint
# plug sot.control controlsmall.in1

# set friction.in [6](150,150,150,.9,.9,.9)
set friction.in [6](150,150,150,3,3,3)

new FeatureGeneric p5
plug rh.jacobian p5.jacobianIN
new Task taskForce5
taskForce5.add p5
plug forceInt.velocity p5.errorIN
set taskForce5.controlGain -.4
p5.dimDefault 6
set taskForce5.controlGain -1
set p5.selec 111011

taskForce.unselec :
taskForce.selec 16:22
taskForceLH.unselec :
taskForceLH.selec 23:29

new Sequencer seq
seq.sot sot
seq.stop
seq.reset
seq.verbose
OpenHRP.periodicCallBefore addSignal seq.trigger

new DirtyMemory sotmemory
# squeeze controlsmall.in1 sotmemory.in sotmemory.out

compute sot.control

# --- TASK DEF ----------------------------
# --- TASK DEF ----------------------------
# --- TASK DEF ----------------------------


# --- T0__RIGHT_HAND_TASK_OPENING
# --- GRIPPER
new Task T0__RIGHT_HAND_TASK_OPENING
new GainAdaptive gainT0__RIGHT_HAND_TASK_OPENING
plug T0__RIGHT_HAND_TASK_OPENING.error gainT0__RIGHT_HAND_TASK_OPENING.error
plug gainT0__RIGHT_HAND_TASK_OPENING.gain T0__RIGHT_HAND_TASK_OPENING.controlGain
gainT0__RIGHT_HAND_TASK_OPENING.setConstant .1
new FeatureGeneric featureT0
new FeatureGeneric featureT0des
plug JgripRh.out  featureT0.jacobianIN 
plug griperRhPos.out featureT0.errorIN
set featureT0.sdes featureT0des
# set featureT0des.errorIN [1](0.2)
T0__RIGHT_HAND_TASK_OPENING.add featureT0

# --- T1a__RIGHT_ARM_TASK_FRIDGE_UP
# --- Position task
new TaskConti T1a__RIGHT_ARM_TASK_FRIDGE_UP
T1a__RIGHT_ARM_TASK_FRIDGE_UP.touch sot.control
T1a__RIGHT_ARM_TASK_FRIDGE_UP.mu 8
T1a__RIGHT_ARM_TASK_FRIDGE_UP.unselec :
T1a__RIGHT_ARM_TASK_FRIDGE_UP.selec 16:22
new GainAdaptive gainT1a__RIGHT_ARM_TASK_FRIDGE_UP
plug T1a__RIGHT_ARM_TASK_FRIDGE_UP.error gainT1a__RIGHT_ARM_TASK_FRIDGE_UP.error
plug gainT1a__RIGHT_ARM_TASK_FRIDGE_UP.gain T1a__RIGHT_ARM_TASK_FRIDGE_UP.controlGain
gainT1a__RIGHT_ARM_TASK_FRIDGE_UP.setConstant .1
new FeaturePoint6d featureT1a
new FeaturePoint6d featureT1ades
set featureT1a.sdes featureT1ades
plug rh.position featureT1a.position
plug rh.jacobian featureT1a.Jq
new PoseUThetaToMatrixHomo posdesT1a
plug posdesT1a.out featureT1ades.position
# set posdesT1a.in [6](0,0,0,0,0,0)
T1a__RIGHT_ARM_TASK_FRIDGE_UP.add featureT1a

# --- T1__RIGHT_ARM_TASK_FRIDGE_UP
# --- Position task
new TaskConti T1__RIGHT_ARM_TASK_FRIDGE_UP
T1__RIGHT_ARM_TASK_FRIDGE_UP.touch sot.control
T1__RIGHT_ARM_TASK_FRIDGE_UP.mu 8
T1__RIGHT_ARM_TASK_FRIDGE_UP.unselec :
T1__RIGHT_ARM_TASK_FRIDGE_UP.selec 16:22
new GainAdaptive gainT1__RIGHT_ARM_TASK_FRIDGE_UP
plug T1__RIGHT_ARM_TASK_FRIDGE_UP.error gainT1__RIGHT_ARM_TASK_FRIDGE_UP.error
plug gainT1__RIGHT_ARM_TASK_FRIDGE_UP.gain T1__RIGHT_ARM_TASK_FRIDGE_UP.controlGain
gainT1__RIGHT_ARM_TASK_FRIDGE_UP.setConstant .1
new FeaturePoint6d featureT1
new FeaturePoint6d featureT1des
set featureT1.sdes featureT1des
plug rh.position featureT1.position
plug rh.jacobian featureT1.Jq
new PoseUThetaToMatrixHomo posdesT1
plug posdesT1.out featureT1des.position
# set posdesT1.in [6](0,0,0,0,0,0)
T1__RIGHT_ARM_TASK_FRIDGE_UP.add featureT1


# --- T2__RIGHT_HAND_TASK_CLOSING
# --- GRIPPER
new TaskConti T2__RIGHT_HAND_TASK_CLOSING
T2__RIGHT_HAND_TASK_CLOSING.touch sot.control
T2__RIGHT_HAND_TASK_CLOSING.mu 8
new GainAdaptive gainT2__RIGHT_HAND_TASK_CLOSING
plug T2__RIGHT_HAND_TASK_CLOSING.error gainT2__RIGHT_HAND_TASK_CLOSING.error
plug gainT2__RIGHT_HAND_TASK_CLOSING.gain T2__RIGHT_HAND_TASK_CLOSING.controlGain
gainT2__RIGHT_HAND_TASK_CLOSING.setConstant .1
new FeatureGeneric featureT2
new FeatureGeneric featureT2des
plug JgripRh.out  featureT2.jacobianIN 
plug griperRhPos.out featureT2.errorIN
set featureT2.sdes featureT2des
# set featureT2des.errorIN [1](0.2)
T2__RIGHT_HAND_TASK_CLOSING.add featureT2

# --- T3__RIGHT_ARM_TASK_FRIDGE_UP_OPENING
# --- FRIDGE
new Task T3__RIGHT_ARM_TASK_FRIDGE_UP_OPENING
T3__RIGHT_ARM_TASK_FRIDGE_UP_OPENING.unselec :
T3__RIGHT_ARM_TASK_FRIDGE_UP_OPENING.selec 16:22
new GainAdaptive gainT3__RIGHT_ARM_TASK_FRIDGE_UP_OPENING
plug T3__RIGHT_ARM_TASK_FRIDGE_UP_OPENING.error gainT3__RIGHT_ARM_TASK_FRIDGE_UP_OPENING.error
# plug gainT3__RIGHT_ARM_TASK_FRIDGE_UP_OPENING.gain T3__RIGHT_ARM_TASK_FRIDGE_UP_OPENING.controlGain
gainT3__RIGHT_ARM_TASK_FRIDGE_UP_OPENING.setConstant .1

new FeaturePoint6d distanceT3
new FeaturePoint6d distanceT3des
set distanceT3.sdes distanceT3des
set distanceT3.selec 111
plug rh.position distanceT3.position
# plug rh.jacobian distanceT3.Jq
new Compose<R+T> wMhdT3
set wMhdT3.in1 [3,3]((1,0,0),(0,1,0),(0,0,1))
# set wMhdT3.in2 [3](0,0,0)
plug wMhdT3.out distanceT3des.position

new Nullificator nullT3
plug distanceT3.error nullT3.in1
set nullT3.in2 [3](.05,.05,.1)
new WeightDir errorT3
plug nullT3.out errorT3.in1
set errorT3.in2 [3](0,0,-1)

new FeatureGeneric featureT3
set featureT3.selec 100
plug errorT3.out featureT3.errorIN
plug rh.jacobian featureT3.jacobianIN

new TaskConti T3_position
T3_position.touch sot.control
T3_position.mu 8
T3_position.add featureT3
plug T3_position.error gainT3__RIGHT_ARM_TASK_FRIDGE_UP_OPENING.error
plug gainT3__RIGHT_ARM_TASK_FRIDGE_UP_OPENING.gain T3_position.controlGain

new FeatureTask T3_fpos
T3_fpos.task T3_position
new FeatureTask T3_fforce
T3_fforce.task taskForce5

T3__RIGHT_ARM_TASK_FRIDGE_UP_OPENING.add T3_fforce
T3__RIGHT_ARM_TASK_FRIDGE_UP_OPENING.add T3_fpos
set T3__RIGHT_ARM_TASK_FRIDGE_UP_OPENING.controlGain 1

# --- T4__RIGHT_ARM_TASK_FRIDGE_UP_CLOSING
# --- FRIDGE

new Task T4__RIGHT_ARM_TASK_FRIDGE_UP_CLOSING
T4__RIGHT_ARM_TASK_FRIDGE_UP_CLOSING.unselec :
T4__RIGHT_ARM_TASK_FRIDGE_UP_CLOSING.selec 16:22
new GainAdaptive gainT4__RIGHT_ARM_TASK_FRIDGE_UP_CLOSING
plug T4__RIGHT_ARM_TASK_FRIDGE_UP_CLOSING.error gainT4__RIGHT_ARM_TASK_FRIDGE_UP_CLOSING.error
# plug gainT4__RIGHT_ARM_TASK_FRIDGE_UP_CLOSING.gain T4__RIGHT_ARM_TASK_FRIDGE_UP_CLOSING.controlGain
gainT4__RIGHT_ARM_TASK_FRIDGE_UP_CLOSING.setConstant .1

new FeaturePoint6d distanceT4
new FeaturePoint6d distanceT4des
set distanceT4.sdes distanceT4des
set distanceT4.selec 111
plug rh.position distanceT4.position
# plug rh.jacobian distanceT4.Jq
new Compose<R+T> wMhdT4
set wMhdT4.in1 [3,3]((1,0,0),(0,1,0),(0,0,1))
# set wMhdT4.in2 [3](0,0,0)
plug wMhdT4.out distanceT4des.position

new Nullificator nullT4
plug distanceT4.error nullT4.in1
set nullT4.in2 [3](.05,.05,.1)
new WeightDir errorT4
plug nullT4.out errorT4.in1
set errorT4.in2 [3](0,0,1)

new FeatureGeneric featureT4
set featureT4.selec 100
plug errorT4.out featureT4.errorIN
plug rh.jacobian featureT4.jacobianIN

new TaskConti T4_position
T4_position.touch sot.control
T4_position.mu 8
T4_position.add featureT4
plug T4_position.error gainT4__RIGHT_ARM_TASK_FRIDGE_UP_CLOSING.error
plug gainT4__RIGHT_ARM_TASK_FRIDGE_UP_CLOSING.gain T4_position.controlGain

new FeatureTask T4_fpos
T4_fpos.task T4_position
new FeatureTask T4_fforce
T4_fforce.task taskForce5

T4__RIGHT_ARM_TASK_FRIDGE_UP_CLOSING.add T4_fforce
T4__RIGHT_ARM_TASK_FRIDGE_UP_CLOSING.add T4_fpos
set T4__RIGHT_ARM_TASK_FRIDGE_UP_CLOSING.controlGain 1

# --- T5__LEFT_HAND_TASK_OPENING
# --- GRIPPER
new Task T5__LEFT_HAND_TASK_OPENING
new GainAdaptive gainT5__LEFT_HAND_TASK_OPENING
plug T5__LEFT_HAND_TASK_OPENING.error gainT5__LEFT_HAND_TASK_OPENING.error
plug gainT5__LEFT_HAND_TASK_OPENING.gain T5__LEFT_HAND_TASK_OPENING.controlGain
gainT5__LEFT_HAND_TASK_OPENING.setConstant .1
new FeatureGeneric featureT5
new FeatureGeneric featureT5des
plug JgripLh.out  featureT5.jacobianIN 
plug griperLhPos.out featureT5.errorIN
set featureT5.sdes featureT5des
# set featureT5des.errorIN [1](0.2)
T5__LEFT_HAND_TASK_OPENING.add featureT5

# --- T6__LEFT_ARM_TASK
# --- Position task
 new TaskConti T6__LEFT_ARM_TASK
T6__LEFT_ARM_TASK.touch sot.control
T6__LEFT_ARM_TASK.mu 8
T6__LEFT_ARM_TASK.unselec :
T6__LEFT_ARM_TASK.selec 23:29
new GainAdaptive gainT6__LEFT_ARM_TASK
plug T6__LEFT_ARM_TASK.error gainT6__LEFT_ARM_TASK.error
plug gainT6__LEFT_ARM_TASK.gain T6__LEFT_ARM_TASK.controlGain
gainT6__LEFT_ARM_TASK.setConstant .1
new FeaturePoint6d featureT6
new FeaturePoint6d featureT6des
set featureT6.sdes featureT6des
plug lh.position featureT6.position
plug lh.jacobian featureT6.Jq
new PoseUThetaToMatrixHomo posdesT6
plug posdesT6.out featureT6des.position
# set posdesT6.in [6](0,0,0,0,0,0)
T6__LEFT_ARM_TASK.add featureT6

# --- T7__LEFT_ARM_TASK_CAN
# --- Position task
new TaskConti T7__LEFT_ARM_TASK_CAN
T7__LEFT_ARM_TASK_CAN.touch sot.control
T7__LEFT_ARM_TASK_CAN.mu 8
T7__LEFT_ARM_TASK_CAN.unselec :
T7__LEFT_ARM_TASK_CAN.selec 23:29
new GainAdaptive gainT7__LEFT_ARM_TASK_CAN
plug T7__LEFT_ARM_TASK_CAN.error gainT7__LEFT_ARM_TASK_CAN.error
plug gainT7__LEFT_ARM_TASK_CAN.gain T7__LEFT_ARM_TASK_CAN.controlGain
gainT7__LEFT_ARM_TASK_CAN.setConstant .1
new FeaturePoint6d featureT7
new FeaturePoint6d featureT7des
set featureT7.sdes featureT7des
plug lh.position featureT7.position
plug lh.jacobian featureT7.Jq
new PoseUThetaToMatrixHomo posdesT7
plug posdesT7.out featureT7des.position
# set posdesT7.in [6](0,0,0,0,0,0)
T7__LEFT_ARM_TASK_CAN.add featureT7

# --- T8__LEFT_HAND_TASK_CLOSING
# --- Position task
new Task T8__LEFT_HAND_TASK_CLOSING
new GainAdaptive gainT8__LEFT_HAND_TASK_CLOSING
plug T8__LEFT_HAND_TASK_CLOSING.error gainT8__LEFT_HAND_TASK_CLOSING.error
plug gainT8__LEFT_HAND_TASK_CLOSING.gain T8__LEFT_HAND_TASK_CLOSING.controlGain
gainT8__LEFT_HAND_TASK_CLOSING.setConstant .1
new FeatureGeneric featureT8
new FeatureGeneric featureT8des
plug JgripLh.out  featureT8.jacobianIN 
plug griperLhPos.out featureT8.errorIN
set featureT8.sdes featureT8des
# set featureT8des.errorIN [1](0.2)
T8__LEFT_HAND_TASK_CLOSING.add featureT8

# --- T9__LEFT_ARM_TASK_MOVETO
# --- Position task
new TaskConti T9__LEFT_ARM_TASK_MOVETO
T9__LEFT_ARM_TASK_MOVETO.touch sot.control
T9__LEFT_ARM_TASK_MOVETO.mu 8
T9__LEFT_ARM_TASK_MOVETO.unselec :
T9__LEFT_ARM_TASK_MOVETO.selec 23:29
new GainAdaptive gainT9__LEFT_ARM_TASK_MOVETO
plug T9__LEFT_ARM_TASK_MOVETO.error gainT9__LEFT_ARM_TASK_MOVETO.error
plug gainT9__LEFT_ARM_TASK_MOVETO.gain T9__LEFT_ARM_TASK_MOVETO.controlGain
gainT9__LEFT_ARM_TASK_MOVETO.setConstant .1
new FeaturePoint6d featureT9
new FeaturePoint6d featureT9des
set featureT9.sdes featureT9des
plug lh.position featureT9.position
plug lh.jacobian featureT9.Jq
new PoseUThetaToMatrixHomo posdesT9
plug posdesT9.out featureT9des.position
# set posdesT9.in [6](0,0,0,0,0,0)
T9__LEFT_ARM_TASK_MOVETO.add featureT9

# --- T9b__LEFT_ARM_TASK_MOVETO
# --- Position task
new TaskConti T9b__LEFT_ARM_TASK_MOVETO
T9b__LEFT_ARM_TASK_MOVETO.touch sot.control
T9b__LEFT_ARM_TASK_MOVETO.mu 8
T9b__LEFT_ARM_TASK_MOVETO.unselec :
T9b__LEFT_ARM_TASK_MOVETO.selec 23:29
new GainAdaptive gainT9b__LEFT_ARM_TASK_MOVETO
plug T9b__LEFT_ARM_TASK_MOVETO.error gainT9b__LEFT_ARM_TASK_MOVETO.error
plug gainT9b__LEFT_ARM_TASK_MOVETO.gain T9b__LEFT_ARM_TASK_MOVETO.controlGain
gainT9b__LEFT_ARM_TASK_MOVETO.setConstant .1
new FeaturePoint6d featureT9b
new FeaturePoint6d featureT9bdes
set featureT9b.sdes featureT9bdes
plug lh.position featureT9b.position
plug lh.jacobian featureT9b.Jq
new PoseUThetaToMatrixHomo posdesT9b
plug posdesT9b.out featureT9bdes.position
# set posdesT9b.in [6](0,0,0,0,0,0)
T9b__LEFT_ARM_TASK_MOVETO.add featureT9b

# --- T10__LEFT_ARM_TASK
# --- Position task
new TaskConti T10__LEFT_ARM_TASK
T10__LEFT_ARM_TASK.touch sot.control
T10__LEFT_ARM_TASK.mu 8
T10__LEFT_ARM_TASK.unselec :
T10__LEFT_ARM_TASK.selec 23:29
new GainAdaptive gainT10__LEFT_ARM_TASK
plug T10__LEFT_ARM_TASK.error gainT10__LEFT_ARM_TASK.error
plug gainT10__LEFT_ARM_TASK.gain T10__LEFT_ARM_TASK.controlGain
gainT10__LEFT_ARM_TASK.setConstant .1
new FeaturePoint6d featureT10
new FeaturePoint6d featureT10des
set featureT10.sdes featureT10des
plug lh.position featureT10.position
plug lh.jacobian featureT10.Jq
new PoseUThetaToMatrixHomo posdesT10
plug posdesT10.out featureT10des.position
# set posdesT10.in [6](0,0,0,0,0,0)
T10__LEFT_ARM_TASK.add featureT10




# --- CONFIG

# Value griper task 0 (OPEN)
set featureT0des.errorIN [1](0.5)

# Pose finale task1a
set featureT1ades.position [4,4]((-0.005276,-0.796785,-0.604240,0.424558),(-0.048169,0.603749,-0.795718,-0.145166),(0.998825,0.024908,-0.041566,0.926794),(0.000000,0.000000,0.000000,1.000000))

	
# Pose finale task1
set featureT1des.position [4,4]((0.000358,-0.750394,-0.660991,0.499870),(-0.080926,0.658801,-0.747952,-0.057798),(0.996720,0.053759,-0.060491,0.960079),(0.000000,0.000000,0.000000,1.000000))
	
# Value griper task 2 (CLOSE FRIDGE)
set featureT2des.errorIN [1](0.125)

# Pose finale tak3: end fridge operture
set wMhdT3.in2 [3](0.365623,-0.305074,0.952690) 

# Pose finale tak4: end fridge closure
set wMhdT4.in2 [3](0.499870,-0.057798,0.960079)

# Value griper task 5 (OPEN)
set featureT5des.errorIN [1](0.65)

# Pose finale task 6 (Before can)
# set posdesT6.in [6](0,0,0,0,0,0)
# set featureT6des.position [4,4]((-0.035647,0.468735,-0.882619,0.315862),(0.061983,0.882517,0.466177,0.094088),(0.997440,-0.038090,-0.060513,0.926075),(0.000000,0.000000,0.000000,1.000000))
# set featureT6des.position [4,4]((-0.073984,0.739868,-0.668671,0.278641),(0.062612,0.672632,0.737323,0.136304),(0.995292,0.012683,-0.096089,0.881805),(0.000000,0.000000,0.000000,1.000000))
set featureT6des.position [4,4]((-0.073984,0.739868,-0.668671,0.278641),(0.062612,0.672632,0.737323,0.136304),(0.995292,0.012683,-0.096089,0.921805),(0.000000,0.000000,0.000000,1.000000))

# Pose finale task 7 (Grasp can)
# set posdesT7.in [6](0,0,0,0,0,0)
# set featureT7des.position [4,4]((0.136644,0.670594,-0.729131,0.455290),(0.175846,0.707926,0.684046,-0.049518),(0.974888,-0.221685,-0.021187,0.910358),(0.000000,0.000000,0.000000,1.000000))
set featureT7des.position [4,4]((0.054534,0.677617,-0.733390,0.436530),(0.115874,0.725226,0.678690,-0.064603),(0.991766,-0.121993,-0.038969,0.923588),(0.000000,0.000000,0.000000,1.000000))

# Value griper task 8 (CLOSE CAN)
set featureT8des.errorIN [1](0.41)

# Pose finale task 9 (up can)
# set posdesT9.in [6](0,0,0,0,0,0)
# set featureT9des.position [4,4]((0.147747,0.693103,-0.705535,0.474954),(0.134011,0.692756,0.708612,-0.033058),(0.979904,-0.199245,0.009469,1.061060),(0.000000,0.000000,0.000000,1.000000))
set featureT9des.position [4,4]((0.054534,0.677617,-0.733390,0.436530),(0.115874,0.725226,0.678690,-0.064603),(0.991766,-0.121993,-0.038969,1.063588),(0.000000,0.000000,0.000000,1.000000))

# Pose finale task 9b inter (remove can inter)
set featureT9bdes.position [4,4]((-0.058375,0.766142,-0.640015,0.361451),(0.038803,0.642365,0.765416,0.092456),(0.997540,0.019847,-0.067227,1.037440),(0.000000,0.000000,0.000000,1.000000))

# Pose finale task 10 (remove can)
# set posdesT10.in [6](0,0,0,0,0,0)
set featureT10des.position [4,4]((0.627151,0.348653,-0.696508,0.216738),(-0.231837,0.937250,0.260412,0.183420),(0.743595,-0.001841,0.668628,0.630962),(0.000000,0.000000,0.000000,1.000000))

# --- GAINS
gainT0__RIGHT_HAND_TASK_OPENING.setConstant 1
gainT1__RIGHT_ARM_TASK_FRIDGE_UP.setConstant .8
gainT2__RIGHT_HAND_TASK_CLOSING.setConstant 1
gainT3__RIGHT_ARM_TASK_FRIDGE_UP_OPENING.setConstant .15
gainT4__RIGHT_ARM_TASK_FRIDGE_UP_CLOSING.setConstant .15
gainT5__LEFT_HAND_TASK_OPENING.setConstant 1
gainT6__LEFT_ARM_TASK.setConstant .1
gainT7__LEFT_ARM_TASK_CAN.setConstant .3
gainT8__LEFT_HAND_TASK_CLOSING.setConstant 1
gainT9__LEFT_ARM_TASK_MOVETO.setConstant .3
gainT10__LEFT_ARM_TASK.setConstant .3

gainT1a__RIGHT_ARM_TASK_FRIDGE_UP.setConstant .2
gainT9b__LEFT_ARM_TASK_MOVETO.setConstant .1

new PeriodicCallEntity nextcall
OpenHRP.periodicCall addSignal nextcall.trigerOnce

proc reinit()
-> proc next
-> -> nextcall.addCmd sot.push T0__RIGHT_HAND_TASK_OPENING
-> -> proc next
-> -> -> nextcall.addCmd sot.clear
-> -> -> nextcall.addCmd sot.push T1a__RIGHT_ARM_TASK_FRIDGE_UP
-> -> -> proc next
-> -> -> -> nextcall.addCmd sot.clear
-> -> -> -> nextcall.addCmd sot.push T1__RIGHT_ARM_TASK_FRIDGE_UP
-> -> -> -> proc next
-> -> -> -> -> nextcall.addCmd sot.clear
-> -> -> -> -> nextcall.addCmd sot.push T2__RIGHT_HAND_TASK_CLOSING
-> -> -> -> -> proc next
-> -> -> -> -> -> resettr()
-> -> -> -> -> -> nextcall.addCmd sot.clear
-> -> -> -> -> -> nextcall.addCmd sot.push T3__RIGHT_ARM_TASK_FRIDGE_UP_OPENING
# -> -> -> -> -> -> nextcall.addCmd sot.push T1__RIGHT_ARM_TASK_FRIDGE_UP
# -> -> -> -> -> -> set featureT1des.position [4,4]((0.011901,-0.624500,-0.780934,0.295696),(0.018045,0.780996,-0.624275,-0.387618),(0.999766,-0.006663,0.020563,0.972299),(0.000000,0.000000,0.000000,1.000000))
-> -> -> -> -> -> proc next
-> -> -> -> -> -> -> nextcall.addCmd sot.clear
-> -> -> -> -> -> -> nextcall.addCmd sot.push T5__LEFT_HAND_TASK_OPENING
-> -> -> -> -> -> -> proc next
-> -> -> -> -> -> -> -> nextcall.addCmd sot.clear
-> -> -> -> -> -> -> -> nextcall.addCmd sot.push T6__LEFT_ARM_TASK
-> -> -> -> -> -> -> -> proc next
-> -> -> -> -> -> -> -> -> nextcall.addCmd sot.clear
-> -> -> -> -> -> -> -> -> nextcall.addCmd sot.push T7__LEFT_ARM_TASK_CAN
-> -> -> -> -> -> -> -> -> proc next
-> -> -> -> -> -> -> -> -> -> nextcall.addCmd sot.clear
-> -> -> -> -> -> -> -> -> -> nextcall.addCmd sot.push T8__LEFT_HAND_TASK_CLOSING
-> -> -> -> -> -> -> -> -> -> proc next
-> -> -> -> -> -> -> -> -> -> -> nextcall.addCmd sot.clear
-> -> -> -> -> -> -> -> -> -> -> nextcall.addCmd sot.push T9__LEFT_ARM_TASK_MOVETO
-> -> -> -> -> -> -> -> -> -> -> proc next
-> -> -> -> -> -> -> -> -> -> -> -> nextcall.addCmd sot.clear
-> -> -> -> -> -> -> -> -> -> -> -> nextcall.addCmd sot.push T9b__LEFT_ARM_TASK_MOVETO
-> -> -> -> -> -> -> -> -> -> -> -> proc next
-> -> -> -> -> -> -> -> -> -> -> -> -> nextcall.addCmd sot.clear
-> -> -> -> -> -> -> -> -> -> -> -> -> nextcall.addCmd sot.push T10__LEFT_ARM_TASK
-> -> -> -> -> -> -> -> -> -> -> -> -> proc next
-> -> -> -> -> -> -> -> -> -> -> -> -> -> nextcall.addCmd sot.clear
-> -> -> -> -> -> -> -> -> -> -> -> -> -> nextcall.addCmd sot.push T4__RIGHT_ARM_TASK_FRIDGE_UP_CLOSING
-> -> -> -> -> -> -> -> -> -> -> -> -> -> proc next
-> -> -> -> -> -> -> -> -> -> -> -> -> -> -> nextcall.addCmd sot.clear
-> -> -> -> -> -> -> -> -> -> -> -> -> -> -> echo Done,done, done ... it is done!
-> -> -> -> -> -> -> -> -> -> -> -> -> -> endproc
-> -> -> -> -> -> -> -> -> -> -> -> -> endproc
-> -> -> -> -> -> -> -> -> -> -> -> endproc
-> -> -> -> -> -> -> -> -> -> -> endproc
-> -> -> -> -> -> -> -> -> -> endproc
-> -> -> -> -> -> -> -> -> endproc
-> -> -> -> -> -> -> -> endproc
-> -> -> -> -> -> -> endproc
-> -> -> -> -> -> endproc
-> -> -> -> -> endproc
-> -> -> -> endproc
-> -> -> endproc
-> -> endproc
-> endproc
endproc
reinit()

proc nextNow
-> next
-> OpenHRP.inc
-> sot.print
endproc

proc urg
-> plug zeroCom.out controlsmall.in1
endproc

proc endOfUrg
-> plug sot.control controlsmall.in1
-> zeroCom.fill 0
endproc

proc addT0
-> echo "addT0 now"
-> nextcall.addCmd sot.push T0__RIGHT_HAND_TASK_OPENING
endproc

proc addT1
-> echo "addT1 now"
-> nextcall.addCmd sot.push T1__RIGHT_ARM_TASK_FRIDGE_UP
-> nextcall.addCmd T1__RIGHT_ARM_TASK_FRIDGE_UP.touch sot.control
endproc

proc addT2
-> echo "addT2 now"
-> nextcall.addCmd sot.push T2__RIGHT_HAND_TASK_CLOSING
endproc

proc addT3
-> echo "addT3 now"
-> nextcall.addCmd sot.push T3__RIGHT_ARM_TASK_FRIDGE_UP_OPENING
-> nextcall.addCmd T3_position.touch sot.control
endproc

proc addT4
-> echo "addT4 now"
-> nextcall.addCmd sot.push T4__RIGHT_ARM_TASK_FRIDGE_UP_CLOSING
-> nextcall.addCmd T4_position.touch sot.control
endproc

proc addT5
-> echo "addT5 now"
-> nextcall.addCmd sot.push T5__LEFT_HAND_TASK_OPENING
endproc

proc addT6
-> echo "addT6 now"
-> nextcall.addCmd T6__LEFT_ARM_TASK.touch sot.control
-> nextcall.addCmd sot.push T6__LEFT_ARM_TASK
endproc

proc addT7
-> echo "addT7 now"
-> nextcall.addCmd sot.push T7__LEFT_ARM_TASK_CAN
-> nextcall.addCmd T7__LEFT_ARM_TASK_CAN.touch sot.control
endproc

proc addT8
-> echo "addT8 now"
-> nextcall.addCmd sot.push T8__LEFT_HAND_TASK_CLOSING
endproc

proc addT9
-> echo "addT9 now"
-> nextcall.addCmd sot.push T9__LEFT_ARM_TASK_MOVETO
-> nextcall.addCmd T9__LEFT_ARM_TASK_MOVETO.touch sot.control
endproc

proc addT10
-> echo "addT10 now"
-> nextcall.addCmd sot.push T10__LEFT_ARM_TASK
-> nextcall.addCmd T10__LEFT_ARM_TASK.touch sot.control
endproc

proc addT1a
-> echo "addT1a now"
-> nextcall.addCmd sot.push T1a__RIGHT_ARM_TASK_FRIDGE_UP
-> nextcall.addCmd T1a__RIGHT_ARM_TASK_FRIDGE_UP.touch sot.control
endproc

proc addT9b
-> echo "addT9b now"
-> nextcall.addCmd sot.push T9b__LEFT_ARM_TASK_MOVETO
-> nextcall.addCmd T9b__LEFT_ARM_TASK_MOVETO.touch sot.control
endproc


proc addTfr
-> echo "addTfr now"
-> nextcall.addCmd sot.push taskForce
endproc

proc addTfl
-> echo "addTfl now"
-> nextcall.addCmd sot.push taskForceLH
endproc


proc closeR
-> echo "closeR now"
-> nextcall.addCmd sot.push T2__RIGHT_HAND_TASK_CLOSING
endproc

proc closeL
-> echo "closeL now"
-> nextcall.addCmd sot.push T8__LEFT_HAND_TASK_CLOSING
endproc

proc openR
-> echo "openR now"
-> nextcall.addCmd sot.push T0__RIGHT_HAND_TASK_OPENING
endproc

proc openL
-> echo "openL now"
-> nextcall.addCmd sot.push T5__LEFT_HAND_TASK_OPENING
endproc



# --- DEBUG ---
# OpenHRP.periodicCall addSignal T0__RIGHT_HAND_TASK_OPENING.task T0
# OpenHRP.periodicCall addSignal T1a__RIGHT_ARM_TASK_FRIDGE_UP.task
# OpenHRP.periodicCall addSignal T1__RIGHT_ARM_TASK_FRIDGE_UP.task T1
# OpenHRP.periodicCall addSignal T2__RIGHT_HAND_TASK_CLOSING.task T2
# OpenHRP.periodicCall addSignal T3__RIGHT_ARM_TASK_FRIDGE_UP_OPENING.task T3
# OpenHRP.periodicCall addSignal T4__RIGHT_ARM_TASK_FRIDGE_UP_CLOSING.task T4
# OpenHRP.periodicCall addSignal T5__LEFT_HAND_TASK_OPENING.task T5
# OpenHRP.periodicCall addSignal T6__LEFT_ARM_TASK.task T6
# OpenHRP.periodicCall addSignal T7__LEFT_ARM_TASK_CAN.task T7
# OpenHRP.periodicCall addSignal T8__LEFT_HAND_TASK_CLOSING.task T8
# OpenHRP.periodicCall addSignal T9__LEFT_ARM_TASK_MOVETO.task T9
# OpenHRP.periodicCall addSignal T9b__LEFT_ARM_TASK_MOVETO.task
# OpenHRP.periodicCall addSignal T10__LEFT_ARM_TASK.task T10

# tr.add T0__RIGHT_HAND_TASK_OPENING.error T0
# tr.add T1a__RIGHT_ARM_TASK_FRIDGE_UP.error T1a
# tr.add T1__RIGHT_ARM_TASK_FRIDGE_UP.error T1
# tr.add T2__RIGHT_HAND_TASK_CLOSING.error T2
# # tr.add T3__RIGHT_ARM_TASK_FRIDGE_UP_OPENING.error T3
# # tr.add T4__RIGHT_ARM_TASK_FRIDGE_UP_CLOSING.error T4
# tr.add distanceT3.error T3
# tr.add distanceT4.error T4
# tr.add T5__LEFT_HAND_TASK_OPENING.error T5
# tr.add T6__LEFT_ARM_TASK.error T6
# tr.add T7__LEFT_ARM_TASK_CAN.error T7
# tr.add T8__LEFT_HAND_TASK_CLOSING.error T8
# tr.add T9__LEFT_ARM_TASK_MOVETO.error T9
# tr.add T9b__LEFT_ARM_TASK_MOVETO.error T9b
# tr.add T10__LEFT_ARM_TASK.error T10

# tr.add T0__RIGHT_HAND_TASK_OPENING.task v0
# tr.add T1a__RIGHT_ARM_TASK_FRIDGE_UP.task v1a
# tr.add T1__RIGHT_ARM_TASK_FRIDGE_UP.task v1
# tr.add T2__RIGHT_HAND_TASK_CLOSING.task v2
# tr.add T3__RIGHT_ARM_TASK_FRIDGE_UP_OPENING.task v3
# tr.add T4__RIGHT_ARM_TASK_FRIDGE_UP_CLOSING.task v4
# tr.add T5__LEFT_HAND_TASK_OPENING.task v5
# tr.add T6__LEFT_ARM_TASK.task v6
# tr.add T7__LEFT_ARM_TASK_CAN.task v7
# tr.add T8__LEFT_HAND_TASK_CLOSING.task v8
# tr.add T9__LEFT_ARM_TASK_MOVETO.task v9
# tr.add T9b__LEFT_ARM_TASK_MOVETO.task v9b
# tr.add T10__LEFT_ARM_TASK.task v10

# tr.add rh.position rh 
# tr.add distanceT3.error T3
# tr.add gainT3__RIGHT_ARM_TASK_FRIDGE_UP_OPENING.gain gainT3

# tr.add gainT0__RIGHT_HAND_TASK_OPENING.gain gain0
# tr.add gainT1a__RIGHT_ARM_TASK_FRIDGE_UP.gain gain1a
# tr.add gainT1__RIGHT_ARM_TASK_FRIDGE_UP.gain  gain1


# tr.add OpenHRP.control hrpcontrol
# tr.add sot.control sotcontrol


# --- DEBUG ---
set sot.damping .08

# set featureT1.selec 111111
# featureT1.frame current
# T1__RIGHT_ARM_TASK_FRIDGE_UP.unselec :
# T1__RIGHT_ARM_TASK_FRIDGE_UP.selec 16:22
# set T1__RIGHT_ARM_TASK_FRIDGE_UP.controlGain .8

# plug dyn.rh featureT1.position
# plug dyn.Jrh featureT1.Jq



proc showJ
-> rh.jacobian
-> T3__RIGHT_ARM_TASK_FRIDGE_UP_OPENING.jacobian
endproc


proc showE
-> get rh.position
-> get wMhdT3.out
-> get hdT3Mh.out
-> T1__RIGHT_ARM_TASK_FRIDGE_UP.task
endproc

                                                         
seq.addEvent   add  2 T0__RIGHT_HAND_TASK_OPENING
seq.addEvent   rm   1005 T0__RIGHT_HAND_TASK_OPENING
seq.addEvent   add  0 T1a__RIGHT_ARM_TASK_FRIDGE_UP
seq.addEvent   rm   1429 T1a__RIGHT_ARM_TASK_FRIDGE_UP
seq.addEvent   add  1429 T1__RIGHT_ARM_TASK_FRIDGE_UP
seq.addEvent   rm   2369 T1__RIGHT_ARM_TASK_FRIDGE_UP
seq.addEvent   add  2369 T2__RIGHT_HAND_TASK_CLOSING
seq.addEvent   rm   10546 T2__RIGHT_HAND_TASK_CLOSING
seq.addEvent   add  2709 T3__RIGHT_ARM_TASK_FRIDGE_UP_OPENING
seq.addEvent   rm   7332 T3__RIGHT_ARM_TASK_FRIDGE_UP_OPENING
seq.addEvent   add  7421 T4__RIGHT_ARM_TASK_FRIDGE_UP_CLOSING
seq.addEvent   rm   9873 T4__RIGHT_ARM_TASK_FRIDGE_UP_CLOSING
seq.addEvent   add  0 T5__LEFT_HAND_TASK_OPENING
seq.addEvent   rm   3565 T5__LEFT_HAND_TASK_OPENING
seq.addEvent   add  265 T6__LEFT_ARM_TASK
seq.addEvent   rm   1948 T6__LEFT_ARM_TASK
seq.addEvent   add  3986 T7__LEFT_ARM_TASK_CAN
seq.addEvent   rm   5830 T7__LEFT_ARM_TASK_CAN
seq.addEvent   add  5830 T8__LEFT_HAND_TASK_CLOSING
seq.addEvent   rm   11172 T8__LEFT_HAND_TASK_CLOSING
seq.addEvent   add  6567 T9__LEFT_ARM_TASK_MOVETO
seq.addEvent   rm   7081 T9__LEFT_ARM_TASK_MOVETO
seq.addEvent   add  7081 T9b__LEFT_ARM_TASK_MOVETO
seq.addEvent   rm   7561 T9b__LEFT_ARM_TASK_MOVETO
seq.addEvent   add  7561 T10__LEFT_ARM_TASK
seq.addEvent   rm   11173 T10__LEFT_ARM_TASK

gainT0__RIGHT_HAND_TASK_OPENING.set 2.5    2.5    1
gainT1a__RIGHT_ARM_TASK_FRIDGE_UP.set 0.4    0.4    1
gainT1__RIGHT_ARM_TASK_FRIDGE_UP.set 1.4    0.4    10
gainT2__RIGHT_HAND_TASK_CLOSING.set 2.5    2.5    1
gainT3__RIGHT_ARM_TASK_FRIDGE_UP_OPENING.set 0.3    0.3    1
gainT4__RIGHT_ARM_TASK_FRIDGE_UP_CLOSING.set 0.4    0.4    1
gainT5__LEFT_HAND_TASK_OPENING.set 1    1    1
gainT6__LEFT_ARM_TASK.set 0.4    0.4    1
gainT7__LEFT_ARM_TASK_CAN.set 0.6    0.4    10
gainT8__LEFT_HAND_TASK_CLOSING.set 1    1    1
gainT9__LEFT_ARM_TASK_MOVETO.set 0.4    0.4    1
gainT9b__LEFT_ARM_TASK_MOVETO.set 0.4    0.4    1
gainT10__LEFT_ARM_TASK.set 0.4    0.3    10
	
run ${CMAKE_INSTALL_PREFIX}/script/forceSimu



# set featureT4.errorIN [3](0,0,1)

proc nas
-> get OpenHRP.state
-> next
endproc


# ---
new Selec<vector> copy<state>
new Selec<matrix> copy<rh>
new Selec<matrix> copy<lh>
proc record
-> copy OpenHRP.state copy<state>.in
-> copy lh.position copy<lh>.in
-> copy rh.position copy<rh>.in
endproc
# tr.add copy<state>.in copy_state
# tr.add copy<rh>.in copy_rh
# tr.add copy<lh>.in copy_lh

proc show
-> get OpenHRP.state
-> get rh.position
-> get lh.position
endproc

# ---

set nullT3.in2 [3](0.008,0.005,0.01)
set nullT4.in2 [3](0.008,0.005,0.01)
# tr.add wMhdT3.out desT3


flex.fromSensor false
set sot.damping .08
gainT6__LEFT_ARM_TASK.set 1

