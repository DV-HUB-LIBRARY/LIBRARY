local KeyManager = {}

function KeyManager.new(parent, Config, Utils, options)
    options = options or {}
    
    local HttpService = game:GetService("HttpService")
    local LocalPlayer = game.Players.LocalPlayer
    local BACKEND = options.Backend or "https://igr-backen.vercel.app/api"
    
    local root = Instance.new("Frame", parent)
    root.Name = "KeyManager"
    root.Size = UDim2.new(1, 0, 1, 0)
    root.BackgroundTransparency = 1
    root.ZIndex = 10
    
    local toolbar = Instance.new("Frame", root)
    toolbar.Name = "Toolbar"
    toolbar.Size = UDim2.new(1, -20, 0, 30)
    toolbar.Position = UDim2.new(0, 10, 0, 4)
    toolbar.BackgroundTransparency = 1
    toolbar.ZIndex = 20
    
    local toolbarLayout = Instance.new("UIListLayout", toolbar)
    toolbarLayout.FillDirection = Enum.FillDirection.Horizontal
    toolbarLayout.Padding = UDim.new(0, 6)
    toolbarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local function makeToolbarBtn(text, color, hoverColor, width, callback)
        local btn = Instance.new("TextButton", toolbar)
        btn.Size = UDim2.new(0, width, 1, 0)
        btn.BackgroundColor3 = color
        btn.Text = text
        btn.TextColor3 = Config.Colors.Text
        btn.Font = Config.Fonts.Title
        btn.TextSize = 10
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = false
        btn.ZIndex = 21
        Utils.corner(btn, Config.Sizes.RadiusSmall)
        Utils.stroke(btn, Config.Colors.Border, 1)
        Utils.hover(btn, color, hoverColor or Config.Colors.CardHover)
        if callback then btn.MouseButton1Click:Connect(callback) end
        return btn
    end
    
    local generateBtn = makeToolbarBtn("➕ Generate", Config.Colors.Accent, Config.Colors.AccentDim, 105, nil)
    generateBtn.LayoutOrder = 1
    
    local refreshBtn = makeToolbarBtn("🔄 Refresh", Config.Colors.Card, Config.Colors.CardHover, 90, nil)
    refreshBtn.LayoutOrder = 2
    
    local statsBar = Instance.new("Frame", root)
    statsBar.Name = "StatsBar"
    statsBar.Size = UDim2.new(1, -20, 0, 32)
    statsBar.Position = UDim2.new(0, 10, 0, 38)
    statsBar.BackgroundColor3 = Config.Colors.Card
    statsBar.BorderSizePixel = 0
    statsBar.ZIndex = 15
    Utils.corner(statsBar, Config.Sizes.RadiusSmall)
    Utils.stroke(statsBar, Config.Colors.Border, 1)
    
    local statsLabel = Instance.new("TextLabel", statsBar)
    statsLabel.Size = UDim2.new(1, -16, 1, 0)
    statsLabel.Position = UDim2.new(0, 8, 0, 0)
    statsLabel.BackgroundTransparency = 1
    statsLabel.Font = Config.Fonts.Mono
    statsLabel.Text = "📊 Loading..."
    statsLabel.TextColor3 = Config.Colors.Muted
    statsLabel.TextSize = 10
    statsLabel.TextXAlignment = Enum.TextXAlignment.Left
    statsLabel.ZIndex = 16
    
    local scroll = Instance.new("ScrollingFrame", root)
    scroll.Name = "KeyScroll"
    scroll.Size = UDim2.new(1, -20, 1, -80)
    scroll.Position = UDim2.new(0, 10, 0, 76)
    scroll.BackgroundColor3 = Config.Colors.Card
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 4
    scroll.ScrollBarImageColor3 = Config.Colors.Accent
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.ZIndex = 15
    Utils.corner(scroll, Config.Sizes.RadiusSmall)
    
    local scrollPad = Instance.new("UIPadding", scroll)
    scrollPad.PaddingTop = UDim.new(0, 8)
    scrollPad.PaddingBottom = UDim.new(0, 8)
    scrollPad.PaddingLeft = UDim.new(0, 8)
    scrollPad.PaddingRight = UDim.new(0, 8)
    
    local scrollLayout = Instance.new("UIListLayout", scroll)
    scrollLayout.Padding = UDim.new(0, 6)
    scrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local function apiCall(method, path, body, callback)
        task.spawn(function()
            local opts = {
                Url = BACKEND .. path,
                Method = method,
                Headers = {
                    ["X-User-Id"] = tostring(LocalPlayer.UserId),
                },
            }
            
            if body then
                opts.Body = HttpService:JSONEncode(body)
                opts.Headers["Content-Type"] = "application/json"
            end
            
            local ok, res = pcall(function() return request(opts) end)
            
            if not ok or not res then
                if callback then callback(nil, "Network error") end
                return
            end
            
            local decoded = nil
            pcall(function()
                if res.Body and res.Body ~= "" then
                    decoded = HttpService:JSONDecode(res.Body)
                end
            end)
            
            if callback then callback(decoded, nil, res.StatusCode) end
        end)
    end
    
    local function clearList()
        for _, child in ipairs(scroll:GetChildren()) do
            if child:IsA("Frame") or child:IsA("TextLabel") then
                child:Destroy()
            end
        end
    end
    
    local roleColors = {
        owner = Config.Colors.Owner,
        admin = Config.Colors.Admin,
        vip = Config.Colors.VIP,
        user = Config.Colors.User,
    }
    local roleIcons = {
        owner = "👑",
        admin = "🛡️",
        vip = "💎",
        user = "✅",
    }
    
    local function makeKeyCard(keyData, isUsedSection)
        local card = Instance.new("Frame", scroll)
        card.Name = "KeyCard"
        card.Size = UDim2.new(1, 0, 0, isUsedSection and 105 or 90)
        card.BackgroundColor3 = Config.Colors.Base
        card.BorderSizePixel = 0
        card.ZIndex = 16
        Utils.corner(card, Config.Sizes.RadiusSmall)
        
        local tierColors = roleColors[keyData.tier] or Config.Colors.Muted
        local tierIcon = roleIcons[keyData.tier] or "❓"
        
        local cardStroke = Instance.new("UIStroke", card)
        cardStroke.Thickness = 1
        if keyData.banned then
            cardStroke.Color = Config.Colors.Danger
        elseif isUsedSection then
            cardStroke.Color = Config.Colors.Muted
        else
            cardStroke.Color = tierColors
        end
        
        local keyLabel = Instance.new("TextLabel", card)
        keyLabel.Size = UDim2.new(1, -100, 0, 18)
        keyLabel.Position = UDim2.new(0, 10, 0, 8)
        keyLabel.BackgroundTransparency = 1
        keyLabel.Font = Config.Fonts.Mono
        keyLabel.Text = keyData.key
        keyLabel.TextColor3 = Config.Colors.Text
        keyLabel.TextSize = 11
        keyLabel.TextXAlignment = Enum.TextXAlignment.Left
        keyLabel.ZIndex = 17
        
        local tierBadge = Instance.new("Frame", card)
        tierBadge.Size = UDim2.new(0, 80, 0, 20)
        tierBadge.Position = UDim2.new(1, -90, 0, 8)
        tierBadge.BackgroundColor3 = tierColors
        tierBadge.BackgroundTransparency = 0.85
        tierBadge.BorderSizePixel = 0
        tierBadge.ZIndex = 17
        Utils.corner(tierBadge, Config.Sizes.RadiusSmall)
        
        local tierStroke = Instance.new("UIStroke", tierBadge)
        tierStroke.Color = tierColors
        tierStroke.Thickness = 1
        
        local tierIconLbl = Instance.new("TextLabel", tierBadge)
        tierIconLbl.Size = UDim2.new(0, 18, 1, 0)
        tierIconLbl.Position = UDim2.new(0, 4, 0, 0)
        tierIconLbl.BackgroundTransparency = 1
        tierIconLbl.Font = Config.Fonts.Title
        tierIconLbl.Text = tierIcon
        tierIconLbl.TextColor3 = tierColors
        tierIconLbl.TextSize = 11
        tierIconLbl.TextXAlignment = Enum.TextXAlignment.Left
        tierIconLbl.ZIndex = 18
        
        local tierTextLbl = Instance.new("TextLabel", tierBadge)
        tierTextLbl.Size = UDim2.new(1, -24, 1, 0)
        tierTextLbl.Position = UDim2.new(0, 22, 0, 0)
        tierTextLbl.BackgroundTransparency = 1
        tierTextLbl.Font = Config.Fonts.Title
        tierTextLbl.Text = string.upper(keyData.tier)
        tierTextLbl.TextColor3 = tierColors
        tierTextLbl.TextSize = 9
        tierTextLbl.TextXAlignment = Enum.TextXAlignment.Left
        tierTextLbl.ZIndex = 18
        
        local infoLabel = Instance.new("TextLabel", card)
        infoLabel.Size = UDim2.new(1, -20, 0, 14)
        infoLabel.Position = UDim2.new(0, 10, 0, 30)
        infoLabel.BackgroundTransparency = 1
        infoLabel.Font = Config.Fonts.Mono
        infoLabel.Text = "📊 Usage: " .. keyData.usedCount .. "/" .. keyData.maxUsage .. " • ⏱️ " .. keyData.duration
        infoLabel.TextColor3 = Config.Colors.Muted
        infoLabel.TextSize = 9
        infoLabel.TextXAlignment = Enum.TextXAlignment.Left
        infoLabel.ZIndex = 17
        
        local createdLabel = Instance.new("TextLabel", card)
        createdLabel.Size = UDim2.new(1, -20, 0, 12)
        createdLabel.Position = UDim2.new(0, 10, 0, 46)
        createdLabel.BackgroundTransparency = 1
        createdLabel.Font = Config.Fonts.Mono
        createdLabel.Text = "👤 Created by: " .. keyData.createdBy
        createdLabel.TextColor3 = Config.Colors.Muted
        createdLabel.TextSize = 8
        createdLabel.TextXAlignment = Enum.TextXAlignment.Left
        createdLabel.ZIndex = 17
        
        if isUsedSection then
            local usedLabel = Instance.new("TextLabel", card)
            usedLabel.Size = UDim2.new(1, -20, 0, 12)
            usedLabel.Position = UDim2.new(0, 10, 0, 60)
            usedLabel.BackgroundTransparency = 1
            usedLabel.Font = Config.Fonts.Mono
            usedLabel.Text = "👥 Used by: " .. (keyData.usedBy or "?")
            usedLabel.TextColor3 = Config.Colors.Muted
            usedLabel.TextSize = 8
            usedLabel.TextXAlignment = Enum.TextXAlignment.Left
            usedLabel.ZIndex = 17
        end
        
        local btnRow = Instance.new("Frame", card)
        btnRow.Size = UDim2.new(1, -20, 0, 24)
        btnRow.Position = UDim2.new(0, 10, 1, -30)
        btnRow.BackgroundTransparency = 1
        btnRow.ZIndex = 17
        
        local btnLayout = Instance.new("UIListLayout", btnRow)
        btnLayout.FillDirection = Enum.FillDirection.Horizontal
        btnLayout.Padding = UDim.new(0, 4)
        
        local function makeActionBtn(text, color, width, callback)
            local btn = Instance.new("TextButton", btnRow)
            btn.Size = UDim2.new(0, width, 1, 0)
            btn.BackgroundColor3 = color
            btn.Text = text
            btn.TextColor3 = Config.Colors.Text
            btn.Font = Config.Fonts.Title
            btn.TextSize = 9
            btn.BorderSizePixel = 0
            btn.AutoButtonColor = false
            btn.ZIndex = 18
            Utils.corner(btn, Config.Sizes.RadiusSmall)
            Utils.hover(btn, color, Config.Colors.CardHover)
            btn.MouseButton1Click:Connect(callback)
            return btn
        end
        
        makeActionBtn("📋 Copy", Config.Colors.Card, 68, function()
            pcall(function()
                if setclipboard then
                    setclipboard(keyData.key)
                end
            end)
            if options.OnNotify then
                options.OnNotify("📋 Copied", keyData.key, 2)
            end
        end)
        
        makeActionBtn("✏️ Edit", Config.Colors.Card, 68, function()
            if options.OnEdit then
                options.OnEdit(keyData, function()
                    if options.OnRefresh then options.OnRefresh() end
                end)
            end
        end)
        
        makeActionBtn("🗑️ Revoke", Config.Colors.Danger, 78, function()
            if options.OnRevoke then
                options.OnRevoke(keyData, function()
                    if options.OnRefresh then options.OnRefresh() end
                end)
            end
        end)
    end
    
    local function renderList(data)
        clearList()
        
        if not data then
            statsLabel.Text = "❌ Gagal load key"
            statsLabel.TextColor3 = Config.Colors.Danger
            return
        end
        
        if data.stats then
            local s = data.stats
            statsLabel.Text = string.format(
                "📊 Total: %d • ✅ Active: %d • 🔓 Used: %d • ⏰ Expired: %d",
                s.total or 0, s.active or 0, s.used or 0, s.expired or 0
            )
            statsLabel.TextColor3 = Config.Colors.Success
        end
        
        local function addSection(title, list, isUsed)
            if not list or #list == 0 then return end
            
            local header = Instance.new("TextLabel", scroll)
            header.Size = UDim2.new(1, 0, 0, 22)
            header.BackgroundTransparency = 1
            header.Font = Config.Fonts.Title
            header.Text = title .. " (" .. #list .. ")"
            header.TextColor3 = Config.Colors.Accent
            header.TextSize = 11
            header.TextXAlignment = Enum.TextXAlignment.Left
            header.ZIndex = 16
            
            for _, keyData in ipairs(list) do
                makeKeyCard(keyData, isUsed)
            end
        end
        
        addSection("✅ ACTIVE", data.active, false)
        addSection("🔓 USED", data.used, true)
        addSection("⏰ EXPIRED", data.expired, true)
        addSection("🚫 BANNED", data.banned, true)
        
        local hasAny = (#data.active > 0 or #data.used > 0 or #data.expired > 0 or #data.banned > 0)
        
        if not hasAny then
            local emptyLbl = Instance.new("TextLabel", scroll)
            emptyLbl.Size = UDim2.new(1, 0, 0, 60)
            emptyLbl.BackgroundTransparency = 1
            emptyLbl.Font = Config.Fonts.Body
            emptyLbl.Text = "Belum ada key.\nKlik ➕ Generate buat bikin key baru."
            emptyLbl.TextColor3 = Config.Colors.Muted
            emptyLbl.TextSize = 11
            emptyLbl.TextWrapped = true
            emptyLbl.ZIndex = 16
        end
    end
    
    local function fetchKeys()
        statsLabel.Text = "⏳ Loading..."
        statsLabel.TextColor3 = Config.Colors.Muted
        
        apiCall("GET", "/key/list", nil, function(data, err)
            if err then
                statsLabel.Text = "❌ " .. err
                statsLabel.TextColor3 = Config.Colors.Danger
                return
            end
            renderList(data)
        end)
    end
    
    refreshBtn.MouseButton1Click:Connect(fetchKeys)
    
    generateBtn.MouseButton1Click:Connect(function()
        if options.OnGenerate then
            options.OnGenerate(function()
                fetchKeys()
            end)
        end
    end)
    
    task.delay(0.1, fetchKeys)
    
    task.spawn(function()
        while root.Parent do
            task.wait(30)
            if root.Parent then
                fetchKeys()
            end
        end
    end)
    
    return {
        Frame = root,
        Refresh = fetchKeys,
    }
end

return KeyManager
