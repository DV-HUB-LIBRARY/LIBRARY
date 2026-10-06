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
    
    local scroll = Instance.new("ScrollingFrame", root)
    scroll.Size = UDim2.new(1, 0, 1, -70)
    scroll.Position = UDim2.new(0, 0, 0, 70)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 4
    scroll.ScrollBarImageColor3 = Config.Colors.Accent
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.ZIndex = 11
    
    local scrollPadding = Instance.new("UIPadding", scroll)
    scrollPadding.PaddingTop = UDim.new(0, 8)
    scrollPadding.PaddingBottom = UDim.new(0, 8)
    scrollPadding.PaddingLeft = UDim.new(0, 10)
    scrollPadding.PaddingRight = UDim.new(0, 10)
    
    local scrollLayout = Instance.new("UIListLayout", scroll)
    scrollLayout.Padding = UDim.new(0, 6)
    scrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local toolbar = Instance.new("Frame", root)
    toolbar.Size = UDim2.new(1, 0, 0, 30)
    toolbar.BackgroundTransparency = 1
    toolbar.ZIndex = 12
    
    local toolbarLayout = Instance.new("UIListLayout", toolbar)
    toolbarLayout.FillDirection = Enum.FillDirection.Horizontal
    toolbarLayout.Padding = UDim.new(0, 6)
    
    local toolbarPad = Instance.new("UIPadding", toolbar)
    toolbarPad.PaddingLeft = UDim.new(0, 10)
    toolbarPad.PaddingRight = UDim.new(0, 10)
    
    local function makeBtn(text, color, width, callback)
        local btn = Instance.new("TextButton", toolbar)
        btn.Size = UDim2.new(0, width, 1, 0)
        btn.BackgroundColor3 = color
        btn.Text = text
        btn.TextColor3 = Config.Colors.Text
        btn.Font = Config.Fonts.Title
        btn.TextSize = 11
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = false
        btn.ZIndex = 13
        Utils.corner(btn, Config.Sizes.RadiusSmall)
        
        btn.MouseEnter:Connect(function()
            Utils.tween(btn, { BackgroundColor3 = Config.Colors.CardHover }, 0.1)
        end)
        btn.MouseLeave:Connect(function()
            Utils.tween(btn, { BackgroundColor3 = color }, 0.1)
        end)
        
        if callback then btn.MouseButton1Click:Connect(callback) end
        return btn
    end
    
    local generateBtn = makeBtn("➕ Generate", Config.Colors.Accent, 110, nil)
    local refreshBtn = makeBtn("🔄 Refresh", Config.Colors.Card, 100, nil)
    
    local statsBar = Instance.new("Frame", root)
    statsBar.Size = UDim2.new(1, 0, 0, 32)
    statsBar.Position = UDim2.new(0, 0, 0, 36)
    statsBar.BackgroundColor3 = Config.Colors.Card
    statsBar.BorderSizePixel = 0
    statsBar.ZIndex = 12
    Utils.corner(statsBar, Config.Sizes.RadiusSmall)
    
    local statsPad = Instance.new("UIPadding", statsBar)
    statsPad.PaddingLeft = UDim.new(0, 10)
    statsPad.PaddingRight = UDim.new(0, 10)
    
    local statsLabel = Instance.new("TextLabel", statsBar)
    statsLabel.Size = UDim2.new(1, 0, 1, 0)
    statsLabel.BackgroundTransparency = 1
    statsLabel.Font = Config.Fonts.Mono
    statsLabel.Text = "📊 Loading..."
    statsLabel.TextColor3 = Config.Colors.Text
    statsLabel.TextSize = 11
    statsLabel.TextXAlignment = Enum.TextXAlignment.Left
    statsLabel.ZIndex = 13
    
    local container = Instance.new("Frame", root)
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundTransparency = 1
    container.ZIndex = 10
    container.Parent = scroll
    
    statsBar.Position = UDim2.new(0, 0, 0, 36)
    scroll.Position = UDim2.new(0, 0, 0, 74)
    scroll.Size = UDim2.new(1, 0, 1, -74)
    
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
            
            local ok, res = pcall(function()
                return request(opts)
            end)
            
            if not ok or not res then
                warn("[KeyManager] Request failed:", res)
                if callback then callback(nil, "Network error") end
                return
            end
            
            local decoded = nil
            pcall(function()
                decoded = HttpService:JSONDecode(res.Body)
            end)
            
            if callback then callback(decoded, nil) end
        end)
    end
    
    local function clearList()
        for _, child in ipairs(scroll:GetChildren()) do
            if child:IsA("Frame") and child.Name ~= "Toolbar" and child.Name ~= "StatsBar" then
                child:Destroy()
            end
        end
    end
    
    local function makeKeyCard(keyData, isUsedSection)
        local card = Instance.new("Frame", scroll)
        card.Name = "KeyCard"
        card.Size = UDim2.new(1, 0, 0, isUsedSection and 100 or 85)
        card.BackgroundColor3 = Config.Colors.Card
        card.BorderSizePixel = 0
        card.ZIndex = 13
        Utils.corner(card, Config.Sizes.RadiusSmall)
        
        local stroke = Instance.new("UIStroke", card)
        stroke.Thickness = 1
        if keyData.banned then
            stroke.Color = Config.Colors.Danger
        elseif isUsedSection then
            stroke.Color = Config.Colors.Muted
        else
            stroke.Color = Config.Colors.Accent
        end
        
        local keyLabel = Instance.new("TextLabel", card)
        keyLabel.Size = UDim2.new(1, -20, 0, 18)
        keyLabel.Position = UDim2.new(0, 10, 0, 6)
        keyLabel.BackgroundTransparency = 1
        keyLabel.Font = Config.Fonts.Mono
        keyLabel.Text = keyData.key
        keyLabel.TextColor3 = Config.Colors.Text
        keyLabel.TextSize = 11
        keyLabel.TextXAlignment = Enum.TextXAlignment.Left
        keyLabel.ZIndex = 14
        
        local tierColors = {
            owner = Config.Colors.Owner,
            admin = Config.Colors.Admin,
            vip = Config.Colors.VIP,
            user = Config.Colors.User,
        }
        local tierColor = tierColors[keyData.tier] or Config.Colors.Muted
        
        local tierLabel = Instance.new("TextLabel", card)
        tierLabel.Size = UDim2.new(0, 70, 0, 18)
        tierLabel.Position = UDim2.new(1, -80, 0, 6)
        tierLabel.BackgroundColor3 = tierColor
        tierLabel.BackgroundTransparency = 0.85
        tierLabel.Font = Config.Fonts.Title
        tierLabel.Text = string.upper(keyData.tier)
        tierLabel.TextColor3 = tierColor
        tierLabel.TextSize = 10
        tierLabel.ZIndex = 14
        Utils.corner(tierLabel, Config.Sizes.RadiusSmall)
        Utils.stroke(tierLabel, tierColor, 1)
        
        local infoLabel = Instance.new("TextLabel", card)
        infoLabel.Size = UDim2.new(1, -20, 0, 14)
        infoLabel.Position = UDim2.new(0, 10, 0, 26)
        infoLabel.BackgroundTransparency = 1
        infoLabel.Font = Config.Fonts.Mono
        infoLabel.Text = "Usage: " .. keyData.usedCount .. "/" .. keyData.maxUsage .. " • " .. keyData.duration
        infoLabel.TextColor3 = Config.Colors.Muted
        infoLabel.TextSize = 9
        infoLabel.TextXAlignment = Enum.TextXAlignment.Left
        infoLabel.ZIndex = 14
        
        local createdLabel = Instance.new("TextLabel", card)
        createdLabel.Size = UDim2.new(1, -20, 0, 12)
        createdLabel.Position = UDim2.new(0, 10, 0, 42)
        createdLabel.BackgroundTransparency = 1
        createdLabel.Font = Config.Fonts.Mono
        createdLabel.Text = "Created by: " .. keyData.createdBy
        createdLabel.TextColor3 = Config.Colors.Muted
        createdLabel.TextSize = 9
        createdLabel.TextXAlignment = Enum.TextXAlignment.Left
        createdLabel.ZIndex = 14
        
        if isUsedSection then
            local usedLabel = Instance.new("TextLabel", card)
            usedLabel.Size = UDim2.new(1, -20, 0, 12)
            usedLabel.Position = UDim2.new(0, 10, 0, 56)
            usedLabel.BackgroundTransparency = 1
            usedLabel.Font = Config.Fonts.Mono
            usedLabel.Text = "Used by: " .. (keyData.usedBy or "?")
            usedLabel.TextColor3 = Config.Colors.Muted
            usedLabel.TextSize = 9
            usedLabel.TextXAlignment = Enum.TextXAlignment.Left
            usedLabel.ZIndex = 14
        end
        
        local btnRow = Instance.new("Frame", card)
        btnRow.Size = UDim2.new(1, -20, 0, 24)
        btnRow.Position = UDim2.new(0, 10, 1, -30)
        btnRow.BackgroundTransparency = 1
        btnRow.ZIndex = 14
        
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
            btn.ZIndex = 15
            Utils.corner(btn, Config.Sizes.RadiusSmall)
            
            btn.MouseEnter:Connect(function()
                Utils.tween(btn, { BackgroundColor3 = Config.Colors.CardHover }, 0.1)
            end)
            btn.MouseLeave:Connect(function()
                Utils.tween(btn, { BackgroundColor3 = color }, 0.1)
            end)
            
            btn.MouseButton1Click:Connect(callback)
            return btn
        end
        
        makeActionBtn("📋 COPY", Config.Colors.Card, 70, function()
            pcall(function()
                if setclipboard then
                    setclipboard(keyData.key)
                end
            end)
            if options.OnNotify then
                options.OnNotify("📋 Key Copied", keyData.key, 2)
            end
        end)
        
        makeActionBtn("✏️ EDIT", Config.Colors.Card, 70, function()
            if options.OnEdit then
                options.OnEdit(keyData, function() 
                    if options.OnRefresh then options.OnRefresh() end
                end)
            end
        end)
        
        makeActionBtn("🗑️ REVOKE", Config.Colors.Danger, 80, function()
            if options.OnRevoke then
                options.OnRevoke(keyData, function()
                    if options.OnRefresh then options.OnRefresh() end
                end)
            end
        end)
        
        return card
    end
    
    local function renderList(data)
        clearList()
        
        if not data then
            statsLabel.Text = "❌ Gagal load key"
            return
        end
        
        if data.stats then
            local s = data.stats
            statsLabel.Text = string.format(
                "📊 Total: %d • ✅ Active: %d • 🔓 Used: %d • ⏰ Expired: %d • 🚫 Banned: %d",
                s.total or 0, s.active or 0, s.used or 0, s.expired or 0, s.banned or 0
            )
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
            header.ZIndex = 12
            
            for _, keyData in ipairs(list) do
                makeKeyCard(keyData, isUsed)
            end
        end
        
        addSection("✅ ACTIVE", data.active, false)
        addSection("🔓 USED", data.used, true)
        addSection("⏰ EXPIRED", data.expired, true)
        addSection("🚫 BANNED", data.banned, true)
        
        if #scroll:GetChildren() == 0 then
            local emptyLbl = Instance.new("TextLabel", scroll)
            emptyLbl.Size = UDim2.new(1, 0, 0, 40)
            emptyLbl.BackgroundTransparency = 1
            emptyLbl.Font = Config.Fonts.Body
            emptyLbl.Text = "Belum ada key. Klik ➕ Generate buat bikin key baru."
            emptyLbl.TextColor3 = Config.Colors.Muted
            emptyLbl.TextSize = 11
            emptyLbl.ZIndex = 12
        end
    end
    
    local function fetchKeys()
        statsLabel.Text = "⏳ Loading..."
        apiCall("GET", "/key/list", nil, function(data, err)
            if err then
                statsLabel.Text = "❌ " .. err
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
    
    local autoRefresh = true
    task.spawn(function()
        while root.Parent and autoRefresh do
            task.wait(30)
            fetchKeys()
        end
    end)
    
    return {
        Frame = root,
        Refresh = fetchKeys,
    }
end

return KeyManager
