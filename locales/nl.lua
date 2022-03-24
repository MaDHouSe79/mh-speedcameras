local Translations = {
    discord = {
        ["title"]    = "Te hard rijden",
        ["model"]    = "Model %{model}",
        ["plate"]    = "Kenteken %{plate}",
        ["speed"]    = "Snelheid %{speed} %{displaymph}",
        ["maxspeed"] = "Snelheidslimit %{maxspeed} ",
        ["radar"]    = "Straat %{street}",
        ["fine"]     = "Boete €%{fine}",
        ["vehicle"]  = "Voertuig",
    },
    notify = {
        ["flashed"]  = "Je bent geflits om dat je te hard reed mafkees",
        ["payfine"]  = "Je boete is betaald eikel", 
    },
    blip = {
        title1 = "Flitsbaal",
        title2 = "Flitspaal %{maxspeed}",
    }
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})