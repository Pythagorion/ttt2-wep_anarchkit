if SERVER then
    AddCSLuaFile()

    resource.AddFile("sound/hardiscream.wav")
    resource.AddFile("sound/chrisanarchie.wav")
    resource.AddFile("sound/justdoit.wav")
end

SWEP.Base = "weapon_tttbase"
SWEP.Kind = WEAPON_EXTRA
SWEP.InLoadoutFor = nil

SWEP.CanBuy = {ROLE_DETECTIVE, ROLE_TRAITOR}

SWEP.LimitedStock = true
SWEP.Icon = "vgui/ttt/weapon_anarchkit"

SWEP.EquipMenuData = {
    type = "item_weapon",
    name = "ttt2_anarchkit_name",
    desc = "ttt2_anarchkit_desc"
}

SWEP.Author = "aPythagorion"
SWEP.PrintName = "AnarchKit"
SWEP.Contact = "Neoxult Discord"
SWEP.Instructions = "Left-Click to start the Anarchy."
SWEP.Purpose = "Let the round fall into the hands of anarchy."
SWEP.ViewModelFOV = 82
SWEP.ViewModelFlip = true
SWEP.NoSights = false
SWEP.AllowDrop = false
SWEP.Spawnable = false
SWEP.AdminOnly = false
SWEP.AdminSpawnable = false
SWEP.AutoSpawnable = false

SWEP.Primary.Recoil = 0
SWEP.Primary.Damage = 0
SWEP.Primary.NumShots = -1
SWEP.Primary.Delay = 3
SWEP.Primary.Distance = 100
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

function SWEP:Initialize()
    if CLIENT then
        self:AddHUDHelp("ttt2_anarchkit_helper", true)
    end
end

if SERVER then
    local function ResetAnarchKitFlags()
        //Reset GlobalBoolean to false
        SetGlobalBool("ttt2_anarchkit_has_been_launched", false)
        SetGlobalEntity("ttt2_owner_of_anarchkit", NULL)
    end

    function SWEP:PrimaryAttack()

        -- cache CVars for later purposes
        local AnarchkitExtremeModeStatus = GetConVar("ttt2_anarchkit_extreme_mode"):GetBool()
        local AnarchKitPlayGermanSounds = GetConVar("ttt2_anarchkit_play_german_sounds"):GetBool()
        local AnarchKitSurType = GetConVar("ttt2_anarchkit_surrender_type"):GetInt()
        local AnarchKitSurrenderMsg = GetConVar("ttt2_anarchkit_sur_msg"):GetBool()

        local owner = self:GetOwner()

        -- don't let the user use the item while round isn't active
        if GetRoundState() ~= ROUND_ACTIVE or GetRoundState() == ROUND_PREP or GetRoundState() == ROUND_WAIT or GetRoundState() == ROUND_POST then
            LANG.Msg(owner, "ttt2_anarchkit_round_not_active", nil, MSG_MSTACK_WARN)
            
            return
        end

        local plys = player.GetAll()

        for i = 1, #plys do
            local ply = plys[i]

            -- Kill or Kick all Members of the Owner's team and the owner themselves
            if ply:GetTeam() == owner:GetTeam() then
                if AnarchkitExtremeModeStatus then
                    ply:Kick()
                end

                -- Choose the Kill type as configured
                if AnarchKitSurType == 1 then -- Burn the surrenderers

                else if AnarchKitSurType == 2 then -- let the surrenderers explode
                
                else if AnarchKitSurType == 3 then -- Bury the surrenderers alive
                
                else if AnarchKitSurType == 4 then -- let them fall to death
                
                else if AnarchKitSurType == 5 then -- strip their inventory

                else if AnarchKitSurType == 6 then -- set HP to 1
                
                else -- Just kill them
                    ply:Kill()
                end
            end
        end

        -- cache Global vars for other hooks
        SetGlobalBool("ttt2_anarchkit_has_been_launched", true)
        SetGlobalEntity("ttt2_owner_of_anarchkit", owner)

        -- Send out an EPOP if configured which team and player gave up
        if AnarchKitSurrenderMsg then

        end
    end

    hook.Add("TTTCheckForWin", "ttt2_anarchkit_let_a_team_win", function()
        -- cache Cvars, players, an empty table and global vars for further purposes
        local AnarchKitHyperModeStatus = GetConVar("ttt2_anarchkit_hyper_mode"):GetBool()     
        local AnarchkitSurrendererCanWin = GetConVar("ttt2_anarchkit_surrenderer_can_win"):GetBool()
        local plys = player.GetAll()
        local theoretical_winners = {}
        local owner = GetGlobalEntity("ttt2_owner_of_anarchkit")

        -- if the round shall end and the item has been launched, this block is called
        if AnarchKitHyperModeStatus and GetGlobalBool("ttt2_anarchkit_has_been_launched") then

            for i = 1, #plys do
                local ply = plys[i]

                -- if the owner's team can win aswell, they must be add to the winning pool
                if AnarchkitSurrendererCanWin then
                    if ply:GetTeam() == owner:GetTeam() or ply:GetTeam() ~= owner:GetTeam() then
                        table.insert(theoretical_winners, ply)
                    end
                else -- Otherwise all the other players will be added only
                    if ply:GetTeam() ~= owner:GetTeam() then
                        table.insert(theoretical_winners, ply)
                    end
                end
            end

            -- Choose a random winner and let them win
            local winner = theoretical_winners[math.random(1, #theoretical_winners)]

            return winner:GetTeam()
        end
    end)

    -- cache CurTime
    local nxt_anarch_time = 0

    -- If the surrenderes try to revive after launching the item, they will be killed everytime
    hook.Add("Think", "ttt2_anarchkit_kill_surrenderers", function()
        
        -- cache Global Vars
        local owner = GetGlobalEntity("ttt2_owner_of_anarchkit")
        local AnarchKitLaunched = GetGlobalBool("ttt2_anarchkit_has_been_launched")

        if CurTime() < nxt_anarch_time then return end

        -- check only 4 times a second
        nxt_anarch_time = CurTime() + 0.25

        local plys = player.GetAll()

        for i = 1, #plys do
            local ply = plys[i]

            if ply:GetTeam() == owner:GetTeam() and ply:Alive() and AnarchKitLaunched then
                ply:Kill()
            end
        end
    end)

    hook.Add("TTTEndRound", "ttt2_anarchkit_end_round", function()
        ResetAnarchKitFlags()
    end)

    hook.Add("TTTBeginRound", "ttt2_anarchkit_begin_round", function()
        ResetAnarchKitFlags()
    end)

    hook.Add("TTTPrepareRound", "ttt2_anarchkit_prep_round", function()
        ResetAnarchKitFlags()
    end)
end