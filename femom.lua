-- Создаём GUI
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local TextBox = Instance.new("TextBox")
local TextLabel = Instance.new("TextLabel")
local ScrollFrame = Instance.new("ScrollingFrame")
local CodeLabel = Instance.new("TextLabel")
local ExecuteButton = Instance.new("TextButton")

ScreenGui.Parent = game.CoreGui

Frame.Size = UDim2.new(0, 500, 0, 300)
Frame.Position = UDim2.new(0.5, -250, 0.5, -150)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.Parent = ScreenGui

TextLabel.Text = "Вставь команду с loadstring:"
TextLabel.Size = UDim2.new(1, 0, 0, 30)
TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.BackgroundTransparency = 1
TextLabel.Parent = Frame

TextBox.Size = UDim2.new(1, -20, 0, 30)
TextBox.Position = UDim2.new(0, 10, 0, 35)
TextBox.Text = ""
TextBox.TextColor3 = Color3.fromRGB(0, 0, 0)
TextBox.Parent = Frame

ExecuteButton.Size = UDim2.new(1, -20, 0, 30)
ExecuteButton.Position = UDim2.new(0, 10, 0, 70)
ExecuteButton.Text = "Перехватить код"
ExecuteButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
ExecuteButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ExecuteButton.Parent = Frame

ScrollFrame.Size = UDim2.new(1, -20, 1, -110)
ScrollFrame.Position = UDim2.new(0, 10, 0, 110)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 5, 0)
ScrollFrame.ScrollBarThickness = 8
ScrollFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ScrollFrame.Parent = Frame

CodeLabel.Size = UDim2.new(1, -10, 0, 2000)
CodeLabel.Text = ""
CodeLabel.TextXAlignment = Enum.TextXAlignment.Left
CodeLabel.TextYAlignment = Enum.TextYAlignment.Top
CodeLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
CodeLabel.TextWrapped = false
CodeLabel.TextSize = 14
CodeLabel.Font = Enum.Font.Code
CodeLabel.Parent = ScrollFrame

-- Логика кнопки
ExecuteButton.MouseButton1Click:Connect(function()
    local input = TextBox.Text
    local url = input:match("%((['\"])(https.-)%1%)")
    if url then
        local data = game:HttpGet(url)
        CodeLabel.Text = data
    else
        CodeLabel.Text = "Не удалось найти ссылку в команде!"
    end
end)
