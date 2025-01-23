HTEventsController = {}
HTEventsController.dataEvents = {}
HTEventsController.attachedEvents = {}

function HTEventsController.OnDataEvent(dataEvent)
    print("HTEventsController" .. tostring(dataEvent.name or "nil"))

    local time = getGametimeTimestamp()
    dataEvent["time"] = time
    table.insert(HTEventsController.dataEvents, dataEvent)

    for _, attachedEvent in pairs(HTEventsController.attachedEvents) do
        attachedEvent(dataEvent)
    end
end

function HTEventsController.Attach(callback)
    table.insert(HTEventsController.attachedEvents, callback)
end

---@param attacker IsoGameCharacter - The character who attacked.
---@param target IsoGameCharacter - The character who was hit by the attack.
---@param weapon HandWeapon - The weapon that was attacked with.
---@param damage number - How much damage the attack did. TODO: what does this actually mean? injuries?
function HTEventsController.OnWeaponHitCharacter(attacker, target, weapon, damage)
    local data = IsoHelper.dumpIsoObject(target)
    local description = "Target:" .. tostring(data['id'])
    description = description .. " IsZombie:" .. tostring(data['is_zombie'])

    local data2 = IsoHelper.dumpIsoObject(attacker)
    description = description .. " Attacker:" .. tostring(data2['id'])
    
    local data3 = IsoHelper.dumpIsoObject(weapon)
    description = description .. " Weapon:" .. tostring(data3['type'])
    
    description = description .. " Damage:" .. tostring(damage)

    local dataEvent = {}
    dataEvent.name = "OnWeaponHitCharacter"
    dataEvent.description = description
    dataEvent.parameters = {}
    dataEvent.parameters["attacker"] = attacker
    dataEvent.parameters["target"] = target
    dataEvent.parameters["weapon"] = weapon
    dataEvent.parameters["damage"] = damage
    HTEventsController.OnDataEvent(dataEvent)
end

---@param attacker IsoGameCharacter - The character attacking the object.
---@param weapon HandWeapon - The weapon the object was attacked with.
---@param object IsoThumpable - The object that was attacked.
function HTEventsController.OnWeaponHitThumpable(attacker, weapon, object)
    local data = IsoHelper.dumpIsoObject(attacker)
    local description = "Attacker:" .. tostring(data['id'])

    local data3 = IsoHelper.dumpIsoObject(weapon)
    description = description .. " Weapon:" .. tostring(data3['type'])

    local dataEvent = {}
    dataEvent.name = "OnWeaponHitThumpable"
    dataEvent.description = description
    dataEvent.parameters = {}
    dataEvent.parameters["attacker"] = attacker
    dataEvent.parameters["weapon"] = weapon
    dataEvent.parameters["object"] = object
    HTEventsController.OnDataEvent(dataEvent)
end


---@param attacker IsoGameCharacter - The character hitting the tree.
---@param weapon HandWeapon - The weapon the tree was hit with.
function HTEventsController.OnWeaponHitTree(attacker, weapon)
    local data = IsoHelper.dumpIsoObject(attacker)
    local description = "Attacker:" .. tostring(data['id'])

    local data3 = IsoHelper.dumpIsoObject(weapon)
    description = description .. " Weapon:" .. tostring(data3['type'])

    local dataEvent = {}
    dataEvent.name = "OnWeaponHitTree"
    dataEvent.description = description
    dataEvent.parameters = {}
    dataEvent.parameters["attacker"] = attacker
    dataEvent.parameters["weapon"] = weapon
    HTEventsController.OnDataEvent(dataEvent)
end


---@param attacker IsoGameCharacter - The character who attacked.
---@param weapon HandWeapon - The weapon the character attacked with.
---@param target IsoMovingObject - The target of the attack.
---@param damage number - The damage of the attack.
function HTEventsController.OnWeaponHitXp(attacker, weapon, target, damage)
    local data = IsoHelper.dumpIsoObject(target)
    local description = "Target:" .. tostring(data['id'])
    description = description .. " IsZombie:" .. tostring(data['is_zombie'])

    local data2 = IsoHelper.dumpIsoObject(attacker)
    description = description .. " Attacker:" .. tostring(data2['id'])

    local data3 = IsoHelper.dumpIsoObject(weapon)
    description = description .. " Weapon:" .. tostring(data3['type'])
    
    description = description .. " Damage:" .. tostring(damage)

    local dataEvent = {}
    dataEvent.name = "OnWeaponHitXp"
    dataEvent.description = description
    dataEvent.parameters = {}
    dataEvent.parameters["attacker"] = attacker
    dataEvent.parameters["weapon"] = weapon
    dataEvent.parameters["target"] = target
    dataEvent.parameters["damage"] = damage
    HTEventsController.OnDataEvent(dataEvent)
end


---@param attacker IsoPlayer - The character attacking.
---@param weapon HandWeapon - The weapon being attacked with.
function HTEventsController.OnWeaponSwing(attacker, weapon)
    local data = IsoHelper.dumpIsoObject(attacker)
    local description = "Attacker:" .. tostring(data['id'])

    local data3 = IsoHelper.dumpIsoObject(weapon)
    description = description .. " Weapon:" .. tostring(data3['type'])
    
    local dataEvent = {}
    dataEvent.name = "OnWeaponSwing"
    dataEvent.description = description
    dataEvent.parameters = {}
    dataEvent.parameters["attacker"] = attacker
    dataEvent.parameters["weapon"] = weapon
    HTEventsController.OnDataEvent(dataEvent)
end

---@param attacker IsoPlayer - The player attacking.
---@param weapon HandWeapon - The weapon being attacked with.
function HTEventsController.OnWeaponSwingHitPoint(attacker, weapon)
    local data = IsoHelper.dumpIsoObject(attacker)
    local description = "Attacker:" .. tostring(data['id'])

    local data3 = IsoHelper.dumpIsoObject(weapon)
    description = description .. " Weapon:" .. tostring(data3['type'])
    
    local dataEvent = {}
    dataEvent.name = "OnWeaponSwingHitPoint"
    dataEvent.description = description
    dataEvent.parameters = {}
    dataEvent.parameters["attacker"] = attacker
    dataEvent.parameters["weapon"] = weapon
    HTEventsController.OnDataEvent(dataEvent)
end

---@param zombie IsoZombie - The zombie that was hit.
---@param attacker IsoGameCharacter - The character that hit the zombie.
---@param bodyPart BodyPartType - The type of the body part that was hit.
---@param weapon HandWeapon - The weapon the zombie was hit with.
function HTEventsController.OnHitZombie(zombie, attacker, bodyPart, weapon)
    local data = IsoHelper.dumpIsoObject(zombie)
    local description = "Zombie:" .. tostring(data['id'])

    local data2 = IsoHelper.dumpIsoObject(attacker)
    description = description .. " Attacker:" .. tostring(data2['id'])

    local data3 = IsoHelper.dumpIsoObject(weapon)
    description = description .. " Weapon:" .. tostring(data3['type'])
    
    local dataEvent = {}
    dataEvent.name = "OnHitZombie"
    dataEvent.description = description
    dataEvent.parameters = {}
    dataEvent.parameters["zombie"] = zombie
    dataEvent.parameters["attacker"] = attacker
    dataEvent.parameters["bodyPart"] = bodyPart
    dataEvent.parameters["weapon"] = weapon
    HTEventsController.OnDataEvent(dataEvent)
end

---@param zombie IsoZombie - The zombie that died.
function HTEventsController.OnZombieDead(zombie)
    local data = IsoHelper.dumpIsoObject(zombie)
    local description = "Zombie:" .. tostring(data['id'])
    description = description .. " IsFemale:" .. tostring(data['is_female'])

    local dataEvent = {}
    dataEvent.name = "OnZombieDead"
    dataEvent.description = description
    dataEvent.parameters = {}
    dataEvent.parameters["zombie"] = zombie
    HTEventsController.OnDataEvent(dataEvent)
end

Events.OnWeaponHitCharacter.Add(HTEventsController.OnWeaponHitCharacter)
Events.OnWeaponHitThumpable.Add(HTEventsController.OnWeaponHitThumpable)
Events.OnWeaponHitTree.Add(HTEventsController.OnWeaponHitTree)
Events.OnWeaponHitXp.Add(HTEventsController.OnWeaponHitXp)
Events.OnWeaponSwing.Add(HTEventsController.OnWeaponSwing)
Events.OnWeaponSwingHitPoint.Add(HTEventsController.OnWeaponSwingHitPoint)
Events.OnHitZombie.Add(HTEventsController.OnHitZombie)
Events.OnZombieDead.Add(HTEventsController.OnZombieDead)

