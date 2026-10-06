local Profile = {}

function Profile.new(parent, options, Config, Utils)
    options = options or {}
    
    local avatarUrl = options.Avatar or "rbxthumb://type=AvatarHeadShot&id=1&w=150&h=150"
    local username = options.Username or "Unknown"
    local userId = options.UserId or "0"
    local role = options.Role or "unknown"
    
    local roleColors = {
        owner = Config.Colors.Owner,
        admin = Config.Colors.Admin,
        vip = Config.Colors.VIP,
        user = Config.Colors.User,
        pending = Config.Colors.Warning,
        expired = Config.Colors.Warning,
        banned = Config.Colors.Danger,
        denied = Config.Colors.Danger,
        unknown = Config.Colors.Muted,
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
    
    local roleColor = roleColors[role] or Config.Colors.Muted
    local roleText = roleTexts[role] or roleTexts.unknown
    
    local card = Instance.new("Frame")
    card.Name = "ProfileCard"
    card.Size = options.Size or UDim2.new(1, 0, 0, 92)
    card.BackgroundColor3 = Config.Colors.Card
    card.BorderSizePixel = 0
    card.ZIndex = options.ZIndex or 14
    card.Parent = parent
    
    Utils.corner(card, Config.Sizes.Radius)
    Utils.stroke(card, Config.Colors.Border, 1)
    
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
    Utils.stroke(avatar, Config.Colors.Accent, 2)
    
    local nameLbl = Instance.new("TextLabel")
    nameLbl.Name = "NameLbl"
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
    idLbl.Name = "IdLbl"
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
    roleBadge.Name = "RoleBadge"
    roleBadge.Size = UDim2.new(0, 100, 0, 22)
    roleBadge.Position = UDim2.new(0, 88, 0, 54)
    roleBadge.BackgroundColor3 = roleColor
    roleBadge.BackgroundTransparency = 0.85
    roleBadge.BorderSizePixel = 0
    roleBadge.ZIndex = 15
    roleBadge.Parent = card
    Utils.corner(roleBadge, Config.Sizes.RadiusSmall)
    Utils.stroke(roleBadge, roleColor, 1)
    
    local roleLbl = Instance.new("TextLabel")
    roleLbl.Name = "RoleLbl"
    roleLbl.Size = UDim2.new(1, -8, 1, 0)
    roleLbl.Position = UDim2.new(0, 4, 0, 0)
    roleLbl.BackgroundTransparency = 1
    roleLbl.Font = Config.Fonts.Title
    roleLbl.Text = roleText
    roleLbl.TextColor3 = roleColor
    roleLbl.TextSize = Config.Sizes.SmallSize
    roleLbl.TextXAlignment = Enum.TextXAlignment.Left
    roleLbl.ZIndex = 16
    roleLbl.Parent = roleBadge
    
    card.SetRole = function(_, newRole)
        local newColor = roleColors[newRole] or Config.Colors.Muted
        local newText = roleTexts[newRole] or roleTexts.unknown
        roleBadge.BackgroundColor3 = newColor
        roleLbl.Text = newText
        roleLbl.TextColor3 = newColor
        local stroke = roleBadge:FindFirstChildOfClass("UIStroke")
        if stroke then stroke.Color = newColor end
    end
    
    card.SetAvatar = function(_, url)
        avatar.Image = url
    end
    
    card.SetUsername = function(_, name)
        nameLbl.Text = tostring(name)
    end
    
    card.SetUserId = function(_, id)
        idLbl.Text = "ID: " .. tostring(id)
    end
    
    return card
end

return Profile
