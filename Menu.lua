local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("ESP and Aimbot Menu", "BloodTheme")

-- Services  
local Players = game:GetService("Players")  
local RunService = game:GetService("RunService")  
local UserInputService = game:GetService("UserInputService")  
local Camera = workspace.CurrentCamera  
local LocalPlayer = Players.LocalPlayer  
local ESPObjects = {}

-- FOV Circle  
local FOVCircle = Drawing.new("Circle")  
FOVCircle.Visible = false  
FOVCircle.Thickness = 2  
FOVCircle.Color = Color3.fromRGB(255, 255, 255)  
FOVCircle.Filled = false  
FOVCircle.Transparency = 1  
FOVCircle.NumSides = 100  
FOVCircle.Radius = 100  

-- Settings  
local Settings = {  
    AimbotEnabled = false,  
    TeamCheck = true,  
    AimPart = "Head",  
    FOVSize = 100,  
    ESPEnabled = true,  
    BoxESP = true,  
    BoneESP = true,  
    ShowFOV = true,  
    RainbowESP = false,  
    ESPColor = Color3.fromRGB(255, 255, 255),  
    AnapLinesEnabled = false -- Anap line toggle
}  

-- Create Tabs  
local CombatTab = Window:NewTab("💥 Combat")  
local VisualTab = Window:NewTab("👁️ Visuals")  

-- Combat Section  
local AimbotSection = CombatTab:NewSection("Universal Aimbot")  

AimbotSection:NewToggle("Enable Aimbot", "Activate the aimbot", function(state)  
    Settings.AimbotEnabled = state  
end)  

AimbotSection:NewToggle("Team Check", "Only aim at non-teammates", function(state)  
    Settings.TeamCheck = state  
end)  

AimbotSection:NewDropdown("Aim Part", "Select which part to aim at", {"Head", "Torso", "HumanoidRootPart"}, function(part)  
    Settings.AimPart = part  
end)  

-- FOV Size Slider
AimbotSection:NewSlider("FOV Size", "Adjust the size of the FOV circle", 500, 50, function(value)
    Settings.FOVSize = value
    FOVCircle.Radius = value  
end)

-- FOV Toggle  
local FOVToggle = AimbotSection:NewToggle("Show FOV Circle", "Toggle the visibility of the FOV circle", function(state)  
    Settings.ShowFOV = state  
    FOVCircle.Visible = state  
end)  

-- Enhanced Visual Section  
local ESPSection = VisualTab:NewSection("Universal ESP")  

ESPSection:NewToggle("Enable ESP", "Toggle player ESP", function(state)  
    Settings.ESPEnabled = state  
end)  

ESPSection:NewToggle("Box ESP", "Toggle box ESP around players", function(state)  
    Settings.BoxESP = state  
end)  

ESPSection:NewToggle("Bone ESP", "Toggle bone ESP around players", function(state)  
    Settings.BoneESP = state  
end)  

ESPSection:NewToggle("Rainbow ESP", "Dynamic color for ESP", function(state)  
    Settings.RainbowESP = state  
end)  

-- Anap Line Toggle
ESPSection:NewToggle("Enable Anap Lines", "Draw lines from bottom of the screen to player heads", function(state)  
    Settings.AnapLinesEnabled = state  
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
    local closest = nil  
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
                    character.PrimaryPart and character.PrimaryPart.Name  
                })  

                if targetPart then  
                    if Settings.TeamCheck and player.Team == LocalPlayer.Team then  
                        continue  
                    end  

                    local pos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)  
                    if onScreen then  
                        local distance = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude  
                        if distance < shortestDistance then  
                            closest = player  
                            shortestDistance = distance  
                        end  
                    end  
                end  
            end  
        end  
    end  
    return closest  
end  

-- Function to get rainbow color
local function GetRainbowColor()  
    local time = tick() % 5 / 5  
    return Color3.fromHSV(time, 1, 1)  
end  

-- Function to update ESP
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
                        Box = Drawing.new("Square"),  
                        BoneDots = {}  
                    }  

                    ESPObjects[player].Box.Thickness = 2  
                    ESPObjects[player].Box.Filled = false  
                end  

                if Settings.ESPEnabled then  
                    local espColor = Settings.RainbowESP and GetRainbowColor() or Settings.ESPColor  

                    if Settings.BoxESP then  
                        local rootPart = FindFirstAvailablePart(character, {  
                            "HumanoidRootPart",  
                            "Torso",  
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

                    -- Bone ESP
                    if Settings.BoneESP then
                        for _, boneName in pairs({"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg", "HumanoidRootPart"}) do
                            local bone = character:FindFirstChild(boneName)
                            if bone then
                                local vector, onScreen = Camera:WorldToViewportPoint(bone.Position)
                                if onScreen then
                                    -- Remove old boneDot if exists
                                    if ESPObjects[player].BoneDots[boneName] then
                                        ESPObjects[player].BoneDots[boneName]:Remove()
                                        ESPObjects[player].BoneDots[boneName] = nil -- Clear reference
                                    end

                                    -- Create a new bone overlay
                                    local boneDot = Drawing.new("Circle")
                                    boneDot.Position = Vector2.new(vector.X, vector.Y)
                                    boneDot.Radius = 3
                                    boneDot.Color = espColor
                                    boneDot.Transparency = 1
                                    boneDot.Filled = true
                                    boneDot.Visible = true

                                    ESPObjects[player].BoneDots[boneName] = boneDot  -- Store the new overlay
                                end
                            end
                        end
                    else
                        -- If Bone ESP is disabled, remove all bone dots
                        for _, boneDot in pairs(ESPObjects[player].BoneDots) do
                            boneDot:Remove()
                        end
                        ESPObjects[player].BoneDots = {} -- Clear all bone dots
                    end

                else  
                    ESPObjects[player].Box.Visible = false  
                    for _, boneDot in pairs(ESPObjects[player].BoneDots) do
                        boneDot.Visible = false
                    end
                end  
            end  
        end  
    end  
end  

-- Function to draw Anap Lines
local function DrawAnapLines()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            if character then
                local head = character:FindFirstChild("Head")
                if head then
                    local headPosition, onScreen = Camera:WorldToViewportPoint(head.Position)
                    if onScreen then
                        local line = Drawing.new("Line")
                        line.From = Vector2.new(headPosition.X, headPosition.Y)
                        line.To = Vector2.new(headPosition.X, game:GetService("Workspace").CurrentCamera.ViewportSize.Y)  -- From head to bottom of the screen
                        line.Thickness = 2
                        line.Color = Color3.fromRGB(255, 0, 0)  -- Color of the line
                        line.Visible = true
                        line:Remove() -- Clean up the line after drawing
                    end
                end
            end
        end
    end
end

-- Main Loop  
RunService.RenderStepped:Connect(function()  
    if Settings.ShowFOV then  
        FOVCircle.Position = UserInputService:GetMouseLocation()  
        FOVCircle.Radius = Settings.FOVSize  
        FOVCircle.Visible = true  
    else  
        FOVCircle.Visible = false  
    end  

    if Settings.AimbotEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then  
        local target = GetClosestPlayer()  
        if target and target.Character then  
            local targetPart = FindFirstAvailablePart(target.Character, {  
                Settings.AimPart,  
                "Head",  
                "HumanoidRootPart",  
                "Torso",  
                target.Character.PrimaryPart and target.Character.PrimaryPart.Name  
            })  

            if targetPart then  
                local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)  
                Camera.CFrame = targetCFrame  
            end  
        end  
    end  

    UpdateESP()  

    -- Reset ESP objects every 1ms
    for _, player in pairs(Players:GetPlayers()) do  
        if player ~= LocalPlayer and ESPObjects[player] then  
            if ESPObjects[player].Box then 
                ESPObjects[player].Box.Visible = false 
            end
            for _, boneDot in pairs(ESPObjects[player].BoneDots) do
                boneDot.Visible = false
            end
        end  
    end

    -- Draw Anap Lines if enabled
    if Settings.AnapLinesEnabled then
        DrawAnapLines()
    end
end)  

-- Toggle the menu visibility with the B key
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.B then  
        CombatTab.Visible = not CombatTab.Visible  
        VisualTab.Visible = not VisualTab.Visible  
    end  
end)

-- Cleanup  
Players.PlayerRemoving:Connect(function(player)  
    if ESPObjects[player] then  
        ESPObjects[player].Box:Remove()  
        for _, boneDot in pairs(ESPObjects[player].BoneDots) do
            boneDot:Remove()
        end
        ESPObjects[player] = nil  
    end  
end)

-- Run the script
RunService.RenderStepped:Connect(function()
    -- No text display at any point
end)
