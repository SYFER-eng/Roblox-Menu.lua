local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Combat Suite", "BloodTheme")

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = true
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Filled = false
FOVCircle.Transparency = 1
FOVCircle.NumSides = 100

-- Create a text label for the menu popup
local MenuPopup = Drawing.new("Text")
MenuPopup.Text = "Syfer-eng Menu"
MenuPopup.Size = 18
MenuPopup.Color = Color3.fromRGB(255, 255, 255)
MenuPopup.Position = Vector2.new(workspace.CurrentCamera.ViewportSize.X - 180, workspace.CurrentCamera.ViewportSize.Y - 50)
MenuPopup.Visible = false
MenuPopup.Outline = true
MenuPopup.OutlineColor = Color3.fromRGB(0, 0, 0)

-- Settings
local Settings = {
    AimbotEnabled = false,
    TeamCheck = true,
    AimPart = "Head",
    FOVSize = 100,
    Smoothness = 0.5,
    ESPEnabled = false,
    BoneESP = false,
    BoxESP = false,
    ShowFOV = true,
    RainbowESP = false,
    ESPColor = Color3.fromRGB(255, 255, 255)
}

-- Enhanced Universal Bone Connections
local BoneConnections = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
    {"RightLowerLeg", "RightFoot"}
}

-- ESP Cache with Universal Support
local ESPObjects = {}

-- Create Tabs
local CombatTab = Window:NewTab("💥 Combat")
local VisualTab = Window:NewTab("👁️ Visuals")

-- Combat Section
local AimbotSection = CombatTab:NewSection("Universal Aimbot")
AimbotSection:NewToggle("Enable Aimbot", "Universal targeting system", function(state)
    Settings.AimbotEnabled = state
end)

AimbotSection:NewToggle("Team Check", "Universal team detection", function(state)
    Settings.TeamCheck = state
end)

AimbotSection:NewDropdown("Aim Part", "Universal part targeting", {"Head", "Torso", "HumanoidRootPart", "UpperTorso", "LowerTorso"}, function(part)
    Settings.AimPart = part
end)

AimbotSection:NewSlider("FOV Size", "Universal FOV range", 250, 0, 250, function(value)
    Settings.FOVSize = value
    FOVCircle.Radius = value
end)

AimbotSection:NewSlider("Aimbot Smoothness", "Control how fast the aimbot aims at players", 100, 0, 100, function(value)
    Settings.Smoothness = value / 100
end)

-- Enhanced Visual Section
local ESPSection = VisualTab:NewSection("Universal ESP")
ESPSection:NewToggle("Enable ESP", "Universal player ESP", function(state)
    Settings.ESPEnabled = state
end)

ESPSection:NewToggle("Bone ESP", "Universal skeleton system", function(state)
    Settings.BoneESP = state
end)

ESPSection:NewToggle("Box ESP", "Universal box system", function(state)
    Settings.BoxESP = state
end)

ESPSection:NewToggle("Rainbow ESP", "Dynamic color system", function(state)
    Settings.RainbowESP = state
end)

-- Function to find the first available part
local function FindFirstAvailablePart(character, partNames)
    for _, name in ipairs(partNames) do
        local part = character:FindFirstChild(name)
        if part then return part end
    end
    return nil
end

-- Get the closest player based on FOV
local function GetClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = Settings.FOVSize
    local mousePos = UserInputService:GetMouseLocation()

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character or player.CharacterAdded:Wait()
            if character then
                local targetPart = FindFirstAvailablePart(character, {
                    Settings.AimPart,
                    "Head",
                    "HumanoidRootPart",
                    "Torso",
                    "UpperTorso",
                    character.PrimaryPart and character.PrimaryPart.Name
                })

                if targetPart and (not Settings.TeamCheck or player.Team ~= LocalPlayer.Team) then
                    local pos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                    if onScreen then
                        local distance = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                        if distance < shortestDistance then
                            closestPlayer = player
                            shortestDistance = distance
                        end
                    end
                end
            end
        end
    end
    return closestPlayer
end

local function CreateBoneDrawing()
    local drawing = Drawing.new("Line")
    drawing.Thickness = 2
    drawing.Color = Color3.new(1, 0, 0)
    return drawing
end

local function GetRainbowColor()
    local time = tick() % 5 / 5
    return Color3.fromHSV(time, 1, 1)
end

local function UpdateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            if character then
                if Settings.TeamCheck and player.Team == LocalPlayer.Team then
                    continue
                end

                if not ESPObjects[player] then
                    ESPObjects[player] = {
                        Bones = {},
                        Box = Drawing.new("Square")
                    }

                    ESPObjects[player].Box.Thickness = 2
                    ESPObjects[player].Box.Filled = false

                    for _ = 1, #BoneConnections do
                        table.insert(ESPObjects[player].Bones, CreateBoneDrawing())
                    end
                end

                if Settings.ESPEnabled then
                    local espColor = Settings.RainbowESP and GetRainbowColor() or Settings.ESPColor

                    if Settings.BoxESP then
                        local rootPart = FindFirstAvailablePart(character, {
                            "HumanoidRootPart",
                            "Torso",
                            "UpperTorso",
                            character.PrimaryPart and character.PrimaryPart.Name
                        })

                        if rootPart then
                            local vector, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                            if onScreen then
                                local size = Vector2.new(2000 / vector.Z, 3000 / vector.Z)
                                ESPObjects[player].Box.Size = size
                                ESPObjects[player].Box.Position = Vector2.new(vector.X - size.X / 2, vector.Y - size.Y / 2)
                                ESPObjects[player].Box.Color = espColor
                                ESPObjects[player].Box.Visible = true
                            else
                                ESPObjects[player].Box.Visible = false
                            end
                        end
                    else
                        ESPObjects[player].Box.Visible = false
                    end

                    if Settings.BoneESP then
                        for i, connection in pairs(BoneConnections) do
                            local part1 = FindFirstAvailablePart(character, {connection[1]})
                            local part2 = FindFirstAvailablePart(character, {connection[2]})

                            if part1 and part2 then
                                local pos1, vis1 = Camera:WorldToViewportPoint(part1.Position)
                                local pos2, vis2 = Camera:WorldToViewportPoint(part2.Position)

                                if vis1 and vis2 then
                                    local bone = ESPObjects[player].Bones[i]
                                    bone.From = Vector2.new(pos1.X, pos1.Y)
                                    bone.To = Vector2.new(pos2.X, pos2.Y)
                                    bone.Color = espColor
                                    bone.Visible = true
                                else
                                    ESPObjects[player].Bones[i].Visible = false
                                end
                            else
                                ESPObjects[player].Bones[i].Visible = false
                            end
                        end
                    else
                        for _, bone in pairs(ESPObjects[player].Bones) do
                            bone.Visible = false
                        end
                    end
                else
                    ESPObjects[player].Box.Visible = false
                    for _, bone in pairs(ESPObjects[player].Bones) do
                        bone.Visible = false
                    end
                end
            end
        end
    end
end

-- Main Loop
RunService.RenderStepped:Connect(function()
    FOVCircle.Position = UserInputService:GetMouseLocation()
    FOVCircle.Radius = Settings.FOVSize
    FOVCircle.Visible = Settings.ShowFOV

    if Settings.AimbotEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = GetClosestPlayer()
        if target and target.Character then
            local targetPart = FindFirstAvailablePart(target.Character, {
                Settings.AimPart,
                "Head",
                "HumanoidRootPart",
                "Torso",
                "UpperTorso",
                target.Character.PrimaryPart and target.Character.PrimaryPart.Name
            })

            if targetPart then
                local targetPos = targetPart.Position
                local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPos)
                Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Settings.Smoothness)
            end
        end
    end

    UpdateESP()

    -- Update menu popup color
    if MenuPopup.Visible then
        MenuPopup.Color = GetRainbowColor()
        MenuPopup.OutlineColor = Color3.new(0, 0, 0)
    end
end)

-- Show Menu Popup on startup
MenuPopup.Visible = true
wait(3)
MenuPopup.Visible = false

-- Menu Toggle
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then
        game:GetService("CoreGui"):FindFirstChild("CombatSuite").Enabled = not game:GetService("CoreGui"):FindFirstChild("CombatSuite").Enabled
    end
end)

-- Cleanup
Players.PlayerRemoving:Connect(function(player)
    if ESPObjects[player] then
        for _, bone in pairs(ESPObjects[player].Bones) do
            bone:Remove()
        end
        ESPObjects[player].Box:Remove()
        ESPObjects[player] = nil
    end
end)
