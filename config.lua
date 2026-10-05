local Config = {}

Config.Version = "1.0.0"
Config.Name = "DVLlib"
Config.Author = "DV Exploits"

Config.Colors = {
    Base        = Color3.fromRGB(10, 10, 15),
    Topbar      = Color3.fromRGB(16, 16, 22),
    Tabbar      = Color3.fromRGB(22, 22, 30),
    Card        = Color3.fromRGB(22, 22, 30),
    CardHover   = Color3.fromRGB(30, 30, 40),
    Border      = Color3.fromRGB(42, 42, 53),
    Text        = Color3.fromRGB(230, 230, 230),
    Muted       = Color3.fromRGB(138, 138, 148),
    
    Accent      = Color3.fromRGB(255, 59, 59),
    AccentDim   = Color3.fromRGB(180, 40, 40),
    
    Success     = Color3.fromRGB(59, 255, 136),
    Warning     = Color3.fromRGB(255, 184, 59),
    Danger      = Color3.fromRGB(255, 59, 59),
    
    Owner       = Color3.fromRGB(255, 215, 0),
    Admin       = Color3.fromRGB(100, 180, 255),
    VIP         = Color3.fromRGB(200, 150, 255),
    User        = Color3.fromRGB(150, 255, 180),
}

Config.Fonts = {
    Title   = Enum.Font.GothamBold,
    Body    = Enum.Font.Gotham,
    Mono    = Enum.Font.Code,
    Black   = Enum.Font.GothamBlack,
}

Config.Sizes = {
    TitleSize   = 14,
    BodySize    = 12,
    SmallSize   = 10,
    MonoSize    = 10,
    
    Radius      = 8,
    RadiusSmall = 5,
    
    Padding     = 10,
    GapSmall    = 4,
    Gap         = 8,
    GapLarge    = 16,
    
    TopbarH     = 40,
    TabbarH     = 36,
    ButtonH     = 34,
    InputH      = 28,
    RowH        = 34,
}

return Config
