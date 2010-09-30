import time

# Specific to HRP-2
import hrp
import hstsetup
from hrp import *

class WalkTask:

  # --------------------------------------------------------------------------------
  # Constructor
  #
  # - Loads the plugins
  # - Goes to initial position
  # - Initializes the SoT
  # --------------------------------------------------------------------------------
  def __init__(self,name):

    self.GEOMETRIC_MODE = 0
    self.Name = name 
    self.with_trace = 1
    self.with_altitude = 0
    self.with_teleop = 0
    self.with_deadzone = 0
    self.with_taskchest = 1
    self.with_table = 0
    self.with_posture = 0
    self.with_collision = 0
    self.with_homotopy = 0
    self.with_joystick = 0
    
    self.robot = "HRP2JRL10Small"
    # ------------------------------------------------------------------------------
    # --- LOAD THE PLUGINS ---------------------------------------------------------
    # ------------------------------------------------------------------------------

    self.ms = findPluginManager("motionsys")

    # --- Kalman filter --- #

    if(self.GEOMETRIC_MODE == 0):
      self.ms.load("kfplugin")
      self.kf = self.ms.create("kfplugin","kf","")
      self.kf.start()

    # --- Sequence player --- #

    self.ms.load("seqplay")
    self.seq = SequencePlayerHelper.narrow(self.ms.create("seqplay","seq","-ORBconfig../../../../../Common/orb.conf"))
    self.seq.start()

    # --- Stack of Tasks --- #

    self.ms.load("StackOfTasks")
    self.SoT = self.ms.create("StackOfTasks","SoT",self.robot)

    # --- Stabilizer --- #

    if(self.GEOMETRIC_MODE == 0):
      self.ms.load("hstabilizer")
      self.st = self.ms.create("hstabilizer","st","")

    # --- Log plugin --- #

    self.ms.load("logplugin")
    self.log = LoggerPluginHelper.narrow(self.ms.create("logplugin","log",""))
    if(self.GEOMETRIC_MODE == 0):
      self.log.add("kf")
      self.log.add("st")
    self.log.sendMsg(":max-length 80")
    self.log.start()

    # --- Specific to walking --- #

    if(self.GEOMETRIC_MODE == 0):
      hstsetup.stsetup(self.st)
      self.kf.start()
      self.st.start()


    # ------------------------------------------------------------------------------
    # --- INITIAL POSITION ---------------------------------------------------------
    # ------------------------------------------------------------------------------

    #seq.goHalfSitting(2.5)

    # Custom pose
    rleg_a = "0 0 -26 50 -24 0"
    lleg_a = "0 0 -26 50 -24 0"
    chest_a = "0 0"
    head_a = "0 0"
    rhand_a = "-10.0 10.0 -10.0 10.0 -10.0"
    lhand_a = "-10.0 10.0 -10.0 10.0 -10.0"

    #rleg_a = "0 0 0 0 0 0"
    #lleg_a = "0 0 0 0 0 0"
    #chest_a = "0 0"
    #head_a = "0 0"
    #rhand_a = "0.0 0.0 0.0 0.0 0.0"
    #lhand_a = "0.0 0.0 0.0 0.0 0.0"

    # Half sitting 
    if ((self.robot=="HRP2JRL10SmallOld") or (self.robot=="HRP2JRL10Small")):
      rarm_a = "15 -10 0 -30 0 0 0 10"
      larm_a = "15  10 0 -30 0 0 0 10"
    elif (self.robot=="HRP214"):
      rarm_a = "15 -10 0 -30 0 0 10"
      larm_a = "15  10 0 -30 0 0 10"
    
  
    # New Germany
    #rarm_a = "33 -10 0 -120 -10 0 10" # <-- ballrose: "10 -10 -10 -80 0 -0 0", dunnowhat: "10 -10 -10 -70 0 -0 10"
    #larm_a = "33  10 0 -120  10 0 10" # <-- ballrose: "35 5 0 -20.0 0 0 10.0", dunnowhat: "10  10 10 -70 0 0 10"
   
    # Old Germany
    # rarm_a = "10 -18 0 -100 -18 0 10"
    # larm_a = "10  18 0 -100  18 0 10"

    self.seq.sendMsg(":joint-angles "+rleg_a+" "+lleg_a+" "+chest_a+" "+head_a+" "+rarm_a+" "+larm_a+" "+rhand_a+" "+lhand_a+" 2.5")
    self.seq.waitInterpolation()

    #seq.stop()
    #ms.sendMsg(":destroy seq")
    #ms.sendMsg(":unload seqplay")


    # ---------------------------------------------------------------------------- #
    # --- SOT INITIALIZATION ----------------------------------------------------- #
    # ---------------------------------------------------------------------------- #

    self.SoT.sendMsg(":init")

    #
    # --- Init SoT core ---
    #
    # !!! teleop runs with dynsmall, NOT with standard dyn !!!
    #
    if (self.robot=="HRP214"):
      self.SoT.sendMsg(":script run ${CMAKE_INSTALL_PREFIX}/script/dynsmall")
    elif (self.robot=="HRP2JRL10SmallOld"):
      self.SoT.sendMsg(":script run ${CMAKE_INSTALL_PREFIX}/script/dynsmallpart1hrp2_10_old")
      self.SoT.sendMsg(":script run ${CMAKE_INSTALL_PREFIX}/script/dynsmallpart2")
    elif (self.robot=="HRP2JRL10Small"):
      self.SoT.sendMsg(":script run ${CMAKE_INSTALL_PREFIX}/script/dynsmallpart1hrp2_10")
      self.SoT.sendMsg(":script run ${CMAKE_INSTALL_PREFIX}/script/dynsmallpart2hrp2_10")
      
    # self.SoT.sendMsg(":script run ${CMAKE_INSTALL_PREFIX}/script/dynsmall")
    self.SoT.sendMsg(":script run ${CMAKE_INSTALL_PREFIX}/script/coshell")
    self.SoT.sendMsg(":script run ${CMAKE_INSTALL_PREFIX}/script/traces")

    self.SoT.sendMsg(":script OpenHRP.refstate mc")
    self.SoT.sendMsg(":script plug OpenHRP.state dyn.position")
    self.SoT.sendMsg(":script plug OpenHRP.state dyn2.position")
    self.SoT.sendMsg(":script plug OpenHRP.attitude posKF.attitudeIN")
    self.SoT.sendMsg(":script plug OpenHRP.attitude flex.sensorWorldRotation")
    self.SoT.sendMsg(":script plug sot.control OpenHRP.control")

    if (self.robot=="HRP2JRL10Small"):
      self.SoT.sendMsg(":script run ${CMAKE_INSTALL_PREFIX}/script/smallhrp2_10")
    else:
      self.SoT.sendMsg(":script run ${CMAKE_INSTALL_PREFIX}/script/small")

    self.SoT.sendMsg(":script run ${CMAKE_INSTALL_PREFIX}/script/jointlimit")

    # --- Manipulation --- #

    self.SoT.sendMsg(":script OpenHRP.pause")
    self.SoT.start()

    if (self.robot=="HRP2JRL10Small"):
      self.SoT.sendMsg(":script run ${CMAKE_INSTALL_PREFIX}/script/forcehrp2_10")
      self.SoT.sendMsg(":script run ${CMAKE_INSTALL_PREFIX}/script/forceLhrp2_10")
    else:
      self.SoT.sendMsg(":script run ${CMAKE_INSTALL_PREFIX}/script/force")
      self.SoT.sendMsg(":script run ${CMAKE_INSTALL_PREFIX}/script/forceL")

    self.SoT.sendMsg(":script run ${CMAKE_INSTALL_PREFIX}/script/grip")

    # --- Teleop --- #
    
    if (self.robot=="HRP2JRL10Small"):
      self.SoT.sendMsg(":script run ${CMAKE_INSTALL_PREFIX}/script/teleoperation/teleophrp2_10")
    else:
      self.SoT.sendMsg(":script run ${CMAKE_INSTALL_PREFIX}/script/teleoperation/teleop")

    self.SoT.sendMsg(":script sot.clear")

    # --- PG --- #
    if (self.robot=="HRP2JRL10Small"):
      self.SoT.sendMsg(":script run ${CMAKE_INSTALL_PREFIX}/script/hwpgpginitpart1hrp2_10")
    else:
      self.SoT.sendMsg(":script run ${CMAKE_INSTALL_PREFIX}/script/hwpgpginitpart1")
    self.SoT.sendMsg(":script run ${CMAKE_INSTALL_PREFIX}/script/hwpgpginitpart2")


    time.sleep(1)
    self.SoT.sendMsg(":script run ${CMAKE_INSTALL_PREFIX}/script/hwpginitframes")
    self.SoT.sendMsg(":script plug lfo_H_wa.out OpenHRP.positionIN")

    # --- Reactive Walk --- #

    if(self.with_joystick == 0):
      self.SoT.sendMsg(":script run ${CMAKE_INSTALL_PREFIX}/script/walkreact-new")
    else:
      self.SoT.sendMsg(":script run ${CMAKE_INSTALL_PREFIX}/script/walkreact-joystick")
    self.SoT.sendMsg(":script run ${CMAKE_INSTALL_PREFIX}/script/walking/hwpgfeettasksrel")

    # --- Play --- #

    self.SoT.sendMsg(":script OpenHRP.reinit from mc")
    self.SoT.sendMsg(":script OpenHRP.play")
    
    if(self.with_trace):
      self.SoT.sendMsg(":script tr.start")

    # --- Misc --- #
    self.SoT.sendMsg(":script run ${CMAKE_INSTALL_PREFIX}/script/clamp-workspace")
    if(self.with_altitude):
      self.SoT.sendMsg(":script run ${CMAKE_INSTALL_PREFIX}/script/handsAltitude")
    if(self.with_posture):
      if (self.robot=="HRP2JRL10Small"):
        self.SoT.sendMsg(":script run ${CMAKE_INSTALL_PREFIX}/script/taskPosturehrp2_10")
      else:
        self.SoT.sendMsg(":script run ${CMAKE_INSTALL_PREFIX}/script/taskPosture")

    if(self.with_collision):
      self.SoT.sendMsg(":script run ${CMAKE_INSTALL_PREFIX}/script/collisiondetection")

    # --- Ensure end-effector positions is computed properly --- #

    # This avoids a lot of troubles for tasks which record a "zero" position!
    # It often occured that the zero was not properly computed because the update of
    # dyn.0 and dyn.lh was not asked by any entity - and the "compute enity.out"
    # doesn't seem to work.
    self.SoT.sendMsg(":script OpenHRP.periodicCall addSignal dyn.0")
    self.SoT.sendMsg(":script OpenHRP.periodicCall addSignal dyn.lh")
    self.SoT.sendMsg(":script OpenHRP.periodicCall addSignal dyn2.0")
    self.SoT.sendMsg(":script OpenHRP.periodicCall addSignal dyn2.lh")

    time.sleep(1)

    # --- Tasks --- #

    self.SoT.sendMsg(":script sot.clear")
    if(self.with_taskchest):
      self.SoT.sendMsg(":script sot.push taskLeftArm")
      self.SoT.sendMsg(":script sot.push taskRightArm")

    self.SoT.sendMsg(":script sot.push taskTwofeet")
    self.SoT.sendMsg(":script sot.push taskWaist")

    if(self.with_altitude):
      self.SoT.sendMsg(":script zeroaltitude")
      self.SoT.sendMsg(":script sot.push taskRhand")
      self.SoT.sendMsg(":script sot.push taskLhand")

    self.SoT.sendMsg(":script sot.push taskComPD")
    # self.SoT.sendMsg(":script sot.push taskGrip")


  # --------------------------------------------------------------------------------
  # Open-close the grippers
  # --------------------------------------------------------------------------------
  def Ungrip(self):
    self.SoT.sendMsg(":script set gripdes.position [2](0.8,0.8)")

  def Grip(self):
    self.SoT.sendMsg(":script set gripdes.position [2](0.2,0.2)")


  # --------------------------------------------------------------------------------
  # Maniplulation tasks and settings
  # --------------------------------------------------------------------------------
  def StartManip(self):
    if(self.with_collision):
      self.SoT.sendMsg(":script collision.run")
    if(self.with_deadzone):
      self.SoT.sendMsg(":script set forceCompRH.deadZoneLimit [6](15,.8,.8,.1,3,.1)")
      self.SoT.sendMsg(":script set forceCompLH.deadZoneLimit [6](15,.8,.8,.1,3,.1)")

    if(self.with_teleop == 0):
      if(self.with_table == 0):
        self.SoT.sendMsg(":script set friction.in [6](50,50,50,2,2,1)")
      else:
        self.SoT.sendMsg(":script set friction.in [6](100,100,100,3,3,2)")

    if(self.with_homotopy == 1):
      self.SoT.sendMsg(":script zeroclampworkspace")
      self.SoT.sendMsg(":script sot.push thomotopy")
      self.SoT.sendMsg(":script sot.push thomotopy_lh")
    else:
      self.SoT.sendMsg(":script sot.push taskForce")
      self.SoT.sendMsg(":script sot.push taskForceLH")

    if(self.with_posture):
      if (self.robot=="HRP2JRL10Small"):
        self.SoT.sendMsg(":script sot.push taskPosturehrp2_10")
      else:
        self.SoT.sendMsg(":script sot.push taskPosture")

    self.SoT.sendMsg(":script sot.push taskHead")
    self.SoT.sendMsg(":script stepcomp.thisIsZero record")
 

  # --------------------------------------------------------------------------------
  # Stepper start and stop
  # --------------------------------------------------------------------------------
  def StartStepper(self):
    self.SoT.sendMsg(":script run ${CMAKE_INSTALL_PREFIX}/script/stepping")
    self.SoT.sendMsg(":script stepper.state start")

  def StopStepper(self):
    self.SoT.sendMsg(":script stepper.state stop")

  # --------------------------------------------------------------------------------
  # Utility functions for the demonstrator
  # --------------------------------------------------------------------------------
  def OffsetDataTrackerGermany(self):
    pass

  def ZeroHands(self):
    self.SoT.sendMsg(":script zerohands")

  def RemoveHandsTasks(self):
    self.SoT.sendMsg(":script sot.rm taskLhand")
    self.SoT.sendMsg(":script sot.rm taskRhand")

  # --------------------------------------------------------------------------------
  # End of the exp. log and quit
  # --------------------------------------------------------------------------------
  def StopAndCleanup(self):
    # ---------------------------------------------------------------------------- #
    # --- STOP AND CLEANUP ------------------------------------------------------- #
    # ---------------------------------------------------------------------------- #
    # -------------------------------------------------------------------------
    # waitInputConfirm("Click [OK] to stop the SoT.")
    self.SoT.sendMsg(":hold")
    #
    # Careful! The SOT plugin should not be stopped before seqplay has ended its
    # motion. waitInterpolation should block the script. If not, don't push [OK] to
    # the next dialog box before the robot has reached the 1/2seating
    #
    if(self.with_trace):
      self.SoT.sendMsg(":script tr.trace")
    self.SoT.sendMsg(":waitForFinished")

    # -------------------------------------------------------------------------
    self.SoT.stop()

    # -------------------------------------------------------------------------
    self.SoT.sendMsg(':profile')
    self.ms.sendMsg(":destroy SoT")
    self.ms.sendMsg(":unload StackOfTasks")

    # --- 
    # --- LOGS
    # --- 
    # waitInputConfirm("Click [OK] to log")
    self.log.stop()
    self.log.save("WalkTask")

    print("Script finished")


# --------------------------------------------------------------------------------
# --------------------------------------------------------------------------------
# --------------------------------------------------------------------------------

aWalkTask = WalkTask("MunichJRL")

if aWalkTask.with_teleop:
  defaultMenuE = [[
        '------- Sequence ----------', '#label',
        'Offset data tracker Germany',           'aWalkTask.OffsetDataTrackerGermany()',
        'Zero Hands',           'aWalkTask.ZeroHands()',
        'Remove hands tasks',           'aWalkTask.RemoveHandTasks()',
        'StopAndCleanup',           'aWalkTask.StopAndCleanup()'
      ]]
else:
  defaultMenuE = [[
        '------- Sequence ----------', '#label',
        'Ungrip',                  'aWalkTask.Ungrip()',
        'Grip',                    'aWalkTask.Grip()',
        'Start Manipulation',           'aWalkTask.StartManip()',
        'Start Stepping',           'aWalkTask.StartStepper()',
        'Stop Stepping',           'aWalkTask.StopStepper()',
        'StopAndCleanup',           'aWalkTask.StopAndCleanup()'
      ]]

waitInputMenu(defaultMenuE)
