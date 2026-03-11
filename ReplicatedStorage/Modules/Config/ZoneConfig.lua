local ZoneConfig = {}

ZoneConfig.Zones = {
    Zone1 = {
        Name = "Rivière Tranquille",
        DisplayName = "Zone 1 — Rivière Tranquille",
        Description = "Eaux calmes, or facile à trouver. Parfait pour apprendre.",
        RequiredLevel = 1,
        AllowedTools = { "Batee", "Tapis" },
        MaxActiveDeposits = 8,
        SpawnInterval = 15,
        IsTutorialZone = true,
        -- Position dans le monde (centre de la zone)
        WorldPosition = Vector3.new(0, 0, -350),
    },
    Zone2 = {
        Name = "Collines Ambrées",
        DisplayName = "Zone 2 — Collines Ambrées",
        Description = "Terrain vallonné, pépites et premiers filons. Détecteur recommandé.",
        RequiredLevel = 2,
        AllowedTools = { "Batee", "Tapis", "Pioche" },
        MaxActiveDeposits = 10,
        SpawnInterval = 20,
        IsTutorialZone = false,
        WorldPosition = Vector3.new(-200, 0, 0),
    },
    Zone3 = {
        Name = "Mine de Crow Creek",
        DisplayName = "Zone 3 — Mine de Crow Creek",
        Description = "Mine souterraine profonde. Riches filons, mais danger !",
        RequiredLevel = 3,
        AllowedTools = { "Pioche" },
        MaxActiveDeposits = 12,
        SpawnInterval = 25,
        IsTutorialZone = false,
        HasBoss = true,
        BossId = "GardienMine",
        WorldPosition = Vector3.new(0, 0, 200),
    },
}

return ZoneConfig
