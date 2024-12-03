--------------
-- constants
--------------
MAX_FRAME = 60 -- maximum number of frame to keep track
LH = 30 -- line height
MAX_SCANLINE = 260 -- maximum scanline that a recorded value can reach

------------------
-- timing arrays
------------------
time = {}
fpsArray = {}
timeNMI = {}
timeCrit = {}
-- init arrays to 0
for i=1, MAX_FRAME do
  time[i] = 0
  fpsArray[i] = 0
  timeNMI[i] = 0
  timeCrit[i] = 0
end

------------------
-- help function
------------------
-- convert a scanline value to a range
-- from 0 / the start of the frame
-- to MAX_SCANLINE / the end of the frame
function scanlineRange(s)
  if s < 240 then
    return s + (MAX_SCANLINE - 240)
  else
    return s - 240
  end
end

------------------
-- main function
------------------
-- update graph and values
function nextFrame()
  -- variables
  timeUsage = 0
  fps = 0
  
  -- draw graph background
  emu.drawRectangle(7, 7, MAX_FRAME+2, LH+3, 0xA0000000, true, 1)
  -- for each column
  for i=1, MAX_FRAME do
    -- select main function time color between
    -- green or or red if NMI occure before end of main
    color = 0x6000FF00
    if time[i] == MAX_SCANLINE then
      color = 0x60FF0000
    end
    -- draw column with the different colors for each time category
    -- blue = NMI
    -- yellow = critical code / code that run after NMI
    -- green/red = main function
    emu.drawLine(i+7, LH+8, i+7, LH-(timeNMI[i]*LH/MAX_SCANLINE)+8, 0x600000FF, 1)
    emu.drawLine(i+7, LH-(timeNMI[i]*LH/MAX_SCANLINE)+8, i+7, LH-(timeCrit[i]*LH/MAX_SCANLINE)+8, 0x60FFFF00, 1)
    emu.drawLine(i+7, LH-(timeCrit[i]*LH/MAX_SCANLINE)+8, i+7, LH-(time[i]*LH/MAX_SCANLINE)+8, color, 1)
    -- update variables
    timeUsage = timeUsage + time[i]
    fps = fps + fpsArray[i]
  end
  -- draw NMI limit line in purple
  y_limit = LH-(LH*(LH/MAX_SCANLINE))
  emu.drawLine(7, 7+y_limit, 7+MAX_FRAME, 7+y_limit, 0xA0FF00FF, 1)

  -- compute percentage of CPU time used during the last MAX_FRAME frames
  timeUsage = timeUsage / MAX_FRAME / MAX_SCANLINE * 100
  
  -- print CPU time and FPS
  emu.drawString(MAX_FRAME+10, 9, "CPU:" .. math.ceil(timeUsage) .. "%", 0x00FFFFFF, 0xA0000000, 1)
  emu.drawString(MAX_FRAME+10, 19, "FPS:" .. fps, 0x00FFFFFF, 0xA0000000, 1)

  -- shift values in arrays
  for i=MAX_FRAME, 1, -1 do
    time[i] = time[i-1]
    fpsArray[i] = fpsArray[i-1]
    timeNMI[i] = timeNMI[i-1]
    timeCrit[i] = timeCrit[i-1]
  end
  -- last value in arrays = default value
  time[1] = MAX_SCANLINE
  fpsArray[1] = 0
  timeNMI[1] = MAX_SCANLINE
  timeCrit[1] = MAX_SCANLINE
end

-----------------------
-- callback functions
-----------------------
function frameEndLabel()
  time[1] = scanlineRange(emu.getState().ppu.scanline)
end
function fpsUpdate()
  fpsArray[1] = 1
end
function nmiEndLabel()
  timeNMI[1] = scanlineRange(emu.getState().ppu.scanline)
end
function criticalLabel()
  timeCrit[1] = scanlineRange(emu.getState().ppu.scanline)
end

-------------------
-- callback hooks
-------------------
emu.addEventCallback(nextFrame, emu.eventType.endFrame)
adr = emu.getLabelAddress("@MAIN_END")
emu.addMemoryCallback(frameEndLabel, emu.memCallbackType.cpuExec, adr)
adr = emu.getLabelAddress("@MAIN_LOOP_START")
emu.addMemoryCallback(fpsUpdate, emu.memCallbackType.cpuExec, adr)
adr = emu.getLabelAddress("@nmi_end")
emu.addMemoryCallback(nmiEndLabel, emu.memCallbackType.cpuExec, adr)
adr = emu.getLabelAddress("@nmi_ret")
emu.addMemoryCallback(criticalLabel, emu.memCallbackType.cpuExec, adr)

-- display starting message
emu.displayMessage("Script", "Starting.")
