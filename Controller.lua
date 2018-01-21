local comp = require('component')
local modem = comp.modem
local term = require("term")
local event = require("event")
local computer = require('computer')
local gpu = comp.gpu
 
--Vars
local port = 12345
local full = true
local x_max, y_max = gpu.maxResolution()
local x_min, y_min = 1, 1
local speed = 1
local col = 0x0000FF
 
modem.open(port)
gpu.setResolution(x_max,y_max)
function link()
    print("Введите 5-ти значный код, появившийся на мониторе дрона")
    io.write(">>")
    modem.broadcast(port,io.read())
    modem.broadcast(port,"drone = component.proxy(component.list('drone')())")
end
 
function help()
term.clear()
print([[
                        Основное:
                    Подключиться к дрону: 1
                    Узнать расстояние до дрона: 2
   ctr - вызов данной подсказки |H - Уменьшить/Увеличить экран
             Поменять текст дрона: 3 | Ввести свою комманду: 4
                        Выход:    Информация:
                            Q         B
                   Управление дроном:
                   Изменить цвет дрона:   C
                   Движение:              
       ↑
       W             Вниз:                Вверх:      
    ← A S →         LShift                Space                                  
       S                Скорость движения
       ↓      Повысить скорость:    Понизить скорость:
                      R                     F    
                        Работа с инвентарями:
       Забрать вещи из сундука:    Выбросить все вещи:
                 K                            I                                                                                                
]])
 
end
 
buttons = {
[17] = 'drone.move(1,0,0)', --forw
[31] = "drone.move(-1,0,0)", --back
[30] = "drone.move(0,0,-1)", --left
[32] = "drone.move(0,0,1)", --right
[42] = "drone.move(0,-1,0)",--down
[57] = "drone.move(0,1,0)", --up
[23] = "for i = 1, drone.inventorySize() do drone.select(i) drone.drop(0) end",
[37] = "for i = 1,drone.inventorySize() do for i = 0, 5 do drone.suck(i) end end",
}
 
help()
print('Start')
while true do
    e = {event.pull()}
    if e[1] == 'key_down' then
        if e[4] == 16 then
            print('Exit!')
            break
        elseif e[4] == 29 then
            help()
        elseif e[4] ==  2 then
            link()
        elseif e[4] == 19 then
            speed = speed+0.5
            modem.broadcast(port,"drone.setAcceleration(speed)")
            print("Скорость изменена: " .. speed)
        elseif e[4] == 33 then
            speed = speed-0.5
            modem.broadcast(port,"drone.setAcceleration(speed)")
            print("Скорость изменена: " .. speed)
        elseif e[4] == 46 then
            col = math.random(0x0, 0xFFFFFF)
            modem.broadcast(port,"drone.setLightColor(" .. col ..")")
            print("Цвет дрона: " .. col .. " Скорость дрона: " .. speed)
        elseif e[4] == 48 then
            print("INFO: Цвет дрона: " .. col)
        elseif e[4] == 4 then
            print('Введите текст для дрона')
            io.write(">>")
            local cmd ="drone.setStatusText('" .. io.read() .."')"
            modem.broadcast(port,cmd)
        elseif e[4] == 5 then
            print([[Уже отправлено:
                drone = component.proxy(component.list('drone')())
                modem = component.proxy(component.list("modem")()))
                    Введите комманду!]])
            io.write(">>")
            modem.broadcast(port,io.read())
        elseif e[4] == 3 then
            modem.broadcast(port,'PING')
            e = {event.pull('modem_message')}
            dis = e[5]
            print("Расстояние до дрона: ",dis)
        elseif e[4] == 35 then
                if full then
                    full = false
                    gpu.setResolution(x_min,y_min)
                else
                    full = true
                    gpu.setResolution(x_max,y_max)
                end
        else
            if buttons[e[4]] then
                modem.broadcast(port,buttons[e[4]])
                print("Комманда '" .. buttons[e[4]] .. "' отправлена дрону.")
            else
                computer.beep()
            end
        end
    end
end
