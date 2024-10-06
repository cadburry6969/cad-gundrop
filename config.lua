Config = {}

-- Inventory Config
Config.Inventory = 'ox_inventory' -- 'qb-inventory', 'ps-inventory', 'lj-inventory', 'ox_inventory'

-- Target Config
Config.Target = 'ox_target' -- 'qb-target', 'ox_target'
Config.TargetIcon = 'fab fa-dropbox'
Config.TargetLabel = 'Open Crate'

-- Police Config
Config.RequiredCops = 0        -- How many cops are required to drop a gun?
Config.PoliceJobs = { "police" } -- All types of police job in server.

-- Other Config
Config.PlaneSpawnDistance = 400.0
Config.TimeUntilDrop = 1 -- How long does it take to drop a gun? (in minutes)
Config.Cooldown = 120      -- in mins

-- Objects and models Config
Config.LoadModels = { "w_am_flare", "p_cargo_chute_s", "ex_prop_adv_case_sm", "cuban800", "s_m_m_pilot_02" } -- Models to pre-load.
Config.FlareName = "weapon_flare"                                                                          -- Name of the flare weapon.
Config.FlareModel = "w_am_flare"                                                                           -- Model of the flare weapon.
Config.PlaneModel = "cuban800"                                                                             -- Model of the plane.
Config.PlanePilotModel = "s_m_m_pilot_02"                                                                  -- Model of the plane pilot.
Config.ParachuteModel = "p_cargo_chute_s"                                                                  -- Model of the parachute.
Config.CrateModel = "ex_prop_adv_case_sm"                                                                  -- Model of the crate.

-- Item Drops Config
Config.ItemDrops = {
    {
        -- { name = 'WEAPON_CARBINERIFLE', amount = 1, metadata = {}},
        { name = 'WEAPON_SMG', amount = 1 },
    },
}

-- Locale Config
Config.Lang = {
    ["contacted_mafia"] = "You Have Contacted With Russian Mafia",
    ["pilot_contact"] = "After few minutes pilot will contact you",
    ["no_cops"] = "Not enough cops",
    ["pilot_dropping_soon"] = "Satellite Response: We are preparing the crate with the plane and will be dropping it soon",
    ["pilot_crashed"] = "The plane has crashed delivery failed",
    ["crate_dropping"] = "Pilot: keep the eye on sky the crate is droping",
    ["item_recieved"] = "You opened the crate and recieved",
    ["cooldown_active"] = "Please wait for sometime before you use again!",
    ["collect_items"] = "Collecting Items"
}
