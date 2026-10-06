local OwnerPanel = {}

function OwnerPanel.open(Config, Utils, modules)
    local HttpService = game:GetService("HttpService")
    local LocalPlayer = game.Players.LocalPlayer
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
    
    local BACKEND = "https://igr-backen.vercel.app/api"
    
    if PlayerGui:FindFirstChild("DVLlib_OwnerPanel") then
        PlayerGui["DVLlib_OwnerPanel"]:Destroy()
    end
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "DVLlib_OwnerPanel"
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 10001
    gui.IgnoreGuiInset = true
    gui.Parent = PlayerGui
    
    local win = Instance.new("Frame", gui)
    win.Size = UDim2.new(0, 380, 0, 480)
    win.Position = UDim2.new(0.5, -190, 0.5, -220)
    win.BackgroundColor3 = Config.Colors.Base
    win.BorderSizePixel = 0
    win.Active = true
    win.Draggable = true
    Utils.corner(win, Config.Sizes.Radius)
    Utils.stroke(win, Config.Colors.Border, 1)
    
    local topbar = Instance.new("Frame", win)
    topbar.Size = UDim2.new(1, 0, 0, 36)
    topbar.BackgroundColor3 = Config.Colors.Topbar
    topbar.BorderSizePixel = 0
    Utils.corner(topbar, Config.Sizes.Radius)
    
    local accent = Instance.new("Frame", topbar)
    accent.Size = UDim2.new(0, 3, 0, 36)
    accent.BackgroundColor3 = Config.Colors.Accent
    accent.BorderSizePixel = 0
    Utils.corner(accent, Config.Sizes.Radius)
    
    local title = Instance.new("TextLabel", topbar)
    title.Size = UDim2.new(1, -60, 1, 0)
    title.Position = UDim2.new(0, 12, 0, 0)
    title.BackgroundTransparency = 1
    title.Font = Config.Fonts.Title
    title.Text = "👑 DV OWNER PANEL"
    title.TextColor3 = Config.Colors.Text
    title.TextSize = 12
    title.TextXAlignment = Enum.TextXAlignment.Left
    
    local closeBtn = Instance.new("TextButton", topbar)
    closeBtn.Size = UDim2.new(0, 22, 0, 22)
    closeBtn.Position = UDim2.new(1, -28, 0.5, -11)
    closeBtn.BackgroundColor3 = Config.Colors.Danger
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Config.Colors.Text
    closeBtn.Font = Config.Fonts.Title
    closeBtn.TextSize = 11
    closeBtn.BorderSizePixel = 0
    Utils.corner(closeBtn, 5)
    closeBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)
    
    local tabbar = Instance.new("Frame", win)
    tabbar.Size = UDim2.new(1, 0, 0, 38)
    tabbar.Position = UDim2.new(0, 0, 0, 36)
    tabbar.BackgroundColor3 = Config.Colors.Tabbar
    tabbar.BorderSizePixel = 0
    
    local tabsList = {
        { id = "wl",   icon = "📋", label = "WL" },
        { id = "req",  icon = "📩", label = "REQ" },
        { id = "ban",  icon = "🚫", label = "BAN" },
        { id = "stat", icon = "📊", label = "STAT" },
        { id = "log",  icon = "📜", label = "LOG" },
        { id = "dev",  icon = "📱", label = "DEV" },
        { id = "ann",  icon = "📢", label = "ANN" },
        { id = "cfg",  icon = "⚙️", label = "CFG" },
        { id = "key",  icon = "🔑", label = "KEY" },
    }
    
    local tabButtons = {}
    local tabPages = {}
    local activePage = nil
    
    for i, tab in ipairs(tabsList) do
        local btn = Instance.new("TextButton", tabbar)
        btn.Size = UDim2.new(1 / #tabsList, -2, 1, -4)
        btn.Position = UDim2.new((i - 1) / #tabsList, 1, 0, 2)
        btn.BackgroundColor3 = Config.Colors.Base
        btn.Text = tab.icon
        btn.TextColor3 = Config.Colors.Muted
        btn.Font = Config.Fonts.Title
        btn.TextSize = 14
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = false
        Utils.corner(btn, Config.Sizes.RadiusSmall)
        tabButtons[tab.id] = btn
        
        local page = Instance.new("Frame", win)
        page.Size = UDim2.new(1, 0, 1, -74)
        page.Position = UDim2.new(0, 0, 0, 74)
        page.BackgroundTransparency = 1
        page.Visible = false
        page.ZIndex = 10
        tabPages[tab.id] = page
        
        btn.MouseButton1Click:Connect(function()
            for id, b in pairs(tabButtons) do
                if id == tab.id then
                    b.BackgroundColor3 = Config.Colors.Card
                    b.TextColor3 = Config.Colors.Accent
                else
                    b.BackgroundColor3 = Config.Colors.Base
                    b.TextColor3 = Config.Colors.Muted
                end
            end
            for id, p in pairs(tabPages) do
                p.Visible = (id == tab.id)
            end
            activePage = tab.id
        end)
        
        btn.MouseEnter:Connect(function()
            if activePage ~= tab.id then
                Utils.tween(btn, { BackgroundColor3 = Config.Colors.CardHover }, 0.1)
            end
        end)
        btn.MouseLeave:Connect(function()
            if activePage ~= tab.id then
                Utils.tween(btn, { BackgroundColor3 = Config.Colors.Base }, 0.1)
            end
        end)
    end
    
    local function apiCall(method, path, body, callback)
        task.spawn(function()
            local opts = {
                Url = BACKEND .. path,
                Method = method,
                Headers = {
                    ["X-User-Id"] = tostring(LocalPlayer.UserId),
                },
            }
            
            if body ~= nil then
                opts.Body = HttpService:JSONEncode(body)
                opts.Headers["Content-Type"] = "application/json"
            end
            
            local ok, res = pcall(function()
                return request(opts)
            end)
            
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
    
    local function notify(t, c, d)
        modules.Notification.send(modules.win, {
            Title = t,
            Content = c,
            Duration = d or 3,
        }, Config, Utils)
    end
    
    local function makeClearScroll(scroll)
        for _, child in ipairs(scroll:GetChildren()) do
            if child:IsA("Frame") or child:IsA("TextLabel") or child:IsA("TextButton") then
                child:Destroy()
            end
        end
    end
    
    local function lookupUserId(input, callback)
        input = tostring(input):gsub("%s", "")
        if input == "" then
            callback(nil)
            return
        end
        
        if input:match("^%d+$") then
            callback(input)
            return
        end
        
        apiCall("GET", "/get?path=" .. HttpService:UrlEncode("/Whitelist"), nil, function(data)
            if not data then
                callback(nil)
                return
            end
            
            local target = string.lower(input)
            for userId, info in pairs(data) do
                if type(info) == "table" and info.Username then
                    if string.lower(tostring(info.Username)) == target then
                        callback(tostring(userId))
                        return
                    end
                end
            end
            callback(nil)
        end)
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
        pending = "🟡",
        expired = "⏰",
        banned = "🚫",
    }
    
    local wlPage = tabPages["wl"]
    local wlScroll = Instance.new("ScrollingFrame", wlPage)
    wlScroll.Size = UDim2.new(1, -16, 1, -16)
    wlScroll.Position = UDim2.new(0, 8, 0, 8)
    wlScroll.BackgroundColor3 = Config.Colors.Card
    wlScroll.BorderSizePixel = 0
    wlScroll.ScrollBarThickness = 4
    wlScroll.ScrollBarImageColor3 = Config.Colors.Accent
    wlScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    wlScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Utils.corner(wlScroll, Config.Sizes.RadiusSmall)
    
    local wlPad = Instance.new("UIPadding", wlScroll)
    wlPad.PaddingTop = UDim.new(0, 8)
    wlPad.PaddingBottom = UDim.new(0, 8)
    wlPad.PaddingLeft = UDim.new(0, 8)
    wlPad.PaddingRight = UDim.new(0, 8)
    
    local wlLayout = Instance.new("UIListLayout", wlScroll)
    wlLayout.Padding = UDim.new(0, 6)
    wlLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local function renderWL()
        makeClearScroll(wlScroll)
        apiCall("GET", "/get?path=" .. HttpService:UrlEncode("/Whitelist"), nil, function(data)
            if not data then
                notify("❌ Error", "Gagal load WL", 3)
                return
            end
            
            local entries = {}
            for userId, info in pairs(data) do
                table.insert(entries, { userId = userId, info = info })
            end
            
            table.sort(entries, function(a, b)
                local order = { owner = 4, admin = 3, vip = 2, user = 1 }
                local aRole = order[string.lower(a.info.Role or "user")] or 0
                local bRole = order[string.lower(b.info.Role or "user")] or 0
                return aRole > bRole
            end)
            
            for _, entry in ipairs(entries) do
                local userId = entry.userId
                local info = entry.info
                local role = string.lower(info.Role or "user")
                local isOwner = role == "owner"
                local rColor = roleColors[role] or Config.Colors.Muted
                local rIcon = roleIcons[role] or "❓"
                
                local card = Instance.new("Frame", wlScroll)
                card.Size = UDim2.new(1, 0, 0, 90)
                card.BackgroundColor3 = isOwner and Color3.fromRGB(45, 35, 5) or Config.Colors.Base
                card.BorderSizePixel = 0
                Utils.corner(card, Config.Sizes.RadiusSmall)
                
                if isOwner then
                    local s = Instance.new("UIStroke", card)
                    s.Color = Config.Colors.Owner
                    s.Thickness = 1
                end
                
                local avatar = Instance.new("ImageLabel", card)
                avatar.Size = UDim2.new(0, 44, 0, 44)
                avatar.Position = UDim2.new(0, 8, 0, 8)
                avatar.BackgroundColor3 = Config.Colors.Card
                avatar.BorderSizePixel = 0
                avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. userId .. "&w=150&h=150"
                Utils.corner(avatar, 999)
                
                local nameLbl = Instance.new("TextLabel", card)
                nameLbl.Size = UDim2.new(1, -140, 0, 18)
                nameLbl.Position = UDim2.new(0, 60, 0, 6)
                nameLbl.BackgroundTransparency = 1
                nameLbl.Font = Config.Fonts.Title
                nameLbl.Text = info.Username or userId
                nameLbl.TextColor3 = Config.Colors.Text
                nameLbl.TextSize = 10
                nameLbl.TextXAlignment = Enum.TextXAlignment.Left
                
                local roleBadge = Instance.new("Frame", card)
                roleBadge.Size = UDim2.new(0, 80, 0, 18)
                roleBadge.Position = UDim2.new(1, -88, 0, 6)
                roleBadge.BackgroundColor3 = rColor
                roleBadge.BackgroundTransparency = 0.85
                roleBadge.BorderSizePixel = 0
                Utils.corner(roleBadge, Config.Sizes.RadiusSmall)
                
                local rStroke = Instance.new("UIStroke", roleBadge)
                rStroke.Color = rColor
                rStroke.Thickness = 1
                
                local roleIconLbl = Instance.new("TextLabel", roleBadge)
                roleIconLbl.Size = UDim2.new(0, 18, 1, 0)
                roleIconLbl.Position = UDim2.new(0, 4, 0, 0)
                roleIconLbl.BackgroundTransparency = 1
                roleIconLbl.Font = Config.Fonts.Title
                roleIconLbl.Text = rIcon
                roleIconLbl.TextColor3 = rColor
                roleIconLbl.TextSize = 11
                roleIconLbl.TextXAlignment = Enum.TextXAlignment.Left
                
                local roleTextLbl = Instance.new("TextLabel", roleBadge)
                roleTextLbl.Size = UDim2.new(1, -24, 1, 0)
                roleTextLbl.Position = UDim2.new(0, 22, 0, 0)
                roleTextLbl.BackgroundTransparency = 1
                roleTextLbl.Font = Config.Fonts.Title
                roleTextLbl.Text = role:upper()
                roleTextLbl.TextColor3 = rColor
                roleTextLbl.TextSize = 9
                roleTextLbl.TextXAlignment = Enum.TextXAlignment.Left
                
                local idLbl = Instance.new("TextLabel", card)
                idLbl.Size = UDim2.new(1, -70, 0, 12)
                idLbl.Position = UDim2.new(0, 60, 0, 26)
                idLbl.BackgroundTransparency = 1
                idLbl.Font = Config.Fonts.Mono
                idLbl.Text = "ID: " .. userId
                idLbl.TextColor3 = Config.Colors.Muted
                idLbl.TextSize = 8
                idLbl.TextXAlignment = Enum.TextXAlignment.Left
                
                local expLbl = Instance.new("TextLabel", card)
                expLbl.Size = UDim2.new(1, -70, 0, 12)
                expLbl.Position = UDim2.new(0, 60, 0, 40)
                expLbl.BackgroundTransparency = 1
                expLbl.Font = Config.Fonts.Mono
                expLbl.Text = "📅 " .. (info.Expired or "Lifetime")
                expLbl.TextColor3 = Config.Colors.Muted
                expLbl.TextSize = 8
                expLbl.TextXAlignment = Enum.TextXAlignment.Left
                
                local btnRow = Instance.new("Frame", card)
                btnRow.Size = UDim2.new(1, -16, 0, 24)
                btnRow.Position = UDim2.new(0, 8, 1, -30)
                btnRow.BackgroundTransparency = 1
                
                local btnLayout = Instance.new("UIListLayout", btnRow)
                btnLayout.FillDirection = Enum.FillDirection.Horizontal
                btnLayout.Padding = UDim.new(0, 4)
                
                local function mkBtn(text, color, width, cb)
                    local b = Instance.new("TextButton", btnRow)
                    b.Size = UDim2.new(0, width, 1, 0)
                    b.BackgroundColor3 = color
                    b.Text = text
                    b.TextColor3 = Config.Colors.Text
                    b.Font = Config.Fonts.Title
                    b.TextSize = 8
                    b.BorderSizePixel = 0
                    b.AutoButtonColor = false
                    Utils.corner(b, Config.Sizes.RadiusSmall)
                    b.MouseButton1Click:Connect(cb)
                    return b
                end
                
                if not isOwner then
                    mkBtn("⚙️ ROLE", Color3.fromRGB(60, 40, 100), 60, function()
                        showRoleChangeModal(userId, info, renderWL)
                    end)
                    
                    mkBtn("📅 EXP", Color3.fromRGB(60, 60, 20), 60, function()
                        showExpiryModal(userId, info, renderWL)
                    end)
                    
                    mkBtn("🔨 BAN", Config.Colors.Danger, 60, function()
                        showBanConfirmModal(userId, info, renderWL)
                    end)
                    
                    mkBtn("🗑️ DEL", Color3.fromRGB(100, 20, 20), 60, function()
                        showDeleteConfirmModal(userId, info, renderWL)
                    end)
                else
                    local lock = Instance.new("TextLabel", btnRow)
                    lock.Size = UDim2.new(1, 0, 1, 0)
                    lock.BackgroundColor3 = Color3.fromRGB(60, 40, 0)
                    lock.Text = "🔒 OWNER PROTECTED"
                    lock.TextColor3 = Config.Colors.Owner
                    lock.Font = Config.Fonts.Title
                    lock.TextSize = 9
                    lock.BorderSizePixel = 0
                    Utils.corner(lock, Config.Sizes.RadiusSmall)
                end
            end
        end)
    end
    
    function showRoleChangeModal(userId, info, refreshCallback)
        local overlay = Instance.new("Frame", gui)
        overlay.Size = UDim2.new(1, 0, 1, 0)
        overlay.BackgroundColor3 = Color3.new(0, 0, 0)
        overlay.BackgroundTransparency = 0.5
        overlay.BorderSizePixel = 0
        overlay.ZIndex = 500
        
        local modal = Instance.new("Frame", overlay)
        modal.Size = UDim2.new(0, 240, 0, 220)
        modal.Position = UDim2.new(0.5, -120, 0.5, -110)
        modal.BackgroundColor3 = Config.Colors.Card
        modal.BorderSizePixel = 0
        modal.ZIndex = 501
        Utils.corner(modal, Config.Sizes.Radius)
        Utils.stroke(modal, Config.Colors.Accent, 1)
        
        local closeX = Instance.new("TextButton", modal)
        closeX.Size = UDim2.new(0, 22, 0, 22)
        closeX.Position = UDim2.new(1, -28, 0, 8)
        closeX.BackgroundColor3 = Config.Colors.Danger
        closeX.Text = "✕"
        closeX.TextColor3 = Config.Colors.Text
        closeX.Font = Config.Fonts.Title
        closeX.TextSize = 11
        closeX.BorderSizePixel = 0
        closeX.ZIndex = 503
        Utils.corner(closeX, 5)
        closeX.MouseButton1Click:Connect(function() overlay:Destroy() end)
        
        local t = Instance.new("TextLabel", modal)
        t.Size = UDim2.new(1, -60, 0, 22)
        t.Position = UDim2.new(0, 10, 0, 8)
        t.BackgroundTransparency = 1
        t.Font = Config.Fonts.Title
        t.Text = "⚙️ PILIH ROLE"
        t.TextColor3 = Config.Colors.Accent
        t.TextSize = 11
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.ZIndex = 502
        
        local u = Instance.new("TextLabel", modal)
        u.Size = UDim2.new(1, -20, 0, 14)
        u.Position = UDim2.new(0, 10, 0, 30)
        u.BackgroundTransparency = 1
        u.Font = Config.Fonts.Mono
        u.Text = info.Username or userId
        u.TextColor3 = Config.Colors.Muted
        u.TextSize = 9
        u.TextXAlignment = Enum.TextXAlignment.Left
        u.ZIndex = 502
        
        local roles = { "user", "vip", "admin" }
        local y = 50
        
        for _, r in ipairs(roles) do
            local rCol = roleColors[r] or Config.Colors.Muted
            local rIco = roleIcons[r] or "❓"
            
            local b = Instance.new("TextButton", modal)
            b.Size = UDim2.new(1, -20, 0, 28)
            b.Position = UDim2.new(0, 10, 0, y)
            b.BackgroundColor3 = (string.lower(info.Role or "") == r) and rCol or Config.Colors.Base
            b.Text = rIco .. "  " .. string.upper(r)
            b.TextColor3 = Config.Colors.Text
            b.Font = Config.Fonts.Title
            b.TextSize = 10
            b.BorderSizePixel = 0
            b.ZIndex = 502
            Utils.corner(b, Config.Sizes.RadiusSmall)
            
            b.MouseButton1Click:Connect(function()
                apiCall("PUT", "/put?path=" .. HttpService:UrlEncode("/Whitelist/" .. userId .. "/Role"), r, function(result)
                    if result and result.ok then
                        overlay:Destroy()
                        notify("✅ Role Changed", info.Username .. ": " .. r, 3)
                        refreshCallback()
                    else
                        notify("❌ Gagal", "Coba lagi", 3)
                    end
                end)
            end)
            
            y = y + 32
        end
        
        local cancel = Instance.new("TextButton", modal)
        cancel.Size = UDim2.new(1, -20, 0, 28)
        cancel.Position = UDim2.new(0, 10, 1, -38)
        cancel.BackgroundColor3 = Config.Colors.Danger
        cancel.Text = "❌ BATAL"
        cancel.TextColor3 = Config.Colors.Text
        cancel.Font = Config.Fonts.Title
        cancel.TextSize = 10
        cancel.BorderSizePixel = 0
        cancel.ZIndex = 502
        Utils.corner(cancel, Config.Sizes.RadiusSmall)
        cancel.MouseButton1Click:Connect(function()
            overlay:Destroy()
        end)
    end
    
    function showExpiryModal(userId, info, refreshCallback)
        local overlay = Instance.new("Frame", gui)
        overlay.Size = UDim2.new(1, 0, 1, 0)
        overlay.BackgroundColor3 = Color3.new(0, 0, 0)
        overlay.BackgroundTransparency = 0.5
        overlay.BorderSizePixel = 0
        overlay.ZIndex = 500
        
        local modal = Instance.new("Frame", overlay)
        modal.Size = UDim2.new(0, 300, 0, 260)
        modal.Position = UDim2.new(0.5, -150, 0.5, -130)
        modal.BackgroundColor3 = Config.Colors.Card
        modal.BorderSizePixel = 0
        modal.ZIndex = 501
        Utils.corner(modal, Config.Sizes.Radius)
        Utils.stroke(modal, Config.Colors.Accent, 1)
        
        local closeX = Instance.new("TextButton", modal)
        closeX.Size = UDim2.new(0, 22, 0, 22)
        closeX.Position = UDim2.new(1, -28, 0, 8)
        closeX.BackgroundColor3 = Config.Colors.Danger
        closeX.Text = "✕"
        closeX.TextColor3 = Config.Colors.Text
        closeX.Font = Config.Fonts.Title
        closeX.TextSize = 11
        closeX.BorderSizePixel = 0
        closeX.ZIndex = 503
        Utils.corner(closeX, 5)
        closeX.MouseButton1Click:Connect(function() overlay:Destroy() end)
        
        local t = Instance.new("TextLabel", modal)
        t.Size = UDim2.new(1, -60, 0, 22)
        t.Position = UDim2.new(0, 10, 0, 8)
        t.BackgroundTransparency = 1
        t.Font = Config.Fonts.Title
        t.Text = "📅 SET EXPIRY"
        t.TextColor3 = Config.Colors.Accent
        t.TextSize = 11
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.ZIndex = 502
        
        local u = Instance.new("TextLabel", modal)
        u.Size = UDim2.new(1, -20, 0, 14)
        u.Position = UDim2.new(0, 10, 0, 30)
        u.BackgroundTransparency = 1
        u.Font = Config.Fonts.Mono
        u.Text = info.Username or userId
        u.TextColor3 = Config.Colors.Muted
        u.TextSize = 9
        u.TextXAlignment = Enum.TextXAlignment.Left
        u.ZIndex = 502
        
        local durFrame = Instance.new("Frame", modal)
        durFrame.Size = UDim2.new(1, -20, 0, 130)
        durFrame.Position = UDim2.new(0, 10, 0, 50)
        durFrame.BackgroundTransparency = 1
        durFrame.ZIndex = 502
        
        local picker = modules.DurationPicker.new(durFrame, {}, Config, Utils, nil)
        
        local save = Instance.new("TextButton", modal)
        save.Size = UDim2.new(0.5, -15, 0, 28)
        save.Position = UDim2.new(0, 10, 1, -38)
        save.BackgroundColor3 = Config.Colors.Accent
        save.Text = "💾 SET"
        save.TextColor3 = Config.Colors.Text
        save.Font = Config.Fonts.Title
        save.TextSize = 10
        save.BorderSizePixel = 0
        save.ZIndex = 502
        Utils.corner(save, Config.Sizes.RadiusSmall)
        
        local cancel = Instance.new("TextButton", modal)
        cancel.Size = UDim2.new(0.5, -15, 0, 28)
        cancel.Position = UDim2.new(0.5, 5, 1, -38)
        cancel.BackgroundColor3 = Config.Colors.Danger
        cancel.Text = "❌ BATAL"
        cancel.TextColor3 = Config.Colors.Text
        cancel.Font = Config.Fonts.Title
        cancel.TextSize = 10
        cancel.BorderSizePixel = 0
        cancel.ZIndex = 502
        Utils.corner(cancel, Config.Sizes.RadiusSmall)
        
        cancel.MouseButton1Click:Connect(function()
            overlay:Destroy()
        end)
        
        save.MouseButton1Click:Connect(function()
            local durData = picker.GetValue()
            local expiryValue = nil
            
            if durData.unit ~= "lifetime" and durData.amount > 0 then
                local units = {
                    menit = 60, jam = 3600, hari = 86400,
                    bulan = 2592000, tahun = 31536000,
                }
                local expiry = os.time() + (durData.amount * units[durData.unit])
                expiryValue = os.date("%Y-%m-%d", expiry)
            end
            
            apiCall("PUT", "/put?path=" .. HttpService:UrlEncode("/Whitelist/" .. userId .. "/Expired"), expiryValue, function(result)
                if result and result.ok then
                    overlay:Destroy()
                    notify("📅 Expiry Set", info.Username .. ": " .. tostring(expiryValue or "Lifetime"), 3)
                    refreshCallback()
                else
                    notify("❌ Gagal", "Coba lagi", 3)
                end
            end)
        end)
    end
    
    function showBanConfirmModal(userId, info, refreshCallback)
        local overlay = Instance.new("Frame", gui)
        overlay.Size = UDim2.new(1, 0, 1, 0)
        overlay.BackgroundColor3 = Color3.new(0, 0, 0)
        overlay.BackgroundTransparency = 0.5
        overlay.BorderSizePixel = 0
        overlay.ZIndex = 500
        
        local modal = Instance.new("Frame", overlay)
        modal.Size = UDim2.new(0, 300, 0, 260)
        modal.Position = UDim2.new(0.5, -150, 0.5, -130)
        modal.BackgroundColor3 = Config.Colors.Card
        modal.BorderSizePixel = 0
        modal.ZIndex = 501
        Utils.corner(modal, Config.Sizes.Radius)
        Utils.stroke(modal, Config.Colors.Danger, 1)
        
        local closeX = Instance.new("TextButton", modal)
        closeX.Size = UDim2.new(0, 22, 0, 22)
        closeX.Position = UDim2.new(1, -28, 0, 8)
        closeX.BackgroundColor3 = Config.Colors.Danger
        closeX.Text = "✕"
        closeX.TextColor3 = Config.Colors.Text
        closeX.Font = Config.Fonts.Title
        closeX.TextSize = 11
        closeX.BorderSizePixel = 0
        closeX.ZIndex = 503
        Utils.corner(closeX, 5)
        closeX.MouseButton1Click:Connect(function() overlay:Destroy() end)
        
        local t = Instance.new("TextLabel", modal)
        t.Size = UDim2.new(1, -60, 0, 22)
        t.Position = UDim2.new(0, 10, 0, 8)
        t.BackgroundTransparency = 1
        t.Font = Config.Fonts.Title
        t.Text = "🔨 BAN USER"
        t.TextColor3 = Config.Colors.Danger
        t.TextSize = 11
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.ZIndex = 502
        
        local u = Instance.new("TextLabel", modal)
        u.Size = UDim2.new(1, -20, 0, 14)
        u.Position = UDim2.new(0, 10, 0, 30)
        u.BackgroundTransparency = 1
        u.Font = Config.Fonts.Mono
        u.Text = info.Username or userId
        u.TextColor3 = Config.Colors.Muted
        u.TextSize = 9
        u.TextXAlignment = Enum.TextXAlignment.Left
        u.ZIndex = 502
        
        local reasonLbl = Instance.new("TextLabel", modal)
        reasonLbl.Size = UDim2.new(1, -20, 0, 14)
        reasonLbl.Position = UDim2.new(0, 10, 0, 50)
        reasonLbl.BackgroundTransparency = 1
        reasonLbl.Font = Config.Fonts.Title
        reasonLbl.Text = "📝 Alasan:"
        reasonLbl.TextColor3 = Config.Colors.Text
        reasonLbl.TextSize = 9
        reasonLbl.TextXAlignment = Enum.TextXAlignment.Left
        reasonLbl.ZIndex = 502
        
        local reasonInput = Instance.new("TextBox", modal)
        reasonInput.Size = UDim2.new(1, -20, 0, 22)
        reasonInput.Position = UDim2.new(0, 10, 0, 66)
        reasonInput.BackgroundColor3 = Config.Colors.Base
        reasonInput.BorderSizePixel = 0
        reasonInput.PlaceholderText = "Alasan ban..."
        reasonInput.PlaceholderColor3 = Config.Colors.Muted
        reasonInput.Text = ""
        reasonInput.TextColor3 = Config.Colors.Text
        reasonInput.Font = Config.Fonts.Body
        reasonInput.TextSize = 10
        reasonInput.ClearTextOnFocus = false
        reasonInput.ZIndex = 502
        Utils.corner(reasonInput, Config.Sizes.RadiusSmall)
        
        local durLbl = Instance.new("TextLabel", modal)
        durLbl.Size = UDim2.new(1, -20, 0, 14)
        durLbl.Position = UDim2.new(0, 10, 0, 94)
        durLbl.BackgroundTransparency = 1
        durLbl.Font = Config.Fonts.Title
        durLbl.Text = "⏱️ Durasi:"
        durLbl.TextColor3 = Config.Colors.Text
        durLbl.TextSize = 9
        durLbl.TextXAlignment = Enum.TextXAlignment.Left
        durLbl.ZIndex = 502
        
        local durFrame = Instance.new("Frame", modal)
        durFrame.Size = UDim2.new(1, -20, 0, 78)
        durFrame.Position = UDim2.new(0, 10, 0, 110)
        durFrame.BackgroundTransparency = 1
        durFrame.ZIndex = 502
        
        local picker = modules.DurationPicker.new(durFrame, {}, Config, Utils, nil)
        
        local okBtn = Instance.new("TextButton", modal)
        okBtn.Size = UDim2.new(0.5, -15, 0, 28)
        okBtn.Position = UDim2.new(0, 10, 1, -38)
        okBtn.BackgroundColor3 = Config.Colors.Danger
        okBtn.Text = "🔨 BAN"
        okBtn.TextColor3 = Config.Colors.Text
        okBtn.Font = Config.Fonts.Title
        okBtn.TextSize = 10
        okBtn.BorderSizePixel = 0
        okBtn.ZIndex = 502
        Utils.corner(okBtn, Config.Sizes.RadiusSmall)
        
        local cancelBtn = Instance.new("TextButton", modal)
        cancelBtn.Size = UDim2.new(0.5, -15, 0, 28)
        cancelBtn.Position = UDim2.new(0.5, 5, 1, -38)
        cancelBtn.BackgroundColor3 = Config.Colors.Card
        cancelBtn.Text = "❌ BATAL"
        cancelBtn.TextColor3 = Config.Colors.Text
        cancelBtn.Font = Config.Fonts.Title
        cancelBtn.TextSize = 10
        cancelBtn.BorderSizePixel = 0
        cancelBtn.ZIndex = 502
        Utils.corner(cancelBtn, Config.Sizes.RadiusSmall)
        
        cancelBtn.MouseButton1Click:Connect(function()
            overlay:Destroy()
        end)
        
        okBtn.MouseButton1Click:Connect(function()
            local durData = picker.GetValue()
            local expiresAt = nil
            local durationStr = "permanent"
            
            if durData.unit ~= "lifetime" and durData.amount > 0 then
                local units = {
                    menit = 60, jam = 3600, hari = 86400,
                    bulan = 2592000, tahun = 31536000,
                }
                expiresAt = os.time() + (durData.amount * units[durData.unit])
                durationStr = durData.amount .. " " .. durData.unit
            end
            
            local banData = {
                banned = true,
                Reason = reasonInput.Text ~= "" and reasonInput.Text or "Banned by admin",
                Duration = durationStr,
                Timestamp = os.time(),
                ExpiresAt = expiresAt,
            }
            
            apiCall("PUT", "/put?path=" .. HttpService:UrlEncode("/Banned/" .. userId), banData, function(result)
                if result and result.ok then
                    apiCall("PUT", "/put?path=" .. HttpService:UrlEncode("/Whitelist/" .. userId), nil, function()
                        overlay:Destroy()
                        notify("🔨 Banned", info.Username or userId, 3)
                        refreshCallback()
                    end)
                end
            end)
        end)
    end
    
    function showDeleteConfirmModal(userId, info, refreshCallback)
        local overlay = Instance.new("Frame", gui)
        overlay.Size = UDim2.new(1, 0, 1, 0)
        overlay.BackgroundColor3 = Color3.new(0, 0, 0)
        overlay.BackgroundTransparency = 0.5
        overlay.BorderSizePixel = 0
        overlay.ZIndex = 500
        
        local modal = Instance.new("Frame", overlay)
        modal.Size = UDim2.new(0, 260, 0, 160)
        modal.Position = UDim2.new(0.5, -130, 0.5, -80)
        modal.BackgroundColor3 = Config.Colors.Card
        modal.BorderSizePixel = 0
        modal.ZIndex = 501
        Utils.corner(modal, Config.Sizes.Radius)
        Utils.stroke(modal, Config.Colors.Danger, 1)
        
        local closeX = Instance.new("TextButton", modal)
        closeX.Size = UDim2.new(0, 22, 0, 22)
        closeX.Position = UDim2.new(1, -28, 0, 8)
        closeX.BackgroundColor3 = Config.Colors.Danger
        closeX.Text = "✕"
        closeX.TextColor3 = Config.Colors.Text
        closeX.Font = Config.Fonts.Title
        closeX.TextSize = 11
        closeX.BorderSizePixel = 0
        closeX.ZIndex = 503
        Utils.corner(closeX, 5)
        closeX.MouseButton1Click:Connect(function() overlay:Destroy() end)
        
        local t = Instance.new("TextLabel", modal)
        t.Size = UDim2.new(1, -60, 0, 22)
        t.Position = UDim2.new(0, 10, 0, 10)
        t.BackgroundTransparency = 1
        t.Font = Config.Fonts.Title
        t.Text = "🗑️ HAPUS USER?"
        t.TextColor3 = Config.Colors.Danger
        t.TextSize = 12
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.ZIndex = 502
        
        local m = Instance.new("TextLabel", modal)
        m.Size = UDim2.new(1, -20, 0, 50)
        m.Position = UDim2.new(0, 10, 0, 38)
        m.BackgroundTransparency = 1
        m.Font = Config.Fonts.Body
        m.Text = "Yakin hapus " .. (info.Username or userId) .. "?"
        m.TextColor3 = Config.Colors.Text
        m.TextSize = 10
        m.TextWrapped = true
        m.TextXAlignment = Enum.TextXAlignment.Left
        m.ZIndex = 502
        
        local okBtn = Instance.new("TextButton", modal)
        okBtn.Size = UDim2.new(0.5, -15, 0, 28)
        okBtn.Position = UDim2.new(0, 10, 1, -38)
        okBtn.BackgroundColor3 = Config.Colors.Danger
        okBtn.Text = "🗑️ HAPUS"
        okBtn.TextColor3 = Config.Colors.Text
        okBtn.Font = Config.Fonts.Title
        okBtn.TextSize = 10
        okBtn.BorderSizePixel = 0
        okBtn.ZIndex = 502
        Utils.corner(okBtn, Config.Sizes.RadiusSmall)
        
        local cancelBtn = Instance.new("TextButton", modal)
        cancelBtn.Size = UDim2.new(0.5, -15, 0, 28)
        cancelBtn.Position = UDim2.new(0.5, 5, 1, -38)
        cancelBtn.BackgroundColor3 = Config.Colors.Card
        cancelBtn.Text = "❌ BATAL"
        cancelBtn.TextColor3 = Config.Colors.Text
        cancelBtn.Font = Config.Fonts.Title
        cancelBtn.TextSize = 10
        cancelBtn.BorderSizePixel = 0
        cancelBtn.ZIndex = 502
        Utils.corner(cancelBtn, Config.Sizes.RadiusSmall)
        
        cancelBtn.MouseButton1Click:Connect(function()
            overlay:Destroy()
        end)
        
        okBtn.MouseButton1Click:Connect(function()
            apiCall("PUT", "/put?path=" .. HttpService:UrlEncode("/Whitelist/" .. userId), nil, function(result)
                if result and result.ok then
                    overlay:Destroy()
                    notify("🗑️ Deleted", info.Username or userId, 3)
                    refreshCallback()
                end
            end)
        end)
    end
    
    local reqPage = tabPages["req"]
    local reqScroll = Instance.new("ScrollingFrame", reqPage)
    reqScroll.Size = UDim2.new(1, -16, 1, -16)
    reqScroll.Position = UDim2.new(0, 8, 0, 8)
    reqScroll.BackgroundColor3 = Config.Colors.Card
    reqScroll.BorderSizePixel = 0
    reqScroll.ScrollBarThickness = 4
    reqScroll.ScrollBarImageColor3 = Config.Colors.Accent
    reqScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    reqScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Utils.corner(reqScroll, Config.Sizes.RadiusSmall)
    
    local reqPad = Instance.new("UIPadding", reqScroll)
    reqPad.PaddingTop = UDim.new(0, 8)
    reqPad.PaddingBottom = UDim.new(0, 8)
    reqPad.PaddingLeft = UDim.new(0, 8)
    reqPad.PaddingRight = UDim.new(0, 8)
    
    local reqLayout = Instance.new("UIListLayout", reqScroll)
    reqLayout.Padding = UDim.new(0, 6)
    
    local function renderReq()
        makeClearScroll(reqScroll)
        apiCall("GET", "/get?path=" .. HttpService:UrlEncode("/Requests"), nil, function(data)
            if not data then
                notify("❌ Error", "Gagal load request", 3)
                return
            end
            
            local count = 0
            for reqId, info in pairs(data) do
                if type(info) == "table" and string.lower(info.Status or "") == "pending" then
                    count = count + 1
                    
                    local card = Instance.new("Frame", reqScroll)
                    card.Size = UDim2.new(1, 0, 0, 85)
                    card.BackgroundColor3 = Config.Colors.Base
                    card.BorderSizePixel = 0
                    Utils.corner(card, Config.Sizes.RadiusSmall)
                    
                    local avatar = Instance.new("ImageLabel", card)
                    avatar.Size = UDim2.new(0, 40, 0, 40)
                    avatar.Position = UDim2.new(0, 8, 0, 8)
                    avatar.BackgroundColor3 = Config.Colors.Card
                    avatar.BorderSizePixel = 0
                    avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(info.UserId or reqId) .. "&w=150&h=150"
                    Utils.corner(avatar, 999)
                    
                    local nameLbl = Instance.new("TextLabel", card)
                    nameLbl.Size = UDim2.new(1, -70, 0, 18)
                    nameLbl.Position = UDim2.new(0, 56, 0, 6)
                    nameLbl.BackgroundTransparency = 1
                    nameLbl.Font = Config.Fonts.Title
                    nameLbl.Text = "👤 " .. (info.Username or reqId)
                    nameLbl.TextColor3 = Config.Colors.Text
                    nameLbl.TextSize = 10
                    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
                    
                    local idLbl = Instance.new("TextLabel", card)
                    idLbl.Size = UDim2.new(1, -70, 0, 12)
                    idLbl.Position = UDim2.new(0, 56, 0, 24)
                    idLbl.BackgroundTransparency = 1
                    idLbl.Font = Config.Fonts.Mono
                    idLbl.Text = "ID: " .. (info.UserId or reqId) .. " • " .. (info.DateRequest or "?")
                    idLbl.TextColor3 = Config.Colors.Muted
                    idLbl.TextSize = 8
                    idLbl.TextXAlignment = Enum.TextXAlignment.Left
                    
                    local btnRow = Instance.new("Frame", card)
                    btnRow.Size = UDim2.new(1, -16, 0, 26)
                    btnRow.Position = UDim2.new(0, 8, 1, -32)
                    btnRow.BackgroundTransparency = 1
                    
                    local bl = Instance.new("UIListLayout", btnRow)
                    bl.FillDirection = Enum.FillDirection.Horizontal
                    bl.Padding = UDim.new(0, 6)
                    
                    local approveBtn = Instance.new("TextButton", btnRow)
                    approveBtn.Size = UDim2.new(0.5, -3, 1, 0)
                    approveBtn.BackgroundColor3 = Color3.fromRGB(20, 100, 40)
                    approveBtn.Text = "✅ APPROVE"
                    approveBtn.TextColor3 = Config.Colors.Text
                    approveBtn.Font = Config.Fonts.Title
                    approveBtn.TextSize = 9
                    approveBtn.BorderSizePixel = 0
                    Utils.corner(approveBtn, Config.Sizes.RadiusSmall)
                    
                    approveBtn.MouseButton1Click:Connect(function()
                        local targetId = tostring(info.UserId or reqId)
                        local wlData = {
                            Username = info.Username or "unknown",
                            UserId = targetId,
                            Role = "user",
                            Status = "ACTIVE",
                            Expired = nil,
                            Source = "request-approve",
                            ApprovedBy = LocalPlayer.Name,
                            ApprovedAt = os.time(),
                        }
                        
                        apiCall("PUT", "/put?path=" .. HttpService:UrlEncode("/Whitelist/" .. targetId), wlData, function(r1)
                            if r1 and r1.ok then
                                apiCall("PUT", "/put?path=" .. HttpService:UrlEncode("/Requests/" .. reqId .. "/Status"), "approved", function()
                                    notify("✅ Approved", info.Username, 3)
                                    renderReq()
                                end)
                            end
                        end)
                    end)
                    
                    local rejectBtn = Instance.new("TextButton", btnRow)
                    rejectBtn.Size = UDim2.new(0.5, -3, 1, 0)
                    rejectBtn.BackgroundColor3 = Config.Colors.Danger
                    rejectBtn.Text = "❌ REJECT"
                    rejectBtn.TextColor3 = Config.Colors.Text
                    rejectBtn.Font = Config.Fonts.Title
                    rejectBtn.TextSize = 9
                    rejectBtn.BorderSizePixel = 0
                    Utils.corner(rejectBtn, Config.Sizes.RadiusSmall)
                    
                    rejectBtn.MouseButton1Click:Connect(function()
                        apiCall("PUT", "/put?path=" .. HttpService:UrlEncode("/Requests/" .. reqId .. "/Status"), "rejected", function()
                            notify("❌ Rejected", info.Username, 3)
                            renderReq()
                        end)
                    end)
                end
            end
            
            if count == 0 then
                local empty = Instance.new("TextLabel", reqScroll)
                empty.Size = UDim2.new(1, 0, 0, 40)
                empty.BackgroundTransparency = 1
                empty.Font = Config.Fonts.Body
                empty.Text = "Gak ada request pending"
                empty.TextColor3 = Config.Colors.Muted
                empty.TextSize = 10
            end
        end)
    end
    
    local banPage = tabPages["ban"]
    
    local banFormCard = Instance.new("Frame", banPage)
    banFormCard.Size = UDim2.new(1, -16, 0, 110)
    banFormCard.Position = UDim2.new(0, 8, 0, 8)
    banFormCard.BackgroundColor3 = Config.Colors.Card
    banFormCard.BorderSizePixel = 0
    Utils.corner(banFormCard, Config.Sizes.RadiusSmall)
    
    local formTitle = Instance.new("TextLabel", banFormCard)
    formTitle.Size = UDim2.new(1, -12, 0, 16)
    formTitle.Position = UDim2.new(0, 6, 0, 4)
    formTitle.BackgroundTransparency = 1
    formTitle.Font = Config.Fonts.Title
    formTitle.Text = "🔨 BAN MANUAL"
    formTitle.TextColor3 = Config.Colors.Danger
    formTitle.TextSize = 10
    formTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    local targetInput = Instance.new("TextBox", banFormCard)
    targetInput.Size = UDim2.new(0.6, -6, 0, 24)
    targetInput.Position = UDim2.new(0, 6, 0, 22)
    targetInput.BackgroundColor3 = Config.Colors.Base
    targetInput.BorderSizePixel = 0
    targetInput.PlaceholderText = "UserId / Username"
    targetInput.PlaceholderColor3 = Config.Colors.Muted
    targetInput.Text = ""
    targetInput.TextColor3 = Config.Colors.Text
    targetInput.Font = Config.Fonts.Mono
    targetInput.TextSize = 10
    targetInput.ClearTextOnFocus = false
    targetInput.ZIndex = 15
    Utils.corner(targetInput, Config.Sizes.RadiusSmall)
    Utils.stroke(targetInput, Config.Colors.Border, 1)
    
    local banDurationBtn = Instance.new("TextButton", banFormCard)
    banDurationBtn.Size = UDim2.new(0.4, -6, 0, 24)
    banDurationBtn.Position = UDim2.new(0.6, 0, 0, 22)
    banDurationBtn.BackgroundColor3 = Config.Colors.Base
    banDurationBtn.Text = "♾️ Permanent ▾"
    banDurationBtn.TextColor3 = Config.Colors.Text
    banDurationBtn.Font = Config.Fonts.Body
    banDurationBtn.TextSize = 9
    banDurationBtn.BorderSizePixel = 0
    banDurationBtn.AutoButtonColor = false
    banDurationBtn.ZIndex = 15
    Utils.corner(banDurationBtn, Config.Sizes.RadiusSmall)
    Utils.stroke(banDurationBtn, Config.Colors.Border, 1)
    
    local reasonInput = Instance.new("TextBox", banFormCard)
    reasonInput.Size = UDim2.new(1, -12, 0, 22)
    reasonInput.Position = UDim2.new(0, 6, 0, 50)
    reasonInput.BackgroundColor3 = Config.Colors.Base
    reasonInput.BorderSizePixel = 0
    reasonInput.PlaceholderText = "Reason (opsional)"
    reasonInput.PlaceholderColor3 = Config.Colors.Muted
    reasonInput.Text = ""
    reasonInput.TextColor3 = Config.Colors.Text
    reasonInput.Font = Config.Fonts.Body
    reasonInput.TextSize = 10
    reasonInput.ClearTextOnFocus = false
    reasonInput.ZIndex = 15
    Utils.corner(reasonInput, Config.Sizes.RadiusSmall)
    Utils.stroke(reasonInput, Config.Colors.Border, 1)
    
    local banSubmitBtn = Instance.new("TextButton", banFormCard)
    banSubmitBtn.Size = UDim2.new(1, -12, 0, 26)
    banSubmitBtn.Position = UDim2.new(0, 6, 0, 78)
    banSubmitBtn.BackgroundColor3 = Config.Colors.Danger
    banSubmitBtn.Text = "🔨 BAN USER"
    banSubmitBtn.TextColor3 = Config.Colors.Text
    banSubmitBtn.Font = Config.Fonts.Title
    banSubmitBtn.TextSize = 10
    banSubmitBtn.BorderSizePixel = 0
    banSubmitBtn.ZIndex = 15
    Utils.corner(banSubmitBtn, Config.Sizes.RadiusSmall)
    
    local selectedBanDuration = { value = "permanent", label = "♾️ Permanent" }
    
    banDurationBtn.MouseButton1Click:Connect(function()
        local overlay = Instance.new("Frame", gui)
        overlay.Size = UDim2.new(1, 0, 1, 0)
        overlay.BackgroundColor3 = Color3.new(0, 0, 0)
        overlay.BackgroundTransparency = 0.5
        overlay.BorderSizePixel = 0
        overlay.ZIndex = 700
        
        local modal = Instance.new("Frame", overlay)
        modal.Size = UDim2.new(0, 240, 0, 250)
        modal.Position = UDim2.new(0.5, -120, 0.5, -125)
        modal.BackgroundColor3 = Config.Colors.Card
        modal.BorderSizePixel = 0
        modal.ZIndex = 701
        Utils.corner(modal, Config.Sizes.Radius)
        Utils.stroke(modal, Config.Colors.Danger, 1)
        
        local closeX = Instance.new("TextButton", modal)
        closeX.Size = UDim2.new(0, 22, 0, 22)
        closeX.Position = UDim2.new(1, -28, 0, 8)
        closeX.BackgroundColor3 = Config.Colors.Danger
        closeX.Text = "✕"
        closeX.TextColor3 = Config.Colors.Text
        closeX.Font = Config.Fonts.Title
        closeX.TextSize = 11
        closeX.BorderSizePixel = 0
        closeX.ZIndex = 703
        Utils.corner(closeX, 5)
        closeX.MouseButton1Click:Connect(function() overlay:Destroy() end)
        
        local t = Instance.new("TextLabel", modal)
        t.Size = UDim2.new(1, -60, 0, 22)
        t.Position = UDim2.new(0, 10, 0, 8)
        t.BackgroundTransparency = 1
        t.Font = Config.Fonts.Title
        t.Text = "⏱️ PILIH DURASI"
        t.TextColor3 = Config.Colors.Danger
        t.TextSize = 11
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.ZIndex = 702
        
        local options = {
            { value = "permanent", label = "♾️ Permanent" },
            { value = "1 jam", label = "⏱️ 1 Jam" },
            { value = "24 jam", label = "⏱️ 24 Jam" },
            { value = "7 hari", label = "📅 7 Hari" },
            { value = "30 hari", label = "📅 30 Hari" },
            { value = "90 hari", label = "📅 90 Hari" },
        }
        
        local y = 36
        for _, opt in ipairs(options) do
            local b = Instance.new("TextButton", modal)
            b.Size = UDim2.new(1, -20, 0, 28)
            b.Position = UDim2.new(0, 10, 0, y)
            b.BackgroundColor3 = (selectedBanDuration.value == opt.value) and Config.Colors.Danger or Config.Colors.Base
            b.Text = opt.label
            b.TextColor3 = Config.Colors.Text
            b.Font = Config.Fonts.Title
            b.TextSize = 10
            b.BorderSizePixel = 0
            b.ZIndex = 702
            Utils.corner(b, Config.Sizes.RadiusSmall)
            
            b.MouseButton1Click:Connect(function()
                selectedBanDuration.value = opt.value
                selectedBanDuration.label = opt.label
                banDurationBtn.Text = opt.label .. " ▾"
                overlay:Destroy()
            end)
            
            y = y + 32
        end
    end)
    
    banSubmitBtn.MouseButton1Click:Connect(function()
        local target = targetInput.Text:gsub("%s", "")
        if target == "" then
            notify("⚠️ Warning", "Isi UserId/Username", 3)
            return
        end
        
        notify("⏳ Loading", "Mencari user...", 2)
        
        lookupUserId(target, function(foundUserId)
            if not foundUserId then
                notify("❌ Not Found", "User gak ketemu di WL", 3)
                return
            end
            
            local banData = {
                banned = true,
                Reason = reasonInput.Text ~= "" and reasonInput.Text or "Banned by admin",
                Duration = selectedBanDuration.value,
                Timestamp = os.time(),
            }
            
            if selectedBanDuration.value ~= "permanent" then
                local durations = {
                    ["1 jam"] = 3600,
                    ["24 jam"] = 86400,
                    ["7 hari"] = 604800,
                    ["30 hari"] = 2592000,
                    ["90 hari"] = 7776000,
                }
                local sec = durations[selectedBanDuration.value]
                if sec then
                    banData.ExpiresAt = os.time() + sec
                end
            end
            
            apiCall("PUT", "/put?path=" .. HttpService:UrlEncode("/Banned/" .. foundUserId), banData, function(r1)
                if r1 and r1.ok then
                    apiCall("PUT", "/put?path=" .. HttpService:UrlEncode("/Whitelist/" .. foundUserId), nil, function()
                        notify("🔨 Banned", target .. " (" .. foundUserId .. ")", 3)
                        targetInput.Text = ""
                        reasonInput.Text = ""
                        renderBan()
                    end)
                else
                    notify("❌ Gagal", "Coba lagi", 3)
                end
            end)
        end)
    end)
    
    local banScroll = Instance.new("ScrollingFrame", banPage)
    banScroll.Size = UDim2.new(1, -16, 1, -126)
    banScroll.Position = UDim2.new(0, 8, 0, 126)
    banScroll.BackgroundColor3 = Config.Colors.Card
    banScroll.BorderSizePixel = 0
    banScroll.ScrollBarThickness = 4
    banScroll.ScrollBarImageColor3 = Config.Colors.Accent
    banScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    banScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Utils.corner(banScroll, Config.Sizes.RadiusSmall)
    
    local banPad = Instance.new("UIPadding", banScroll)
    banPad.PaddingTop = UDim.new(0, 8)
    banPad.PaddingBottom = UDim.new(0, 8)
    banPad.PaddingLeft = UDim.new(0, 8)
    banPad.PaddingRight = UDim.new(0, 8)
    
    local banLayout = Instance.new("UIListLayout", banScroll)
    banLayout.Padding = UDim.new(0, 6)
    
    local function renderBan()
        makeClearScroll(banScroll)
        apiCall("GET", "/get?path=" .. HttpService:UrlEncode("/Banned"), nil, function(data)
            if not data then
                local empty = Instance.new("TextLabel", banScroll)
                empty.Size = UDim2.new(1, 0, 0, 40)
                empty.BackgroundTransparency = 1
                empty.Font = Config.Fonts.Body
                empty.Text = "Gak ada user di-ban"
                empty.TextColor3 = Config.Colors.Muted
                empty.TextSize = 10
                return
            end
            
            local entries = {}
            for userId, val in pairs(data) do
                table.insert(entries, { userId = userId, val = val })
            end
            
            table.sort(entries, function(a, b)
                local aTime = type(a.val) == "table" and (tonumber(a.val.Timestamp) or 0) or 0
                local bTime = type(b.val) == "table" and (tonumber(b.val.Timestamp) or 0) or 0
                return aTime > bTime
            end)
            
            if #entries == 0 then
                local empty = Instance.new("TextLabel", banScroll)
                empty.Size = UDim2.new(1, 0, 0, 40)
                empty.BackgroundTransparency = 1
                empty.Font = Config.Fonts.Body
                empty.Text = "Gak ada user di-ban"
                empty.TextColor3 = Config.Colors.Muted
                empty.TextSize = 10
                return
            end
            
            for _, entry in ipairs(entries) do
                local userId = entry.userId
                local val = entry.val
                
                local card = Instance.new("Frame", banScroll)
                card.Size = UDim2.new(1, 0, 0, 85)
                card.BackgroundColor3 = Color3.fromRGB(30, 15, 15)
                card.BorderSizePixel = 0
                Utils.corner(card, Config.Sizes.RadiusSmall)
                
                local s = Instance.new("UIStroke", card)
                s.Color = Config.Colors.Danger
                s.Thickness = 1
                
                local avatar = Instance.new("ImageLabel", card)
                avatar.Size = UDim2.new(0, 40, 0, 40)
                avatar.Position = UDim2.new(0, 8, 0, 8)
                avatar.BackgroundColor3 = Config.Colors.Card
                avatar.BorderSizePixel = 0
                avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. userId .. "&w=150&h=150"
                Utils.corner(avatar, 999)
                
                local n = Instance.new("TextLabel", card)
                n.Size = UDim2.new(1, -70, 0, 18)
                n.Position = UDim2.new(0, 56, 0, 6)
                n.BackgroundTransparency = 1
                n.Font = Config.Fonts.Title
                n.Text = "🚫 " .. tostring(userId)
                n.TextColor3 = Config.Colors.Danger
                n.TextSize = 10
                n.TextXAlignment = Enum.TextXAlignment.Left
                
                local reason = "?"
                local duration = "permanent"
                local dateStr = "?"
                
                if type(val) == "table" then
                    reason = val.Reason or val.reason or "?"
                    duration = val.Duration or val.duration or "permanent"
                    if val.Timestamp then
                        dateStr = os.date("%d/%m/%y %H:%M", tonumber(val.Timestamp))
                    end
                elseif val == true then
                    reason = "Banned (legacy)"
                end
                
                local r = Instance.new("TextLabel", card)
                r.Size = UDim2.new(1, -70, 0, 12)
                r.Position = UDim2.new(0, 56, 0, 24)
                r.BackgroundTransparency = 1
                r.Font = Config.Fonts.Body
                r.Text = "📝 " .. tostring(reason)
                r.TextColor3 = Config.Colors.Text
                r.TextSize = 9
                r.TextXAlignment = Enum.TextXAlignment.Left
                
                local meta = Instance.new("TextLabel", card)
                meta.Size = UDim2.new(1, -70, 0, 12)
                meta.Position = UDim2.new(0, 56, 0, 40)
                meta.BackgroundTransparency = 1
                meta.Font = Config.Fonts.Mono
                meta.Text = "⏱️ " .. tostring(duration) .. " • 📅 " .. dateStr
                meta.TextColor3 = Config.Colors.Muted
                meta.TextSize = 8
                meta.TextXAlignment = Enum.TextXAlignment.Left
                
                local unbanBtn = Instance.new("TextButton", card)
                unbanBtn.Size = UDim2.new(0, 70, 0, 24)
                unbanBtn.Position = UDim2.new(1, -78, 1, -32)
                unbanBtn.BackgroundColor3 = Color3.fromRGB(20, 100, 40)
                unbanBtn.Text = "✅ UNBAN"
                unbanBtn.TextColor3 = Config.Colors.Text
                unbanBtn.Font = Config.Fonts.Title
                unbanBtn.TextSize = 9
                unbanBtn.BorderSizePixel = 0
                Utils.corner(unbanBtn, Config.Sizes.RadiusSmall)
                
                unbanBtn.MouseButton1Click:Connect(function()
                    apiCall("PUT", "/put?path=" .. HttpService:UrlEncode("/Banned/" .. userId), nil, function(result)
                        if result and result.ok then
                            notify("✅ Unbanned", userId, 3)
                            renderBan()
                        end
                    end)
                end)
            end
        end)
    end
    
    local statPage = tabPages["stat"]
    local statScroll = Instance.new("ScrollingFrame", statPage)
    statScroll.Size = UDim2.new(1, -16, 1, -16)
    statScroll.Position = UDim2.new(0, 8, 0, 8)
    statScroll.BackgroundTransparency = 1
    statScroll.BorderSizePixel = 0
    statScroll.ScrollBarThickness = 4
    statScroll.ScrollBarImageColor3 = Config.Colors.Accent
    statScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    statScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    
    local statLayout = Instance.new("UIListLayout", statScroll)
    statLayout.Padding = UDim.new(0, 6)
    
    local function renderStat()
        makeClearScroll(statScroll)
        
        local function addStat(label, value, color)
            local card = Instance.new("Frame", statScroll)
            card.Size = UDim2.new(1, 0, 0, 32)
            card.BackgroundColor3 = Config.Colors.Card
            card.BorderSizePixel = 0
            Utils.corner(card, Config.Sizes.RadiusSmall)
            
            local l = Instance.new("TextLabel", card)
            l.Size = UDim2.new(0.6, -8, 1, 0)
            l.Position = UDim2.new(0, 8, 0, 0)
            l.BackgroundTransparency = 1
            l.Font = Config.Fonts.Title
            l.Text = label
            l.TextColor3 = Config.Colors.Text
            l.TextSize = 10
            l.TextXAlignment = Enum.TextXAlignment.Left
            
            local v = Instance.new("TextLabel", card)
            v.Size = UDim2.new(0.4, -8, 1, 0)
            v.Position = UDim2.new(0.6, 0, 0, 0)
            v.BackgroundTransparency = 1
            v.Font = Config.Fonts.Black
            v.Text = tostring(value)
            v.TextColor3 = color or Config.Colors.Accent
            v.TextSize = 13
            v.TextXAlignment = Enum.TextXAlignment.Right
        end
        
        apiCall("GET", "/get?path=" .. HttpService:UrlEncode("/Whitelist"), nil, function(wl)
            apiCall("GET", "/get?path=" .. HttpService:UrlEncode("/Banned"), nil, function(ban)
                apiCall("GET", "/get?path=" .. HttpService:UrlEncode("/ActiveUsers"), nil, function(active)
                    wl = wl or {}
                    ban = ban or {}
                    active = active or {}
                    
                    local counts = { owner = 0, admin = 0, vip = 0, user = 0 }
                    local total = 0
                    for _, info in pairs(wl) do
                        total = total + 1
                        local r = string.lower(info.Role or "user")
                        if counts[r] then counts[r] = counts[r] + 1 end
                    end
                    
                    local banCount = 0
                    for _ in pairs(ban) do banCount = banCount + 1 end
                    
                    local now = os.time()
                    local onlineCount = 0
                    for _, info in pairs(active) do
                        if info.LastSeen and (now - info.LastSeen) < 300 then
                            onlineCount = onlineCount + 1
                        end
                    end
                    
                    addStat("📊 Total WL", total, Config.Colors.Success)
                    addStat("👑 Owner", counts.owner, Config.Colors.Owner)
                    addStat("🛡️ Admin", counts.admin, Config.Colors.Admin)
                    addStat("💎 VIP", counts.vip, Config.Colors.VIP)
                    addStat("✅ User", counts.user, Config.Colors.User)
                    addStat("🚫 Banned", banCount, Config.Colors.Danger)
                    addStat("🟢 Online (5m)", onlineCount, Config.Colors.Success)
                end)
            end)
        end)
    end
    
    local logPage = tabPages["log"]
    local logScroll = Instance.new("ScrollingFrame", logPage)
    logScroll.Size = UDim2.new(1, -16, 1, -16)
    logScroll.Position = UDim2.new(0, 8, 0, 8)
    logScroll.BackgroundColor3 = Config.Colors.Card
    logScroll.BorderSizePixel = 0
    logScroll.ScrollBarThickness = 4
    logScroll.ScrollBarImageColor3 = Config.Colors.Accent
    logScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    logScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Utils.corner(logScroll, Config.Sizes.RadiusSmall)
    
    local logPad = Instance.new("UIPadding", logScroll)
    logPad.PaddingTop = UDim.new(0, 8)
    logPad.PaddingBottom = UDim.new(0, 8)
    logPad.PaddingLeft = UDim.new(0, 8)
    logPad.PaddingRight = UDim.new(0, 8)
    
    local logLayout = Instance.new("UIListLayout", logScroll)
    logLayout.Padding = UDim.new(0, 4)
    
    local function renderLog()
        makeClearScroll(logScroll)
        apiCall("GET", "/get?path=" .. HttpService:UrlEncode("/AuditLog"), nil, function(data)
            if not data then
                local empty = Instance.new("TextLabel", logScroll)
                empty.Size = UDim2.new(1, 0, 0, 40)
                empty.BackgroundTransparency = 1
                empty.Font = Config.Fonts.Body
                empty.Text = "Belum ada log"
                empty.TextColor3 = Config.Colors.Muted
                empty.TextSize = 10
                return
            end
            
            local entries = {}
            for k, v in pairs(data) do
                table.insert(entries, { key = k, info = v })
            end
            
            table.sort(entries, function(a, b)
                return (tonumber(a.info.Timestamp) or 0) > (tonumber(b.info.Timestamp) or 0)
            end)
            
            local count = 0
            for _, e in ipairs(entries) do
                count = count + 1
                if count > 100 then break end
                
                local info = e.info
                local card = Instance.new("Frame", logScroll)
                card.Size = UDim2.new(1, 0, 0, 34)
                card.BackgroundColor3 = Config.Colors.Base
                card.BorderSizePixel = 0
                Utils.corner(card, Config.Sizes.RadiusSmall)
                
                local actionColors = {
                    BAN = Config.Colors.Danger,
                    APPROVE = Config.Colors.Success,
                    REJECT = Config.Colors.Warning,
                    DELETE = Config.Colors.Danger,
                    UNBAN = Config.Colors.Success,
                    ROLE_CHANGE = Config.Colors.Admin,
                    KEY_GENERATE = Config.Colors.Accent,
                    KEY_REDEEM = Config.Colors.VIP,
                    KEY_REVOKE = Config.Colors.Danger,
                    AUTO_EXPIRE = Config.Colors.Warning,
                    AUTO_UNBAN = Config.Colors.Success,
                }
                local actionColor = actionColors[info.Action] or Config.Colors.Muted
                
                local a = Instance.new("TextLabel", card)
                a.Size = UDim2.new(0.45, -6, 0, 14)
                a.Position = UDim2.new(0, 6, 0, 3)
                a.BackgroundTransparency = 1
                a.Font = Config.Fonts.Title
                a.Text = tostring(info.Action or "?")
                a.TextColor3 = actionColor
                a.TextSize = 9
                a.TextXAlignment = Enum.TextXAlignment.Left
                
                local d = Instance.new("TextLabel", card)
                d.Size = UDim2.new(0.55, -6, 0, 14)
                d.Position = UDim2.new(0.45, 0, 0, 3)
                d.BackgroundTransparency = 1
                d.Font = Config.Fonts.Mono
                d.Text = tostring(info.Date or "?")
                d.TextColor3 = Config.Colors.Muted
                d.TextSize = 8
                d.TextXAlignment = Enum.TextXAlignment.Right
                
                local det = Instance.new("TextLabel", card)
                det.Size = UDim2.new(1, -12, 0, 12)
                det.Position = UDim2.new(0, 6, 0, 18)
                det.BackgroundTransparency = 1
                det.Font = Config.Fonts.Mono
                det.Text = "→ " .. tostring(info.Target or "?") .. " • " .. tostring(info.By or "?")
                det.TextColor3 = Config.Colors.Muted
                det.TextSize = 8
                det.TextXAlignment = Enum.TextXAlignment.Left
            end
        end)
    end
    
    local devPage = tabPages["dev"]
    local devScroll = Instance.new("ScrollingFrame", devPage)
    devScroll.Size = UDim2.new(1, -16, 1, -16)
    devScroll.Position = UDim2.new(0, 8, 0, 8)
    devScroll.BackgroundColor3 = Config.Colors.Card
    devScroll.BorderSizePixel = 0
    devScroll.ScrollBarThickness = 4
    devScroll.ScrollBarImageColor3 = Config.Colors.Accent
    devScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    devScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Utils.corner(devScroll, Config.Sizes.RadiusSmall)
    
    local devPad = Instance.new("UIPadding", devScroll)
    devPad.PaddingTop = UDim.new(0, 8)
    devPad.PaddingBottom = UDim.new(0, 8)
    devPad.PaddingLeft = UDim.new(0, 8)
    devPad.PaddingRight = UDim.new(0, 8)
    
    local devLayout = Instance.new("UIListLayout", devScroll)
    devLayout.Padding = UDim.new(0, 6)
    
    local function renderDev()
        makeClearScroll(devScroll)
        apiCall("GET", "/get?path=" .. HttpService:UrlEncode("/ActiveUsers"), nil, function(data)
            if not data then
                local empty = Instance.new("TextLabel", devScroll)
                empty.Size = UDim2.new(1, 0, 0, 40)
                empty.BackgroundTransparency = 1
                empty.Font = Config.Fonts.Body
                empty.Text = "Belum ada data device"
                empty.TextColor3 = Config.Colors.Muted
                empty.TextSize = 10
                return
            end
            
            local entries = {}
            for k, v in pairs(data) do
                table.insert(entries, { key = k, info = v })
            end
            
            table.sort(entries, function(a, b)
                return (tonumber(a.info.LastSeen) or 0) > (tonumber(b.info.LastSeen) or 0)
            end)
            
            local now = os.time()
            
            for _, e in ipairs(entries) do
                local info = e.info
                local isOnline = info.LastSeen and (now - info.LastSeen) < 300
                
                local card = Instance.new("Frame", devScroll)
                card.Size = UDim2.new(1, 0, 0, 54)
                card.BackgroundColor3 = isOnline and Color3.fromRGB(20, 40, 20) or Config.Colors.Base
                card.BorderSizePixel = 0
                Utils.corner(card, Config.Sizes.RadiusSmall)
                
                local n = Instance.new("TextLabel", card)
                n.Size = UDim2.new(1, -12, 0, 16)
                n.Position = UDim2.new(0, 6, 0, 4)
                n.BackgroundTransparency = 1
                n.Font = Config.Fonts.Title
                n.Text = (isOnline and "🟢 " or "⚫ ") .. tostring(info.Username or e.key)
                n.TextColor3 = Config.Colors.Text
                n.TextSize = 10
                n.TextXAlignment = Enum.TextXAlignment.Left
                
                local l1 = Instance.new("TextLabel", card)
                l1.Size = UDim2.new(1, -12, 0, 12)
                l1.Position = UDim2.new(0, 6, 0, 22)
                l1.BackgroundTransparency = 1
                l1.Font = Config.Fonts.Mono
                l1.Text = "📱 " .. tostring(info.Device or "?") .. " • 🌏 " .. tostring(info.Locale or "?")
                l1.TextColor3 = Config.Colors.Muted
                l1.TextSize = 8
                l1.TextXAlignment = Enum.TextXAlignment.Left
                
                local l2 = Instance.new("TextLabel", card)
                l2.Size = UDim2.new(1, -12, 0, 12)
                l2.Position = UDim2.new(0, 6, 0, 36)
                l2.BackgroundTransparency = 1
                l2.Font = Config.Fonts.Mono
                l2.Text = "👑 " .. tostring(info.Role or "?") .. " • ⏰ " .. tostring(info.LastSeenStr or "?")
                l2.TextColor3 = Config.Colors.Muted
                l2.TextSize = 8
                l2.TextXAlignment = Enum.TextXAlignment.Left
            end
        end)
    end
    
    local annPage = tabPages["ann"]
    
    local annContainer = Instance.new("Frame", annPage)
    annContainer.Size = UDim2.new(1, -16, 1, -16)
    annContainer.Position = UDim2.new(0, 8, 0, 8)
    annContainer.BackgroundTransparency = 1
    
    local titleLbl = Instance.new("TextLabel", annContainer)
    titleLbl.Size = UDim2.new(1, 0, 0, 18)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Font = Config.Fonts.Title
    titleLbl.Text = "📌 Judul:"
    titleLbl.TextColor3 = Config.Colors.Text
    titleLbl.TextSize = 10
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    
    local titleInput = Instance.new("TextBox", annContainer)
    titleInput.Size = UDim2.new(1, 0, 0, 26)
    titleInput.Position = UDim2.new(0, 0, 0, 22)
    titleInput.BackgroundColor3 = Config.Colors.Card
    titleInput.BorderSizePixel = 0
    titleInput.PlaceholderText = "Contoh: Update v10"
    titleInput.PlaceholderColor3 = Config.Colors.Muted
    titleInput.Text = ""
    titleInput.TextColor3 = Config.Colors.Text
    titleInput.Font = Config.Fonts.Body
    titleInput.TextSize = 10
    titleInput.ClearTextOnFocus = false
    Utils.corner(titleInput, Config.Sizes.RadiusSmall)
    
    local msgLbl = Instance.new("TextLabel", annContainer)
    msgLbl.Size = UDim2.new(1, 0, 0, 18)
    msgLbl.Position = UDim2.new(0, 0, 0, 54)
    msgLbl.BackgroundTransparency = 1
    msgLbl.Font = Config.Fonts.Title
    msgLbl.Text = "📝 Pesan:"
    msgLbl.TextColor3 = Config.Colors.Text
    msgLbl.TextSize = 10
    msgLbl.TextXAlignment = Enum.TextXAlignment.Left
    
    local msgInput = Instance.new("TextBox", annContainer)
    msgInput.Size = UDim2.new(1, 0, 0, 80)
    msgInput.Position = UDim2.new(0, 0, 0, 74)
    msgInput.BackgroundColor3 = Config.Colors.Card
    msgInput.BorderSizePixel = 0
    msgInput.PlaceholderText = "Isi announcement..."
    msgInput.PlaceholderColor3 = Config.Colors.Muted
    msgInput.Text = ""
    msgInput.TextColor3 = Config.Colors.Text
    msgInput.Font = Config.Fonts.Body
    msgInput.TextSize = 10
    msgInput.TextWrapped = true
    msgInput.ClearTextOnFocus = false
    Utils.corner(msgInput, Config.Sizes.RadiusSmall)
    
    local sendBtn = Instance.new("TextButton", annContainer)
    sendBtn.Size = UDim2.new(0.5, -4, 0, 30)
    sendBtn.Position = UDim2.new(0, 0, 0, 162)
    sendBtn.BackgroundColor3 = Color3.fromRGB(20, 100, 40)
    sendBtn.Text = "📢 KIRIM"
    sendBtn.TextColor3 = Config.Colors.Text
    sendBtn.Font = Config.Fonts.Title
    sendBtn.TextSize = 10
    sendBtn.BorderSizePixel = 0
    Utils.corner(sendBtn, Config.Sizes.RadiusSmall)
    
    local clearAnnBtn = Instance.new("TextButton", annContainer)
    clearAnnBtn.Size = UDim2.new(0.5, -4, 0, 30)
    clearAnnBtn.Position = UDim2.new(0.5, 4, 0, 162)
    clearAnnBtn.BackgroundColor3 = Config.Colors.Danger
    clearAnnBtn.Text = "🗑️ HAPUS"
    clearAnnBtn.TextColor3 = Config.Colors.Text
    clearAnnBtn.Font = Config.Fonts.Title
    clearAnnBtn.TextSize = 10
    clearAnnBtn.BorderSizePixel = 0
    Utils.corner(clearAnnBtn, Config.Sizes.RadiusSmall)
    
    sendBtn.MouseButton1Click:Connect(function()
        if titleInput.Text == "" and msgInput.Text == "" then
            notify("⚠️ Warning", "Isi judul atau pesan", 3)
            return
        end
        
        apiCall("PUT", "/put?path=" .. HttpService:UrlEncode("/Announcement"), {
            Title = titleInput.Text,
            Text = msgInput.Text,
            Timestamp = os.time(),
            By = LocalPlayer.Name,
        }, function(result)
            if result and result.ok then
                notify("📢 Sent", "Announcement terkirim", 3)
            end
        end)
    end)
    
    clearAnnBtn.MouseButton1Click:Connect(function()
        apiCall("PUT", "/put?path=" .. HttpService:UrlEncode("/Announcement"), nil, function()
            notify("🗑️ Cleared", "Announcement dihapus", 3)
            titleInput.Text = ""
            msgInput.Text = ""
        end)
    end)
    
    local cfgPage = tabPages["cfg"]
    local cfgScroll = Instance.new("ScrollingFrame", cfgPage)
    cfgScroll.Size = UDim2.new(1, -16, 1, -16)
    cfgScroll.Position = UDim2.new(0, 8, 0, 8)
    cfgScroll.BackgroundTransparency = 1
    cfgScroll.BorderSizePixel = 0
    cfgScroll.ScrollBarThickness = 4
    cfgScroll.ScrollBarImageColor3 = Config.Colors.Accent
    cfgScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    cfgScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    
    local cfgLayout = Instance.new("UIListLayout", cfgScroll)
    cfgLayout.Padding = UDim.new(0, 6)
    
    local function renderCfg()
        makeClearScroll(cfgScroll)
        apiCall("GET", "/get?path=" .. HttpService:UrlEncode("/Config/Maintenance"), nil, function(maint)
            maint = maint or {}
            
            local function addToggle(title, current, callback)
                local card = Instance.new("Frame", cfgScroll)
                card.Size = UDim2.new(1, 0, 0, 38)
                card.BackgroundColor3 = Config.Colors.Card
                card.BorderSizePixel = 0
                Utils.corner(card, Config.Sizes.RadiusSmall)
                
                local t = Instance.new("TextLabel", card)
                t.Size = UDim2.new(0.6, -8, 1, 0)
                t.Position = UDim2.new(0, 8, 0, 0)
                t.BackgroundTransparency = 1
                t.Font = Config.Fonts.Title
                t.Text = title
                t.TextColor3 = Config.Colors.Text
                t.TextSize = 10
                t.TextXAlignment = Enum.TextXAlignment.Left
                
                local b = Instance.new("TextButton", card)
                b.Size = UDim2.new(0.35, -8, 0, 24)
                b.Position = UDim2.new(0.65, 0, 0, 7)
                b.BackgroundColor3 = current and Color3.fromRGB(20, 100, 40) or Config.Colors.Danger
                b.Text = current and "✅ ON" or "❌ OFF"
                b.TextColor3 = Config.Colors.Text
                b.Font = Config.Fonts.Title
                b.TextSize = 10
                b.BorderSizePixel = 0
                Utils.corner(b, Config.Sizes.RadiusSmall)
                
                b.MouseButton1Click:Connect(function()
                    callback(not current)
                end)
            end
            
            addToggle("🔧 Maintenance Mode", maint.Enabled == true, function(newVal)
                apiCall("PUT", "/put?path=" .. HttpService:UrlEncode("/Config/Maintenance/Enabled"), newVal, function()
                    notify("🔧 Updated", "Maintenance: " .. (newVal and "ON" or "OFF"), 3)
                    renderCfg()
                end)
            end)
            
            addToggle("⭐ Allow Owner During Maint", maint.AllowOwner ~= false, function(newVal)
                apiCall("PUT", "/put?path=" .. HttpService:UrlEncode("/Config/Maintenance/AllowOwner"), newVal, function()
                    notify("⭐ Updated", "Allow Owner: " .. (newVal and "ON" or "OFF"), 3)
                    renderCfg()
                end)
            end)
            
            local msgCard = Instance.new("Frame", cfgScroll)
            msgCard.Size = UDim2.new(1, 0, 0, 58)
            msgCard.BackgroundColor3 = Config.Colors.Card
            msgCard.BorderSizePixel = 0
            Utils.corner(msgCard, Config.Sizes.RadiusSmall)
            
            local ml = Instance.new("TextLabel", msgCard)
            ml.Size = UDim2.new(1, -12, 0, 16)
            ml.Position = UDim2.new(0, 6, 0, 4)
            ml.BackgroundTransparency = 1
            ml.Font = Config.Fonts.Title
            ml.Text = "📝 Pesan Maintenance:"
            ml.TextColor3 = Config.Colors.Text
            ml.TextSize = 10
            ml.TextXAlignment = Enum.TextXAlignment.Left
            
            local msgInput = Instance.new("TextBox", msgCard)
            msgInput.Size = UDim2.new(1, -12, 0, 28)
            msgInput.Position = UDim2.new(0, 6, 0, 22)
            msgInput.BackgroundColor3 = Config.Colors.Base
            msgInput.BorderSizePixel = 0
            msgInput.Text = tostring(maint.Message or "Sedang maintenance.")
            msgInput.TextColor3 = Config.Colors.Text
            msgInput.Font = Config.Fonts.Body
            msgInput.TextSize = 10
            msgInput.ClearTextOnFocus = false
            Utils.corner(msgInput, Config.Sizes.RadiusSmall)
            
            msgInput.FocusLost:Connect(function()
                apiCall("PUT", "/put?path=" .. HttpService:UrlEncode("/Config/Maintenance/Message"), msgInput.Text, function()
                    notify("📝 Saved", "Message updated", 2)
                end)
            end)
        end)
    end
    
    local keyPage = tabPages["key"]
    local kmContainer = Instance.new("Frame", keyPage)
    kmContainer.Size = UDim2.new(1, 0, 1, 0)
    kmContainer.BackgroundTransparency = 1
    
    local KM = modules.KeyManager
    KM.new(kmContainer, Config, Utils, {
        OnNotify = notify,
        OnGenerate = function(refreshCallback)
            modules.KeyManagerWindow.showGenerateModalInternal(gui, Config, Utils, modules, notify, refreshCallback)
        end,
        OnEdit = function(keyData, refreshCallback)
            modules.KeyManagerWindow.showEditModalInternal(gui, Config, Utils, modules, notify, keyData, refreshCallback)
        end,
        OnRevoke = function(keyData, refreshCallback)
            modules.KeyManagerWindow.showRevokeConfirmInternal(gui, Config, Utils, modules, notify, keyData, refreshCallback)
        end,
    })
    
    renderWL()
    renderReq()
    renderBan()
    renderStat()
    renderLog()
    renderDev()
    renderCfg()
    
    task.spawn(function()
        while win.Parent do
            task.wait(30)
            if activePage == "wl" then renderWL() end
            if activePage == "req" then renderReq() end
            if activePage == "ban" then renderBan() end
            if activePage == "stat" then renderStat() end
            if activePage == "log" then renderLog() end
            if activePage == "dev" then renderDev() end
        end
    end)
    
    tabButtons["wl"].BackgroundColor3 = Config.Colors.Card
    tabButtons["wl"].TextColor3 = Config.Colors.Accent
    tabPages["wl"].Visible = true
    activePage = "wl"
    
    _G.DV_OpenOwnerPanel = function()
        if gui and gui.Parent then gui:Destroy() end
        OwnerPanel.open(Config, Utils, modules)
    end
    
    return {
        Gui = gui,
    }
end

return OwnerPanel
