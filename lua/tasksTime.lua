--
maxFrame = 60
lh = 30
MAX_SCANLINE = 260

--
time = {}
fpsArray = {}
timeNMI = {}
timeCrit = {}
for i=1, maxFrame do
  time[i] = 0
  fpsArray[i] = 0
  timeNMI[i] = 0
  timeCrit[i] = 0
end

--
function scanlineRange(s)
  if s < 240 then
    return s + (MAX_SCANLINE - 240)
  else
    return s - 240
  end
end

--
function frameEndLabel()
  time[1] = scanlineRange(emu.getState().ppu.scanline)
end

--
function fpsUpdate()
  fpsArray[1] = 1
end

--
function nmiEndLabel()
  timeNMI[1] = scanlineRange(emu.getState().ppu.scanline)
end

--
function criticalLabel()
  timeCrit[1] = scanlineRange(emu.getState().ppu.scanline)
end

--
function nextFrame()
  --
  timeUsage = 0
  
  --
  fps = 0
  emu.drawRectangle(7, 7, maxFrame+2, lh+3, 0xA0000000, true, 1)
  for i=1, maxFrame do
    --
    color = 0x6000FF00
    if time[i] == MAX_SCANLINE then
      color = 0x60FF0000
    end
    emu.drawLine(i+7, lh+8, i+7, lh-(timeNMI[i]*lh/MAX_SCANLINE)+8, 0x600000FF, 1)
    emu.drawLine(i+7, lh-(timeNMI[i]*lh/MAX_SCANLINE)+8, i+7, lh-(timeCrit[i]*lh/MAX_SCANLINE)+8, 0x60FFFF00, 1)
    emu.drawLine(i+7, lh-(timeCrit[i]*lh/MAX_SCANLINE)+8, i+7, lh-(time[i]*lh/MAX_SCANLINE)+8, color, 1)
    --
    timeUsage = timeUsage + time[i]
    --
    fps = fps + fpsArray[i]
  end
  
  --
  timeUsage = timeUsage / maxFrame / MAX_SCANLINE * 100
  
  --
  emu.drawString(maxFrame+10, 9, "TM:" .. math.ceil(timeUsage) .. "%", 0x00FFFFFF, 0xA0000000, 1)
  emu.drawString(maxFrame+10, 19, "FPS:" .. fps, 0x00FFFFFF, 0xA0000000, 1)

  --
  for i=maxFrame, 1, -1 do
    time[i] = time[i-1]
    fpsArray[i] = fpsArray[i-1]
    timeNMI[i] = timeNMI[i-1]
    timeCrit[i] = timeCrit[i-1]
  end
  time[1] = MAX_SCANLINE
  fpsArray[1] = 0
  timeNMI[1] = MAX_SCANLINE
  timeCrit[1] = MAX_SCANLINE
end

--
emu.displayMessage("Script", "Starting.")
emu.addEventCallback(nextFrame, emu.eventType.endFrame)

--
adr = emu.getLabelAddress("@main_loop")
emu.addMemoryCallback(frameEndLabel, emu.memCallbackType.cpuExec, adr)
--
adr = emu.getLabelAddress("@fps_label")
emu.addMemoryCallback(fpsUpdate, emu.memCallbackType.cpuExec, adr)
--
adr = emu.getLabelAddress("@nmi_end")
emu.addMemoryCallback(nmiEndLabel, emu.memCallbackType.cpuExec, adr)
--
adr = emu.getLabelAddress("@nmi_ret")
emu.addMemoryCallback(criticalLabel, emu.memCallbackType.cpuExec, adr)
