--[[
    ANIMATION RECORDER
    Записывает ВСЕ анимации питомца из яйца
    Включая рост, позицию, прозрачность, взрыв
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local isRecording = false
local animationData = {}
local currentRecording = nil

-- GUI для управления
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AnimationRecorder"
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
title.Text = "🎬 ANIMATION RECORDER"
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

-- Функция записи состояния модели
local function recordModelState(model, frameTime)
    local state = {
        time = frameTime,
        parts = {}
    }
    
    -- Записываем состояние каждой части
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            state.parts[part.Name] = {
                size = part.Size,
                cframe = part.CFrame,
                transparency = part.Transparency,
                canCollide = part.CanCollide,
                color = part.Color,
                material = part.Material
            }
        elseif part:IsA("SpecialMesh") then
            state.parts[part.Parent.Name .. "_Mesh"] = {
                scale = part.Scale,
                meshType = part.MeshType.Name
            }
        elseif part:IsA("Decal") or part:IsA("Texture") then
            state.parts[part.Parent.Name .. "_" .. part.Name] = {
                transparency = part.Transparency,
                color3 = part.Color3
            }
        end
    end
    
    -- Записываем общие свойства модели
    state.modelCFrame = model:GetModelCFrame()
    state.modelSize = model:GetExtentsSize()
    
    return state
end

-- Функция начала записи
local function startRecording(model)
    if isRecording then return end
    
    isRecording = true
    currentRecording = {
        startTime = tick(),
        frames = {},
        model = model
    }
    
    statusLabel.Text = "🔴 RECORDING: " .. model.Name
    recordButton.Text = "⏹️ STOP RECORDING"
    recordButton.BackgroundColor3 = Color3.new(0, 1, 0)
    
    log("🎬 Начинаю запись анимации: " .. model.Name)
    log("📊 Записываю все части модели...")
    
    -- Записываем начальное состояние
    local initialState = recordModelState(model, 0)
    table.insert(currentRecording.frames, initialState)
    
    -- Запускаем запись каждый кадр
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not isRecording or not model.Parent then
            connection:Disconnect()
            stopRecording()
            return
        end
        
        local frameTime = tick() - currentRecording.startTime
        local state = recordModelState(model, frameTime)
        table.insert(currentRecording.frames, state)
        
        -- Обновляем статус
        statusLabel.Text = string.format("🔴 RECORDING: %.1fs (%d frames)", frameTime, #currentRecording.frames)
    end)
    
    -- Останавливаем запись когда модель исчезает
    local disappearConnection
    disappearConnection = model.AncestryChanged:Connect(function()
        if not model.Parent then
            log("💥 Модель исчезла - останавливаю запись")
            disappearConnection:Disconnect()
            connection:Disconnect()
            stopRecording()
        end
    end)
end

-- Функция остановки записи
function stopRecording()
    if not isRecording then return end
    
    isRecording = false
    local duration = tick() - currentRecording.startTime
    
    statusLabel.Text = "✅ Recording complete"
    recordButton.Text = "🔴 START RECORDING"
    recordButton.BackgroundColor3 = Color3.new(1, 0, 0)
    
    log("✅ Запись завершена!")
    log("⏱️ Длительность: " .. string.format("%.2f", duration) .. " секунд")
    log("🎞️ Кадров записано: " .. #currentRecording.frames)
    
    -- Сохраняем данные
    animationData[currentRecording.model.Name] = currentRecording
    
    -- Анализируем записанные данные
    analyzeAnimation(currentRecording)
end

-- Функция анализа анимации
local function analyzeAnimation(recording)
    log("\n=== АНАЛИЗ АНИМАЦИИ ===")
    
    local firstFrame = recording.frames[1]
    local lastFrame = recording.frames[#recording.frames]
    
    -- Анализируем изменения размера
    for partName, firstState in pairs(firstFrame.parts) do
        if firstState.size and lastFrame.parts[partName] and lastFrame.parts[partName].size then
            local startSize = firstState.size
            local endSize = lastFrame.parts[partName].size
            local sizeChange = endSize / startSize
            
            if sizeChange.Magnitude > 1.1 then
                log("📈 " .. partName .. " увеличился в " .. string.format("%.2f", sizeChange.Magnitude) .. " раз")
            end
        end
        
        if firstState.transparency and lastFrame.parts[partName] and lastFrame.parts[partName].transparency then
            local startTrans = firstState.transparency
            local endTrans = lastFrame.parts[partName].transparency
            
            if math.abs(endTrans - startTrans) > 0.1 then
                log("💫 " .. partName .. " прозрачность: " .. string.format("%.2f", startTrans) .. " → " .. string.format("%.2f", endTrans))
            end
        end
    end
    
    -- Анализируем общие изменения модели
    local startModelSize = firstFrame.modelSize
    local endModelSize = lastFrame.modelSize
    local modelGrowth = endModelSize / startModelSize
    
    log("🔍 Общий рост модели: " .. string.format("%.2f", modelGrowth.Magnitude) .. "x")
    log("📍 Позиция изменилась: " .. tostring((lastFrame.modelCFrame.Position - firstFrame.modelCFrame.Position).Magnitude > 1))
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

-- Отслеживаем появление моделей
local function monitorWorkspace()
    -- Ищем папку Visuals
    local visuals = Workspace:FindFirstChild("Visuals")
    if visuals then
        log("✅ Найдена папка Visuals")
        
        visuals.ChildAdded:Connect(function(child)
            if child:IsA("Model") and not isRecording then
                log("🎯 Обнаружена новая модель: " .. child.Name)
                wait(0.1) -- Небольшая задержка для загрузки
                
                if recordButton.Text == "⏹️ STOP RECORDING" or statusLabel.Text:find("Waiting") then
                    startRecording(child)
                end
            end
        end)
    else
        log("❌ Папка Visuals не найдена")
        log("🔍 Мониторю весь Workspace...")
        
        Workspace.ChildAdded:Connect(function(child)
            if child:IsA("Model") and not isRecording then
                log("🎯 Обнаружена модель в Workspace: " .. child.Name)
                wait(0.1)
                
                if recordButton.Text == "⏹️ STOP RECORDING" or statusLabel.Text:find("Waiting") then
                    startRecording(child)
                end
            end
        end)
    end
end

monitorWorkspace()

log("🎬 Animation Recorder готов!")
log("📋 Инструкция:")
log("1. Нажми 'START RECORDING'")
log("2. Открой яйцо")
log("3. Запись автоматически остановится")
log("4. Получишь полный анализ анимации")

print("🎬 Animation Recorder loaded!")
