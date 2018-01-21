modem = component.proxy(component.list("modem")())
drone = component.proxy(component.list("drone")())
 
--Vars
local port = 12345
local speed = 1.0
local Ncol = 0xFF0000
local col = 0x0000FF
local user = false
local msg = 'LINKED'
 
modem.open(port)
 
local ans = {['PING']='PONG'}
local pin = tostring(math.random(10000,99999))
drone.setStatusText(pin)
--Authorization
function authoriz(pin)
    local e = {computer.pullSignal()}
    if e[1] == 'modem_message' and pin == e[6] then
        modem.broadcast(port,"ok")
        return e[3]
    else
        modem.broadcast(port, "No")
    end
end
drone.setLightColor(Ncol)
while not user do
user = authoriz(pin)
end
drone.setLightColor(col)
drone.setStatusText(msg)
drone.setAcceleration(speed)
modem.broadcast(port, ans['info'] )
 
while true do
  e = {computer.pullSignal()}
  if e[1]=="modem_message" and e[3] == user then
    if ans[e[6]] then
        modem.broadcast(port,ans[e[6]])
    else
        pcall(load(e[6]))
    end
  end
end
