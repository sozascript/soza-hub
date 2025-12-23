--// SOZA HUB | Fish It
--// Full WORK Structure
--// by SOZA

-- =====================
-- SERVICES
-- =====================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")

local LP = Players.LocalPlayer

-- =====================
-- CONFIG
-- =====================
local Config = {
    AutoFish = false,
    Blatant = false,
    DelayComplete = 0.5,
    DelayReel = 0.3,
    Webhook = "",
    RarityFilter = {
        Common = true,
        Uncommon = true,
        Rare = true,
        Epic = true,
        Legendary = true,
        Mythic = true,
        SECRET = true
    }
}

-- =====================
-- ANTI AFK
-- =====================
LP.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

-- =====================
-- REMOTES (FISH IT)
-- =====================
-- ⚠️ JIKA GAME UPDATE, GANTI DI SINI SAJA
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local CastRemote       = Remotes:WaitForChild("Cast")        -- lempar pancing
local ReelRemote       = Remotes:WaitForChild("Reel")        -- tarik
local CompleteRemote   = Remotes:WaitForChild("Complete")    -- selesai
local SellRemote       = Remotes:WaitForChild("SellFish")    -- jual ikan

-- =====================
-- UI (SIMPLE)
-- =====================
local gui = Instance.new("ScreenGui", LP.PlayerGui)
gui.Name = "SOZA_HUB"

local main = Instance.new("Frame", gui)
main.Size = UDim2.fromOffset(300, 220)
main.Position = UDim2.fromScale(0.05, 0.4)
main.BackgroundColor3 = Color3.fromRGB(25,25,25)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true

local corner = Instance.new("UICorner", main)
corner.CornerRadius = UDim.new(0,12)

local function Button(text, y)
    local b = Instance.new("TextButton", main)
    b.Size = UDim2.fromOffset(260, 36)
    b.Position = UDim2.fromOffset(20, y)
    b.BackgroundColor3 = Color3.fromRGB(40,40,40)
    b.TextColor3 = Color3.new(1,1,1)
    b.Text = text
    b.Font = Enum.Font.Gotham
    b.TextSize = 14
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
    return b
end

local autoBtn = Button("Auto Fish : OFF", 20)
local blatBtn = Button("Blatant Mode : OFF", 70)
local sellBtn = Button("Auto Sell (ONCE)", 120)
local tpBtn   = Button("Teleport Spawn", 170)

-- =====================
-- BUTTON LOGIC (REAL)
-- =====================
autoBtn.MouseButton1Click:Connect(function()
    Config.AutoFish = not Config.AutoFish
    autoBtn.Text = "Auto Fish : "..(Config.AutoFish and "ON" or "OFF")
end)

blatBtn.MouseButton1Click:Connect(function()
    Config.Blatant = not Config.Blatant
    blatBtn.Text = "Blatant Mode : "..(Config.Blatant and "ON" or "OFF")
end)

sellBtn.MouseButton1Click:Connect(function()
    pcall(function()
        SellRemote:FireServer()
    end)
end)

tpBtn.MouseButton1Click:Connect(function()
    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        LP.Character.HumanoidRootPart.CFrame =
            CFrame.new(0, 10, 0) -- spawn
    end
end)

-- =====================
-- AUTO FISH LOOP (WORK)
-- =====================
task.spawn(function()
    while task.wait(0.1) do
        if not Config.AutoFish then continue end

        -- CAST
        pcall(function()
            CastRemote:FireServer()
        end)

        task.wait(Config.Blatant and Config.DelayReel or 1)

        -- REEL
        pcall(function()
            ReelRemote:FireServer()
        end)

        task.wait(Config.Blatant and Config.DelayComplete or 1)

        -- COMPLETE
        pcall(function()
            CompleteRemote:FireServer()
        end)
    end
end)

-- =====================
-- WEBHOOK FISH CAUGHT
-- =====================
local HttpService = game:GetService("HttpService")

local function SendWebhook(name, rarity)
    if Config.Webhook == "" then return end
    if not Config.RarityFilter[rarity] then return end

    local data = {
        content = "**Fish Caught!**\n🐟 "..name.."\n⭐ "..rarity
    }

    pcall(function()
        HttpService:PostAsync(
            Config.Webhook,
            HttpService:JSONEncode(data),
            Enum.HttpContentType.ApplicationJson
        )
    end)
end

-- =====================
-- FISH DETECTION (GENERIC)
-- =====================
Remotes.ChildAdded:Connect(function(obj)
    if obj.Name == "FishCaught" then
        obj.OnClientEvent:Connect(function(fishName, rarity)
            SendWebhook(fishName, rarity)
        end)
    end
end)

warn("✅ SOZA HUB | Fish It LOADED (WORK STRUCTURE)")
