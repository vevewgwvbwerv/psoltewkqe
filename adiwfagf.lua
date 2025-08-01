-- Services
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer or Players:GetPlayers()[1]

-- Your exact eggChances table
local eggChances = {
["Anti Bee Egg"] = {{name="Wasp",chance=55},{name="Tarantula Hawk",chance=30},{name="Moth",chance=13.75},{name="Butterfly",chance=1},{name="Disco Bee (Divine)",chance=0.5}},
["Bee Egg"] = {{name="Bee",chance=65},{name="Honey Bee",chance=25},{name="Bear Bee",chance=5},{name="Petal Bee",chance=4},{name="Queen Bee",chance=1}},
["Bug Egg"] = {{name="Snail",chance=40},{name="Giant Ant",chance=30},{name="Caterpillar",chance=25},{name="Praying Mantis",chance=4},{name="Dragonfly (Divine)",chance=1}},
["Common Egg"] = {{name="Dog",chance=33},{name="Bunny",chance=33},{name="Golden Lab",chance=34}},
["Common Summer Egg"] = {{name="Starfish",chance=50},{name="Seagull",chance=25},{name="Crab",chance=25}},
["Dinosaur Egg"] = {{name="Raptor",chance=35},{name="Triceratops",chance=32.5},{name="Stegosaurus",chance=28},{name="Pterodactyl",chance=3},{name="Brontosaurus",chance=1},{name="T-Rex (Divine)",chance=0.5}},
["Legendary Egg"] = {{name="Cow",chance=43},{name="Silver Monkey",chance=43},{name="Sea Otter",chance=11},{name="Turtle",chance=2},{name="Polar Bear",chance=2}},
["Mythical Egg"] = {{name="Grey Mouse",chance=36},{name="Brown Mouse",chance=27},{name="Squirrel",chance=27},{name="Red Giant Ant",chance=9},{name="Red Fox",chance=2}},
["Night Egg"] = {{name="Hedgehog",chance=49},{name="Mole",chance=23.5},{name="Frog",chance=17.63},{name="Echo Frog",chance=8.23},{name="Night Owl",chance=3.53},{name="Raccoon",chance=0.2}},
["Oasis Egg"] = {{name="Meerkat",chance=45},{name="Sand Snake",chance=34.5},{name="Axolotl",chance=15},{name="Hyacinth Macaw",chance=5},{name="Fennec Fox",chance=0.5}},
["Paradise Egg"] = {{name="Ostrich",chance=40},{name="Peacock",chance=30},{name="Capybara",chance=21},{name="Scarlet Macaw",chance=8},{name="Mimic Octopus",chance=1}},
["Primal Egg"] = {{name="Parasaurolophus",chance=35},{name="Iguanodon",chance=32.5},{name="Pachycephalosaurus",chance=28},{name="Dilophosaurus",chance=3},{name="Ankylosaurus",chance=1},{name="Spinosaurus (Divine)",chance=0.5}},
["Rare Egg"] = {{name="Orange Tabby",chance=33},{name="Spotted Deer",chance=25},{name="Pig",chance=17},{name="Rooster",chance=17},{name="Monkey",chance=8}},
["Rare Summer Egg"] = {{name="Flamingo",chance=30},{name="Toucan",chance=25},{name="Sea Turtle",chance=20},{name="Orangutan",chance=15},{name="Seal",chance=10}},
["Uncommon Egg"] = {{name="Black Bunny",chance=25},{name="Chicken",chance=25},{name="Cat",chance=25},{name="Deer",chance=25}},
["Zen Egg"] = {
{name="Shiba Inu",chance=49},
{name="Nihonzaru",chance=23.5},
{name="Tanuki",chance=17.63},
{name="Tanchozuru",chance=8.23},
{name="Kappa",chance=3.53},
{name="Kitsune",chance=0.2}
}
}

-- Tracks ESP visibility state
local espEnabled = false

-- Pet rarity color
local function getPetRarityColor(petName)
if petName:find("%(Divine%)") then
return Color3.fromRGB(255, 215, 0) -- Gold
end
return Color3.fromRGB(255, 85, 85) -- Red
end

-- Weighted random pet selector
local function getRandomPet(eggName)
local pets = eggChances[eggName]
if not pets then return "Unknown" end
local totalChance = 0
for _, pet in ipairs(pets) do
totalChance += pet.chance
end
local roll = math.random() * totalChance
local sum = 0
for _, pet in ipairs(pets) do
sum += pet.chance
if roll <= sum then
return pet.name
end
end
return pets[#pets].name
end

-- GUI setup
local gui = Instance.new("ScreenGui")
gui.Name = "EggESP_GUI"
gui.Parent = CoreGui
gui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0, 180, 0, 40)
mainFrame.Position = UDim2.new(0.78, 0, 0.05, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(45, 0, 0)
mainFrame.BorderColor3 = Color3.fromRGB(255, 0, 0)
mainFrame.BorderSizePixel = 2
mainFrame.Active = true
mainFrame.Draggable = true

local toggleBtn = Instance.new("TextButton", mainFrame)
toggleBtn.Size = UDim2.new(1, 0, 1, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
toggleBtn.TextColor3 = Color3.new(1, 0, 0)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 16
toggleBtn.Text = "MakuScripts Menu ⏬"
toggleBtn.AutoButtonColor = false

local buttonHolder = Instance.new("Frame", mainFrame)
buttonHolder.Position = UDim2.new(0, 0, 1, 0)
buttonHolder.Size = UDim2.new(1, 0, 0, 290) -- Increased height to accommodate new button
buttonHolder.BackgroundTransparency = 1
buttonHolder.Visible = false

-- Existing buttons (Egg ESP, Randomize Egg, Auto Age)
local espBtn = Instance.new("TextButton", buttonHolder)
espBtn.Size = UDim2.new(1, 0, 0, 40)
espBtn.BackgroundColor3 = Color3.fromRGB(90, 0, 0)
espBtn.TextColor3 = Color3.new(1, 0.3, 0.3)
espBtn.Font = Enum.Font.GothamBold
espBtn.TextSize = 15
espBtn.Text = "Egg ESP"

local randBtn = Instance.new("TextButton", buttonHolder)
randBtn.Size = UDim2.new(1, 0, 0, 40)
randBtn.Position = UDim2.new(0, 0, 0, 45)
randBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
randBtn.TextColor3 = Color3.new(1, 0.3, 0.3)
randBtn.Font = Enum.Font.GothamBold
randBtn.TextSize = 15
randBtn.Text = "Randomize Egg"

local autoAgeBtn = Instance.new("TextButton", buttonHolder)
autoAgeBtn.Size = UDim2.new(1, 0, 0, 40)
autoAgeBtn.Position = UDim2.new(0, 0, 0, 90)
autoAgeBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
autoAgeBtn.TextColor3 = Color3.new(1, 1, 1)
autoAgeBtn.Font = Enum.Font.GothamBold
autoAgeBtn.TextSize = 15
autoAgeBtn.Text = "Auto Age (hold pet)"

-- Mutation section
local mutationTitle = Instance.new("TextLabel", buttonHolder)  
mutationTitle.Size = UDim2.new(1, 0, 0, 20)  
mutationTitle.Position = UDim2.new(0, 0, 0, 135)  
mutationTitle.BackgroundTransparency = 1  
mutationTitle.Text = "Pet Mutation Hacks 🔽"  
mutationTitle.Font = Enum.Font.GothamBold  
mutationTitle.TextSize = 16  
mutationTitle.TextColor3 = Color3.fromRGB(255, 100, 100)  

local mutationRerollBtn = Instance.new("TextButton", buttonHolder)  
mutationRerollBtn.Size = UDim2.new(1, 0, 0, 40)  
mutationRerollBtn.Position = UDim2.new(0, 0, 0, 155)  
mutationRerollBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)  
mutationRerollBtn.TextColor3 = Color3.new(1, 1, 1)  
mutationRerollBtn.Font = Enum.Font.GothamBold  
mutationRerollBtn.TextSize = 15  
mutationRerollBtn.Text = "Mutation Reroll"  

local mutationToggleBtn = Instance.new("TextButton", buttonHolder)  
mutationToggleBtn.Size = UDim2.new(1, 0, 0, 40)  
mutationToggleBtn.Position = UDim2.new(0, 0, 0, 200)  
mutationToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)  
mutationToggleBtn.TextColor3 = Color3.new(1, 1, 1)  
mutationToggleBtn.Font = Enum.Font.GothamBold  
mutationToggleBtn.TextSize = 15  
mutationToggleBtn.Text = "Toggle Mutation"  

-- NEW LEAK SCRIPT BUTTON
local leakScriptBtn = Instance.new("TextButton", buttonHolder)
leakScriptBtn.Size = UDim2.new(1, 0, 0, 40)
leakScriptBtn.Position = UDim2.new(0, 0, 0, 245)
leakScriptBtn.BackgroundColor3 = Color3.fromRGB(220, 0, 0)
leakScriptBtn.TextColor3 = Color3.new(1, 1, 1)
leakScriptBtn.Font = Enum.Font.GothamBold
leakScriptBtn.TextSize = 15
leakScriptBtn.Text = "Leak Script"

toggleBtn.MouseButton1Click:Connect(function()
buttonHolder.Visible = not buttonHolder.Visible
toggleBtn.Text = buttonHolder.Visible and "MakuScripts Menu ⏫" or "MakuScripts Menu ⏬"
end)

-- Table to store ESP Billboards
local espBillboards = {}

local MAX_DISTANCE = 60 -- studs max distance for ESP to appear

-- Clear ESP
local function clearESP()
for eggModel, billboard in pairs(espBillboards) do
if billboard and billboard.Parent then
billboard:Destroy()
end
end
espBillboards = {}
end

-- Recursive egg finder
local function findEggModels(root)
local eggs = {}
for _, child in pairs(root:GetChildren()) do
if eggChances[child.Name] then
table.insert(eggs, child)
end
for _, subchild in pairs(findEggModels(child)) do
table.insert(eggs, subchild)
end
end
return eggs
end

-- Create ESP for an egg
local function createESP(eggModel)
if espBillboards[eggModel] then return end

local adornee = eggModel.PrimaryPart or eggModel:FindFirstChildWhichIsA("BasePart")  
if not adornee then  
    print("No PrimaryPart or BasePart found for egg:", eggModel.Name)  
    return  
end  

local eggName = eggModel.Name  
if not eggChances[eggName] then  
    print("Egg name not in eggChances:", eggName)  
    return  
end  

local petName = getRandomPet(eggName)  

local billboard = Instance.new("BillboardGui")  
billboard.Name = "EggESP"  
billboard.Adornee = adornee  
billboard.Size = UDim2.new(0, 140, 0, 50)  
billboard.AlwaysOnTop = true  
billboard.StudsOffset = Vector3.new(0, 3, 0)  
billboard.Parent = CoreGui  

local eggLabel = Instance.new("TextLabel", billboard)  
eggLabel.Size = UDim2.new(1, 0, 0.5, 0)  
eggLabel.Position = UDim2.new(0, 0, 0, 0)  
eggLabel.BackgroundTransparency = 1  
eggLabel.Text = eggName  
eggLabel.TextColor3 = Color3.new(1, 1, 1)  
eggLabel.TextStrokeTransparency = 0.3  
eggLabel.Font = Enum.Font.GothamBold  
eggLabel.TextScaled = true  

local petLabel = Instance.new("TextLabel", billboard)  
petLabel.Size = UDim2.new(1, 0, 0.5, 0)  
petLabel.Position = UDim2.new(0, 0, 0.5, 0)  
petLabel.BackgroundTransparency = 1  
petLabel.Text = petName  
petLabel.TextColor3 = getPetRarityColor(petName)  
petLabel.TextStrokeTransparency = 0.3  
petLabel.Font = Enum.Font.GothamBold  
petLabel.TextScaled = true  

espBillboards[eggModel] = billboard  
print("Created ESP for egg:", eggName)

end

-- Refresh all ESP with proximity filter
local function refreshESP()
clearESP()
if not espEnabled then return end  -- Only show if ESP is enabled

local eggs = findEggModels(Workspace)  
local char = LocalPlayer.Character  
if not char or not char:FindFirstChild("HumanoidRootPart") then return end  
local hrp = char.HumanoidRootPart  

print("Found eggs count:", #eggs)  
for _, egg in ipairs(eggs) do  
    local adornee = egg.PrimaryPart or egg:FindFirstChildWhichIsA("BasePart")  
    if adornee then  
        local dist = (hrp.Position - adornee.Position).Magnitude  
        if dist <= MAX_DISTANCE then  
            createESP(egg)  
        end  
    end  
end

end

-- Randomize pet names on existing ESPs
local function randomizePets()
for eggModel, billboard in pairs(espBillboards) do
if billboard and billboard.Parent then
local petLabel
for _, child in pairs(billboard:GetChildren()) do
if child:IsA("TextLabel") and child.Position.Y.Scale > 0 then
petLabel = child
break
end
end
if petLabel then
local newPet = getRandomPet(eggModel.Name)
petLabel.Text = newPet
petLabel.TextColor3 = getPetRarityColor(newPet)
end
end
end
end

-- ESP toggle button logic
espBtn.MouseButton1Click:Connect(function()
espEnabled = not espEnabled
if espEnabled then
refreshESP()
espBtn.Text = "ESP ✅ ON"
else
clearESP()
espBtn.Text = "ESP ❌ OFF"
end
end)

randBtn.MouseButton1Click:Connect(randomizePets)

-- Auto Age button logic
local isCooldown = false
autoAgeBtn.MouseButton1Click:Connect(function()
if isCooldown then return end

local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")  
if not tool then  
    warn("No pet equipped.")
    return
end

local itemName = tool.Name  
local currentAge = tonumber(itemName:match("%[Age%s*(%d+)%]"))  
if not currentAge then  
    warn("Age not found in item name.")  
    return  
end  

local prefix = itemName:match("^(.-)%s*%[Age%s*%d+%]") or itemName  

isCooldown = true  
autoAgeBtn.Text = "Spoofing..."  

for i = currentAge + 1, 50 do  
    tool.Name = prefix .. "[Age " .. i .. "]"  
    task.wait(0.12)  
end  

autoAgeBtn.Text = "Auto Age (hold pet)"  
isCooldown = false
end)

-- Mutation functions
local RunService = game:GetService("RunService")

local mutations = {
"Shiny", "Inverted", "Frozen", "Windy", "Golden", "Mega", "Tiny",
"Tranquil", "IronSkin", "Radiant", "Rainbow", "Shocked", "Ascended"
}

local currentMutation = mutations[math.random(#mutations)]
local espVisible = false

-- Find mutation machine model in workspace
local function findMachine()
for _, obj in pairs(Workspace:GetDescendants()) do
if obj:IsA("Model") and obj.Name:lower():find("mutation") then
return obj
end
end
end

local machine = findMachine()
if not machine then
warn("Pet Mutation Machine not found.")
else
local basePart = machine:FindFirstChildWhichIsA("BasePart")
if not basePart then
warn("Pet Mutation Machine BasePart not found.")
else
if basePart:FindFirstChild("MutationESP") then
basePart.MutationESP:Destroy()
end

local espGui = Instance.new("BillboardGui")  
    espGui.Name = "MutationESP"  
    espGui.Adornee = basePart  
    espGui.Size = UDim2.new(0, 200, 0, 40)  
    espGui.StudsOffset = Vector3.new(0, 3, 0)  
    espGui.AlwaysOnTop = true  
    espGui.Parent = basePart  
    espGui.Enabled = espVisible  

    local espLabel = Instance.new("TextLabel", espGui)  
    espLabel.Size = UDim2.new(1, 0, 1, 0)  
    espLabel.BackgroundTransparency = 1  
    espLabel.Font = Enum.Font.GothamBold  
    espLabel.TextSize = 24  
    espLabel.TextStrokeTransparency = 0.3  
    espLabel.TextStrokeColor3 = Color3.new(0, 0, 0)  
    espLabel.Text = currentMutation  

    -- Animate rainbow text color when visible  
    local hue = 0  
    RunService.RenderStepped:Connect(function()  
        if espVisible then  
            hue = (hue + 0.01) % 1  
            espLabel.TextColor3 = Color3.fromHSV(hue, 1, 1)  
        end  
    end)  

    local function rerollMutation()  
        espLabel.Text = "⏳ Rerolling..."  
        local duration = 2  
        local interval = 0.1  
        for i = 1, math.floor(duration / interval) do  
            espLabel.Text = mutations[math.random(#mutations)]  
            task.wait(interval)  
        end  
        currentMutation = mutations[math.random(#mutations)]  
        espLabel.Text = currentMutation  
    end  

    local function toggleESP()  
        espVisible = not espVisible  
        espGui.Enabled = espVisible  
    end  

    mutationRerollBtn.MouseButton1Click:Connect(rerollMutation)  
    mutationToggleBtn.MouseButton1Click:Connect(toggleESP)  
end
end

-- Leak Script button functionality
leakScriptBtn.MouseButton1Click:Connect(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/veryimportantrr/x/refs/heads/main/gag_visual.lua", true))()
end)
