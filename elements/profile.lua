local RunService = game:GetService("RunService")

local Profile = {}

function Profile.new(parent, options, Config, Utils)
    options = options or {}
    
    local avatarUrl = options.Avatar or "rbxthumb://type=AvatarHeadShot&id=1&w=150&h=150"
    local username = options.Username or "Unknown"
    local userId = options.UserId or "0"
    local role = options.Role or "unknown"
    
    local roleStatic = {
        pending = Config.Colors.Warning,
        expired = Config.Colors.Warning,
        banned = Config.Colors.Danger,
        denied = Config.Colors.Danger,
        unknown = Config.Colors.Muted,
    }
    
    local roleRainbow = {
        owner = { colors = {
            Color3.fromRGB(255, 0, 0),
            Color3.fromRGB(255, 128, 0),
            Color3.fromRGB(255, 255, 0),
            Color3.fromRGB(0, 255, 0),
            Color3.fromRGB(0, 255, 255),
            Color3.fromRGB(0, 100, 255),
            Color3.fromRGB(128, 0, 255),
            Color3.fromRGB(255, 0, 255),
        }, speed = 3 },
        admin = { colors = {
            Color3.fromRGB(100, 180, 255),
            Color3.fromRGB(20, 20, 30),
            Color3.fromRGB(100, 180, 255),
        }, speed = 2 },
        vip = { colors = {
            Color3.fromRGB(255, 215, 0),
            Color3.fromRGB(30, 25, 10),
            Color3.fromRGB(255, 215, 0),
        }, speed = 2 },
        user = { colors = {
            Color3.fromRGB(100, 255, 150),
            Color3.fromRGB(15, 25, 20),
            Color3.fromRGB(100, 255, 150),
        }, speed = 2 },
    }
    
    local roleTexts = {
        owner = "👑 OWNER",
        admin = "🛡️ ADMIN",
        vip = "🏆 VIP",
        user = "✅ USER",
        pending = "🟡 PENDING",
        expired = "⏰ EXPIRED",
        banned = "🚫 BANNED",
        denied = "❌ DENIED",
        unknown = "❓ UNKNOWN",
    }
    
    local roleText = roleTexts[role] or roleTexts.unknown
    local initialColor = roleStatic[role] or (roleRainbow[role] and roleRainbow[role].colors[1]) or Config.Colors.Muted
    
    local card = Instance.new("Frame")
    card.Name = "ProfileCard"
    card.Size = options.Size or UDim2.new(1, 0, 0, 92)
    card.BackgroundColor3 = Config.Colors.Card
    card.BorderSizePixel = 0
    card.ZIndex = options.ZIndex or 14
    card.Parent = parent
    
    Utils.corner(card, Config.Sizes.Radius)
    local cardStroke = Utils.stroke(card, initialColor, 1.5)
    
    local avatar = Instance.new("ImageLabel")
    avatar.Name = "Avatar"
    avatar.Size = UDim2.new(0, 64, 0, 64)
    avatar.Position = UDim2.new(0, 12, 0.5, -32)
    avatar.BackgroundColor3 = Config.Colors.Base
    avatar.BorderSizePixel = 0
    avatar.Image = avatarUrl
    avatar.ZIndex = 15
    avatar.Parent = card
    Utils.corner(avatar, 999)
    local avatarStroke = Utils.stroke(avatar, initialColor, 2)
    
    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(1, -96, 0, 20)
    nameLbl.Position = UDim2.new(0, 88, 0, 12)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Font = Config.Fonts.Title
    nameLbl.Text = tostring(username)
    nameLbl.TextColor3 = Config.Colors.Text
    nameLbl.TextSize = Config.Sizes.TitleSize
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.ZIndex = 15
    nameLbl.Parent = card
    
    local idLbl = Instance.new("TextLabel")
    idLbl.Size = UDim2.new(1, -96, 0, 14)
    idLbl.Position = UDim2.new(0, 88, 0, 34)
    idLbl.BackgroundTransparency = 1
    idLbl.Font = Config.Fonts.Mono
    idLbl.Text = "ID: " .. tostring(userId)
    idLbl.TextColor3 = Config.Colors.Muted
    idLbl.TextSize = Config.Sizes.SmallSize
    idLbl.TextXAlignment = Enum.TextXAlignment.Left
    idLbl.ZIndex = 15
    idLbl.Parent = card
    
    local roleBadge = Instance.new("Frame")
    roleBadge.Size = UDim2.new(0, 100, 0, 22)
    roleBadge.Position = UDim2.new(0, 88, 0, 54)
    roleBadge.BackgroundColor3 = initialColor
    roleBadge.BackgroundTransparency = 0.85
    roleBadge.BorderSizePixel = 0
    roleBadge.ZIndex = 15
    roleBadge.Parent = card
    Utils.corner(roleBadge, Config.Sizes.RadiusSmall)
    local badgeStroke = Utils.stroke(roleBadge, initialColor, 1)
    
    local roleLbl = Instance.new("TextLabel")
    roleLbl.Size = UDim2.new(1, -8, 1, 0)
    roleLbl.Position = UDim2.new(0, 4, 0, 0)
    roleLbl.BackgroundTransparency = 1
    roleLbl.Font = Config.Fonts.Title
    roleLbl.Text = roleText
    roleLbl.TextColor3 = initialColor
    roleLbl.TextSize = Config.Sizes.SmallSize
    roleLbl.TextXAlignment = Enum.TextXAlignment.Left
    roleLbl.ZIndex = 16
    roleLbl.Parent = roleBadge
    
    local currentConn = nil
    
    local function mixColor(c1, c2, t)
        return Color3.new(
            c1.R + (c2.R - c1.R) * t,
            c1.G + (c2.G - c1.G) * t,
            c1.B + (c2.B - c1.B) * t
        )
    end
    
    local function applyColor(color)
        cardStroke.Color = color
        avatarStroke.Color = color
        badgeStroke.Color = color
        roleLbl.TextColor3 = color
        roleBadge.BackgroundColor3 = color
    end
    
    local function stopAnimation()
        if currentConn then
            currentConn:Disconnect()
            currentConn = nil
        end
    end
    
    local function startRainbow(roleKey)
        local data = roleRainbow[roleKey]
        if not data then return end
        
        local colors = data.colors
        local speed = data.speed
        local total = #colors
        
        currentConn = RunService.Heartbeat:Connect(function()
            if not card.Parent then
                stopAnimation()
                return
            end
            
            local rawIdx = (tick() * speed) % total
            local idx = math.floor(rawIdx) + 1
            local nextIdx = (idx % total) + 1
            local c1 = colors[idx]
            local c2 = colors[nextIdx]
            local t = rawIdx - math.floor(rawIdx)
            
            local mixed = mixColor(c1, c2, t)
            applyColor(mixed)
        end)
    end
    
    -- API object, bukan method
    local api = {}
    
    api.Frame = card
    
    api.SetRole = function(newRole)
        stopAnimation()
        role = newRole
        local newText = roleTexts[newRole] or roleTexts.unknown
        roleLbl.Text = newText
        
        if roleStatic[newRole] then
            applyColor(roleStatic[newRole])
        elseif roleRainbow[newRole] then
            startRainbow(newRole)
        else
            applyColor(Config.Colors.Muted)
        end
    end
    
    api.SetAvatar = function(url)
        avatar.Image = url
    end
    
    api.SetUsername = function(name)
        nameLbl.Text = tostring(name)
    end
    
    api.SetUserId = function(id)
        idLbl.Text = "ID: " .. tostring(id)
    end
    
    api.Destroy = function()
        stopAnimation()
        card:Destroy()
    end
    
    if roleStatic[role] then
        applyColor(roleStatic[role])
    elseif roleRainbow[role] then
        startRainbow(role)
    end
    
    return api
end

return Profile
