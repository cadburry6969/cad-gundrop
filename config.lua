Config = {}

-- Core Config
Config.CoreName = 'qb-core'

-- Target Config
Config.TargetName = 'qb-target'
Config.TargetIcon = 'fab fa-dropbox'
Config.TargetLabel = 'Open Crate'

-- Police Config
Config.RequiredCops = 4 -- How many cops are required to drop a gun?
Config.PoliceJobs = {"police"} -- All types of police job in server.

-- Other Config
Config.TimeUntilDrop = 2 -- How long does it take to drop a gun? (in minutes)

-- Objects and models Config
Config.LoadModels = {"w_am_flare", "p_cargo_chute_s", "ex_prop_adv_case_sm", "cuban800", "s_m_m_pilot_02"} -- Models to pre-load.
Config.FlareName = "weapon_flare" -- Name of the flare weapon.
Config.FlareModel = "w_am_flare" -- Model of the flare weapon.
Config.PlaneModel = "cuban800" -- Model of the plane.
Config.PlanePilotModel = "s_m_m_pilot_02" -- Model of the plane pilot.
Config.ParachuteModel = "p_cargo_chute_s" -- Model of the parachute.
Config.CrateModel = "ex_prop_adv_case_sm" -- Model of the crate.

-- Item Drops Config
Config.ItemDrops = {
    ["goldenphone"] = {
        [1] = {name = "WEAPON_CARBINERIFLE", amount = 1},
        [2] = {name = "WEAPON_ADVANCEDRIFLE", amount = 1},    
    },
    ["redphone"] = {
        [1] = {name = "WEAPON_ASSAULTRIFLE", amount = 1},  
    },
    ["greenphone"] = {
        [1] = {name = "WEAPON_SMG", amount = 1},
    },
}

-- Locale Config
Config.Lang = { 
    ["contacted_mafia"] = "You Have Contacted With Russian Mafia",
    ["pilot_contact"] = "After few minutes pilot will contact you",
    ["no_cops"] = "Not enough cops",
    ["pilot_dropping_soon"] = "Pilot: We are preparing the crate with the plane and will be dropping it soon",
    ["pilot_crashed"] = "The plane has crashed delivery failed",
    ["crate_dropping"] = "Pilot: keep the eye on sky the crate is droping",
    ["item_recieved"] = "You opened the crate and recieved",
}