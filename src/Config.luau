-- Prototype defaults. Unpublished places work without network configuration.
return {
    IncomeInterval = 10,
    BasePayout = 10,
    KioskBonus = 5,
    GuestStayPayments = 3,
    ArrivalDelay = 8,
    ReceptionArrivalDelay = 3,
    StageNames = {"Foundation", "Structure", "Furnish & open"},
    Shop = {
        {Id="Cleaner",Name="Cleaner robot",Price=80,Description="Automatically cleans dirty rooms in 6 seconds"},
        {Id="Turbo",Name="Turbo battery",Price=15,Duration=60,Description="Move 50% faster for 60 seconds"},
        {Id="Foam",Name="Cleaning foam",Price=15,Duration=90,Description="Clean rooms in 1 second for 90 seconds"},
        {Id="Beacon",Name="Guest beacon",Price=25,Duration=90,Description="Shorter arrival gaps for 90 seconds"},
        {Id="Garden",Name="Moon garden",Price=70,Description="Flower beds and +2 tokens per room payout",Bonus=2},
        {Id="Tables",Name="Cafe terrace",Price=90,Description="Outdoor tables and +3 tokens per room payout",Bonus=3},
    },
    Upgrades = {
        {Id = "Room2", Name = "MOON POD", Price = 30, Description = "A second room • twice the capacity"},
        {Id = "Reception", Name = "STAR RECEPTION", Price = 60, Description = "New guests arrive faster"},
        {Id = "Kiosk", Name = "COSMIC SNACKS", Price = 100, Description = "+5 tokens per occupied room / payout"},
        {Id = "Room3", Name = "AURORA SUITE", Price = 180, Description = "A third guest room", RoomX = -35},
        {Id = "Lounge", Name = "STARGAZER LOUNGE", Price = 280, Description = "+5 tokens per occupied room / payout", Bonus = 5},
        {Id = "Observatory", Name = "OBSERVATORY", Price = 420, Description = "+10 tokens per occupied room / payout", Bonus = 10},
    },
}
