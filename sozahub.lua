--================================================
-- SOZA HUB | Simple & Clean
-- Fish It | Anti-AFK | Blatant | Auto Sell | TP | Webhook
--================================================

repeat task.wait() until game:IsLoaded()

--================ SERVICES ======================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer

--================ ANTI AFK ======================
pcall(function()
    LocalPlayer.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
end)

--================ UI CLEAN ======================
if game.CoreGui:FindFirstChild("SozaHub") then
    game.CoreGui.SozaHub:Destroy()
end

local Gui = Instance.new("ScreenGui", game.CoreGui)
Gui.Name = "SozaHub"

local Main = Instance.new("Frame", Gui)
Main.Size = UDim2.new(0, 260, 0, 330)
Main.Position = UDim2.new(0.05, 0, 0.28, 0)
Main.BackgroundColor3 = Color3.fromRGB(25,25,25)
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0,8)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1,0,0,35)
Title.Text = "SOZA HUB"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextColor3 = Color3.fromRGB(235,235,235)
Title.BackgroundColor3 = Color3.fromRGB(35,35,35)
Instance.new("UICorner", Title).CornerRadius = UDim.new(0,8)

--================ STATE =========================
local Flags = {
    AutoFish = false,
    AutoReel = false,
    Blatant = false,
    AutoSell = false,
}

local Config = {
    CompleteDelay = 0.2,
    ReelDelay = 0.15,
    WebhookURL = "", -- ISI JIKA MAU
    WebhookRarity = {
        Common=true, Uncommon=true, Rare=true,
        Epic=true, Legendary=true, Mythic=true, SECRET=true
    }
}

--================ UI HELPERS ===================
local function Toggle(text, y, callback)
    local b = Instance.new("TextButton", Main)
    b.Size = UDim2.new(0.9,0,0,30)
    b.Position = UDim2.new(0.05,0,0,y)
    b.Text = text.." : OFF"
    b.Font = Enum.Font.Gotham
    b.TextSize = 13
    b.TextColor3 = Color3.new(1,1,1)
    b.BackgroundColor3 = Color3.fromRGB(45,45,45)
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)

    local on=false
    b.MouseButton1Click:Connect(function()
        on=not on
        b.Text = text.." : "..(on and "ON" or "OFF")
        callback(on)
    end)
end

local function Input(text, y, default, callback)
    local l = Instance.new("TextLabel", Main)
    l.Size = UDim2.new(0.55,0,0,25)
    l.Position = UDim2.new(0.05,0,0,y)
    l.Text = text
    l.Font = Enum.Font.Gotham
    l.TextSize = 12
    l.TextColor3 = Color3.fromRGB(200,200,200)
    l.BackgroundTransparency = 1
    l.TextXAlignment = Left

    local b = Instance.new("TextBox", Main)
    b.Size = UDim2.new(0.35,0,0,25)
    b.Position = UDim2.new(0.6,0,0,y)
    b.Text = tostring(default)
    b.Font = Enum.Font.Gotham
    b.TextSize = 12
    b.TextColor3 = Color3.new(1,1,1)
    b.BackgroundColor3 = Color3.fromRGB(40,40,40)
    b.ClearTextOnFocus = false
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)

    b.FocusLost:Connect(function()
        local v = tonumber(b.Text)
        if v then callback(math.max(0,v)) else b.Text=tostring(default) end
    end)
end

--================ MENU ==========================
Toggle("Auto Fish", 45, function(v) Flags.AutoFish=v end)
Toggle("Auto Reel", 80, function(v) Flags.AutoReel=v end)
Toggle("Blatant Mode", 115, function(v) Flags.Blatant=v end)
Toggle("Auto Sell", 150, function(v) Flags.AutoSell=v end)

Input("Complete Delay", 185, Config.CompleteDelay, function(v) Config.CompleteDelay=v end)
Input("Reel Delay", 215, Config.ReelDelay, function(v) Config.ReelDelay=v end)

--================ TELEPORT =====================
local Teleports = {
    Dock = CFrame.new(0,5,0),
    Shop = CFrame.new(10,5,10),
    Spawn = CFrame.new(0,5,-10)
}

local function TeleportTo(cf)
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.CFrame = cf end
end

local function TpBtn(text, x)
    local b = Instance.new("TextButton", Main)
    b.Size = UDim2.new(0.28,0,0,25)
    b.Position = UDim2.new(x,0,0,250)
    b.Text = text
    b.Font = Enum.Font.Gotham
    b.TextSize = 12
    b.TextColor3 = Color3.new(1,1,1)
    b.BackgroundColor3 = Color3.fromRGB(45,45,45)
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
    b.MouseButton1Click:Connect(function()
        TeleportTo(Teleports[text])
    end)
end
TpBtn("Dock",0.05); TpBtn("Shop",0.36); TpBtn("Spawn",0.67)

--================ AUTO-DETECT REMOTES ==========
local SellRemote
for _,v in pairs(ReplicatedStorage:GetDescendants()) do
    if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
        if v.Name:lower():find("sell") then
            SellRemote = v
        end
    end
end

local function AutoSell()
    if SellRemote then
        pcall(function()
            SellRemote:FireServer()
        end)
    end
end

--================ WEBHOOK ======================
local function SendWebhook(fishName, rarity)
    if Config.WebhookURL == "" then return end
    if not Config.WebhookRarity[rarity] then return end

    local data = {
        username = "SOZA HUB",
        embeds = {{
            title = "🎣 Fish Caught",
            description = fishName,
            fields = {
                {name="Rarity", value=rarity, inline=true},
                {name="Player", value=LocalPlayer.Name, inline=true}
            },
            color = 3066993
        }}
    }

    pcall(function()
        HttpService:PostAsync(
            Config.WebhookURL,
            HttpService:JSONEncode(data),
            Enum.HttpContentType.ApplicationJson
        )
    end)
end

--================ FISH CAUGHT DETECTOR =========
local function GetRarity(tool)
    if tool:GetAttribute("Rarity") then
        return tostring(tool:GetAttribute("Rarity"))
    end
    local n = tool.Name:lower()
    if n:find("secret") then return "SECRET" end
    if n:find("mythic") then return "Mythic" end
    if n:find("legend") then return "Legendary" end
    if n:find("epic") then return "Epic" end
    if n:find("rare") then return "Rare" end
    if n:find("uncommon") then return "Uncommon" end
    return "Common"
end

LocalPlayer.Backpack.ChildAdded:Connect(function(tool)
    if tool:IsA("Tool") then
        task.wait(0.2)
        local rarity = GetRarity(tool)
        SendWebhook(tool.Name, rarity)
    end
end)

--================ MAIN LOOP ====================
task.spawn(function()
    while task.wait(0.1) do
        if Flags.AutoFish then
            -- cast rod (placeholder)
        end

        if Flags.AutoReel then
            if Flags.Blatant then
                task.wait(Config.CompleteDelay)
                task.wait(Config.ReelDelay)
            else
                task.wait(0.6)
            end
        end
    end
end)

task.spawn(function()
    while task.wait(3) do
        if Flags.AutoSell then
            AutoSell()
        end
    end
end)
