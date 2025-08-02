--[[
    FIXED ANIMATION RECORDER
    Исправленная версия без ошибок
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local isRecording = false
local animationData = {}
local currentRecording = nil
local recordingConnection = nil

-- GUI для управления
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FixedAnimationRecorder"
screenGui.Parent = CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 400, 0, 500)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.new(0, 0, 0)
frame.BackgroundTransparency = 0.2
frame.BorderSizePixel = 0
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "🎬 FIXED ANIMATION RECORDER"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = frame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 25)
statusLabel.Position = UDim2.new(0, 0, 0, 35)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Ready to record"
statusLabel.TextColor3 = Color3.new(1, 1, 1)
statusLabel.TextScaled = true
statusLabel.Font = Enum.Font.Gotham
statusLabel.Parent = frame

local recordButton = Instance.new("TextButton")
recordButton.Size = UDim2.new(0.8, 0, 0, 40)
recordButton.Position = UDim2.new(0.1, 0, 0, 65)
recordButton.BackgroundColor3 = Color3.new(1, 0, 0)
recordButton.Text = "🔴 START RECORDING"
recordButton.TextColor3 = Color3.new(1, 1, 1)
recordButton.TextScaled = true
recordButton.Font = Enum.Font.Gotham
recordButton.Parent = frame

local logFrame = Instance.new("ScrollingFrame")
logFrame.Size = UDim2.new(1, -10, 1, -120)
logFrame.Position = UDim2.new(0, 5, 0, 115)
logFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
logFrame.BorderSizePixel = 0
logFrame.ScrollBarThickness = 8
logFrame.Parent = frame

local logText = Instance.new("TextLabel")
logText.Size = UDim2.new(1, -10, 1, 0)
logText.Position = UDim2.new(0, 5, 0, 0)
logText.BackgroundTransparency = 1
logText.Text = "Готов к записи анимации...\n"
logText.TextColor3 = Color3.new(1, 1, 1)
logText.TextSize = 11
logText.Font = Enum.Font.Code
logText.TextXAlignment = Enum.TextXAlignment.Left
logText.TextYAlignment = Enum.TextYAlignment.Top
logText.TextWrapped = true
logText.Parent = logFrame

local function log(message)
    local timestamp = string.format("%.2f", tick())
    logText.Text = logText.Text .. "[" .. timestamp .. "] " .. message .. "\n"
    logFrame.CanvasSize = UDim2.new(0, 0, 0, logText.TextBounds.Y)
    logFrame.CanvasPosition = Vector2.new(0, logFrame.CanvasSize.Y.Offset)
end

-- Безопасная функция записи состояния модели
local function recordModelState(model, frameTime)
    local state = {
        time = frameTime,
        parts = {},
        modelExists = true
    }
    
    -- Проверяем что модель существует
    if not model or not model.Parent then
        state.modelExists = false
        return state
    end
    
    -- Безопасно записываем состояние каждой части
    local success, error = pcall(function()
        for _, part in ipairs(model:GetDescendants()) do
            if part and part:IsA("BasePart") and part.Parent then
                local partName = part.Name or "UnknownPart"
                state.parts[partName] = {
                    size = part.Size or Vector3.new(1,1,1),
                    position = part.Position or Vector3.new(0,0,0),
                    transparency = part.Transparency or 0,
                    canCollide = part.CanCollide or false
                }
            end
        end
        
        -- Записываем общие свойства модели
        if model.PrimaryPart then
            state.primaryPart = {
                size = model.PrimaryPart.Size,
                position = model.PrimaryPart.Position,
                transparency = model.PrimaryPart.Transparency
            }
        end
        
        -- Пытаемся получить размер модели
        local success2, modelSize = pcall(function()
            return model:GetExtentsSize()
        end)
        if success2 then
            state.modelSize = modelSize
        end
        
    end)
    
    if not success then
        log("⚠️ Ошибка записи кадра: " .. tostring(error))
    end
    
    return state
end

-- Функция начала записи
local function startRecording(model)
    if isRecording then return end
    
    log("🎬 Начинаю запись модели: " .. (model.Name or "Unknown"))
    
    isRecording = true
    currentRecording = {
        startTime = tick(),
        frames = {},
        model = model,
        modelName = model.Name or "Unknown"
    }
    
    statusLabel.Text = "🔴 RECORDING: " .. currentRecording.modelName
    recordButton.Text = "⏹️ STOP RECORDING"
    recordButton.BackgroundColor3 = Color3.new(0, 1, 0)
    
    -- Записываем начальное состояние
    local initialState = recordModelState(model, 0)
    table.insert(currentRecording.frames, initialState)
    log("📊 Записал начальное состояние")
    
    -- Запускаем запись каждый кадр
    recordingConnection = RunService.Heartbeat:Connect(function()
        if not isRecording then
            return
        end
        
        local frameTime = tick() - currentRecording.startTime
        local state = recordModelState(model, frameTime)
        table.insert(currentRecording.frames, state)
        
        -- Обновляем статус каждые 10 кадров
        if #currentRecording.frames % 10 == 0 then
            statusLabel.Text = string.format("🔴 REC: %.1fs (%d frames)", frameTime, #currentRecording.frames)
        end
        
        -- Останавливаем если модель исчезла
        if not state.modelExists then
            log("💥 Модель исчезла - останавливаю запись")
            stopRecording()
        end
        
        -- Автостоп через 10 секунд
        if frameTime > 10 then
            log("⏰ Автостоп через 10 секунд")
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
    
    statusLabel.Text = "✅ Recording complete"
    recordButton.Text = "🔴 START RECORDING"
    recordButton.BackgroundColor3 = Color3.new(1, 0, 0)
    
    log("✅ Запись завершена!")
    log("⏱️ Длительность: " .. string.format("%.2f", duration) .. " секунд")
    log("🎞️ Кадров записано: " .. #currentRecording.frames)
    
    -- Сохраняем данные
    animationData[currentRecording.modelName] = currentRecording
    
    -- Анализируем записанные данные
    analyzeAnimation(currentRecording)
end

-- Функция анализа анимации
local function analyzeAnimation(recording)
    log("\n=== АНАЛИЗ АНИМАЦИИ ===")
    
    if #recording.frames < 2 then
        log("❌ Недостаточно кадров для анализа")
        return
    end
    
    local firstFrame = recording.frames[1]
    local lastFrame = recording.frames[#recording.frames]
    
    log("📊 Анализирую " .. #recording.frames .. " кадров...")
    
    -- Анализируем изменения размера
    for partName, firstState in pairs(firstFrame.parts) do
        if lastFrame.parts[partName] then
            local startSize = firstState.size
            local endSize = lastFrame.parts[partName].size
            
            if startSize and endSize then
                local sizeChange = endSize.Magnitude / startSize.Magnitude
                
                if sizeChange > 1.2 then
                    log("📈 " .. partName .. " увеличился в " .. string.format("%.2f", sizeChange) .. " раз")
                elseif sizeChange < 0.8 then
                    log("📉 " .. partName .. " уменьшился в " .. string.format("%.2f", 1/sizeChange) .. " раз")
                end
            end
            
            local startTrans = firstState.transparency or 0
            local endTrans = lastFrame.parts[partName].transparency or 0
            
            if math.abs(endTrans - startTrans) > 0.1 then
                log("💫 " .. partName .. " прозрачность: " .. string.format("%.2f", startTrans) .. " → " .. string.format("%.2f", endTrans))
            end
        end
    end
    
    log("🎯 Анализ завершен!")
end

-- Кнопка переключения записи
recordButton.MouseButton1Click:Connect(function()
    if isRecording then
        stopRecording()
    else
        statusLabel.Text = "⏳ Waiting for pet..."
        log("⏳ Жду появления питомца из яйца...")
    end
end)

-- Отслеживаем появление моделей в Visuals
local visuals = Workspace:FindFirstChild("Visuals")
if visuals then
    log("✅ Найдена папка Visuals")
    
    visuals.ChildAdded:Connect(function(child)
        if child:IsA("Model") and not isRecording then
            log("🎯 Обнаружена модель: " .. (child.Name or "Unknown"))
            
            -- Проверяем что это питомец (не эффект)
            if child.Name and not child.Name:find("Egg") and not child.Name:find("Explode") and not child.Name:find("Poof") then
                wait(0.1) -- Небольшая задержка
                
                if statusLabel.Text:find("Waiting") or recordButton.Text == "⏹️ STOP RECORDING" then
                    startRecording(child)
                end
            else
                log("⚠️ Пропускаю эффект: " .. (child.Name or "Unknown"))
            end
        end
    end)
else
    log("❌ Папка Visuals не найдена")
end

log("🎬 Fixed Animation Recorder готов!")
log("📋 Нажми START RECORDING и открой яйцо")

print("🎬 Fixed Animation Recorder loaded!")
