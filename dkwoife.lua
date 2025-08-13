-- Создаём GUI
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local TextBox = Instance.new("TextBox")
local TextLabel = Instance.new("TextLabel")
local ScrollFrame = Instance.new("ScrollingFrame")
local CodeLabel = Instance.new("TextLabel")
local ExecuteButton = Instance.new("TextButton")

-- Подключаем GUI к CoreGui
ScreenGui.Parent = game.CoreGui

-- Настройки главного окна
Frame.Size = UDim2.new(0, 600, 0, 400)
Frame.Position = UDim2.new(0.5, -300, 0.5, -200)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

-- Текстовое описание
TextLabel.Text = "Вставь команду с loadstring:"
TextLabel.Size = UDim2.new(1, 0, 0, 30)
TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.BackgroundTransparency = 1
TextLabel.Font = Enum.Font.SourceSansBold
TextLabel.TextSize = 18
TextLabel.Parent = Frame

-- Поле для ввода команды
TextBox.Size = UDim2.new(1, -20, 0, 30)
TextBox.Position = UDim2.new(0, 10, 0, 35)
TextBox.Text = ""
TextBox.PlaceholderText = 'Пример: loadstring(game:HttpGet("https://example.com/script.lua"))()'
TextBox.TextColor3 = Color3.fromRGB(0, 0, 0)
TextBox.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
TextBox.ClearTextOnFocus = false
TextBox.Parent = Frame

-- Кнопка запуска
ExecuteButton.Size = UDim2.new(1, -20, 0, 30)
ExecuteButton.Position = UDim2.new(0, 10, 0, 70)
ExecuteButton.Text = "Перехватить код"
ExecuteButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ExecuteButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ExecuteButton.Font = Enum.Font.SourceSansBold
ExecuteButton.TextSize = 16
ExecuteButton.Parent = Frame

-- Поле для отображения кода
ScrollFrame.Size = UDim2.new(1, -20, 1, -110)
ScrollFrame.Position = UDim2.new(0, 10, 0, 110)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.ScrollBarThickness = 8
ScrollFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ScrollFrame.BorderSizePixel = 0
ScrollFrame.Parent = Frame

CodeLabel.Size = UDim2.new(1, -10, 0, 2000) -- Высота с запасом
CodeLabel.Text = ""
CodeLabel.TextXAlignment = Enum.TextXAlignment.Left
CodeLabel.TextYAlignment = Enum.TextYAlignment.Top
CodeLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
CodeLabel.BackgroundTransparency = 1
CodeLabel.TextWrapped = false
CodeLabel.TextSize = 14
CodeLabel.Font = Enum.Font.Code
CodeLabel.Parent = ScrollFrame

-- Логика кнопки
ExecuteButton.MouseButton1Click:Connect(function()
    local input = TextBox.Text
    local url = input:match("https://[^\"]+")
    if url then
        local success, data = pcall(function()
            return game:HttpGet(url)
        end)
        if success then
            CodeLabel.Text = data
            -- Автоматическая прокрутка и размер
            local lines = select(2, data:gsub("\n", "\n")) + 1
            CodeLabel.Size = UDim2.new(1, -10, 0, lines * 16)
            ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, lines * 16)
        else
            CodeLabel.Text = "Ошибка запроса: " .. tostring(data)
        end
    else
        CodeLabel.Text = "Не удалось найти ссылку в команде!"
    end
end)
