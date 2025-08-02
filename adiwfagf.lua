--[[
    SIMPLE WORKING RECORDER
    Максимально простая версия которая точно работает
]]

local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local isRecording = false
local frames = {}
local startTime = 0
local connection = nil

print("🎬 Simple Working Recorder загружен!")

-- Функция записи одного кадра
local function recordFrame(model)
    local frame = {
        time = tick() - startTime,
        parts = {}
    }
    
    -- Записываем размеры всех частей
    for _, part in pairs(model:GetChildren()) do
        if part:IsA("BasePart") then
            frame.parts[part.Name] = {
                size = part.Size,
                transparency = part.Transparency
            }
        end
    end
    
    table.insert(frames, frame)
end

-- Функция начала записи
local function startRecording(model)
    if isRecording then return end
    
    print("🎬 НАЧИНАЮ ЗАПИСЬ: " .. model.Name)
    
    isRecording = true
    frames = {}
    startTime = tick()
    
    -- Записываем каждый кадр
    connection = RunService.Heartbeat:Connect(function()
        if model.Parent then
            recordFrame(model)
            
            -- Показываем прогресс
            if #frames % 30 == 0 then
                print("🔴 Кадр " .. #frames .. " (время: " .. string.format("%.1f", tick() - startTime) .. "с)")
            end
        else
            -- Модель исчезла - останавливаем запись
            connection:Disconnect()
            isRecording = false
            
            local duration = tick() - startTime
            print("✅ ЗАПИСЬ ЗАВЕРШЕНА!")
            print("⏱️ Длительность: " .. string.format("%.2f", duration) .. " секунд")
            print("🎞️ Кадров: " .. #frames)
            
            -- АНАЛИЗ ПРЯМО ЗДЕСЬ
            if #frames >= 2 then
                print("\n=== 📊 АНАЛИЗ ===")
                
                local firstFrame = frames[1]
                local lastFrame = frames[#frames]
                
                for partName, firstData in pairs(firstFrame.parts) do
                    if lastFrame.parts[partName] then
                        local startSize = firstData.size
                        local endSize = lastFrame.parts[partName].size
                        
                        local growth = endSize.Magnitude / startSize.Magnitude
                        
                        if growth > 1.1 then
                            print("📈 " .. partName .. " вырос в " .. string.format("%.2f", growth) .. " раз")
                            print("   " .. tostring(startSize) .. " → " .. tostring(endSize))
                        end
                        
                        local startTrans = firstData.transparency
                        local endTrans = lastFrame.parts[partName].transparency
                        
                        if math.abs(endTrans - startTrans) > 0.1 then
                            print("💫 " .. partName .. " прозрачность: " .. string.format("%.2f", startTrans) .. " → " .. string.format("%.2f", endTrans))
                        end
                    end
                end
                
                print("🎯 АНАЛИЗ ЗАВЕРШЕН!")
            else
                print("❌ Мало кадров для анализа")
            end
        end
    end)
end

-- Отслеживаем появление питомцев
local visuals = Workspace:FindFirstChild("Visuals")
if visuals then
    print("✅ Найдена папка Visuals")
    
    visuals.ChildAdded:Connect(function(child)
        if child:IsA("Model") and not isRecording then
            local name = child.Name or "Unknown"
            print("🎯 Найдена модель: " .. name)
            
            -- Записываем только питомцев (не эффекты)
            if not name:find("Egg") and not name:find("Explode") and not name:find("Poof") then
                wait(0.1)
                startRecording(child)
            else
                print("⚠️ Пропускаю эффект: " .. name)
            end
        end
    end)
else
    print("❌ Visuals не найдена!")
end

print("🚀 Готов! Открой яйцо и получишь полный анализ в консоли!")
