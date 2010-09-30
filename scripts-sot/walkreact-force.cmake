loadPlugin step-checker${DYN_LIB_EXT}
loadPlugin step-observer${DYN_LIB_EXT}
loadPlugin step-queue${DYN_LIB_EXT}
loadPlugin step-computer-force${DYN_LIB_EXT}
loadPlugin step-computer-joystick${DYN_LIB_EXT}
loadPlugin pg-manager${DYN_LIB_EXT}
loadPlugin step-time-line${DYN_LIB_EXT}




# --- Admittance control on the free flyer (or 'base'): parameters and integrator ---

new MatrixDiagonal massInvBase
massInvBase.resize 3 3
set massInvBase.in [3](5,5,5)

new MatrixDiagonal frictionBase
frictionBase.resize 3 3
set frictionBase.in [3](20,10,20)

new IntegratorForceExact forceIntBase
plug massInvBase.out forceIntBase.massInverse
plug frictionBase.out forceIntBase.friction

new VectorConstant armStiffness
armStiffness.resize 3
armStiffness.[] 0 50
armStiffness.[] 1 15
armStiffness.[] 2 50


# --- Components for the stepping ---

new StepObserver stepobs
new StepQueue stepqueue
new StepComputerForce stepcomp
new PGManager steppg
new TimeLine stepper

stepcomp.setObserver stepobs
stepper.setComputer stepcomp
stepper.setPGManager steppg
stepper.setQueue stepqueue

plug dyn.lh stepobs.lefthand
plug dyn.0 stepobs.righthand
plug dyn.lleg stepobs.leftfoot
plug dyn.rleg stepobs.rightfoot
plug dyn.Waist stepobs.waist

plug pg.SupportFoot stepcomp.contactfoot
plug dyn2.lh stepcomp.waistMlhand
plug dyn2.0 stepcomp.waistMrhand
plug stepobs.position2handWaist stepcomp.posrefwaist
plug armStiffness.out stepcomp.stiffness
plug forceIntBase.velocity stepcomp.velocity

OpenHRP.periodicCall addSignal stepobs.position2handWaist
compute stepcomp.posrefwaist

stepcomp.thisIsZero record
steppg.initPg pg
OpenHRP.periodicCall addSignal stepper.trigger

plug stepcomp.force forceIntBase.force

new Add<vector> armForce
plug forceCompRH.torsorNullified armForce.in1
plug stepcomp.forceR armForce.in2
plug armForce.out forceInt.force

new Add<vector> armForceLH
plug forceCompLH.torsorNullified armForceLH.in1
plug stepcomp.forceL armForceLH.in2
plug armForceLH.out forceIntLH.force

proc bigforcefront
-> set forceCompLH.torsorNullified [6](0,0,-10,0,0,0)
-> set forceCompRH.torsorNullified [6](0,0,-10,0,0,0)
endproc

proc smallforcefront
-> set forceCompLH.torsorNullified [6](0,0,-5,0,0,0)
-> set forceCompRH.torsorNullified [6](0,0,-5,0,0,0)
endproc

proc stopforce
-> set forceCompLH.torsorNullified [6](0,0,0,0,0,0)
-> set forceCompRH.torsorNullified [6](0,0,0,0,0,0)
endproc

proc smallforceleft
-> set forceCompRH.torsorNullified [6](0,5,0,0,0,0)
-> set forceCompLH.torsorNullified [6](0,5,0,0,0,0)
endproc
