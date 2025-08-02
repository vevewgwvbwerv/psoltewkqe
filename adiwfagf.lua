--[[
    CONSOLE ANIMATION RECORDER
    Без GUI - только консольный вывод
    Записывает анимацию питомца из яйца
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local isRecording = false
local animationData = {}
local currentRecording = nil
local recordingConnection = nil

print("🎬 Console Animation Recorder загружен!")
print("📋 Автоматически начнет запись когда появится питомец из яйца")

-- Безопасная функция записи состояния модели
local function recordModelState(model, frameTime)
    local state = {
        time = frameTime,
        parts = {},
        modelExists = true
    }
    
    if not model or not model.Parent then
        state.modelExists = false
        return state
    end
    
    local success, error = pcall(function()
        for _, part in ipairs(model:GetDescendants()) do
            if part and part:IsA("BasePart") and part.Parent then
                local partName = part.Name or "UnknownPart"
                state.parts[partName] = {
                    size = part.Size or Vector3.new(1,1,1),
                    position = part.Position or Vector3.new(0,0,0),
                    transparency = part.Transparency or 0
                }
            end
        end
    end)
    
    if not success then
        print("⚠️ Ошибка записи кадра: " .. tostring(error))
    end
    
    return state
end

-- Функция начала записи
local function startRecording(model)
    if isRecording then return end
    
    print("🎬 НАЧИНАЮ ЗАПИСЬ: " .. (model.Name or "Unknown"))
    
    isRecording = true
    currentRecording = {
        startTime = tick(),
        frames = {},
        model = model,
        modelName = model.Name or "Unknown"
    }
    
    -- Записываем начальное состояние
    local initialState = recordModelState(model, 0)
    table.insert(currentRecording.frames, initialState)
    print("📊 Записал начальное состояние")
    
    -- Запускаем запись каждый кадр
    recordingConnection = RunService.Heartbeat:Connect(function()
        if not isRecording then return end
        
        local frameTime = tick() - currentRecording.startTime
        local state = recordModelState(model, frameTime)
        table.insert(currentRecording.frames, state)
        
        -- Выводим прогресс каждые 30 кадров
        if #currentRecording.frames % 30 == 0 then
            print("🔴 ЗАПИСЬ: " .. string.format("%.1fs (%d кадров)", frameTime, #currentRecording.frames))
        end
        
        -- Останавливаем если модель исчезла
        if not state.modelExists then
            print("💥 Модель исчезла - останавливаю запись")
            stopRecording()
        end
        
        -- Автостоп через 10 секунд
        if frameTime > 10 then
            print("⏰ Автостоп через 10 секунд")
            stopRecording()
        end
    end)
end

-- Функция остановки записи
function stopRecording()
    if not isRecording then return end
    
    isRecording = false
    
    if recordingConnection then
        recordingConnection:Disconnect()
        recordingConnection = nil
    end
    
    local duration = tick() - currentRecording.startTime
    
    print("✅ ЗАПИСЬ ЗАВЕРШЕНА!")
    print("⏱️ Длительность: " .. string.format("%.2f", duration) .. " секунд")
    print("🎞️ Кадров записано: " .. #currentRecording.frames)
    
    -- Сохраняем данные
    animationData[currentRecording.modelName] = currentRecording
    
    -- Анализируем записанные данные
    analyzeAnimation(currentRecording)
end

-- Функция анализа анимации
local function analyzeAnimation(recording)
    print("\n=== 📊 АНАЛИЗ АНИМАЦИИ ===")
    
    if #recording.frames < 2 then
        print("❌ Недостаточно кадров для анализа")
        return
    end
    
    local firstFrame = recording.frames[1]
    local lastFrame = recording.frames[#recording.frames]
    
    print("🔍 Анализирую " .. #recording.frames .. " кадров...")
    
    -- Анализируем изменения размера каждой части
    for partName, firstState in pairs(firstFrame.parts) do
        if lastFrame.parts[partName] then
            local startSize = firstState.size
            local endSize = lastFrame.parts[partName].size
            
            if startSize and endSize then
                local sizeChange = endSize.Magnitude / startSize.Magnitude
                
                if sizeChange > 1.2 then
                    print("📈 " .. partName .. " увеличился в " .. string.format("%.2f", sizeChange) .. " раз")
                    print("   Размер: " .. tostring(startSize) .. " → " .. tostring(endSize))
                elseif sizeChange < 0.8 then
                    print("📉 " .. partName .. " уменьшился в " .. string.format("%.2f", 1/sizeChange) .. " раз")
                end
            end
            
            local startTrans = firstState.transparency or 0
            local endTrans = lastFrame.parts[partName].transparency or 0
            
            if math.abs(endTrans - startTrans) > 0.1 then
                print("💫 " .. partName .. " прозрачность: " .. string.format("%.2f", startTrans) .. " → " .. string.format("%.2f", endTrans))
            end
        end
    end
    
    print("🎯 АНАЛИЗ ЗАВЕРШЕН!")
    print("📋 Данные сохранены в animationData['" .. recording.modelName .. "']")
    print("\n🚀 Готов создать скрипт воспроизведения анимации!")
end

-- Отслеживаем появление моделей в Visuals
local visuals = Workspace:FindFirstChild("Visuals")
if visuals then
    print("✅ Найдена папка Visuals")
    
    visuals.ChildAdded:Connect(function(child)
        if child:IsA("Model") and not isRecording then
            print("🎯 Обнаружена модель: " .. (child.Name or "Unknown"))
            
            -- Проверяем что это питомец (не эффект)
            if child.Name and not child.Name:find("Egg") and not child.Name:find("Explode") and not child.Name:find("Poof") then
                wait(0.1) -- Небольшая задержка
                startRecording(child)
            else
                print("⚠️ Пропускаю эффект: " .. (child.Name or "Unknown"))
            end
        end
    end)
else
    print("❌ Папка Visuals не найдена")
end

print("🎬 Готов к записи! Открой яйцо...")

-- Функция для получения записанных данных
function getAnimationData(petName)
    return animationData[petName or "Dog"]
end

-- Функция для вывода всех записанных анимаций
function listAnimations()
    print("📋 Записанные анимации:")
    for name, data in pairs(animationData) do
        print("  - " .. name .. " (" .. #data.frames .. " кадров, " .. string.format("%.2f", data.frames[#data.frames].time) .. "с)")
    end
end
