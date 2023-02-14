﻿--
maxFrame = 60
lh = 30

--
time = {}
for i=1, maxFrame do
  time[i] = 0
end

--
function mainEnd()
  time[1] = emu.getState().ppu.scanline
  if time[1] > 240 then
    time[1] = 0
  end
end


--
function nextFrame()
  --
  timeUsage = 0
  
  --
  emu.drawRectangle(7, 7, maxFrame+2, lh+3, 0xA0000000, true, 1)
  for i=1, maxFrame do
    --
    emu.drawLine(i+7, lh+8, i+7, lh-(time[i]*lh/240)+8, 0x60FF0000, 1)
    --
    timeUsage = timeUsage + time[i]
  end

  --
  timeUsage = timeUsage / maxFrame / 240 * 100
  
  --
  emu.drawString(maxFrame+10, 9, "TM:" .. math.ceil(timeUsage) .. "%", 0x00FFFFFF, 0xA0000000, 1)

  --
  for i=maxFrame, 1, -1 do
    time[i] = time[i-1]
  end
  time[1] = 240
end

--
emu.displayMessage("Script", "Starting.")
emu.addEventCallback(nextFrame, emu.eventType.endFrame)

--
adr = emu.getLabelAddress("@main_loop")
emu.addMemoryCallback(mainEnd, emu.memCallbackType.cpuExec, adr)