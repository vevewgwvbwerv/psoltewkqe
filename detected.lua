-- 🎯 PET CREATOR - Генератор питомцев по данным
-- Создает новую модель питомца с UUID именем на основе данных из PetGenerator.lua
-- Размещает питомца рядом с игроком в Workspace

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer

print("🎯 === PET CREATOR - ГЕНЕРАТОР ПИТОМЦЕВ ===")
print("=" .. string.rep("=", 50))

-- Полные данные питомца (из PetGenerator.lua)
local PET_DATA = {
    ["PrimaryPart"] = "RootPart",
    ["ModelSize"] = Vector3.new(2.70, 2.80, 2.42),
    ["ModelPosition"] = Vector3.new(34.18, 1.32, -116.14),
    ["TotalParts"] = 15,
    ["TotalMeshes"] = 1,
    ["TotalMotor6D"] = 14,
    ["TotalHumanoids"] = 0,
    ["TotalAttachments"] = 0,
    ["TotalScripts"] = 0,
    
    ["Meshes"] = {
        [1] = {name = "MouthEnd", type = "MeshPart", parent = "MODEL", meshId = "rbxassetid://134824845323237"}
    },

    ["Motor6D"] = {
        [1] = {
            name = "Mouth", 
            part0 = "Jaw", 
            part1 = "Mouth",
            c0 = CFrame.new(0.113, 0.000, -0.000, 0.000, 1.000, 0.000, 1.000, 0.000, 0.000, 0.000, 0.000, -1.000),
            c1 = CFrame.new(0.000, 0.000, 0.000, 1.000, 0.000, 0.000, 0.000, 1.000, 0.000, 0.000, 0.000, 1.000),
            transform = CFrame.new(-0.000, -0.000, 0.000, 1.000, 0.000, 0.000, 0.000, 1.000, 0.000, 0.000, 0.000, 1.000)
        },
        [2] = {
            name = "MouthEnd", 
            part0 = "Jaw", 
            part1 = "MouthEnd",
            c0 = CFrame.new(0.113, -0.204, -0.000, 0.000, 0.000, -1.000, 0.000, 1.000, 0.000, 1.000, 0.000, 0.000),
            c1 = CFrame.new(0.000, 0.000, 0.000, 1.000, 0.000, 0.000, 0.000, 1.000, 0.000, 0.000, 0.000, 1.000),
            transform = CFrame.new(0.000, -0.000, 0.000, 1.000, 0.000, 0.000, 0.000, 1.000, 0.000, 0.000, 0.000, 1.000)
        },
        [3] = {
            name = "Head", 
            part0 = "Torso", 
            part1 = "Head",
            c0 = CFrame.new(0.226, 0.181, 0.000, 1.000, 0.000, 0.000, 0.000, 1.000, 0.000, 0.000, 0.000, 1.000),
            c1 = CFrame.new(-0.633, 0.000, 0.000, 1.000, 0.000, 0.000, 0.000, 1.000, 0.000, 0.000, 0.000, 1.000),
            transform = CFrame.new(0.000, 0.000, 0.000, 0.985, -0.090, 0.146, 0.097, 0.995, -0.036, -0.142, 0.050, 0.989)
        },
        [4] = {
            name = "BackLegL", 
            part0 = "Torso", 
            part1 = "BackLegL",
            c0 = CFrame.new(-0.226, -0.091, 0.452, 1.000, 0.000, 0.000, 0.000, 1.000, 0.000, 0.000, 0.000, 1.000),
            c1 = CFrame.new(0.362, 0.181, 0.000, 1.000, 0.000, 0.000, 0.000, 1.000, 0.000, 0.000, 0.000, 1.000),
            transform = CFrame.new(0.064, -0.037, 0.032, 0.997, 0.077, -0.030, -0.080, 0.988, -0.130, 0.019, 0.132, 0.991)
        },
        [5] = {
            name = "FrontLegL", 
            part0 = "Torso", 
            part1 = "FrontLegL",
            c0 = CFrame.new(-0.226, 0.633, 0.362, 1.000, 0.000, 0.000, 0.000, 1.000, 0.000, 0.000, 0.000, 1.000),
            c1 = CFrame.new(0.362, 0.181, 0.000, 1.000, 0.000, 0.000, 0.000, 1.000, 0.000, 0.000, 0.000, 1.000),
            transform = CFrame.new(0.127, 0.096, 0.037, 0.991, 0.134, -0.005, -0.133, 0.979, -0.157, -0.017, 0.156, 0.988)
        },
        [6] = {
            name = "FrontLegR", 
            part0 = "Torso", 
            part1 = "FrontLegR",
            c0 = CFrame.new(-0.226, 0.633, -0.362, 1.000, 0.000, 0.000, 0.000, 1.000, 0.000, 0.000, 0.000, 1.000),
            c1 = CFrame.new(0.362, 0.181, 0.000, 1.000, 0.000, 0.000, 0.000, 1.000, 0.000, 0.000, 0.000, 1.000),
            transform = CFrame.new(0.137, 0.069, -0.032, 0.984, 0.171, 0.040, -0.175, 0.943, 0.282, 0.011, -0.285, 0.959)
        },
        [7] = {
            name = "BackLegR", 
            part0 = "Torso", 
            part1 = "BackLegR",
            c0 = CFrame.new(-0.226, -0.091, -0.452, 1.000, 0.000, 0.000, 0.000, 1.000, 0.000, 0.000, 0.000, 1.000),
            c1 = CFrame.new(0.362, 0.181, 0.000, 1.000, 0.000, 0.000, 0.000, 1.000, 0.000, 0.000, 0.000, 1.000),
            transform = CFrame.new(0.069, -0.059, -0.014, 0.995, 0.091, 0.037, -0.098, 0.950, 0.297, -0.008, -0.300, 0.954)
        },
        [8] = {
            name = "Tail", 
            part0 = "Torso", 
            part1 = "Tail",
            c0 = CFrame.new(-0.330, -0.543, -0.000, 0.940, -0.340, 0.000, 0.340, 0.940, 0.000, 0.000, 0.000, 1.000),
            c1 = CFrame.new(0.038, 0.371, 0.000, 1.000, 0.000, 0.000, 0.000, 1.000, 0.000, 0.000, 0.000, 1.000),
            transform = CFrame.new(-0.000, 0.000, 0.000, 0.989, 0.045, -0.140, -0.036, 0.997, 0.064, 0.143, -0.058, 0.988)
        },
        [9] = {
            name = "RightEye", 
            part0 = "Head", 
            part1 = "RightEye",
            c0 = CFrame.new(0.068, 0.656, -0.407, 1.000, 0.000, 0.000, 0.000, 1.000, 0.000, 0.000, 0.000, 1.000),
            c1 = CFrame.new(0.000, 0.000, 0.000, 1.000, 0.000, 0.000, 0.000, 1.000, 0.000, 0.000, 0.000, 1.000),
            transform = CFrame.new(0.045, 0.004, 0.045, 1.000, 0.000, 0.000, 0.000, 1.000, 0.000, 0.000, 0.000, 1.000)
        },
        [10] = {
            name = "LeftEye", 
            part0 = "Head", 
            part1 = "LeftEye",
            c0 = CFrame.new(0.068, 0.656, 0.407, 1.000, 0.000, 0.000, 0.000, 1.000, 0.000, 0.000, 0.000, 1.000),
            c1 = CFrame.new(0.000, 0.000, 0.000, 1.000, 0.000, 0.000, 0.000, 1.000, 0.000, 0.000, 0.000, 1.000),
            transform = CFrame.new(0.045, 0.004, 0.045, 1.000, 0.000, 0.000, 0.000, 1.000, 0.000, 0.000, 0.000, 1.000)
        },
        [11] = {
            name = "LeftEar", 
            part0 = "Head", 
            part1 = "LeftEar",
            c0 = CFrame.new(0.416, 0.271, 0.565, 0.500, -0.000, -0.866, 0.000, 1.000, -0.000, 0.866, 0.000, 0.500),
            c1 = CFrame.new(-0.157, 0.000, -0.090, 1.000, 0.000, 0.000, 0.000, 1.000, 0.000, 0.000, 0.000, 1.000),
            transform = CFrame.new(0.000, 0.000, 0.000, 0.996, 0.079, -0.038, -0.076, 0.994, 0.077, 0.044, -0.074, 0.996)
        },
        [12] = {
            name = "RightEar", 
            part0 = "Head", 
            part1 = "RightEar",
            c0 = CFrame.new(0.376, 0.271, -0.635, 1.000, 0.000, 0.000, 0.000, 1.000, 0.000, 0.000, 0.000, 1.000),
            c1 = CFrame.new(0.000, 0.000, 0.181, 1.000, 0.000, 0.000, 0.000, 1.000, 0.000, 0.000, 0.000, 1.000),
            transform = CFrame.new(-0.000, 0.000, -0.000, 0.985, 0.110, 0.131, -0.096, 0.990, -0.102, -0.141, 0.088, 0.986)
        },
        [13] = {
            name = "Jaw", 
            part0 = "Head", 
            part1 = "Jaw",
            c0 = CFrame.new(-0.317, 0.452, -0.000, 0.000, 1.000, 0.000, 1.000, 0.000, 0.000, 0.000, 0.000, -1.000),
            c1 = CFrame.new(-0.271, 0.000, 0.000, 1.000, 0.000, 0.000, 0.000, 1.000, 0.000, 0.000, 0.000, 1.000),
            transform = CFrame.new(-0.000, -0.000, -0.000, 0.994, -0.109, 0.003, 0.109, 0.993, 0.036, -0.006, -0.036, 0.999)
        },
        [14] = {
            name = "Torso", 
            part0 = "RootPart", 
            part1 = "Torso",
            c0 = CFrame.new(0.000, 0.000, 0.000, 1.000, 0.000, 0.000, 0.000, 1.000, 0.000, 0.000, 0.000, 1.000),
            c1 = CFrame.new(0.000, 0.000, 0.000, 1.000, 0.000, 0.000, 0.000, 1.000, 0.000, 0.000, 0.000, 1.000),
            transform = CFrame.new(-0.092, 0.000, 0.000, 0.994, -0.112, 0.012, 0.112, 0.993, -0.029, -0.009, 0.030, 1.000)
        }
    },

    ["Parts"] = {
        [1] = {
            name = "RightEar", 
            type = "UnionOperation", 
            size = Vector3.new(0.79, 0.54, 0.64), 
            material = "Plastic",
            color = Color3.new(0.580, 0.400, 0.298),
            brickColor = "Red flip/flop",
            transparency = 0.00,
            canCollide = false,
            position = Vector3.new(34.93, 1.87, -117.13),
            rotation = Vector3.new(-68.63, -70.78, 27.23),
            relativeCFrame = CFrame.new(0.875, 0.735, -0.920, 0.949, -0.078, 0.307, 0.120, 0.985, -0.120, -0.293, 0.151, 0.944),
            reflectance = 0.00
        },
        [2] = {
            name = "LeftEar", 
            type = "UnionOperation", 
            size = Vector3.new(0.39, 0.54, 0.86), 
            material = "Plastic",
            color = Color3.new(0.580, 0.400, 0.298),
            brickColor = "Red flip/flop",
            transparency = 0.00,
            canCollide = false,
            position = Vector3.new(33.41, 2.18, -117.04),
            rotation = Vector3.new(80.50, -36.52, 173.12),
            relativeCFrame = CFrame.new(1.186, 0.649, 0.606, 0.603, -0.094, -0.793, -0.020, 0.991, -0.133, 0.798, 0.096, 0.595),
            reflectance = 0.00
        },
        [3] = {
            name = "Jaw", 
            type = "UnionOperation", 
            size = Vector3.new(0.18, 0.63, 0.81), 
            material = "Plastic",
            color = Color3.new(0.992, 0.788, 0.506),
            brickColor = "Pastel brown",
            transparency = 0.00,
            canCollide = false,
            position = Vector3.new(34.00, 1.30, -117.38),
            rotation = Vector3.new(114.78, 81.98, -120.37),
            relativeCFrame = CFrame.new(0.303, 0.983, 0.012, -0.093, 0.988, -0.127, 0.993, 0.101, 0.058, 0.071, -0.120, -0.990),
            reflectance = 0.00
        },
        [4] = {
            name = "Mouth", 
            type = "UnionOperation", 
            size = Vector3.new(0.36, 0.05, 0.23), 
            material = "Plastic",
            color = Color3.new(0.106, 0.165, 0.208),
            brickColor = "Black",
            transparency = 0.00,
            canCollide = false,
            position = Vector3.new(33.99, 1.29, -117.49),
            rotation = Vector3.new(-65.22, -81.98, 30.37),
            relativeCFrame = CFrame.new(0.292, 1.095, 0.020, 0.988, -0.093, 0.127, 0.101, 0.993, -0.058, -0.120, 0.071, 0.990),
            reflectance = 0.00
        },
        [5] = {
            name = "Torso", 
            type = "Part", 
            size = Vector3.new(0.45, 1.27, 1.27), 
            material = "Plastic",
            color = Color3.new(0.992, 0.788, 0.506),
            brickColor = "Pastel brown",
            transparency = 0.00,
            canCollide = false,
            position = Vector3.new(34.01, 0.90, -116.40),
            rotation = Vector3.new(-22.19, -88.21, 74.23),
            relativeCFrame = CFrame.new(-0.092, 0.000, 0.000, 0.994, -0.112, 0.012, 0.112, 0.993, -0.029, -0.009, 0.030, 1.000),
            reflectance = 0.00
        },
        [6] = {
            name = "Head", 
            type = "Part", 
            size = Vector3.new(1.27, 1.27, 1.45), 
            material = "Plastic",
            color = Color3.new(0.992, 0.788, 0.506),
            brickColor = "Pastel brown",
            transparency = 0.00,
            canCollide = false,
            position = Vector3.new(34.10, 1.72, -116.73),
            rotation = Vector3.new(-73.30, -80.30, 28.65),
            relativeCFrame = CFrame.new(0.725, 0.338, -0.090, 0.966, -0.200, 0.161, 0.211, 0.976, -0.048, -0.148, 0.081, 0.986),
            reflectance = 0.00
        },
        [7] = {
            name = "Tail", 
            type = "Part", 
            size = Vector3.new(0.36, 1.40, 0.36), 
            material = "Plastic",
            color = Color3.new(0.580, 0.400, 0.298),
            brickColor = "Red flip/flop",
            transparency = 0.00,
            canCollide = false,
            position = Vector3.new(34.02, 0.75, -115.46),
            rotation = Vector3.new(76.84, -81.59, -169.30),
            relativeCFrame = CFrame.new(-0.244, -0.931, -0.009, 0.904, -0.403, -0.142, 0.402, 0.915, -0.033, 0.144, -0.027, 0.989),
            reflectance = 0.00
        },
        [8] = {
            name = "LeftEye", 
            type = "Part", 
            size = Vector3.new(0.32, 0.05, 0.18), 
            material = "Plastic",
            color = Color3.new(0.106, 0.165, 0.208),
            brickColor = "Black",
            transparency = 0.00,
            canCollide = false,
            position = Vector3.new(33.62, 1.77, -117.38),
            rotation = Vector3.new(-73.30, -80.30, 28.65),
            relativeCFrame = CFrame.new(0.774, 0.984, 0.393, 0.966, -0.200, 0.161, 0.211, 0.976, -0.048, -0.148, 0.081, 0.986),
            reflectance = 0.00
        },
        [9] = {
            name = "RightEye", 
            type = "Part", 
            size = Vector3.new(0.32, 0.05, 0.18), 
            material = "Plastic",
            color = Color3.new(0.106, 0.165, 0.208),
            brickColor = "Black",
            transparency = 0.00,
            canCollide = false,
            position = Vector3.new(34.42, 1.64, -117.42),
            rotation = Vector3.new(-73.30, -80.30, 28.65),
            relativeCFrame = CFrame.new(0.643, 1.024, -0.410, 0.966, -0.200, 0.161, 0.211, 0.976, -0.048, -0.148, 0.081, 0.986),
            reflectance = 0.00
        },
        [10] = {
            name = "BackLegL", 
            type = "UnionOperation", 
            size = Vector3.new(0.72, 0.90, 0.72), 
            material = "Plastic",
            color = Color3.new(0.992, 0.788, 0.506),
            brickColor = "Pastel brown",
            transparency = 0.00,
            canCollide = false,
            position = Vector3.new(33.56, 0.41, -116.05),
            rotation = Vector3.new(1.19, -80.74, 93.04),
            relativeCFrame = CFrame.new(-0.590, -0.348, 0.449, 0.999, -0.033, -0.003, 0.032, 0.986, -0.161, 0.009, 0.161, 0.987),
            reflectance = 0.00
        },
        [11] = {
            name = "BackLegR", 
            type = "UnionOperation", 
            size = Vector3.new(0.72, 0.90, 0.72), 
            material = "Plastic",
            color = Color3.new(0.992, 0.788, 0.506),
            brickColor = "Pastel brown",
            transparency = 0.00,
            canCollide = false,
            position = Vector3.new(34.43, 0.40, -116.06),
            rotation = Vector3.new(-176.93, -74.20, -85.95),
            relativeCFrame = CFrame.new(-0.596, -0.332, -0.413, 1.000, -0.019, 0.015, 0.015, 0.962, 0.272, -0.019, -0.272, 0.962),
            reflectance = 0.00
        },
        [12] = {
            name = "FrontLegR", 
            type = "UnionOperation", 
            size = Vector3.new(0.72, 0.72, 0.54), 
            material = "Plastic",
            color = Color3.new(0.992, 0.788, 0.506),
            brickColor = "Pastel brown",
            transparency = 0.00,
            canCollide = false,
            position = Vector3.new(34.34, 0.36, -116.94),
            rotation = Vector3.new(-175.72, -75.06, -89.37),
            relativeCFrame = CFrame.new(-0.636, 0.548, -0.324, 0.998, 0.061, 0.019, -0.064, 0.964, 0.257, -0.003, -0.258, 0.966),
            reflectance = 0.00
        },
        [13] = {
            name = "FrontLegL", 
            type = "UnionOperation", 
            size = Vector3.new(0.72, 0.72, 0.54), 
            material = "Plastic",
            color = Color3.new(0.992, 0.788, 0.506),
            brickColor = "Pastel brown",
            transparency = 0.00,
            canCollide = false,
            position = Vector3.new(33.61, 0.36, -116.93),
            rotation = Vector3.new(-7.61, -79.25, 81.07),
            relativeCFrame = CFrame.new(-0.634, 0.531, 0.398, 0.999, 0.025, 0.025, -0.020, 0.983, -0.185, -0.029, 0.184, 0.982),
            reflectance = 0.00
        },
        [14] = {
            name = "RootPart", 
            type = "Part", 
            size = Vector3.new(0.45, 1.27, 1.27), 
            material = "Plastic",
            color = Color3.new(0.992, 0.788, 0.506),
            brickColor = "Pastel brown",
            transparency = 0.00,
            canCollide = false,
            position = Vector3.new(34.01, 1.00, -116.40),
            rotation = Vector3.new(-90.00, -90.00, 0.00),
            relativeCFrame = CFrame.new(34.013, 0.995, -116.395, 0.000, 0.000, -1.000, 1.000, -0.000, 0.000, -0.000, -1.000, -0.000),
            reflectance = 0.00
        },
        [15] = {
            name = "ColourSpot", 
            type = "Part", 
            size = Vector3.new(0.58, 0.42, 0.56), 
            material = "Plastic",
            color = Color3.new(0.992, 0.788, 0.506),
            brickColor = "Pastel brown",
            transparency = 0.00,
            canCollide = false,
            position = Vector3.new(33.68, 2.04, -117.21),
            rotation = Vector3.new(106.70, 80.30, -28.65),
            relativeCFrame = CFrame.new(1.049, 0.811, 0.333, 0.966, 0.200, -0.161, 0.211, -0.976, 0.048, -0.148, -0.081, -0.986),
            reflectance = 0.00
        }
    }
}

-- === ФУНКЦИЯ ГЕНЕРАЦИИ UUID ===
local function generateUUID()
    local template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
        return string.format('%x', v)
    end)
end

-- === ФУНКЦИЯ ПОЛУЧЕНИЯ ПОЗИЦИИ ИГРОКА ===
local function getPlayerPosition()
    local playerChar = player.Character
    if not playerChar then
        print("❌ Персонаж игрока не найден!")
        return nil
    end

    local hrp = playerChar:FindFirstChild("HumanoidRootPart")
    if not hrp then
        print("❌ HumanoidRootPart не найден!")
        return nil
    end

    return hrp.Position
end

-- === ФУНКЦИЯ СОЗДАНИЯ ЧАСТИ С ПРАВИЛЬНЫМ ПОЗИЦИОНИРОВАНИЕМ ===
local function createPart(partData, model)
    local part = nil
    
    -- Создаем нужный тип части
    if partData.type == "Part" then
        part = Instance.new("Part")
    elseif partData.type == "UnionOperation" then
        -- Для UnionOperation создаем обычный Part (так как UnionOperation нельзя создать через скрипт)
        part = Instance.new("Part")
        part.Shape = Enum.PartType.Block
    elseif partData.type == "MeshPart" then
        part = Instance.new("MeshPart")
        -- Устанавливаем MeshId если есть в данных мешей
        for _, meshData in pairs(PET_DATA.Meshes) do
            if meshData.name == partData.name then
                part.MeshId = meshData.meshId
                break
            end
        end
    else
        print("⚠️ Неизвестный тип части:", partData.type)
        part = Instance.new("Part")
    end
    
    -- Настраиваем свойства части
    part.Name = partData.name
    part.Size = partData.size
    part.Material = Enum.Material[partData.material] or Enum.Material.Plastic
    part.Color = partData.color
    part.BrickColor = BrickColor.new(partData.brickColor)
    part.Transparency = partData.transparency
    part.CanCollide = partData.canCollide
    part.Reflectance = partData.reflectance
    
    -- Временно делаем части Anchored для правильного позиционирования
    part.Anchored = true
    
    -- ИСПОЛЬЗУЕМ ПРАВИЛЬНЫЙ relativeCFrame ИЗ ДАННЫХ!
    if partData.relativeCFrame then
        part.CFrame = partData.relativeCFrame
        print("✅ Создана часть:", partData.name, "(" .. partData.type .. ") - используется relativeCFrame")
    else
        -- Fallback к старому методу если relativeCFrame отсутствует
        local rotationCFrame = CFrame.Angles(
            math.rad(partData.rotation.X),
            math.rad(partData.rotation.Y),
            math.rad(partData.rotation.Z)
        )
        part.CFrame = CFrame.new(partData.position) * rotationCFrame
        print("⚠️ Создана часть:", partData.name, "(" .. partData.type .. ") - fallback позиционирование")
    end
    
    part.Parent = model
    return part
end

-- === ФУНКЦИЯ СОЗДАНИЯ MOTOR6D С ПОЛНЫМИ ДАННЫМИ ===
local function createMotor6D(motorData, model)
    local motor = Instance.new("Motor6D")
    motor.Name = motorData.name
    
    -- Находим части для соединения
    local part0 = model:FindFirstChild(motorData.part0)
    local part1 = model:FindFirstChild(motorData.part1)
    
    if part0 and part1 then
        motor.Part0 = part0
        motor.Part1 = part1
        
        -- УСТАНАВЛИВАЕМ ПРАВИЛЬНЫЕ C0, C1, TRANSFORM ИЗ ДАННЫХ!
        if motorData.c0 then
            motor.C0 = motorData.c0
        end
        if motorData.c1 then
            motor.C1 = motorData.c1
        end
        if motorData.transform then
            motor.Transform = motorData.transform
        end
        
        motor.Parent = part0 -- Motor6D обычно находится в Part0
        
        print("✅ Создан Motor6D:", motorData.name, "(" .. motorData.part0 .. " -> " .. motorData.part1 .. ") с полными данными")
        return motor
    else
        print("❌ Не найдены части для Motor6D:", motorData.name)
        if not part0 then print("  - Не найден Part0:", motorData.part0) end
        if not part1 then print("  - Не найден Part1:", motorData.part1) end
        motor:Destroy()
        return nil
    end
end

-- === ФУНКЦИЯ ПОЗИЦИОНИРОВАНИЯ МОДЕЛИ РЯДОМ С ИГРОКОМ ===
local function positionModelNearPlayer(model, playerPosition)
    if not model.PrimaryPart then
        print("❌ PrimaryPart не установлен!")
        return false
    end
    
    -- Позиционируем модель рядом с игроком (5 единиц справа)
    local targetPosition = playerPosition + Vector3.new(5, 0, 0)
    
    -- ИСПРАВЛЯЕМ ОРИЕНТАЦИЮ: питомец должен стоять вертикально
    local correctOrientation = CFrame.new(targetPosition) * CFrame.Angles(0, 0, 0)
    model:SetPrimaryPartCFrame(correctOrientation)
    
    -- Добавляем Humanoid для движения
    local humanoid = model:FindFirstChild("Humanoid")
    if not humanoid then
        humanoid = Instance.new("Humanoid")
        humanoid.Parent = model
        humanoid.WalkSpeed = 8
        humanoid.JumpPower = 50
        humanoid.MaxHealth = 100
        humanoid.Health = 100
        print("✅ Добавлен Humanoid для движения")
        
        -- Добавляем HumanoidRootPart для правильной работы Humanoid
        if model.PrimaryPart then
            model.PrimaryPart.Name = "HumanoidRootPart"
        end
        
        -- Запускаем случайное движение
        spawn(function()
            wait(2) -- Ждем пока модель стабилизируется
            while humanoid and humanoid.Parent do
                local randomDirection = Vector3.new(
                    math.random(-10, 10),
                    0,
                    math.random(-10, 10)
                )
                humanoid:MoveTo(model.HumanoidRootPart.Position + randomDirection)
                wait(math.random(3, 8)) -- Случайная пауза между движениями
            end
        end)
    end
    
    -- Убираем Anchored со всех частей для физики (кроме HumanoidRootPart)
    for _, part in pairs(model:GetChildren()) do
        if part:IsA("BasePart") then
            if part.Name == "HumanoidRootPart" then
                part.Anchored = false
                part.CanCollide = true -- HumanoidRootPart должен коллайдить с землей
            else
                part.Anchored = false
                part.CanCollide = false -- Остальные части не коллайдят
            end
        end
    end
    
    -- Исправляем позицию на земле с помощью Raycast
    local rayOrigin = targetPosition + Vector3.new(0, 50, 0)
    local rayDirection = Vector3.new(0, -100, 0)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {model}
    
    local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
    if raycastResult then
        local groundPosition = raycastResult.Position + Vector3.new(0, 2, 0) -- Немного над землей
        model:SetPrimaryPartCFrame(CFrame.new(groundPosition))
        print("🌍 Модель размещена на земле:", groundPosition)
    else
        print("⚠️ Земля не найдена, используется стандартная позиция")
    end
    
    print("📍 Модель позиционирована рядом с игроком")
    print("  Позиция игрока:", playerPosition)
    print("  Позиция модели:", targetPosition)
    
    return true
end

-- === ГЛАВНАЯ ФУНКЦИЯ СОЗДАНИЯ ПИТОМЦА ===
local function createPetFromData()
    print("\n🎯 === СОЗДАНИЕ ПИТОМЦА ИЗ ДАННЫХ ===")
    
    -- Шаг 1: Генерируем UUID имя
    local uuid = generateUUID()
    local petName = "{" .. uuid .. "}"
    print("🔑 Сгенерирован UUID:", petName)
    
    -- Шаг 2: Получаем позицию игрока
    local playerPosition = getPlayerPosition()
    if not playerPosition then
        return nil
    end
    print("📍 Позиция игрока:", playerPosition)
    
    -- Шаг 3: Создаем модель
    local petModel = Instance.new("Model")
    petModel.Name = petName
    petModel.Parent = Workspace
    print("📦 Создана модель:", petName)
    
    -- Шаг 4: Создаем все части
    print("\n🧩 === СОЗДАНИЕ ЧАСТЕЙ ===")
    local createdParts = {}
    
    for i, partData in pairs(PET_DATA.Parts) do
        local part = createPart(partData, petModel)
        if part then
            createdParts[partData.name] = part
        end
    end
    
    print("✅ Создано частей:", #PET_DATA.Parts)
    
    -- Шаг 5: Устанавливаем PrimaryPart
    local primaryPart = petModel:FindFirstChild(PET_DATA.PrimaryPart)
    if primaryPart then
        petModel.PrimaryPart = primaryPart
        print("✅ PrimaryPart установлен:", PET_DATA.PrimaryPart)
    else
        print("❌ PrimaryPart не найден:", PET_DATA.PrimaryPart)
    end
    
    -- Шаг 6: Создаем Motor6D соединения
    print("\n🔗 === СОЗДАНИЕ MOTOR6D СОЕДИНЕНИЙ ===")
    local createdMotors = 0
    
    for i, motorData in pairs(PET_DATA.Motor6D) do
        local motor = createMotor6D(motorData, petModel)
        if motor then
            createdMotors = createdMotors + 1
        end
    end
    
    print("✅ Создано Motor6D соединений:", createdMotors .. "/" .. #PET_DATA.Motor6D)
    
    -- Шаг 7: Позиционируем модель рядом с игроком
    print("\n📍 === ПОЗИЦИОНИРОВАНИЕ ===")
    local positionSuccess = positionModelNearPlayer(petModel, playerPosition)
    
    if positionSuccess then
        print("\n🎉 === ПИТОМЕЦ УСПЕШНО СОЗДАН ===")
        print("✅ UUID имя:", petName)
        print("✅ Всего частей:", #PET_DATA.Parts)
        print("✅ Motor6D соединений:", createdMotors)
        print("✅ Позиция: рядом с игроком")
        print("✅ Модель размещена в Workspace")
        
        return petModel
    else
        print("❌ Ошибка позиционирования!")
        petModel:Destroy()
        return nil
    end
end

-- === СОЗДАНИЕ GUI ===
local function createGUI()
    local success, errorMsg = pcall(function()
        local playerGui = player:WaitForChild("PlayerGui")
        
        -- Удаляем старый GUI если есть
        local oldGui = playerGui:FindFirstChild("PetCreatorGUI")
        if oldGui then
            oldGui:Destroy()
            wait(0.1)
        end
        
        -- Создаем новый GUI
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "PetCreatorGUI"
        screenGui.Parent = playerGui
        
        local frame = Instance.new("Frame")
        frame.Name = "MainFrame"
        frame.Size = UDim2.new(0, 280, 0, 80)
        frame.Position = UDim2.new(0, 50, 0, 50)
        frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        frame.BorderSizePixel = 2
        frame.BorderColor3 = Color3.fromRGB(0, 255, 255) -- Голубая рамка
        frame.Parent = screenGui
        
        -- Заголовок
        local title = Instance.new("TextLabel")
        title.Name = "Title"
        title.Size = UDim2.new(1, 0, 0, 25)
        title.Position = UDim2.new(0, 0, 0, 5)
        title.BackgroundTransparency = 1
        title.Text = "🎯 PET CREATOR"
        title.TextColor3 = Color3.fromRGB(0, 255, 255)
        title.TextSize = 14
        title.Font = Enum.Font.SourceSansBold
        title.Parent = frame
        
        -- Кнопка создания питомца
        local createButton = Instance.new("TextButton")
        createButton.Name = "CreatePetButton"
        createButton.Size = UDim2.new(0, 260, 0, 40)
        createButton.Position = UDim2.new(0, 10, 0, 30)
        createButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        createButton.BorderSizePixel = 0
        createButton.Text = "🐾 Создать питомца"
        createButton.TextColor3 = Color3.fromRGB(0, 0, 0)
        createButton.TextSize = 16
        createButton.Font = Enum.Font.SourceSansBold
        createButton.Parent = frame
        
        -- Обработчик кнопки
        createButton.MouseButton1Click:Connect(function()
            createButton.Text = "⏳ Создаю питомца..."
            createButton.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
            
            spawn(function()
                local success, result = pcall(function()
                    return createPetFromData()
                end)
                
                if success and result then
                    createButton.Text = "✅ Питомец создан!"
                    createButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                    wait(3)
                    createButton.Text = "🐾 Создать питомца"
                    createButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                else
                    print("❌ Ошибка создания питомца:", result or "Неизвестная ошибка")
                    createButton.Text = "❌ Ошибка! Попробуйте снова"
                    createButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                    wait(3)
                    createButton.Text = "🐾 Создать питомца"
                    createButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                end
            end)
        end)
        
        print("✅ GUI создан успешно!")
    end)
    
    if not success then
        print("❌ Ошибка создания GUI:", errorMsg)
    end
end

-- === ЗАПУСК СКРИПТА ===
print("🚀 Запуск PET CREATOR...")
createGUI()
print("💡 Нажмите кнопку 'Создать питомца' для генерации нового питомца!")
