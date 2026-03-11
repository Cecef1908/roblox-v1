--[[
    ProfileStore.lua (Simplified Wrapper)
    Wraps Roblox DataStoreService with a ProfileStore-like API.
    Compatible with the DataManager spec interface.

    API:
    - ProfileStore.New(storeName, defaultData) -> ProfileStoreInstance
    - instance:LoadProfileAsync(key, loadMode) -> Profile
    - profile:Release()
    - profile:AddUserId(userId)
    - profile:Reconcile()
    - profile:ListenToRelease(callback)
    - profile.Data (table)
]]

local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")

local ProfileStore = {}
ProfileStore.__index = ProfileStore

-- Profile class
local Profile = {}
Profile.__index = Profile

function Profile.new(data, dataStore, key, defaultData)
    local self = setmetatable({}, Profile)
    self.Data = data
    self._dataStore = dataStore
    self._key = key
    self._defaultData = defaultData
    self._released = false
    self._releaseCallbacks = {}
    self._userIds = {}
    return self
end

function Profile:AddUserId(userId)
    table.insert(self._userIds, userId)
end

-- Reconcile: fill in missing keys from default data (schema migration)
function Profile:Reconcile()
    local function reconcileTable(target, template)
        for key, defaultValue in pairs(template) do
            if target[key] == nil then
                if type(defaultValue) == "table" then
                    target[key] = {}
                    reconcileTable(target[key], defaultValue)
                else
                    target[key] = defaultValue
                end
            elseif type(defaultValue) == "table" and type(target[key]) == "table" then
                reconcileTable(target[key], defaultValue)
            end
        end
    end
    reconcileTable(self.Data, self._defaultData)
end

function Profile:ListenToRelease(callback)
    table.insert(self._releaseCallbacks, callback)
end

function Profile:Release()
    if self._released then return end
    self._released = true

    -- Save data before releasing
    local success, err = pcall(function()
        self._dataStore:SetAsync(self._key, self.Data, self._userIds)
    end)

    if not success then
        warn("[ProfileStore] Failed to save on release:", err)
    end

    -- Fire release callbacks
    for _, callback in ipairs(self._releaseCallbacks) do
        task.spawn(callback)
    end
end

function Profile:IsActive()
    return not self._released
end

-- ProfileStore Instance class
local ProfileStoreInstance = {}
ProfileStoreInstance.__index = ProfileStoreInstance

function ProfileStoreInstance.new(storeName, defaultData)
    local self = setmetatable({}, ProfileStoreInstance)
    self._storeName = storeName
    self._defaultData = defaultData
    self._dataStore = nil
    self._profiles = {} -- key -> Profile

    -- Get DataStore (only in real server, not in Studio test without API access)
    local success, result = pcall(function()
        return DataStoreService:GetDataStore(storeName)
    end)

    if success then
        self._dataStore = result
    else
        warn("[ProfileStore] DataStore unavailable (Studio mode?):", result)
    end

    return self
end

function ProfileStoreInstance:LoadProfileAsync(key, loadMode)
    -- Deep copy default data
    local function deepCopy(original)
        local copy = {}
        for k, v in pairs(original) do
            if type(v) == "table" then
                copy[k] = deepCopy(v)
            else
                copy[k] = v
            end
        end
        return copy
    end

    local data = nil

    if self._dataStore then
        -- Try to load from DataStore
        local success, result = pcall(function()
            return self._dataStore:GetAsync(key)
        end)

        if success and result then
            data = result
        elseif not success then
            warn("[ProfileStore] GetAsync failed for", key, ":", result)
            -- On ForceLoad, we still create a profile with defaults
            if loadMode ~= "ForceLoad" then
                return nil
            end
        end
    end

    -- Use default data if nothing loaded
    if not data then
        data = deepCopy(self._defaultData)
    end

    -- Release existing profile for same key if any
    if self._profiles[key] then
        self._profiles[key]:Release()
    end

    local profile = Profile.new(data, self._dataStore, key, self._defaultData)
    self._profiles[key] = profile

    return profile
end

-- Module interface
function ProfileStore.New(storeName, defaultData)
    return ProfileStoreInstance.new(storeName, defaultData)
end

return ProfileStore
