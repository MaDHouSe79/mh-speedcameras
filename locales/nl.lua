local Translations = {
    discord = {
        ["title"]    = "%{title}",
        ["driver"]   = "Driver %{driver}",
        ["model"]    = "Model %{model}",
        ["plate"]    = "Plate %{plate}",
        ["speed"]    = "Speed %{speed} %{displaymph}",
        ["maxspeed"] = "Max Speed %{maxspeed}",
        ["radar"]    = "Street %{street}",
        ["fine"]     = "Fine $%{fine}",
        ["vehicle"]  = "Vehicle",

    },
    notify = {
        ["flashed"]  = "You got flashed for driving too fast you crazy boy",
        ["payfine"]  = "You have paid a fine of $%{amount} you crazy boy",
    },
    blip = {
        title1 = "Speed Camera",
        title2 = "Speed Camera %{maxspeed}",
    }
}
Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
